import 'package:flutter/material.dart';
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

/// Global navigator key agar layanan non-widget (service) bisa
/// memaksa navigasi kembali ke halaman Login saat session tidak valid.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

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

      debugPrint(" Login Request:");
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

      debugPrint(" Login Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // API returns: {success, message, data: {token, user}}
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final token = data?['token'];
          final user = data?['user'];

          if (token != null) {
            debugPrint(" Login success! Token saved.");
            debugPrint(" User: ${user?['nama_lengkap']} (${user?['email']})");

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
              debugPrint(" Credentials saved for auto-refresh");
            }

            return {
              "success": true,
              "message": responseData['message'] ?? "Login berhasil",
              "token": token,
              "user": user,
            };
          } else {
            debugPrint(" Login failed: No token in response");
            return {
              "success": false,
              "message": "Token tidak ditemukan",
            };
          }
        } else {
          debugPrint(" Login failed: ${responseData['message']}");
          return {
            "success": false,
            "message": responseData['message'] ?? "Login gagal",
          };
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - Wrong credentials
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? "Email atau password salah";

        debugPrint(" Unauthorized (401): $errorMessage");

        return {
          "success": false,
          "message": errorMessage,
          "status": 401,
        };
      } else {
        debugPrint(" HTTP Error: ${response.statusCode}");

        try {
          final data = jsonDecode(response.body);
          return {
            "success": false,
            "message": data['message'] ?? "Login gagal: ${response.statusCode}",
            "status": response.statusCode,
            "error_code": data['error_code'],
            "email": data['data']?['email'] ?? data['email'],
            "requires_verification": data['data']?['requires_verification'] ?? data['requires_verification'] ?? (data['error_code'] == 'EMAIL_NOT_VERIFIED'),
            "data": data['data'],
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
      debugPrint(" Socket Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } on TimeoutException catch (e) {
      debugPrint(" Timeout Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } on http.ClientException catch (e) {
      debugPrint(" Client Exception: $e");
      return {
        "success": false,
        "message": ApiService.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint(" Login Exception: $e");
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
      debugPrint(" Logging out...");

      // Stop background steps tracker
      try {
        await BackgroundStepsTracker.stop();
        debugPrint(" Background tracker stopped");
      } catch (e) {
        debugPrint(" Could not stop background tracker: $e");
      }

      // Stop foreground service (pelacak langkah latar belakang)
      try {
        await StepForegroundService.stop();
        debugPrint(" Step foreground service stopped");
      } catch (e) {
        debugPrint(" Could not stop step foreground service: $e");
      }

      // Clear data SQLite lokal (semua fitur offline-first)
      try {
        await LocalDatabaseService.instance.clearAll();
        debugPrint(" Local SQLite data cleared");
      } catch (e) {
        debugPrint(" Could not clear local database: $e");
      }

      // Clear all auth storage (token, credentials, etc)
      await AuthStorage.clearAll();
      debugPrint(" Auth storage cleared");

      debugPrint(" Logout complete - all data cleared");
      return {
        "success": true,
        "message": "Logout berhasil",
      };
    } catch (e) {
      debugPrint(" Logout error: $e");
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

  /// Force logout & redirect ke Login saat session tidak valid
  /// (mis. 401 terjadi dan auto-refresh token gagal).
  /// Menghentikan pelacak langkah, membersihkan data lokal, lalu navigasi ke /login.
  static Future<void> forceLogoutAndGoToLogin() async {
    debugPrint(' Session invalid - forcing logout...');

    try {
      await BackgroundStepsTracker.stop();
    } catch (e) {
      debugPrint(' Could not stop background tracker: $e');
    }
    try {
      await StepForegroundService.stop();
    } catch (e) {
      debugPrint(' Could not stop step foreground service: $e');
    }
    try {
      await LocalDatabaseService.instance.clearAll();
    } catch (e) {
      debugPrint(' Could not clear local database: $e');
    }
    await AuthStorage.clearAll();

    debugPrint(' Auth storage cleared, redirecting to login...');

    // Navigate ke Login. Aman jika dipanggil dari background isolate
    // (navigatorKey.currentState bernilai null di sana).
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      debugPrint(' Navigator key not attached yet - skipping redirect');
      return;
    }
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

