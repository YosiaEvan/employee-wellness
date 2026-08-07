import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';

/// Service untuk Tracking Kalori (offline-first)
/// Data makanan disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan.
class TrackingKaloriService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  static const Map<String, dynamic> _defaultTarget = {
    'kalori': 2000,
    'protein': 60,
    'karbohidrat': 300,
    'lemak': 65,
    'serat': 25,
  };

  /// POST - Tambah makanan ke tracking kalori
  static Future<Map<String, dynamic>> tambahMakanan({
    required int idFoodNutrition,
    required String jenisMakan,
    required double porsi,
    Map<String, dynamic>? foodDetail,
  }) async {
    final tanggal = LocalDatabaseService.todayStr();

    final nama = foodDetail?['nama_makanan']?.toString() ?? 'Makanan #$idFoodNutrition';
    final kalori = (foodDetail?['kalori'] ?? 0).toDouble();
    final protein = (foodDetail?['protein_gram'] ?? 0).toDouble();
    final karbohidrat = (foodDetail?['karbohidrat_gram'] ?? 0).toDouble();
    final lemak = (foodDetail?['lemak_gram'] ?? 0).toDouble();
    final serat = (foodDetail?['serat_gram'] ?? 0).toDouble();
    final berminyak = foodDetail?['mengandung_minyak'] == true ? 1 : 0;
    final bergula = foodDetail?['mengandung_gula'] == true ? 1 : 0;

    // 1. Simpan ke SQLite lokal dulu
    final rowId = await _db.insert('makanan', {
      'tanggal': tanggal,
      'id_food_nutrition': idFoodNutrition,
      'jenis_makan': jenisMakan,
      'porsi': porsi,
      'nama_makanan': nama,
      'kalori': kalori,
      'protein': protein,
      'karbohidrat': karbohidrat,
      'lemak': lemak,
      'serat': serat,
      'berminyak': berminyak,
      'bergula': bergula,
      'synced': 0,
    });

    // 2. Coba push ke server
    try {
      final response = await ApiService.post(
        "/user/tracking-kalori",
        body: {
          "id_food_nutrition": idFoodNutrition,
          "jenis_makan": jenisMakan,
          "porsi": porsi,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          await _db.markSyncedByDate('makanan', tanggal);
          return {
            "success": true,
            "message": responseData['message'],
            "warning": responseData['warning'],
            "data": responseData['data'],
          };
        } else {
          await _db.delete('makanan', where: 'id = ?', whereArgs: [rowId]);
          return {
            "success": false,
            "message": responseData['message'] ?? "Gagal menambahkan makanan",
          };
        }
      } else {
        // Ditolak server -> batalkan catatan lokal
        await _db.delete('makanan', where: 'id = ?', whereArgs: [rowId]);
        try {
          final errorData = jsonDecode(response.body);
          return {
            "success": false,
            "message": errorData['message'] ?? "Gagal menambahkan makanan",
          };
        } catch (_) {
          return {"success": false, "message": "Gagal menambahkan makanan"};
        }
      }
    } catch (e) {
      // Offline -> tetap dianggap berhasil (tersimpan di SQLite)
      print("❌ Tracking Kalori Error (offline): $e");
      return {
        "success": true,
        "message": "Tersimpan offline, akan disinkronkan saat online",
        "offline": true,
      };
    }
  }

  /// GET - Get tracking kalori hari ini (offline-first)
  static Future<Map<String, dynamic>> getTrackingHariIni() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final todayRows = await _db.query(
        'makanan',
        where: 'tanggal = ?',
        whereArgs: [tanggal],
      );

      if (todayRows.isEmpty) {
        // Tidak ada data lokal -> coba ambil dari server
        final server = await _getFromServer();
        if (server != null) {
          await _cacheServerData(server);
          return {"success": true, "data": server['data']};
        }
        // Offline -> pakai cache snapshot terakhir jika ada
        final cached = await _getCachedData();
        if (cached != null) {
          return {"success": true, "data": cached};
        }
        return _buildEmpty();
      }

      // Data lokal ada -> bangun dari SQLite (offline-first)
      return {"success": true, "data": await _buildFromLocal(todayRows)};
    } catch (e) {
      print("❌ Get Tracking Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }

  // =====================================================
  // LOCAL BUILDER
  // =====================================================

  static Future<Map<String, dynamic>> _buildFromLocal(
      List<Map<String, dynamic>> rows) async {
    const jenisList = ['sarapan', 'makan_siang', 'makan_malam', 'snack'];

    final daftarMakanan = <String, List<Map<String, dynamic>>>{
      for (final jenis in jenisList) jenis: [],
    };

    var totalKalori = 0.0;
    var totalProtein = 0.0;
    var totalKarbo = 0.0;
    var totalLemak = 0.0;
    var totalSerat = 0.0;

    for (final row in rows) {
      final porsi = (row['porsi'] ?? 1).toDouble();
      final kalori = (row['kalori'] ?? 0).toDouble() * porsi;
      final protein = (row['protein'] ?? 0).toDouble() * porsi;
      final karbohidrat = (row['karbohidrat'] ?? 0).toDouble() * porsi;
      final lemak = (row['lemak'] ?? 0).toDouble() * porsi;
      final serat = (row['serat'] ?? 0).toDouble() * porsi;

      totalKalori += kalori;
      totalProtein += protein;
      totalKarbo += karbohidrat;
      totalLemak += lemak;
      totalSerat += serat;

      final jenis = row['jenis_makan']?.toString() ?? 'snack';
      final daftar = daftarMakanan[jenis] ?? [];
      daftar.add({
        'nama_makanan': row['nama_makanan'],
        'porsi': porsi,
        'total_kalori': kalori,
        'total_protein': protein,
        'total_karbohidrat': karbohidrat,
        'total_lemak': lemak,
        'total_serat': serat,
      });
    }

    final target = await _getTarget();

    final konsumsi = {
      'kalori': totalKalori,
      'protein': totalProtein,
      'karbohidrat': totalKarbo,
      'lemak': totalLemak,
      'serat': totalSerat,
    };

    final sisa = <String, dynamic>{};
    final progress = <String, dynamic>{};
    target.forEach((key, value) {
      final konsumsiVal = (konsumsi[key] ?? 0).toDouble();
      final targetVal = (value ?? 0).toDouble();
      sisa[key] = targetVal > 0
          ? (targetVal - konsumsiVal).clamp(0.0, double.infinity)
          : 0.0;
      progress[key] = targetVal > 0
          ? (konsumsiVal / targetVal * 100).clamp(0.0, 100.0)
          : 0.0;
    });

    return {
      'target': target,
      'konsumsi': konsumsi,
      'progress': progress,
      'sisa': sisa,
      'daftar_makanan': daftarMakanan,
      'total_item': rows.length,
      'riwayat_seminggu': await _buildRiwayatSeminggu(),
      'source': 'local',
    };
  }

  static Future<Map<String, dynamic>> _buildRiwayatSeminggu() async {
    final start = LocalDatabaseService.weekStart();
    final rows = await _db.query(
      'makanan',
      where: 'tanggal >= ?',
      whereArgs: [start],
    );

    final perTanggal = <String, Map<String, bool>>{};
    for (final row in rows) {
      final tgl = row['tanggal']?.toString() ?? '';
      final flag = perTanggal[tgl] ?? {'berminyak': false, 'bergula': false};
      if ((row['berminyak'] ?? 0) == 1) flag['berminyak'] = true;
      if ((row['bergula'] ?? 0) == 1) flag['bergula'] = true;
      perTanggal[tgl] = flag;
    }

    var hariBerminyak = 0;
    var hariBergula = 0;
    perTanggal.forEach((tgl, flag) {
      if (flag['berminyak'] == true) hariBerminyak++;
      if (flag['bergula'] == true) hariBergula++;
    });

    return {
      'hari_makan_berminyak': hariBerminyak,
      'hari_makan_bergula': hariBergula,
    };
  }

  static Future<Map<String, dynamic>> _buildEmpty() async {
    final target = await _getTarget();
    final sisa = <String, dynamic>{};
    target.forEach((key, value) {
      sisa[key] = value;
    });
    return {
      'target': target,
      'konsumsi': {'kalori': 0, 'protein': 0, 'karbohidrat': 0, 'lemak': 0, 'serat': 0},
      'progress': {'kalori': 0, 'protein': 0, 'karbohidrat': 0, 'lemak': 0, 'serat': 0},
      'sisa': sisa,
      'daftar_makanan': {
        'sarapan': [],
        'makan_siang': [],
        'makan_malam': [],
        'snack': [],
      },
      'total_item': 0,
      'riwayat_seminggu': {},
      'source': 'local',
    };
  }

  static Future<Map<String, dynamic>> _getTarget() async {
    // Target dari cache server jika tersedia
    try {
      final raw = await _db.cacheGet('tracking_target');
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final target = Map<String, dynamic>.from(_defaultTarget);
          decoded.forEach((key, value) {
            target[key] = value;
          });
          return target;
        }
      }
    } catch (e) {
      print("❌ Error reading tracking target: $e");
    }
    return Map<String, dynamic>.from(_defaultTarget);
  }

  // =====================================================
  // SERVER
  // =====================================================

  static Future<Map<String, dynamic>?> _getFromServer() async {
    try {
      if (!await OfflineSyncService.hasInternet()) return null;
      final response = await ApiService.get("/user/tracking-kalori");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return {
            "success": true,
            "data": responseData['data'],
          };
        }
      }
    } catch (e) {
      print("❌ Get Tracking (server) Error: $e");
    }
    return null;
  }

  static Future<void> _cacheServerData(Map<String, dynamic> server) async {
    try {
      final data = server['data'] ?? {};
      final tanggal = LocalDatabaseService.todayStr();

      // Cache target agar offline tetap punya target
      if (data['target'] != null) {
        await _db.cachePut('tracking_target', jsonEncode(data['target']));
      }
      // Cache snapshot penuh (fallback bila offline & tidak ada data lokal)
      await _db.cachePut('tracking_data_$tanggal', jsonEncode(data));

      // Simpan daftar makanan dari server ke SQLite agar offline bisa dibaca
      final daftar = data['daftar_makanan'] ?? {};
      daftar.forEach((jenis, items) {
        for (final item in (items as List? ?? [])) {
          final porsi = (item['porsi'] ?? 1).toDouble();
          _db.insert('makanan', {
            'tanggal': tanggal,
            'id_food_nutrition': item['id'] ?? 0,
            'jenis_makan': jenis,
            'porsi': porsi,
            'nama_makanan': item['nama_makanan']?.toString(),
            'kalori': (item['total_kalori'] ?? 0).toDouble() / (porsi > 0 ? porsi : 1),
            'protein': (item['total_protein'] ?? 0).toDouble() / (porsi > 0 ? porsi : 1),
            'karbohidrat': (item['total_karbohidrat'] ?? 0).toDouble() / (porsi > 0 ? porsi : 1),
            'lemak': (item['total_lemak'] ?? 0).toDouble() / (porsi > 0 ? porsi : 1),
            'serat': (item['total_serat'] ?? 0).toDouble() / (porsi > 0 ? porsi : 1),
            'berminyak': item['mengandung_minyak'] == true ? 1 : 0,
            'bergula': item['mengandung_gula'] == true ? 1 : 0,
            'synced': 1,
          });
        }
      });
    } catch (e) {
      print("❌ Error caching server tracking data: $e");
    }
  }

  static Future<Map<String, dynamic>?> _getCachedData() async {
    try {
      final tanggal = LocalDatabaseService.todayStr();
      final raw = await _db.cacheGet('tracking_data_$tanggal');
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      print("❌ Error reading cached tracking data: $e");
    }
    return null;
  }
}
