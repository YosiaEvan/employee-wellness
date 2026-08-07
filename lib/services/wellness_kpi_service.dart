import 'dart:convert';
import 'api_service.dart';

class WellnessKPIService {
  /// Skor KPI Wellness bulanan = (%SEHAT × 50%) + (%TENANG × 25%) + (%HIJAU × 25%).
  static Future<Map<String, dynamic>> getMonthlyWellness({
    int? bulan,
    int? tahun,
  }) async {
    try {
      final params = <String>[];
      if (bulan != null) params.add('bulan=$bulan');
      if (tahun != null) params.add('tahun=$tahun');
      final qs = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await ApiService.get('/user/kpi-wellness/bulanan$qs');
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {"success": false, "message": "Failed to get wellness score (${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
