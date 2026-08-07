import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';

/// Service untuk Minum Air 8 Gelas (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class MinumAirService {
  static const int targetGelas = 8;
  static const Duration intervalMinum = Duration(minutes: 15);

  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  /// GET - Cek status minum air hari ini
  static Future<Map<String, dynamic>> getStatusMinum() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final todayRows = await _db.query(
        'minum',
        where: 'tanggal = ?',
        whereArgs: [tanggal],
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
      print("❌ Get Status Minum Error: $e");
      return {"success": false};
    }
  }

  /// POST - Catat minum air
  static Future<Map<String, dynamic>> catatMinum() async {
    final tanggal = LocalDatabaseService.todayStr();
    final now = DateTime.now().toUtc();
    final waktuMinum = now.toIso8601String();

    // 1. Simpan ke SQLite lokal dulu
    final rowId = await _db.insert('minum', {
      'tanggal': tanggal,
      'waktu_minum': waktuMinum,
      'synced': 0,
    });

    // 2. Coba push ke server
    try {
      final response = await ApiService.post(
        "/user/minum",
        body: {"waktu_minum": waktuMinum},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _db.markSyncedByDate('minum', tanggal);
        final responseData = jsonDecode(response.body);
        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat minum air",
          "data": responseData['data'],
        };
      } else {
        // Ditolak server (mis. interval 15 menit belum lewat) -> batalkan catatan lokal
        await _db.delete('minum', where: 'id = ?', whereArgs: [rowId]);
        try {
          final errorData = jsonDecode(response.body);
          return {
            "success": false,
            "message": errorData['message'] ?? "Gagal menyimpan data",
          };
        } catch (_) {
          return {"success": false, "message": "Gagal menyimpan data"};
        }
      }
    } catch (e) {
      // Offline -> tetap dianggap berhasil (tersimpan di SQLite)
      print("❌ Catat Minum Error (offline): $e");
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
      List<Map<String, dynamic>> rows) async {
    final jumlah = rows.length;
    final sisa = (targetGelas - jumlah) < 0 ? 0 : (targetGelas - jumlah);
    final sudahSelesai = jumlah >= targetGelas;

    bool bisaMinumLagi = true;
    int menitTersisa = 0;
    if (rows.isNotEmpty) {
      final last = DateTime.tryParse(rows.last['waktu_minum']?.toString() ?? '');
      if (last != null) {
        final elapsed = DateTime.now().difference(last);
        if (elapsed < intervalMinum) {
          bisaMinumLagi = false;
          menitTersisa =
              ((intervalMinum.inSeconds - elapsed.inSeconds) / 60).ceil();
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
    final rows = await _db.query('minum', where: 'tanggal >= ?', whereArgs: [start]);

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
      'hari_selesai_8_gelas': perTanggal.values.where((c) => c >= targetGelas).length,
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
      print("❌ Get Status Minum (server) Error: $e");
    }
    return null;
  }

  static Map<String, dynamic> _buildStatusFromServer(Map<String, dynamic> server) {
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
          where: 'tanggal = ? AND waktu_minum = ?',
          whereArgs: [tanggal, waktu],
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
      print("❌ Error caching server minum: $e");
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
      print("❌ Error merging minum from server: $e");
    }
  }

  static const Map<String, dynamic> _aturan = {
    'target_harian': targetGelas,
    'interval_menit': 15,
  };
}
