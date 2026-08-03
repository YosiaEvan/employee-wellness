import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class HomeService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, dynamic>> _request(String method, String path) async {
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
      final response = method == 'GET'
          ? await http.get(uri, headers: headers)
          : await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {"success": false, "needsReauth": true};
      }
      return {"success": false};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getDashboardData() =>
      _request('GET', '/user/progress_sehat');

  static Future<Map<String, dynamic>> getWellnessScore() =>
      _request('GET', '/user/progress_sehat');

  static Future<Map<String, dynamic>> getRecentActivities({int? limit}) {
    final qs = limit != null ? '?limit=$limit' : '';
    return _request('GET', '/user/progres$qs');
  }
}
