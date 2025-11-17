import 'dart:convert';
import 'api_service.dart';

/// Service untuk Food Management
class FoodManageService {
  /// GET - Search food by name
  static Future<Map<String, dynamic>> searchFood(String namaMenu) async {
    try {
      print("📤 Search Food Request:");
      print("URL: /user/food-manage?nama=${Uri.encodeComponent(namaMenu)}");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get(
        "/user/food-manage?nama=${Uri.encodeComponent(namaMenu)}",
      );

      print("📥 Search Food Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print("✅ Food data found!");
          print("📊 Sumber: ${responseData['sumber']}");

          return {
            "success": true,
            "message": responseData['message'],
            "sumber": responseData['sumber'],
            "data": responseData['data'],
          };
        } else {
          return {
            "success": false,
            "message": responseData['message'] ?? "Data tidak ditemukan",
          };
        }
      } else if (response.statusCode == 404) {
        return {
          "success": false,
          "message": "Makanan tidak ditemukan",
        };
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {
          "success": false,
          "message": "Gagal mencari makanan",
        };
      }
    } catch (e) {
      print("❌ Search Food Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}

