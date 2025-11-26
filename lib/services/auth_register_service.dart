import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';

/// Service untuk Register & Verify Email
class AuthRegisterService {
  /// POST - Register
  static Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String email,
    required String password,
    required String confirmPassword,
    required String tokenPerusahaan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/user/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_lengkap": namaLengkap,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
          "token_perusahaan": tokenPerusahaan,
        }),
      );

      print("📤 Register Request:");
      print("URL: ${ApiConfig.baseUrl}/user/register");
      print("Body: ${jsonEncode({
        "nama_lengkap": namaLengkap,
        "email": email,
        "password": "***",
        "confirm_password": "***",
        "token_perusahaan": tokenPerusahaan,
      })}");
      print("📥 Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Registrasi berhasil! Silakan cek email untuk verifikasi.",
          "data": data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Registrasi gagal",
        };
      }
    } catch (e) {
      print("❌ Register Error: $e");
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  /// POST - Verify Email with OTP
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/verify-email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "code": otp,
        }),
      );

      print("📤 Verify Email Request:");
      print("URL: ${ApiConfig.baseUrl}/auth/verify-email");
      print("Body: ${jsonEncode({"email": email, "code": otp})}");
      print("📥 Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save token if provided
        if (data['token'] != null) {
          await AuthStorage.saveToken(data['token']);
        }

        return {
          "success": true,
          "message": "Email berhasil diverifikasi!",
          "data": data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Verifikasi gagal",
        };
      }
    } catch (e) {
      print("❌ Verify Error: $e");
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  /// POST - Resend OTP
  static Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/resend-verification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("📤 Resend OTP Request:");
      print("URL: ${ApiConfig.baseUrl}/auth/resend-verification");
      print("Body: ${jsonEncode({"email": email})}");
      print("📥 Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Kode OTP berhasil dikirim ulang",
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Gagal mengirim ulang OTP",
        };
      }
    } catch (e) {
      print("❌ Resend OTP Error: $e");
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  /// GET - Check email availability
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/user/check-email?email=$email"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "available": data['available'] ?? false,
        };
      } else {
        return {"success": false, "available": false};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}

