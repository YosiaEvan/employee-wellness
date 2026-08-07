import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';

/// Service untuk aktivitas Sinar Matahari / Berjemur (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class SinarMatahariService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  /// GET - Cek apakah sudah berjemur hari ini
  static Future<Map<String, dynamic>> cekBerjemur() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final todayRows = await _db.query(
        'sinar_matahari',
        where: 'tanggal = ?',
        whereArgs: [tanggal],
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
      print("❌ Cek Berjemur Error: $e");
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
        await _db.markSyncedByDate('sinar_matahari', tanggal);
        final responseData = jsonDecode(response.body);
        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat aktivitas berjemur",
          "data": responseData['data'],
        };
      } else {
        // Ditolak server -> batalkan catatan lokal
        await _db.delete('sinar_matahari', where: 'id = ?', whereArgs: [rowId]);
        try {
          final errorData = jsonDecode(response.body);
          return {
            "success": false,
            "message": errorData['message'] ?? "Gagal menyimpan aktivitas",
          };
        } catch (_) {
          return {"success": false, "message": "Gagal menyimpan aktivitas"};
        }
      }
    } catch (e) {
      // Offline -> tetap dianggap berhasil (tersimpan di SQLite)
      print("❌ Catat Berjemur Error (offline): $e");
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
    final rows = await _db.query(
      'sinar_matahari',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'waktu_selesai DESC',
    );
    if (rows.isEmpty) return null;
    return {
      'waktu_selesai': rows.first['waktu_selesai'],
    };
  }

  static Future<Map<String, dynamic>> _buildMingguIni() async {
    final start = LocalDatabaseService.weekStart();
    final rows = await _db.query(
      'sinar_matahari',
      where: 'tanggal >= ?',
      whereArgs: [start],
    );
    final uniqueTanggal = <String>{};
    for (final row in rows) {
      uniqueTanggal.add(row['tanggal']?.toString() ?? '');
    }
    return {
      'jumlah_hari_dilakukan': uniqueTanggal.length,
    };
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
      print("❌ Cek Berjemur (server) Error: $e");
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
        final waktu = (server['data']?['waktu_selesai'] ?? server['data']?['waktu'] ?? '').toString();
        if (waktu.isNotEmpty) {
          final existing = await _db.query(
            'sinar_matahari',
            where: 'tanggal = ? AND waktu_selesai = ?',
            whereArgs: [tanggal, waktu],
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
      print("❌ Error caching server sinar matahari: $e");
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
      print("❌ Error merging sinar matahari from server: $e");
    }
  }
}
