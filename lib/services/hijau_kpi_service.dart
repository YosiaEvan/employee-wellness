import 'dart:convert';
import 'api_service.dart';

class HijauKPIService {
  static Future<Map<String, dynamic>> getDailyKPI({String? tanggal}) async {
    try {
      final endpoint = tanggal != null
          ? '/user/kpi-hijau/harian?tanggal=$tanggal'
          : '/user/kpi-hijau/harian';
      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {"success": false, "message": "Failed to get daily KPI (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getWeeklyKPI({
    int? mingguKe, int? bulan, int? tahun,
  }) async {
    try {
      final params = <String>[];
      if (mingguKe != null) params.add('minggu_ke=$mingguKe');
      if (bulan != null) params.add('bulan=$bulan');
      if (tahun != null) params.add('tahun=$tahun');
      final qs = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await ApiService.get('/user/kpi-hijau/mingguan$qs');
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {"success": false, "message": "Failed to get weekly KPI (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getMonthlyKPI({
    int? bulan, int? tahun,
  }) async {
    try {
      final params = <String>[];
      if (bulan != null) params.add('bulan=$bulan');
      if (tahun != null) params.add('tahun=$tahun');
      final qs = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await ApiService.get('/user/kpi-hijau/bulanan$qs');
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {"success": false, "message": "Failed to get monthly KPI (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
