import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service untuk Minum Air 8 Gelas (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class MinumAirService {
  static const int targetGelas = 8;
  static const Duration intervalMinum = Duration(minutes: 45);

  static final LocalDatabaseService _db = LocalDatabaseService.instance;
  static bool _catatMinumSedangDiproses = false;

  /// GET - Cek status minum air hari ini
  static Future<Map<String, dynamic>> getStatusMinum() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final userId = await LocalDatabaseService.getCurrentUserId();
      final todayRows = await _db.query(
        'minum',
        where: 'tanggal = ? AND user_id = ? AND synced != 2',
        whereArgs: [tanggal, userId],
        orderBy: 'waktu_minum ASC',
      );

      if (todayRows.isEmpty) {
        // Tidak ada data lokal -> coba ambil dari server
        final serverResult = await _getFromServer();
        if (serverResult != null) {
          await _cacheServerMinum(serverResult);
          return _buildStatusFromServer(serverResult);
        }
        return _buildStatusEmpty();
      }

      // Data lokal ada -> tampilkan dari lokal, lalu merge server di background
      unawaited(_mergeFromServer());
      return _buildStatusFromLocal(todayRows);
    } catch (e) {
      debugPrint(" Get Status Minum Error: $e");
      return {"success": false};
    }
  }

  /// POST - Catat minum air
  static Future<Map<String, dynamic>> catatMinum() async {
    if (_catatMinumSedangDiproses) {
      return {
        'success': false,
        'message':
            'Pencatatan minum sedang diproses. Coba kembali sebentar lagi.',
      };
    }
    _catatMinumSedangDiproses = true;
    try {
      return await _catatMinum();
    } finally {
      _catatMinumSedangDiproses = false;
    }
  }

  static Future<Map<String, dynamic>> _catatMinum() async {
    final tanggal = LocalDatabaseService.todayStr();
    final now = DateTime.now().toUtc();
    final waktuMinum = now.toIso8601String();
    final userId = await LocalDatabaseService.getCurrentUserId();
    final todayRows = await _db.query(
      'minum',
      where: 'tanggal = ? AND user_id = ? AND synced != 2',
      whereArgs: [tanggal, userId],
      orderBy: 'waktu_minum DESC',
    );

    if (todayRows.length >= targetGelas) {
      return {
        'success': false,
        'statusCode': 400,
        'message': 'Target $targetGelas gelas per hari sudah tercapai!',
        'jumlah_gelas_hari_ini': todayRows.length,
      };
    }

    if (todayRows.isNotEmpty) {
      final lastDrink = DateTime.tryParse(
        todayRows.first['waktu_minum']?.toString() ?? '',
      )?.toUtc();
      if (lastDrink != null) {
        final elapsed = now.difference(lastDrink);
        if (elapsed < intervalMinum) {
          final remaining = intervalMinum - elapsed;
          return {
            'success': false,
            'statusCode': 400,
            'message':
                'Jarak minum terlalu dekat. Minimal jarak ${intervalMinum.inMinutes} menit antar minum.',
            'menit_tersisa': (remaining.inSeconds / 60).ceil(),
            'waktu_minum_terakhir': lastDrink.toIso8601String(),
          };
        }
      }
    }

    // 1. Simpan ke SQLite lokal dulu
    final rowId = await _db.insert('minum', {
      'tanggal': tanggal,
      'waktu_minum': waktuMinum,
      'synced': 0,
    });

    if (!await OfflineSyncService.hasInternet()) {
      DataRefreshNotifier.instance.notifyDataChanged();
      return {
        'success': true,
        'offline': true,
        'pending': true,
        'message': 'Tersimpan offline, akan disinkronkan saat online',
      };
    }

    // 2. Coba push ke server
    try {
      final response = await ApiService.post(
        "/user/minum",
        body: {"waktu_minum": waktuMinum, "tanggal": tanggal},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _db.markSynced('minum', rowId);
        final responseData = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat minum air",
          "data": responseData['data'],
          "tercapai": responseData['tercapai'] ?? false,
        };
      } else {
        // Jangan buang catatan lokal. 4xx ditandai untuk ditinjau, 5xx tetap antre.
        DataRefreshNotifier.instance.notifyDataChanged();
        if (!const [400, 409, 422].contains(response.statusCode)) {
          return {
            'success': true,
            'offline': true,
            'pending': true,
            'message':
                'Tersimpan di perangkat, sinkronisasi akan dicoba kembali',
          };
        }
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? "Gagal menyimpan data";
          if (const [400, 409, 422].contains(response.statusCode)) {
            await _db.markRejected('minum', rowId, message.toString());
          }
          return {
            "success": false,
            "message": message,
            "pending": response.statusCode >= 500,
          };
        } catch (_) {
          if (const [400, 409, 422].contains(response.statusCode)) {
            await _db.markRejected(
              'minum',
              rowId,
              'HTTP ${response.statusCode}',
            );
          }
          return {
            "success": false,
            "message": "Gagal menyimpan data",
            "pending": response.statusCode >= 500,
          };
        }
      }
    } catch (e) {
      // Offline -> tetap dianggap berhasil (tersimpan di SQLite)
      debugPrint(" Catat Minum Error (offline): $e");
      DataRefreshNotifier.instance.notifyDataChanged();
      return {
        "success": true,
        "message": "Tersimpan offline, akan disinkronkan saat online",
        "offline": true,
      };
    }
  }

  // =====================================================
  // LOCAL STATUS BUILDER
  // =====================================================

  static Future<Map<String, dynamic>> _buildStatusFromLocal(
    List<Map<String, dynamic>> rows,
  ) async {
    final jumlah = rows.length;
    final sisa = (targetGelas - jumlah) < 0 ? 0 : (targetGelas - jumlah);
    final sudahSelesai = jumlah >= targetGelas;

    bool bisaMinumLagi = true;
    int menitTersisa = 0;
    if (rows.isNotEmpty) {
      final last = DateTime.tryParse(
        rows.last['waktu_minum']?.toString() ?? '',
      );
      if (last != null) {
        final elapsed = DateTime.now().difference(last);
        if (elapsed < intervalMinum) {
          bisaMinumLagi = false;
          menitTersisa = ((intervalMinum.inSeconds - elapsed.inSeconds) / 60)
              .ceil();
          if (menitTersisa < 0) menitTersisa = 0;
        }
      }
    }

    final hariIni = {
      'jumlah_gelas': jumlah,
      'target_gelas': targetGelas,
      'sisa_gelas': sisa,
      'sudah_selesai': sudahSelesai,
      'persentase': (jumlah / targetGelas * 100).clamp(0, 100),
      'bisa_minum_lagi': bisaMinumLagi,
      'menit_tersisa_untuk_minum_lagi': menitTersisa,
      'riwayat_minum': rows
          .map((r) => {'waktu_minum': r['waktu_minum'], 'jumlah': 1})
          .toList(),
    };

    final mingguIni = await _buildMingguIni();

    return {
      "success": true,
      "hari_ini": hariIni,
      "minggu_ini": mingguIni,
      "aturan": _aturan,
    };
  }

  static Future<Map<String, dynamic>> _buildStatusEmpty() async {
    final mingguIni = await _buildMingguIni();
    return {
      "success": true,
      "hari_ini": {
        'jumlah_gelas': 0,
        'target_gelas': targetGelas,
        'sisa_gelas': targetGelas,
        'sudah_selesai': false,
        'persentase': 0,
        'bisa_minum_lagi': true,
        'menit_tersisa_untuk_minum_lagi': 0,
        'riwayat_minum': <Map<String, dynamic>>[],
      },
      "minggu_ini": mingguIni,
      "aturan": _aturan,
    };
  }

  static Future<Map<String, dynamic>> _buildMingguIni() async {
    final start = LocalDatabaseService.weekStart();
    final userId = await LocalDatabaseService.getCurrentUserId();
    final rows = await _db.query(
      'minum',
      where: 'tanggal >= ? AND user_id = ? AND synced != 2',
      whereArgs: [start, userId],
    );

    final perTanggal = <String, int>{};
    for (final row in rows) {
      final tgl = row['tanggal']?.toString() ?? '';
      perTanggal[tgl] = (perTanggal[tgl] ?? 0) + 1;
    }

    final startDate = DateTime.parse(start);
    final kalender = LocalDatabaseService.last7Days(startDate).map((d) {
      final tgl = LocalDatabaseService.formatDate(d);
      final jumlah = perTanggal[tgl] ?? 0;
      return {
        'tanggal': tgl,
        'jumlah_gelas': jumlah,
        'sudah_selesai': jumlah >= targetGelas,
      };
    }).toList();

    return {
      'hari_selesai_8_gelas': perTanggal.values
          .where((c) => c >= targetGelas)
          .length,
      'kalender': kalender,
    };
  }

  // =====================================================
  // SERVER
  // =====================================================

  static Future<Map<String, dynamic>?> _getFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return null;
      final response = await ApiService.get("/user/minum");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          "success": true,
          "hari_ini": responseData['hari_ini'],
          "minggu_ini": responseData['minggu_ini'],
          "aturan": responseData['aturan'],
        };
      }
    } catch (e) {
      debugPrint(" Get Status Minum (server) Error: $e");
    }
    return null;
  }

  static Map<String, dynamic> _buildStatusFromServer(
    Map<String, dynamic> server,
  ) {
    return {
      "success": true,
      "hari_ini": server['hari_ini'],
      "minggu_ini": server['minggu_ini'],
      "aturan": server['aturan'],
    };
  }

  /// Simpan riwayat minum dari server ke SQLite (agar offline bisa dibaca)
  static Future<void> _cacheServerMinum(Map<String, dynamic> server) async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final riwayat = (server['hari_ini']?['riwayat_minum'] as List? ?? []);
      for (final item in riwayat) {
        final waktu = item['waktu_minum'] ?? item['waktu'];
        if (waktu == null) continue;
        final existing = await _db.query(
          'minum',
          where: 'tanggal = ? AND waktu_minum = ? AND user_id = ?',
          whereArgs: [
            tanggal,
            waktu,
            await LocalDatabaseService.getCurrentUserId(),
          ],
        );
        if (existing.isEmpty) {
          await _db.insert('minum', {
            'tanggal': tanggal,
            'waktu_minum': waktu.toString(),
            'synced': 1,
          });
        }
      }
    } catch (e) {
      debugPrint(" Error caching server minum: $e");
    }
  }

  /// Merge data server ke lokal di background (tanpa memblokir UI)
  static Future<void> _mergeFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return;
      final server = await _getFromServer();
      if (server != null) {
        await _cacheServerMinum(server);
      }
    } catch (e) {
      debugPrint(" Error merging minum from server: $e");
    }
  }

  static const Map<String, dynamic> _aturan = {
    'target_harian': targetGelas,
    'interval_menit': 45,
  };
}
