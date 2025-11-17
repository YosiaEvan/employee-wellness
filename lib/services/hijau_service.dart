import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Service untuk Modul Hijau (Environmental/Green Wellness)
class HijauService {
  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // GET - Get environmental wellness data
  static Future<Map<String, dynamic>> getHijauData() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          "success": false,
          "message": "Token tidak ditemukan",
          "needsReauth": true,
        };
      }

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/hijau/dashboard"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        return {
          "success": false,
          "message": "Terjadi kesalahan server (${response.statusCode})",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // GET - Get carbon footprint data
  static Future<Map<String, dynamic>> getCarbonFootprint({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          "success": false,
          "message": "Token tidak ditemukan",
          "needsReauth": true,
        };
      }

      String url = "${ApiConfig.baseUrl}/api/hijau/carbon-footprint";
      if (startDate != null && endDate != null) {
        url += "?start_date=$startDate&end_date=$endDate";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        return {
          "success": false,
          "message": "Terjadi kesalahan server (${response.statusCode})",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // POST - Record green activity
  static Future<Map<String, dynamic>> recordGreenActivity({
    required String activityType,
    required String description,
    double? carbonSaved,
    int? points,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          "success": false,
          "message": "Token tidak ditemukan",
          "needsReauth": true,
        };
      }

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/hijau/activities"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "activity_type": activityType,
          "description": description,
          if (carbonSaved != null) "carbon_saved": carbonSaved,
          if (points != null) "points": points,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Aktivitas hijau berhasil dicatat",
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        return {
          "success": false,
          "message": "Gagal mencatat aktivitas hijau",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Update environmental goals
  static Future<Map<String, dynamic>> updateEnvironmentalGoals({
    double? monthlyCarbonGoal,
    int? weeklyGreenActivitiesGoal,
    String? preferredTransport,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          "success": false,
          "message": "Token tidak ditemukan",
          "needsReauth": true,
        };
      }

      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/api/hijau/goals"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (monthlyCarbonGoal != null) "monthly_carbon_goal": monthlyCarbonGoal,
          if (weeklyGreenActivitiesGoal != null) "weekly_green_activities_goal": weeklyGreenActivitiesGoal,
          if (preferredTransport != null) "preferred_transport": preferredTransport,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Target lingkungan berhasil diupdate",
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        return {
          "success": false,
          "message": "Gagal mengupdate target lingkungan",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }
}

