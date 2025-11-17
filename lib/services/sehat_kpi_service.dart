import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';

/// Service untuk Sehat KPI Tracking dengan REST API
/// Auto-refresh token jika expired
class SehatKPIService {
  // =====================================================
  // DAILY ACTIVITIES
  // =====================================================

  /// GET - Get aktivitas hari ini
  static Future<Map<String, dynamic>> getTodayActivities() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await ApiService.get('/sehat/activities/$today');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to get activities"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// POST - Update aktivitas harian
  static Future<Map<String, dynamic>> updateDailyActivity(
    Map<String, dynamic> updates,
  ) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await ApiService.post(
        '/sehat/activities',
        body: {'tanggal': today, ...updates},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to update activity"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // =====================================================
  // BERJEMUR
  // =====================================================

  static Future<Map<String, dynamic>> markBerjemurDone({
    required TimeOfDay waktu,
    required int durasi,
  }) async {
    return await updateDailyActivity({
      'berjemur_done': true,
      'berjemur_waktu': '${waktu.hour}:${waktu.minute}:00',
      'berjemur_durasi': durasi,
    });
  }

  // =====================================================
  // OLAHRAGA / LANGKAH
  // =====================================================

  static Future<Map<String, dynamic>> updateSteps(int steps) async {
    return await updateDailyActivity({
      'langkah_total': steps,
      'langkah_target_tercapai': steps >= 10000,
    });
  }

  // =====================================================
  // HIRUP UDARA
  // =====================================================

  static Future<Map<String, dynamic>> addHirupUdara() async {
    try {
      final response = await ApiService.post('/sehat/hirup-udara');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to add hirup udara"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // =====================================================
  // MINUM AIR
  // =====================================================

  static Future<Map<String, dynamic>> addMinumAir() async {
    try {
      final response = await ApiService.post('/sehat/minum-air');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to add minum air"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> canDrinkNow() async {
    try {
      final response = await ApiService.get('/sehat/minum-air/check');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "can_drink": false};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // =====================================================
  // TIDUR
  // =====================================================

  static Future<Map<String, dynamic>> setTidur({
    required TimeOfDay tidurMulai,
    required TimeOfDay tidurSelesai,
  }) async {
    // Calculate durasi
    int jamMulai = tidurMulai.hour;
    int menitMulai = tidurMulai.minute;
    int jamSelesai = tidurSelesai.hour;
    int menitSelesai = tidurSelesai.minute;

    if (jamSelesai < jamMulai) {
      jamSelesai += 24;
    }

    double durasi = (jamSelesai - jamMulai) + (menitSelesai - menitMulai) / 60;
    bool tidurDone = durasi >= 7 && durasi <= 8;

    return await updateDailyActivity({
      'tidur_mulai': '${tidurMulai.hour}:${tidurMulai.minute}:00',
      'tidur_selesai': '${tidurSelesai.hour}:${tidurSelesai.minute}:00',
      'tidur_durasi': durasi,
      'tidur_done': tidurDone,
    });
  }

  // =====================================================
  // POLA MAKAN
  // =====================================================

  static Future<Map<String, dynamic>> addMakanan({
    required String jenisMakan,
    String? menuMakananId,
    String? namaMakananCustom,
    required double persentaseSerat,
    required double persentaseProtein,
    required double persentaseKarbo,
    String? fotoUrl,
    String? sumber,
  }) async {
    try {
      final response = await ApiService.post(
        '/sehat/pola-makan',
        body: {
          'jenis_makan': jenisMakan,
          if (menuMakananId != null) 'menu_makanan_id': menuMakananId,
          if (namaMakananCustom != null) 'nama_makanan_custom': namaMakananCustom,
          'persentase_serat': persentaseSerat,
          'persentase_protein': persentaseProtein,
          'persentase_karbo': persentaseKarbo,
          if (fotoUrl != null) 'foto_url': fotoUrl,
          'sumber': sumber ?? 'manual',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to add makanan"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// GET - Search menu makanan
  static Future<Map<String, dynamic>> searchMenuMakanan(String query) async {
    try {
      final response = await ApiService.get('/menu-makanan/search?q=$query');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to search menu"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// GET - Get makanan hari ini
  static Future<Map<String, dynamic>> getTodayMakan() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await ApiService.get('/sehat/pola-makan/$today');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to get makanan"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // =====================================================
  // KPI TRACKING
  // =====================================================

  static Future<Map<String, dynamic>> getWeeklyKPI() async {
    try {
      final response = await ApiService.get('/sehat/kpi/weekly');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to get weekly KPI"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getMonthlyKPI() async {
    try {
      final response = await ApiService.get('/sehat/kpi/monthly');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to get monthly KPI"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}

