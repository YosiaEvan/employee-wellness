import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class HijauService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, dynamic>> _request(String path) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan", "needsReauth": true};
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      }
      return {"success": false};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getHijauData() =>
      _request('/user/hijau');

  static Future<Map<String, dynamic>> getCarbonFootprint({String? startDate, String? endDate}) =>
      _request('/user/hijau');

  static Future<Map<String, dynamic>> recordGreenActivity({
    required String activityType, required String description,
    double? carbonSaved, int? points,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {"success": false, "needsReauth": true};
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/hijau'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "activity_type": activityType,
          "description": description,
          "date": DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      }
      return {"success": false};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
