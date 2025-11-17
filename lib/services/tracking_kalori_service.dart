import 'dart:convert';
import 'api_service.dart';

/// Service untuk Tracking Kalori
class TrackingKaloriService {
  /// POST - Tambah makanan ke tracking kalori
  static Future<Map<String, dynamic>> tambahMakanan({
    required int idFoodNutrition,
    required String jenisMakan,
    required double porsi,
  }) async {
    try {
      print("📤 Tambah Makanan ke Tracking Request:");
      print("URL: /user/tracking-kalori");
      print("🔐 Using Bearer token (auto-refresh if expired)");
      print("🍽️ ID Food: $idFoodNutrition");
      print("🍽️ Jenis Makan: $jenisMakan");
      print("🍽️ Porsi: $porsi");

      final response = await ApiService.post(
        "/user/tracking-kalori",
        body: {
          "id_food_nutrition": idFoodNutrition,
          "jenis_makan": jenisMakan,
          "porsi": porsi,
        },
      );

      print("📥 Tracking Kalori Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print("✅ Makanan berhasil ditambahkan!");
          print("📊 Total kalori hari ini: ${responseData['data']['total_kalori_hari_ini']}");

          return {
            "success": true,
            "message": responseData['message'],
            "warning": responseData['warning'],
            "data": responseData['data'],
          };
        } else {
          return {
            "success": false,
            "message": responseData['message'] ?? "Gagal menambahkan makanan",
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal menambahkan makanan",
        };
      }
    } catch (e) {
      print("❌ Tracking Kalori Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// GET - Get tracking kalori hari ini
  static Future<Map<String, dynamic>> getTrackingHariIni() async {
    try {
      print("📤 Get Tracking Kalori Hari Ini Request:");
      print("URL: /user/tracking-kalori");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get("/user/tracking-kalori");

      print("📥 Get Tracking Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print("✅ Tracking data retrieved!");
          print("📊 Total kalori: ${responseData['data']['konsumsi']['kalori']}");
          print("📊 Total item: ${responseData['data']['total_item']}");

          return {
            "success": true,
            "data": responseData['data'],
          };
        } else {
          return {
            "success": false,
            "message": responseData['message'] ?? "Gagal mengambil data",
          };
        }
      } else {
        return {"success": false, "message": "Gagal mengambil data"};
      }
    } catch (e) {
      print("❌ Get Tracking Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}

