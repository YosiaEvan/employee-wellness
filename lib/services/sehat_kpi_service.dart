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
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await updateStepsWithDate(
      tanggal: today,
      totalSteps: steps,
    );
  }

  /// Update steps dengan tanggal spesifik (untuk sinkronisasi data historis)
  static Future<Map<String, dynamic>> updateStepsWithDate({
    required String tanggal,
    required int totalSteps,
  }) async {
    try {
      print('📤 Sending steps to API: $totalSteps steps on $tanggal');

      final response = await ApiService.post(
        '/user/langkah',
        body: {
          'jumlah_langkah': totalSteps,
          'tanggal': tanggal,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('✅ Steps sent successfully: ${result['message']}');
        return result;
      } else {
        print('❌ Failed to send steps: ${response.statusCode}');
        return {"success": false, "message": "Failed to update steps"};
      }
    } catch (e) {
      print('❌ Error sending steps: $e');
      return {"success": false, "message": "Error: $e"};
    }
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

  /// GET - Get KPI Harian
  /// Optional params: tanggal (format: YYYY-MM-DD, default: today)
  /// Example: getDailyKPI(tanggal: '2025-11-20') or getDailyKPI() for today
  static Future<Map<String, dynamic>> getDailyKPI({String? tanggal}) async {
    try {
      // Build query parameters
      String endpoint;

      if (tanggal != null) {
        // With query parameter: /api/user/kpi-sehat/harian?tanggal=2025-11-20
        endpoint = '/user/kpi-sehat/harian?tanggal=$tanggal';
      } else {
        // Without query parameter (backend will use today's date)
        endpoint = '/user/kpi-sehat/harian';
      }


      print('🔄 Fetching daily KPI from $endpoint');
      final response = await ApiService.get(endpoint);

      print('📡 Daily KPI Status Code: ${response.statusCode}');
      print('📡 Daily KPI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ Daily KPI decoded successfully');
        print('📊 Daily KPI data keys: ${decoded.keys.toList()}');
        if (decoded.containsKey('data') && decoded['data'] != null) {
          print('📊 Daily KPI data.aktivitas count: ${(decoded['data']['aktivitas'] as List?)?.length ?? 0}');
        }
        return decoded;
      } else {
        print('❌ Daily KPI failed with status: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return {"success": false, "message": "Failed to get daily KPI (${response.statusCode})"};
      }
    } catch (e) {
      print('❌ Daily KPI error: $e');
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// GET - Get KPI Mingguan
  /// Optional params: minggu_ke, bulan, tahun (default: current week)
  static Future<Map<String, dynamic>> getWeeklyKPI({
    int? mingguKe,
    int? bulan,
    int? tahun,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String>[];

      if (mingguKe != null) queryParams.add('minggu_ke=$mingguKe');
      if (bulan != null) queryParams.add('bulan=$bulan');
      if (tahun != null) queryParams.add('tahun=$tahun');

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final endpoint = '/user/kpi-sehat/mingguan$queryString';

      print('🔄 Fetching weekly KPI from $endpoint');
      final response = await ApiService.get(endpoint);

      print('📡 Weekly KPI Status Code: ${response.statusCode}');
      print('📡 Weekly KPI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ Weekly KPI decoded successfully');
        print('📊 Weekly KPI data keys: ${decoded.keys.toList()}');
        return decoded;
      } else {
        print('❌ Weekly KPI failed with status: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return {"success": false, "message": "Failed to get weekly KPI (${response.statusCode})"};
      }
    } catch (e) {
      print('❌ Weekly KPI error: $e');
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// GET - Get KPI Bulanan
  /// Optional params: bulan, tahun (default: current month)
  static Future<Map<String, dynamic>> getMonthlyKPI({
    int? bulan,
    int? tahun,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String>[];

      if (bulan != null) queryParams.add('bulan=$bulan');
      if (tahun != null) queryParams.add('tahun=$tahun');

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final endpoint = '/user/kpi-sehat/bulanan$queryString';

      print('🔄 Fetching monthly KPI from $endpoint');
      final response = await ApiService.get(endpoint);

      print('📡 Monthly KPI Status Code: ${response.statusCode}');
      print('📡 Monthly KPI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ Monthly KPI decoded successfully');
        print('📊 Monthly KPI data keys: ${decoded.keys.toList()}');
        return decoded;
      } else {
        print('❌ Monthly KPI failed with status: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return {"success": false, "message": "Failed to get monthly KPI (${response.statusCode})"};
      }
    } catch (e) {
      print('❌ Monthly KPI error: $e');
      return {"success": false, "message": "Error: $e"};
    }
  }
}

