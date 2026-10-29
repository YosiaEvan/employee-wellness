import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service untuk mengambil nama dan foto user
class UserProfileService {
  /// GET - Get user name and photo
  static Future<Map<String, dynamic>> getUserNameAndPhoto() async {
    try {
      debugPrint(" Get User Name and Photo Request:");
      debugPrint("URL: /user/nama-foto");
      debugPrint(" Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.get("/user/nama-foto");

      debugPrint(" Get User Name/Photo Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract data from nested structure
        final data = responseData['data'];

        if (data != null) {
          debugPrint(" User data retrieved successfully!");
          debugPrint(" Data keys: ${data.keys.toList()}");
          debugPrint(" Foto value: ${data['foto']}");

          return {
            "success": true,
            "nama_lengkap": data['nama_lengkap'],
            "foto_url": data['foto_url'] ?? data['foto'], // Try both field names
          };
        } else {
          debugPrint(" No data in response");
          return {
            "success": false,
            "message": "No data found"
          };
        }
      } else {
        debugPrint(" HTTP Error ${response.statusCode}");
        return {"success": false, "message": "Failed to get user data"};
      }
    } catch (e) {
      debugPrint(" Get User Data Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}

