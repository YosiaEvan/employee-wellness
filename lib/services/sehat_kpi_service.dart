import 'dart:convert';
import 'api_service.dart';

class SehatKPIService {
  static Future<Map<String, dynamic>> updateStepsWithDate({
    required String tanggal,
    required int totalSteps,
  }) async {
    try {
      final response = await ApiService.post(
        '/user/langkah',
        body: {
          'jumlah_langkah': totalSteps,
          'tanggal': tanggal,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Failed to update steps"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateSteps(int steps) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await updateStepsWithDate(tanggal: today, totalSteps: steps);
  }

  static Future<Map<String, dynamic>> getDailyKPI({String? tanggal}) async {
    try {
      final endpoint = tanggal != null
          ? '/user/kpi-sehat/harian?tanggal=$tanggal'
          : '/user/kpi-sehat/harian';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Failed to get daily KPI (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getWeeklyKPI({
    int? mingguKe, int? bulan, int? tahun,
  }) async {
    try {
      final queryParams = <String>[];
      if (mingguKe != null) queryParams.add('minggu_ke=$mingguKe');
      if (bulan != null) queryParams.add('bulan=$bulan');
      if (tahun != null) queryParams.add('tahun=$tahun');
      final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final endpoint = '/user/kpi-sehat/mingguan$qs';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Failed to get weekly KPI (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getMonthlyKPI({
    int? bulan, int? tahun,
  }) async {
    try {
      final queryParams = <String>[];
      if (bulan != null) queryParams.add('bulan=$bulan');
      if (tahun != null) queryParams.add('tahun=$tahun');
      final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final endpoint = '/user/kpi-sehat/bulanan$qs';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Failed to get monthly KPI (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
