import 'dart:convert';
import 'api_service.dart';

/// Service untuk aktivitas Sinar Matahari / Berjemur
class SinarMatahariService {
  /// GET - Cek apakah sudah berjemur hari ini
  static Future<Map<String, dynamic>> cekBerjemur() async {
    try {
      print("📤 Cek Berjemur Request:");
      print("URL: /user/sinar-matahari");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get("/user/sinar-matahari");

      print("📥 Cek Berjemur Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "sudah_berjemur": responseData['sudah_berjemur'] ?? false,
          "data": responseData['data'],
        };
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {
          "success": false,
          "sudah_berjemur": false,
        };
      }
    } catch (e) {
      print("❌ Cek Berjemur Error: $e");
      return {
        "success": false,
        "sudah_berjemur": false,
      };
    }
  }

  /// POST - Catat aktivitas berjemur
  static Future<Map<String, dynamic>> catatBerjemur() async {
    try {
      final now = DateTime.now();
      final waktuSelesai = now.toIso8601String();

      print("📤 Catat Berjemur Request:");
      print("URL: /user/sinar-matahari");
      print("🔐 Using Bearer token (auto-refresh if expired)");
      print("☀️ Mencatat aktivitas berjemur hari ini...");
      print("⏰ Waktu selesai: $waktuSelesai");

      final response = await ApiService.post(
        "/user/sinar-matahari",
        body: {
          "waktu_selesai": waktuSelesai,
        },
      );

      print("📥 Catat Berjemur Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat aktivitas berjemur",
          "data": responseData['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal menyimpan aktivitas",
        };
      }
    } catch (e) {
      print("❌ Catat Berjemur Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}

