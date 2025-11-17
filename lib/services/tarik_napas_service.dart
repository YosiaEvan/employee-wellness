import 'dart:convert';
import 'api_service.dart';

/// Service untuk Tarik Napas / Udara Segar
class TarikNapasService {
  /// GET - Cek apakah sudah tarik napas hari ini
  static Future<Map<String, dynamic>> cekTarikNapas() async {
    try {
      print("📤 Cek Tarik Napas Request:");
      print("URL: /user/tarik-napas");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get("/user/tarik-napas");

      print("📥 Cek Tarik Napas Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        return {
          "success": true,
          "sudah_tarik_napas": responseData['sudah_tarik_napas'] ?? false,
          "data": responseData['data'],
          "minggu_ini": responseData['minggu_ini'], // Pass minggu_ini from root level
        };
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {
          "success": false,
          "sudah_tarik_napas": false,
        };
      }
    } catch (e) {
      print("❌ Cek Tarik Napas Error: $e");
      return {
        "success": false,
        "sudah_tarik_napas": false,
      };
    }
  }

  /// POST - Catat aktivitas tarik napas
  static Future<Map<String, dynamic>> catatTarikNapas() async {
    try {
      print("📤 Catat Tarik Napas Request:");
      print("URL: /user/tarik-napas");
      print("🔐 Using Bearer token (auto-refresh if expired)");
      print("🌬️ Mencatat aktivitas tarik napas hari ini...");

      final response = await ApiService.post(
        "/user/tarik-napas",
        body: {
          "waktu_selesai": DateTime.now().toIso8601String(),
        },
      );

      print("📥 Catat Tarik Napas Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat aktivitas tarik napas",
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
      print("❌ Catat Tarik Napas Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}

