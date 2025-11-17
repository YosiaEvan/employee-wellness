import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Service untuk Home/Dashboard
class HomeService {
  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // GET - Get dashboard/home data
  static Future<Map<String, dynamic>> getDashboardData() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/home/dashboard"),
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

  // GET - Get wellness score/summary
  static Future<Map<String, dynamic>> getWellnessScore() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/home/wellness-score"),
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

  // GET - Get recent activities
  static Future<Map<String, dynamic>> getRecentActivities({int? limit}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          "success": false,
          "message": "Token tidak ditemukan",
          "needsReauth": true,
        };
      }

      final url = limit != null
          ? "${ApiConfig.baseUrl}/api/home/recent-activities?limit=$limit"
          : "${ApiConfig.baseUrl}/api/home/recent-activities";

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

  // GET - Get announcements/news
  static Future<Map<String, dynamic>> getAnnouncements() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/home/announcements"),
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

  // POST - Log activity/interaction
  static Future<Map<String, dynamic>> logActivity({
    required String activityType,
    required String activityData,
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
        Uri.parse("${ApiConfig.baseUrl}/api/home/log-activity"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "activity_type": activityType,
          "activity_data": activityData,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Aktivitas berhasil dicatat",
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
          "message": "Gagal mencatat aktivitas",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // POST - Submit daily check-in
  static Future<Map<String, dynamic>> submitDailyCheckIn({
    required int moodScore,
    String? notes,
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
        Uri.parse("${ApiConfig.baseUrl}/api/home/daily-checkin"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "mood_score": moodScore,
          if (notes != null) "notes": notes,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Check-in berhasil disimpan",
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
          "message": "Gagal menyimpan check-in",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Update user preferences
  static Future<Map<String, dynamic>> updatePreferences({
    bool? notificationsEnabled,
    bool? dailyReminder,
    String? language,
    String? theme,
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
        Uri.parse("${ApiConfig.baseUrl}/api/home/preferences"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (notificationsEnabled != null) "notifications_enabled": notificationsEnabled,
          if (dailyReminder != null) "daily_reminder": dailyReminder,
          if (language != null) "language": language,
          if (theme != null) "theme": theme,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Preferensi berhasil diupdate",
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
          "message": "Gagal mengupdate preferensi",
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

