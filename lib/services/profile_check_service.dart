import 'dart:convert';
import 'api_service.dart';

/// Service untuk check kelengkapan profile
class ProfileCheckService {
  /// GET - Check apakah profile sudah lengkap
  static Future<bool> checkProfileComplete() async {
    try {
      print("📤 Check Profile Complete Request:");
      print("URL: /user/cek-kelengkapan-profile");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.get("/user/cek-kelengkapan-profile");

      print("📥 Check Profile Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final isComplete = responseData['isComplete'] ?? false;
        print("✅ Profile complete status: $isComplete");

        return isComplete;
      } else {
        print("❌ Failed to check profile: ${response.statusCode}");
        // Default to false if API fails - show the card
        return false;
      }
    } catch (e) {
      print("❌ Check Profile Error: $e");
      // Default to false on error - show the card
      return false;
    }
  }
}

