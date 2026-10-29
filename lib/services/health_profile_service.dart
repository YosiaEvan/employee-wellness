import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service untuk mengelola Health Profile
class HealthProfileService {
  /// GET - Get health profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      debugPrint(" Get Profile Health Request:");
      debugPrint("URL: /user/profile-health/get");
      debugPrint(" Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.get("/user/profile-health");

      debugPrint(" Get Profile Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle nested response structure
        if (responseData['success'] == true) {
          debugPrint(" Profile retrieved successfully!");
          return {
            "success": true,
            "data": responseData['data'],
          };
        } else {
          debugPrint(" No profile data or failed: ${responseData['message']}");
          return {
            "success": false,
            "message": responseData['message'] ?? "Failed to get profile"
          };
        }
      } else if (response.statusCode == 404) {
        debugPrint(" No profile found (404) - User may not have created profile yet");
        return {
          "success": false,
          "message": "Profil belum dibuat",
          "data": null
        };
      } else {
        debugPrint(" HTTP Error ${response.statusCode}");
        return {"success": false, "message": "Failed to get profile"};
      }
    } catch (e) {
      debugPrint(" Get Profile Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// POST - Create health profile
  static Future<Map<String, dynamic>> createProfile({
    required double height,
    required double weight,
    required String bloodType,
    String? allergies,
    String? diseases,
  }) async {
    try {
      final response = await ApiService.post(
        "/health-profile",
        body: {
          "height": height,
          "weight": weight,
          "blood_type": bloodType,
          "allergies": ?allergies,
          "diseases": ?diseases,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to create profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// PUT - Update health profile
  static Future<Map<String, dynamic>> updateProfile({
    required int id,
    double? height,
    double? weight,
    String? bloodType,
    String? allergies,
    String? diseases,
  }) async {
    try {
      final response = await ApiService.put(
        "/health-profile/$id",
        body: {
          "height": ?height,
          "weight": ?weight,
          "blood_type": ?bloodType,
          "allergies": ?allergies,
          "diseases": ?diseases,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to update profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// DELETE - Delete health profile
  static Future<Map<String, dynamic>> deleteProfile(int id) async {
    try {
      final response = await ApiService.delete("/health-profile/$id");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to delete profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}

