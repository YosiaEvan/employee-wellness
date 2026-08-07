import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service untuk Lupa Password / Reset Password di aplikasi mobile
class PasswordService {
  /// POST - Minta kode reset (OTP 6 digit) ke email
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      print("📤 Forgot Password Request:");
      print("URL: ${ApiConfig.baseUrl}/auth/forgot-password");

      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/auth/forgot-password"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email.trim(),
              "channel": "mobile",
            }),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Koneksi timeout. Periksa koneksi internet Anda.');
            },
          );

      print("📥 Response: ${response.statusCode}");
      print("Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          "success": true,
          "message": data['message'] ?? "Kode reset telah dikirim ke email Anda",
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Gagal mengirim kode reset",
        };
      }
    } on SocketException catch (e) {
      print("❌ Socket Exception: $e");
      return {"success": false, "message": "Tidak dapat terhubung ke server. Periksa koneksi internet Anda."};
    } on TimeoutException catch (e) {
      print("❌ Timeout: $e");
      return {"success": false, "message": "Koneksi timeout. Periksa koneksi internet Anda."};
    } catch (e) {
      print("❌ Forgot Password Error: $e");
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  /// POST - Reset password dengan kode OTP
  static Future<Map<String, dynamic>> resetPassword({
    required String code,
    required String password,
  }) async {
    try {
      print("📤 Reset Password Request:");
      print("URL: ${ApiConfig.baseUrl}/auth/reset-password");

      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/auth/reset-password"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "token": code.trim(),
              "password": password,
            }),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Koneksi timeout. Periksa koneksi internet Anda.');
            },
          );

      print("📥 Response: ${response.statusCode}");
      print("Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          "success": true,
          "message": data['message'] ?? "Password berhasil direset",
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Gagal mereset password",
        };
      }
    } on SocketException catch (e) {
      print("❌ Socket Exception: $e");
      return {"success": false, "message": "Tidak dapat terhubung ke server. Periksa koneksi internet Anda."};
    } on TimeoutException catch (e) {
      print("❌ Timeout: $e");
      return {"success": false, "message": "Koneksi timeout. Periksa koneksi internet Anda."};
    } catch (e) {
      print("❌ Reset Password Error: $e");
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }
}
