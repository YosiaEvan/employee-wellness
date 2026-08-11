import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';
import 'api_service.dart';
import 'background_steps_tracker.dart';
import 'step_foreground_service.dart';
import 'local_database_service.dart';
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

      debugPrint("ðŸ“¤ Login Request:");
      debugPrint("URL: ${ApiConfig.baseUrl}/auth/login");
      debugPrint("Email: $email");

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

      debugPrint("ðŸ“¥ Login Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // API returns: {success, message, data: {token, user}}
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final token = data?['token'];
          final user = data?['user'];

          if (token != null) {
            debugPrint("âœ… Login success! Token saved.");
            debugPrint("ðŸ‘¤ User: ${user?['nama_lengkap']} (${user?['email']})");

            // Save token
            await AuthStorage.saveToken(token);

            // Save session info untuk kebutuhan offline & KPI
            await AuthStorage.saveUserSession(
              userId: user?['id']?.toString(),
              email: user?['email']?.toString() ?? email,
            );

            // Save credentials for auto-refresh
            if (rememberMe) {
              await AuthStorage.saveCredentials(
                email: email,
                password: password,
                rememberMe: true,
              );
              debugPrint("âœ… Credentials saved for auto-refresh");
            }

            return {
              "success": true,
              "message": responseData['message'] ?? "Login berhasil",
              "token": token,
              "user": user,
            };
          } else {
            debugPrint("âŒ Login failed: No token in response");
            return {
              "success": false,
              "message": "Token tidak ditemukan",
            };
          }
        } else {
          debugPrint("âŒ Login failed: ${responseData['message']}");
          return {
            "success": false,
            "message": responseData['message'] ?? "Login gagal",
          };
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - Wrong credentials
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? "Email atau password salah";

        debugPrint("âŒ Unauthorized (401): $errorMessage");

        return {
          "success": false,
          "message": errorMessage,
          "status": 401,
        };
      } else {
        debugPrint("âŒ HTTP Error: ${response.statusCode}");

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
      debugPrint("âŒ Socket Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } on TimeoutException catch (e) {
      debugPrint("âŒ Timeout Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } on http.ClientException catch (e) {
      debugPrint("âŒ Client Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint("âŒ Login Exception: $e");
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
      debugPrint("ðŸ”“ Logging out...");

      // Stop background steps tracker
      try {
        await BackgroundStepsTracker.stop();
        debugPrint("âœ… Background tracker stopped");
      } catch (e) {
        debugPrint("âš ï¸ Could not stop background tracker: $e");
      }

      // Stop foreground service (pelacak langkah latar belakang)
      try {
        await StepForegroundService.stop();
        debugPrint("âœ… Step foreground service stopped");
      } catch (e) {
        debugPrint("âš ï¸ Could not stop step foreground service: $e");
      }

      // Clear offline steps data
      try {
        await OfflineStepsService.clearAllStepsData();
        debugPrint("âœ… Offline steps data cleared");
      } catch (e) {
        debugPrint("âš ï¸ Could not clear offline steps: $e");
      }

      // Clear data SQLite lokal (semua fitur offline-first)
      try {
        await LocalDatabaseService.instance.clearAll();
        debugPrint("âœ… Local SQLite data cleared");
      } catch (e) {
        debugPrint("âš ï¸ Could not clear local database: $e");
      }

      // Clear all auth storage (token, credentials, etc)
      await AuthStorage.clearAll();
      debugPrint("âœ… Auth storage cleared");

      debugPrint("âœ… Logout complete - all data cleared");
      return {
        "success": true,
        "message": "Logout berhasil",
      };
    } catch (e) {
      debugPrint("âŒ Logout error: $e");
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

