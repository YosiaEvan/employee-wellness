import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Service untuk User Profile
class ProfileService {
  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // GET - Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/profile"),
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("token");

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

  // GET - Get profile completion status
  static Future<Map<String, dynamic>> getProfileCompletion() async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/profile/completion"),
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

  // POST - Create/Complete profile
  static Future<Map<String, dynamic>> createProfile({
    required String name,
    required String phone,
    String? address,
    String? birthDate,
    String? gender,
    String? avatar,
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
        Uri.parse("${ApiConfig.baseUrl}/api/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "phone": phone,
          if (address != null) "address": address,
          if (birthDate != null) "birth_date": birthDate,
          if (gender != null) "gender": gender,
          if (avatar != null) "avatar": avatar,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Profil berhasil dibuat",
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["message"] ?? "Gagal membuat profil",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Update profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
    String? avatar,
    String? bio,
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
        Uri.parse("${ApiConfig.baseUrl}/api/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (name != null) "name": name,
          if (phone != null) "phone": phone,
          if (address != null) "address": address,
          if (birthDate != null) "birth_date": birthDate,
          if (gender != null) "gender": gender,
          if (avatar != null) "avatar": avatar,
          if (bio != null) "bio": bio,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Profil berhasil diupdate",
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["message"] ?? "Gagal mengupdate profil",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // POST - Upload profile avatar
  static Future<Map<String, dynamic>> uploadAvatar(String base64Image) async {
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
        Uri.parse("${ApiConfig.baseUrl}/api/profile/avatar"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "avatar": base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Avatar berhasil diupload",
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
          "message": "Gagal mengupload avatar",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  // UPDATE - Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
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
        Uri.parse("${ApiConfig.baseUrl}/api/profile/change-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "current_password": currentPassword,
          "new_password": newPassword,
          "new_password_confirmation": newPasswordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Password berhasil diubah",
          "data": data,
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Sesi telah berakhir, silakan login kembali",
          "needsReauth": true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["message"] ?? "Gagal mengubah password",
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

