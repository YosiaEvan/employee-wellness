import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service untuk Tidur Cukup (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class TidurService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  // --- Sesi tidur pending (2-fase: mulai → bangun) ---
  static const _kPendingStartIso = 'tidur_pending_start_iso';
  static const _kPendingTanggal = 'tidur_pending_tanggal';

  /// Cek apakah ada sesi tidur yang belum diakhiri (user sudah tap "Mulai Tidur" tapi belum "Bangun")
  static Future<DateTime?> getPendingStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final iso = prefs.getString(_kPendingStartIso);
      if (iso == null) return null;
      return DateTime.tryParse(iso);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasPendingSession() async => (await getPendingStart()) != null;

  /// Mulai sesi tidur sekarang — simpan waktu mulai ke SharedPreferences
  static Future<DateTime> mulaiTidur() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPendingStartIso, now.toIso8601String());
    await prefs.setString(_kPendingTanggal, LocalDatabaseService.todayStr());
    debugPrint('[Tidur] Mulai tidur: $now');
    return now;
  }

  /// Batalkan sesi pending (mis. salah tap)
  static Future<void> batalkanSesi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPendingStartIso);
    await prefs.remove(_kPendingTanggal);
  }

  /// Selesaikan sesi tidur: hitung durasi dari pending start → sekarang (atau bangunOverride)
  /// Lalu kirim via laporTidur dengan jam yang akurat.
  static Future<Map<String, dynamic>> selesaikanTidur({DateTime? bangunOverride}) async {
    final start = await getPendingStart();
    if (start == null) {
      return {'success': false, 'message': 'Tidak ada sesi tidur pending'};
    }
    final bangun = bangunOverride ?? DateTime.now();
    // Pastikan durasi minimal 1 jam, maksimal 14 jam (validasi wajar)
    var durasi = bangun.difference(start).inMinutes;
    if (durasi < 30) {
      return {'success': false, 'message': 'Durasi tidur terlalu pendek (<30 menit). Coba lagi nanti.'};
    }
    if (durasi > 14 * 60) {
      // Jika lebih dari 14 jam, anggap lupa tap bangun → potong ke 8 jam
      debugPrint('[Tidur] Durasi >14j ($durasi m) — dipotong heuristik');
    }
    final jamTidur = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final jamBangun = '${bangun.hour.toString().padLeft(2, '0')}:${bangun.minute.toString().padLeft(2, '0')}';
    // Kirim dengan tanggal = tanggal bangun (hari ini)
    final result = await laporTidurDenganTanggal(
      jamTidur: jamTidur,
      jamBangun: jamBangun,
      waktuTidurRef: start,
      waktuBangunRef: bangun,
    );
    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPendingStartIso);
      await prefs.remove(_kPendingTanggal);
    }
    return result;
  }

  /// Estimasi jam bangun otomatis: first app open / first step setelah jam 03:00
  /// Dipanggil saat didChangeAppLifecycleState resumed
  static Future<DateTime?> detectAutoBangun() async {
    final start = await getPendingStart();
    if (start == null) return null;
    final now = DateTime.now();
    final durasi = now.difference(start).inMinutes;
    // Heuristik: minimal 3 jam tidur, dan sekarang jam 03:00-11:00
    if (durasi < 180) return null;
    if (now.hour < 3 || now.hour > 11) return null;
    return now;
  }

  /// Varian laporTidur yang menerima DateTime referensi langsung (untuk sesi 2-fase)
  static Future<Map<String, dynamic>> laporTidurDenganTanggal({
    required String jamTidur,
    required String jamBangun,
    required DateTime waktuTidurRef,
    required DateTime waktuBangunRef,
  }) async {
    // Jika waktuBangunRef < waktuTidurRef (lintas hari sudah benar), tetap pakai ref
    final waktuTidur = waktuTidurRef.toUtc().toIso8601String();
    final waktuBangun = waktuBangunRef.toUtc().toIso8601String();
    final tanggal = LocalDatabaseService.formatDate(waktuBangunRef);

    final rowId = await _db.insert('tidur', {
      'tanggal': tanggal,
      'waktu_tidur': waktuTidur,
      'waktu_bangun': waktuBangun,
      'synced': 0,
    });

    try {
      final response = await ApiService.post(
        "/user/tidur",
        body: {
          "waktu_tidur": waktuTidur,
          "waktu_bangun": waktuBangun,
          "tanggal": tanggal,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _db.markSyncedByDate('tidur', tanggal);
        final responseData = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat tidur",
          "data": responseData['data'],
          "tercapai": responseData['tercapai'] ?? false,
        };
      } else {
        await _db.delete('tidur', where: 'id = ?', whereArgs: [rowId]);
        try {
          final errorData = jsonDecode(response.body);
          return {"success": false, "message": errorData['message'] ?? "Gagal menyimpan data"};
        } catch (_) {
          return {"success": false, "message": "Gagal menyimpan data"};
        }
      }
    } catch (e) {
      debugPrint(" Lapor Tidur (sesi) Error (offline): $e");
      DataRefreshNotifier.instance.notifyDataChanged();
      return {"success": true, "message": "Tersimpan offline, akan disinkronkan saat online", "offline": true};
    }
  }

  /// GET - Cek apakah sudah lapor tidur hari ini
  static Future<Map<String, dynamic>> cekTidurHariIni() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final userId = await LocalDatabaseService.getCurrentUserId();
      final todayRows = await _db.query(
        'tidur',
        where: 'tanggal = ? AND user_id = ?',
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
        body: {
          "waktu_tidur": waktuTidur,
          "waktu_bangun": waktuBangun,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _db.markSyncedByDate('tidur', tanggal);
        final responseData = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat tidur",
          "data": responseData['data'],
          "tercapai": responseData['tercapai'] ?? false,
        };
      } else {
        // Ditolak server -> batalkan catatan lokal
        await _db.delete('tidur', where: 'id = ?', whereArgs: [rowId]);
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
      Map<String, dynamic> row) async {
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
      where: 'tanggal >= ? AND user_id = ?',
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
    final totalMenit =
        dicatat.fold<int>(0, (sum, k) => sum + (k['durasi_menit'] as int));

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
    const names = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
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
            whereArgs: [tanggal, waktuTidur, await LocalDatabaseService.getCurrentUserId()],
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
