import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service untuk Tidur Cukup (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class TidurService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  /// GET - Cek apakah sudah lapor tidur hari ini
  static Future<Map<String, dynamic>> cekTidurHariIni() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final userId = await LocalDatabaseService.getCurrentUserId();
      final todayRows = await _db.query(
        'tidur',
        where: 'tanggal = ? AND user_id = ? AND synced != 2',
        whereArgs: [tanggal, userId],
        orderBy: 'id ASC',
      );

      if (todayRows.isEmpty) {
        // Tidak ada data lokal -> coba ambil dari server
        final server = await _getFromServer();
        if (server != null) {
          await _cacheServerTidur(server);
          return _buildFromServer(server);
        }
        return _buildEmpty();
      }

      // Data lokal ada -> tampilkan dari lokal, lalu merge server di background
      unawaited(_mergeFromServer());
      return _buildFromLocal(todayRows.first);
    } catch (e) {
      debugPrint(" Cek Tidur Error: $e");
      return {"success": false, "sudah_lapor": false};
    }
  }

  /// POST - Lapor tidur hari ini
  static Future<Map<String, dynamic>> laporTidur({
    required String jamTidur,
    required String jamBangun,
  }) async {
    final tanggal = LocalDatabaseService.todayStr();
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    final sleepTimeParts = jamTidur.split(':');
    final sleepTime = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      int.parse(sleepTimeParts[0]),
      int.parse(sleepTimeParts[1]),
    );

    final wakeTimeParts = jamBangun.split(':');
    final wakeTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(wakeTimeParts[0]),
      int.parse(wakeTimeParts[1]),
    );

    final waktuTidur = sleepTime.toUtc().toIso8601String();
    final waktuBangun = wakeTime.toUtc().toIso8601String();

    // 1. Simpan ke SQLite lokal dulu
    final rowId = await _db.insert('tidur', {
      'tanggal': tanggal,
      'waktu_tidur': waktuTidur,
      'waktu_bangun': waktuBangun,
      'synced': 0,
    });

    // 2. Coba push ke server
    try {
      final response = await ApiService.post(
        "/user/tidur",
        body: {"waktu_tidur": waktuTidur, "waktu_bangun": waktuBangun},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _db.markSynced('tidur', rowId);
        final responseData = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat tidur",
          "data": responseData['data'],
          "tercapai": responseData['tercapai'] ?? false,
        };
      } else {
        // Simpan catatan lokal; tandai hanya penolakan permanen (4xx).
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
            await _db.markRejected('tidur', rowId, message.toString());
          }
          return {
            "success": false,
            "message": message,
            "pending": response.statusCode >= 500,
          };
        } catch (_) {
          if (const [400, 409, 422].contains(response.statusCode)) {
            await _db.markRejected(
              'tidur',
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
      debugPrint(" Lapor Tidur Error (offline): $e");
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

  static Future<Map<String, dynamic>> _buildFromLocal(
    Map<String, dynamic> row,
  ) async {
    final durasiMenit = _durasiMenit(row['waktu_tidur'], row['waktu_bangun']);
    return {
      "success": true,
      "sudah_lapor": true,
      "data": {
        'waktu_tidur': row['waktu_tidur'],
        'waktu_bangun': row['waktu_bangun'],
        'durasi_menit': durasiMenit,
      },
      "minggu_ini": await _buildMingguIni(),
    };
  }

  static Future<Map<String, dynamic>> _buildEmpty() async {
    return {
      "success": true,
      "sudah_lapor": false,
      "data": null,
      "minggu_ini": await _buildMingguIni(),
    };
  }

  static Future<Map<String, dynamic>> _buildMingguIni() async {
    final start = LocalDatabaseService.weekStart();
    final userId = await LocalDatabaseService.getCurrentUserId();
    final rows = await _db.query(
      'tidur',
      where: 'tanggal >= ? AND user_id = ? AND synced != 2',
      whereArgs: [start, userId],
    );

    final byTanggal = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      byTanggal[row['tanggal']?.toString() ?? ''] = row;
    }

    final startDate = DateTime.parse(start);
    final kalender = LocalDatabaseService.last7Days(startDate).map((d) {
      final tgl = LocalDatabaseService.formatDate(d);
      final row = byTanggal[tgl];
      if (row == null) {
        return {
          'hari': _dayName(d.weekday),
          'sudah_dicatat': false,
          'durasi_menit': 0,
          'waktu_tidur': null,
          'waktu_bangun': null,
        };
      }
      return {
        'hari': _dayName(d.weekday),
        'sudah_dicatat': true,
        'durasi_menit': _durasiMenit(row['waktu_tidur'], row['waktu_bangun']),
        'waktu_tidur': row['waktu_tidur'],
        'waktu_bangun': row['waktu_bangun'],
      };
    }).toList();

    final dicatat = kalender.where((k) => k['sudah_dicatat'] == true).toList();
    final totalMenit = dicatat.fold<int>(
      0,
      (sum, k) => sum + (k['durasi_menit'] as int),
    );

    return {
      'jumlah_hari_dicatat': dicatat.length,
      'rata_rata_durasi_jam': dicatat.isEmpty
          ? 0.0
          : (totalMenit / dicatat.length) / 60.0,
      'kalender': kalender,
    };
  }

  static int _durasiMenit(String? waktuTidur, String? waktuBangun) {
    final t = DateTime.tryParse(waktuTidur ?? '');
    final b = DateTime.tryParse(waktuBangun ?? '');
    if (t == null || b == null) return 0;
    return b.difference(t).inMinutes;
  }

  static String _dayName(int weekday) {
    const names = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return weekday >= 1 && weekday <= 7 ? names[weekday] : '';
  }

  // =====================================================
  // SERVER
  // =====================================================

  static Future<Map<String, dynamic>?> _getFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return null;
      final response = await ApiService.get("/user/tidur");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          "success": true,
          "sudah_lapor": responseData['sudah_tidur_hari_ini'] ?? false,
          "data": responseData['data_hari_ini'],
          "minggu_ini": responseData['minggu_ini'],
        };
      }
    } catch (e) {
      debugPrint(" Cek Tidur (server) Error: $e");
    }
    return null;
  }

  static Map<String, dynamic> _buildFromServer(Map<String, dynamic> server) {
    return {
      "success": true,
      "sudah_lapor": server['sudah_lapor'] ?? false,
      "data": server['data'],
      "minggu_ini": server['minggu_ini'],
    };
  }

  /// Simpan data tidur dari server ke SQLite (agar offline bisa dibaca)
  static Future<void> _cacheServerTidur(Map<String, dynamic> server) async {
    try {
      final data = server['data'];
      if (server['sudah_lapor'] == true && data != null) {
        final tanggal = LocalDatabaseService.todayStr();
        final waktuTidur = data['waktu_tidur']?.toString();
        if (waktuTidur != null) {
          final existing = await _db.query(
            'tidur',
            where: 'tanggal = ? AND waktu_tidur = ? AND user_id = ?',
            whereArgs: [
              tanggal,
              waktuTidur,
              await LocalDatabaseService.getCurrentUserId(),
            ],
          );
          if (existing.isEmpty) {
            await _db.insert('tidur', {
              'tanggal': tanggal,
              'waktu_tidur': waktuTidur,
              'waktu_bangun': data['waktu_bangun']?.toString() ?? '',
              'synced': 1,
            });
          }
        }
      }
    } catch (e) {
      debugPrint(" Error caching server tidur: $e");
    }
  }

  /// Merge data server ke lokal di background (tanpa memblokir UI)
  static Future<void> _mergeFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return;
      final server = await _getFromServer();
      if (server != null) {
        await _cacheServerTidur(server);
      }
    } catch (e) {
      debugPrint(" Error merging tidur from server: $e");
    }
  }
}
