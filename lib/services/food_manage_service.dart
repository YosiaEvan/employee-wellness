import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service untuk Food Management
class FoodManageService {
  /// GET - Search food by name
  static Future<Map<String, dynamic>> searchFood(String namaMenu) async {
    try {
      debugPrint("ðŸ“¤ Search Food Request:");
      debugPrint("URL: /user/food-manage?nama=${Uri.encodeComponent(namaMenu)}");
      debugPrint("ðŸ” Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get(
        "/user/food-manage?nama=${Uri.encodeComponent(namaMenu)}",
      );

      debugPrint("ðŸ“¥ Search Food Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          debugPrint("âœ… Food data found!");
          debugPrint("ðŸ“Š Sumber: ${responseData['sumber']}");

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
        debugPrint("âŒ HTTP Error ${response.statusCode}");
        return {
          "success": false,
          "message": "Gagal mencari makanan",
        };
      }
    } catch (e) {
      debugPrint("âŒ Search Food Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}

