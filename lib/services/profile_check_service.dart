import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service untuk check kelengkapan profile
class ProfileCheckService {
  /// GET - Check apakah profile sudah lengkap
  static Future<bool> checkProfileComplete() async {
    try {
      debugPrint("ðŸ“¤ Check Profile Complete Request:");
      debugPrint("URL: /user/cek-kelengkapan-profile");
      debugPrint("ðŸ” Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.get("/user/cek-kelengkapan-profile");

      debugPrint("ðŸ“¥ Check Profile Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final isComplete = responseData['isComplete'] ?? false;
        debugPrint("âœ… Profile complete status: $isComplete");

        return isComplete;
      } else {
        debugPrint("âŒ Failed to check profile: ${response.statusCode}");
        // Default to false if API fails - show the card
        return false;
      }
    } catch (e) {
      debugPrint("âŒ Check Profile Error: $e");
      // Default to false on error - show the card
      return false;
    }
  }
}

