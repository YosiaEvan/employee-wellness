import 'dart:convert';
import 'api_service.dart';

/// Service untuk mengambil nama dan foto user
class UserProfileService {
  /// GET - Get user name and photo
  static Future<Map<String, dynamic>> getUserNameAndPhoto() async {
    try {
      print("📤 Get User Name and Photo Request:");
      print("URL: /user/nama-foto");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.get("/user/nama-foto");

      print("📥 Get User Name/Photo Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract data from nested structure
        final data = responseData['data'];

        if (data != null) {
          print("✅ User data retrieved successfully!");
          print("📊 Data keys: ${data.keys.toList()}");
          print("📷 Foto value: ${data['foto']}");

          return {
            "success": true,
            "nama_lengkap": data['nama_lengkap'],
            "foto_url": data['foto_url'] ?? data['foto'], // Try both field names
          };
        } else {
          print("⚠️ No data in response");
          return {
            "success": false,
            "message": "No data found"
          };
        }
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {"success": false, "message": "Failed to get user data"};
      }
    } catch (e) {
      print("❌ Get User Data Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}

