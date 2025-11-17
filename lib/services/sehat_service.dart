import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Service untuk Modul Sehat (Health/Physical Wellness)
class SehatService {
  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // GET - Get health profile/data
  static Future<Map<String, dynamic>> getHealthData() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/profile"),
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

  // GET - Get step count history
  static Future<Map<String, dynamic>> getStepHistory({
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

      String url = "${ApiConfig.baseUrl}/api/sehat/steps";
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

  // GET - Get health metrics (BMI, heart rate, etc)
  static Future<Map<String, dynamic>> getHealthMetrics() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/metrics"),
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

  // POST - Record daily steps
  static Future<Map<String, dynamic>> recordSteps({
    required int steps,
    required String date,
    double? distance,
    int? calories,
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
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/steps"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "steps": steps,
          "date": date,
          if (distance != null) "distance": distance,
          if (calories != null) "calories": calories,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Data langkah berhasil disimpan",
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
          "message": "Gagal menyimpan data langkah",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // POST - Record health metrics
  static Future<Map<String, dynamic>> recordHealthMetrics({
    double? weight,
    double? height,
    int? heartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? bloodSugar,
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
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/metrics"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (weight != null) "weight": weight,
          if (height != null) "height": height,
          if (heartRate != null) "heart_rate": heartRate,
          if (bloodPressureSystolic != null) "bp_systolic": bloodPressureSystolic,
          if (bloodPressureDiastolic != null) "bp_diastolic": bloodPressureDiastolic,
          if (bloodSugar != null) "blood_sugar": bloodSugar,
          if (notes != null) "notes": notes,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Data kesehatan berhasil disimpan",
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
          "message": "Gagal menyimpan data kesehatan",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // POST - Record exercise/workout
  static Future<Map<String, dynamic>> recordExercise({
    required String exerciseType,
    required int duration,
    int? calories,
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
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/exercise"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "exercise_type": exerciseType,
          "duration": duration,
          if (calories != null) "calories": calories,
          if (notes != null) "notes": notes,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Data olahraga berhasil disimpan",
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
          "message": "Gagal menyimpan data olahraga",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Update health profile
  static Future<Map<String, dynamic>> updateHealthProfile({
    double? height,
    double? weight,
    String? bloodType,
    String? allergies,
    String? chronicDiseases,
    String? medications,
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
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (height != null) "height": height,
          if (weight != null) "weight": weight,
          if (bloodType != null) "blood_type": bloodType,
          if (allergies != null) "allergies": allergies,
          if (chronicDiseases != null) "chronic_diseases": chronicDiseases,
          if (medications != null) "medications": medications,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Profil kesehatan berhasil diupdate",
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
          "message": "Gagal mengupdate profil kesehatan",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Update health goals
  static Future<Map<String, dynamic>> updateHealthGoals({
    int? dailyStepsGoal,
    int? weeklyExerciseGoal,
    double? weightGoal,
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

      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/api/sehat/goals"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (dailyStepsGoal != null) "daily_steps_goal": dailyStepsGoal,
          if (weeklyExerciseGoal != null) "weekly_exercise_goal": weeklyExerciseGoal,
          if (weightGoal != null) "weight_goal": weightGoal,
          if (notes != null) "notes": notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Target kesehatan berhasil diupdate",
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
          "message": "Gagal mengupdate target kesehatan",
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

