import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';

class SehatService {
  static Future<String?> _getToken() => AuthStorage.getToken();

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan", "needsReauth": true};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        default:
          return {"success": false, "message": "Method not supported"};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {"success": false, "message": "Sesi telah berakhir", "needsReauth": true};
      } else {
        return {"success": false, "message": "Error (${response.statusCode})"};
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  static Future<Map<String, dynamic>> getHealthData() =>
      _request('GET', '/user/profile-health');

  static Future<Map<String, dynamic>> updateHealthProfile({
    double? height, double? weight, String? bloodType,
    String? allergies, String? chronicDiseases, String? medications,
  }) =>
      _request('POST', '/user/profile-health', body: {
        if (height != null) 'tinggi_badan': height,
        if (weight != null) 'berat_badan': weight,
      });

  static Future<Map<String, dynamic>> getStepHistory({String? startDate, String? endDate}) {
    final params = <String>[];
    if (startDate != null) params.add('start_date=$startDate');
    if (endDate != null) params.add('end_date=$endDate');
    final qs = params.isNotEmpty ? '?${params.join('&')}' : '';
    return _request('GET', '/user/langkah$qs');
  }

  static Future<Map<String, dynamic>> recordSteps({
    required int steps, required String date,
  }) =>
      _request('POST', '/user/langkah', body: {
        'jumlah_langkah': steps,
        'tanggal': date,
      });
}
