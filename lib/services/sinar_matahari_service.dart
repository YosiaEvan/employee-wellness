import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service untuk aktivitas Sinar Matahari / Berjemur (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class SinarMatahariService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  /// GET - Cek apakah sudah berjemur hari ini
  static Future<Map<String, dynamic>> cekBerjemur() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final userId = await LocalDatabaseService.getCurrentUserId();
      final todayRows = await _db.query(
        'sinar_matahari',
        where: 'tanggal = ? AND user_id = ? AND synced != 2',
        whereArgs: [tanggal, userId],
        orderBy: 'id ASC',
      );

      if (todayRows.isEmpty) {
        // Tidak ada data lokal -> coba ambil dari server
        final server = await _getFromServer();
        if (server != null) {
          await _cacheServer(server);
          return _buildFromServer(server);
        }
        return _buildEmpty();
      }

      // Data lokal ada -> tampilkan dari lokal, lalu merge server di background
      unawaited(_mergeFromServer());
      return _buildFromLocal();
    } catch (e) {
      debugPrint(" Cek Berjemur Error: $e");
      return {"success": false, "sudah_berjemur": false};
    }
  }

  /// POST - Catat aktivitas berjemur
  static Future<Map<String, dynamic>> catatBerjemur() async {
    final tanggal = LocalDatabaseService.todayStr();
    final waktuSelesai = DateTime.now().toUtc().toIso8601String();

    // 1. Simpan ke SQLite lokal dulu
    final rowId = await _db.insert('sinar_matahari', {
      'tanggal': tanggal,
      'waktu_selesai': waktuSelesai,
      'synced': 0,
    });

    // 2. Coba push ke server
    try {
      final response = await ApiService.post(
        "/user/sinar-matahari",
        body: {"waktu_selesai": waktuSelesai},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _db.markSynced('sinar_matahari', rowId);
        final responseData = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          "success": true,
          "message":
              responseData['message'] ?? "Berhasil mencatat aktivitas berjemur",
          "data": responseData['data'],
          "tercapai": responseData['tercapai'] ?? true,
        };
      } else {
        // Simpan catatan lokal; tandai penolakan 4xx untuk ditinjau.
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
          final message = errorData['message'] ?? "Gagal menyimpan aktivitas";
          if (const [400, 409, 422].contains(response.statusCode)) {
            await _db.markRejected('sinar_matahari', rowId, message.toString());
          }
          return {
            "success": false,
            "message": message,
            "pending": response.statusCode >= 500,
          };
        } catch (_) {
          if (const [400, 409, 422].contains(response.statusCode)) {
            await _db.markRejected(
              'sinar_matahari',
              rowId,
              'HTTP ${response.statusCode}',
            );
          }
          return {
            "success": false,
            "message": "Gagal menyimpan aktivitas",
            "pending": response.statusCode >= 500,
          };
        }
      }
    } catch (e) {
      // Offline -> tetap dianggap berhasil (tersimpan di SQLite)
      debugPrint(" Catat Berjemur Error (offline): $e");
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

  static Future<Map<String, dynamic>> _buildFromLocal() async {
    return {
      "success": true,
      "sudah_berjemur": true,
      "data": await _buildDataHariIni(),
      "minggu_ini": await _buildMingguIni(),
    };
  }

  static Future<Map<String, dynamic>> _buildEmpty() async {
    return {
      "success": true,
      "sudah_berjemur": false,
      "data": null,
      "minggu_ini": await _buildMingguIni(),
    };
  }

  static Future<Map<String, dynamic>?> _buildDataHariIni() async {
    final tanggal = LocalDatabaseService.todayStr();
    final userId = await LocalDatabaseService.getCurrentUserId();
    final rows = await _db.query(
      'sinar_matahari',
      where: 'tanggal = ? AND user_id = ? AND synced != 2',
      whereArgs: [tanggal, userId],
      orderBy: 'waktu_selesai DESC',
    );
    if (rows.isEmpty) return null;
    return {'waktu_selesai': rows.first['waktu_selesai']};
  }

  static Future<Map<String, dynamic>> _buildMingguIni() async {
    final start = LocalDatabaseService.weekStart();
    final userId = await LocalDatabaseService.getCurrentUserId();
    final rows = await _db.query(
      'sinar_matahari',
      where: 'tanggal >= ? AND user_id = ? AND synced != 2',
      whereArgs: [start, userId],
    );
    final uniqueTanggal = <String>{};
    for (final row in rows) {
      uniqueTanggal.add(row['tanggal']?.toString() ?? '');
    }
    return {'jumlah_hari_dilakukan': uniqueTanggal.length};
  }

  // =====================================================
  // SERVER
  // =====================================================

  static Future<Map<String, dynamic>?> _getFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return null;
      final response = await ApiService.get("/user/sinar-matahari");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          "success": true,
          "sudah_berjemur": responseData['sudah_berjemur'] ?? false,
          "data": responseData['data'],
          "minggu_ini": responseData['minggu_ini'],
        };
      }
    } catch (e) {
      debugPrint(" Cek Berjemur (server) Error: $e");
    }
    return null;
  }

  static Map<String, dynamic> _buildFromServer(Map<String, dynamic> server) {
    return {
      "success": true,
      "sudah_berjemur": server['sudah_berjemur'] ?? false,
      "data": server['data'],
      "minggu_ini": server['minggu_ini'],
    };
  }

  /// Simpan data dari server ke SQLite (agar offline bisa dibaca)
  static Future<void> _cacheServer(Map<String, dynamic> server) async {
    try {
      if (server['sudah_berjemur'] == true) {
        final tanggal = LocalDatabaseService.todayStr();
        final waktu =
            (server['data']?['waktu_selesai'] ?? server['data']?['waktu'] ?? '')
                .toString();
        if (waktu.isNotEmpty) {
          final existing = await _db.query(
            'sinar_matahari',
            where: 'tanggal = ? AND waktu_selesai = ? AND user_id = ?',
            whereArgs: [
              tanggal,
              waktu,
              await LocalDatabaseService.getCurrentUserId(),
            ],
          );
          if (existing.isEmpty) {
            await _db.insert('sinar_matahari', {
              'tanggal': tanggal,
              'waktu_selesai': waktu,
              'synced': 1,
            });
          }
        }
      }
    } catch (e) {
      debugPrint(" Error caching server sinar matahari: $e");
    }
  }

  /// Merge data server ke lokal di background (tanpa memblokir UI)
  static Future<void> _mergeFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return;
      final server = await _getFromServer();
      if (server != null) {
        await _cacheServer(server);
      }
    } catch (e) {
      debugPrint(" Error merging sinar matahari from server: $e");
    }
  }
}
