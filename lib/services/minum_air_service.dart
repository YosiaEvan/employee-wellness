import 'dart:convert';
import 'api_service.dart';

/// Service untuk Minum Air 8 Gelas
class MinumAirService {
  /// GET - Cek status minum air hari ini
  static Future<Map<String, dynamic>> getStatusMinum() async {
    try {
      print("📤 Get Status Minum Request:");
      print("URL: /user/minum");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get("/user/minum");

      print("📥 Get Status Minum Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "hari_ini": responseData['hari_ini'],
          "minggu_ini": responseData['minggu_ini'],
          "aturan": responseData['aturan'],
        };
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {
          "success": false,
        };
      }
    } catch (e) {
      print("❌ Get Status Minum Error: $e");
      return {
        "success": false,
      };
    }
  }

  /// POST - Catat minum air
  static Future<Map<String, dynamic>> catatMinum() async {
    try {
      print("📤 Catat Minum Request:");
      print("URL: /user/minum");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      // Gunakan waktu saat ini
      final now = DateTime.now();
      print("💧 Waktu minum: ${now.toIso8601String()}");

      final response = await ApiService.post(
        "/user/minum",
        body: {
          "waktu_minum": now.toIso8601String(),
        },
      );

      print("📥 Catat Minum Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat minum air",
          "data": responseData['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal menyimpan data",
        };
      }
    } catch (e) {
      print("❌ Catat Minum Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}

