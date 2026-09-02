import 'package:flutter/foundation.dart';
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

      debugPrint(" Register Request:");
      debugPrint("URL: ${ApiConfig.baseUrl}/user/register");
      debugPrint("Body: ${jsonEncode({
        "nama_lengkap": namaLengkap,
        "email": email,
        "password": "***",
        "confirm_password": "***",
        "token_perusahaan": tokenPerusahaan,
      })}");
      debugPrint(" Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Jika backend sertakan debug_code (SMTP gagal / dev mode), tampilkan ke user agar tetap bisa verifikasi
        final debugCode = data['data']?['debug_code'] ?? data['debug_code'];
        String msg = data['message'] ?? "Registrasi berhasil! Silakan cek email untuk verifikasi.";
        if (debugCode != null) {
          msg += " [DEBUG code: $debugCode]";
        }
        if (data['data']?['email_sent'] == false) {
          msg += " (Email gagal terkirim - cek SPAM atau gunakan debug code di atas / minta admin cek log server & env SMTP di Netlify)";
        }
        return {
          "success": true,
          "message": msg,
          "data": data,
          "debug_code": debugCode,
        };
      } else {
        final data = jsonDecode(response.body);
        // Jika 429 throttling dari resend, tampilkan wait message
        return {
          "success": false,
          "message": data['message'] ?? "Registrasi gagal",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      debugPrint(" Register Error: $e");
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

      debugPrint(" Verify Email Request:");
      debugPrint("URL: ${ApiConfig.baseUrl}/auth/verify-email");
      debugPrint("Body: ${jsonEncode({"email": email, "code": otp})}");
      debugPrint(" Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

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
      debugPrint(" Verify Error: $e");
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

      debugPrint(" Resend OTP Request:");
      debugPrint("URL: ${ApiConfig.baseUrl}/auth/resend-verification");
      debugPrint("Body: ${jsonEncode({"email": email})}");
      debugPrint(" Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final debugCode = data['data']?['debug_code'] ?? data['debug_code'];
        String msg = data['message'] ?? "Kode OTP berhasil dikirim ulang";
        if (debugCode != null) msg += " [DEBUG code: $debugCode]";
        return {
          "success": true,
          "message": msg,
          "data": data,
          "debug_code": debugCode,
        };
      } else {
        final data = jsonDecode(response.body);
        // 429 = throttling resend
        final isThrottle = response.statusCode == 429;
        return {
          "success": false,
          "message": data['message'] ?? (isThrottle ? "Tunggu sebelum resend lagi" : "Gagal mengirim ulang OTP"),
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      debugPrint(" Resend OTP Error: $e");
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

