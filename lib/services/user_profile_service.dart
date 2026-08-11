import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service untuk mengambil nama dan foto user
class UserProfileService {
  /// GET - Get user name and photo
  static Future<Map<String, dynamic>> getUserNameAndPhoto() async {
    try {
      debugPrint("ðŸ“¤ Get User Name and Photo Request:");
      debugPrint("URL: /user/nama-foto");
      debugPrint("ðŸ” Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.get("/user/nama-foto");

      debugPrint("ðŸ“¥ Get User Name/Photo Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract data from nested structure
        final data = responseData['data'];

        if (data != null) {
          debugPrint("âœ… User data retrieved successfully!");
          debugPrint("ðŸ“Š Data keys: ${data.keys.toList()}");
          debugPrint("ðŸ“· Foto value: ${data['foto']}");

          return {
            "success": true,
            "nama_lengkap": data['nama_lengkap'],
            "foto_url": data['foto_url'] ?? data['foto'], // Try both field names
          };
        } else {
          debugPrint("âš ï¸ No data in response");
          return {
            "success": false,
            "message": "No data found"
          };
        }
      } else {
        debugPrint("âŒ HTTP Error ${response.statusCode}");
        return {"success": false, "message": "Failed to get user data"};
      }
    } catch (e) {
      debugPrint("âŒ Get User Data Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}

