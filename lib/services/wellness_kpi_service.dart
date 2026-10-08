import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';

class WellnessKPIService {
  /// Skor KPI Wellness bulanan = (%SEHAT  50%) + (%TENANG  25%) + (%HIJAU  25%).
  static Future<Map<String, dynamic>> getMonthlyWellness({
    int? bulan,
    int? tahun,
  }) async {
    final now = DateTime.now();
    final month = bulan ?? now.month;
    final year = tahun ?? now.year;
    final userId = await LocalDatabaseService.getCurrentUserId();
    final cacheKey = 'kpi_wellness_${userId}_${year}_$month';
    try {
      final params = <String>[];
      params.add('bulan=$month');
      params.add('tahun=$year');
      final qs = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await ApiService.get('/user/kpi-wellness/bulanan$qs');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        if (result['success'] == true) {
          try {
            await LocalDatabaseService.instance.cachePut(
              cacheKey,
              jsonEncode(result),
            );
          } catch (_) {
            // API data is still valid when local cache is temporarily unavailable.
          }
          return result;
        }
      }
      final cached = await _getCached(cacheKey);
      if (cached != null) return cached;
      return {
        'success': false,
        'message': 'Failed to get wellness score (${response.statusCode})',
      };
    } catch (e) {
      final cached = await _getCached(cacheKey);
      if (cached != null) return cached;
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>?> _getCached(String key) async {
    try {
      final raw = await LocalDatabaseService.instance.cacheGet(key);
      if (raw == null) return null;
      final cached = jsonDecode(raw) as Map<String, dynamic>;
      final cachedData = cached['data'];
      return {
        ...cached,
        if (cachedData is Map<String, dynamic>)
          'data': {...cachedData, 'source': 'sqlite_cache'},
        'source': 'sqlite_cache',
      };
    } catch (_) {
      return null;
    }
  }
}
