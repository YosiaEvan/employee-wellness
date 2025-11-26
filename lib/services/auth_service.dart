import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';
import 'api_service.dart';
import 'background_steps_tracker.dart';
import 'offline_steps_service.dart';

/// Service untuk Authentication dengan auto-refresh token
class AuthService {
  /// Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ApiService.hasInternetConnection();
      if (!hasInternet) {
        return {
          "success": false,
          "message": "Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.",
        };
      }

      print("📤 Login Request:");
      print("URL: ${ApiConfig.baseUrl}/auth/login");
      print("Email: $email");

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Koneksi timeout. Periksa koneksi internet Anda.');
        },
      );

      print("📥 Login Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // API returns: {success, message, data: {token, user}}
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final token = data?['token'];
          final user = data?['user'];

          if (token != null) {
            print("✅ Login success! Token saved.");
            print("👤 User: ${user?['nama_lengkap']} (${user?['email']})");

            // Save token
            await AuthStorage.saveToken(token);

            // Save credentials for auto-refresh
            if (rememberMe) {
              await AuthStorage.saveCredentials(
                email: email,
                password: password,
                rememberMe: true,
              );
              print("✅ Credentials saved for auto-refresh");
            }

            return {
              "success": true,
              "message": responseData['message'] ?? "Login berhasil",
              "token": token,
              "user": user,
            };
          } else {
            print("❌ Login failed: No token in response");
            return {
              "success": false,
              "message": "Token tidak ditemukan",
            };
          }
        } else {
          print("❌ Login failed: ${responseData['message']}");
          return {
            "success": false,
            "message": responseData['message'] ?? "Login gagal",
          };
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - Wrong credentials
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? "Email atau password salah";

        print("❌ Unauthorized (401): $errorMessage");

        return {
          "success": false,
          "message": errorMessage,
          "status": 401,
        };
      } else {
        print("❌ HTTP Error: ${response.statusCode}");

        try {
          final data = jsonDecode(response.body);
          return {
            "success": false,
            "message": data['message'] ?? "Login gagal: ${response.statusCode}",
            "status": response.statusCode,
          };
        } catch (e) {
          return {
            "success": false,
            "message": "Login gagal: ${response.statusCode}",
            "status": response.statusCode,
          };
        }
      }
    } on SocketException catch (e) {
      print("❌ Socket Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } on TimeoutException catch (e) {
      print("❌ Timeout Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } on http.ClientException catch (e) {
      print("❌ Client Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } catch (e) {
      print("❌ Login Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    }
  }

  /// Auto-refresh token menggunakan saved credentials
  static Future<String?> refreshToken() async {
    try {
      // Get saved credentials
      final credentials = await AuthStorage.getCredentials();

      if (credentials == null) {
        return null;
      }

      // Re-login dengan credentials
      final result = await login(
        email: credentials['email']!,
        password: credentials['password']!,
        rememberMe: true,
      );

      if (result['success'] == true) {
        return result['token'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout - Clear all data
  static Future<Map<String, dynamic>> logout() async {
    try {
      print("🔓 Logging out...");

      // Stop background steps tracker
      try {
        await BackgroundStepsTracker.stop();
        print("✅ Background tracker stopped");
      } catch (e) {
        print("⚠️ Could not stop background tracker: $e");
      }

      // Clear offline steps data
      try {
        await OfflineStepsService.clearAllStepsData();
        print("✅ Offline steps data cleared");
      } catch (e) {
        print("⚠️ Could not clear offline steps: $e");
      }

      // Clear all auth storage (token, credentials, etc)
      await AuthStorage.clearAll();
      print("✅ Auth storage cleared");

      print("✅ Logout complete - all data cleared");
      return {
        "success": true,
        "message": "Logout berhasil",
      };
    } catch (e) {
      print("❌ Logout error: $e");
      // Even if error, still return success to force logout
      return {
        "success": true,
        "message": "Logout berhasil",
      };
    }
  }

  /// Check if user logged in
  static Future<bool> isLoggedIn() async {
    final token = await AuthStorage.getToken();
    return token != null;
  }
}

