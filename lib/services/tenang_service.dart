import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Service untuk Modul Tenang (Mental/Peace Wellness)
class TenangService {
  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // GET - Get mental wellness data
  static Future<Map<String, dynamic>> getTenangData() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/tenang/dashboard"),
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

  // GET - Get mood history
  static Future<Map<String, dynamic>> getMoodHistory({
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

      String url = "${ApiConfig.baseUrl}/api/tenang/mood-history";
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

  // POST - Record mood
  static Future<Map<String, dynamic>> recordMood({
    required int moodScore,
    List<String>? emotions,
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
        Uri.parse("${ApiConfig.baseUrl}/api/tenang/mood"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "mood_score": moodScore,
          if (emotions != null) "emotions": emotions,
          if (notes != null) "notes": notes,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Mood berhasil dicatat",
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
          "message": "Gagal mencatat mood",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Update mental wellness goals
  static Future<Map<String, dynamic>> updateMentalGoals({
    int? dailyMeditationMinutes,
    int? weeklyJournalEntries,
    String? stressManagementPlan,
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
        Uri.parse("${ApiConfig.baseUrl}/api/tenang/goals"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (dailyMeditationMinutes != null) "daily_meditation_minutes": dailyMeditationMinutes,
          if (weeklyJournalEntries != null) "weekly_journal_entries": weeklyJournalEntries,
          if (stressManagementPlan != null) "stress_management_plan": stressManagementPlan,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Target kesehatan mental berhasil diupdate",
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
          "message": "Gagal mengupdate target kesehatan mental",
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

