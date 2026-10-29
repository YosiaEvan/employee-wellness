import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service untuk mengelola Profile Kesehatan
class ProfileHealthService {
  /// GET - Get health profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      debugPrint(" Get Profile Health Request:");
      debugPrint("URL: /user/profile-health (GET method)");
      debugPrint(" Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      // Using GET method (no body required)
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
      } else if (response.statusCode == 401) {
        debugPrint(" Unauthorized (401) - Token invalid or expired");
        return {
          "success": false,
          "message": "Unauthorized",
          "needsLogin": true
        };
      } else if (response.statusCode == 400) {
        debugPrint(" Bad Request (400)");
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Bad request"
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

  /// POST - Create or Update Health Profile
  static Future<Map<String, dynamic>> saveProfile({
    required String namaLengkap,
    required String email,
    required String jenisKelamin,
    required String tanggalLahir,
    required double tinggiBadan,
    required double beratBadan,
    required double targetBerat,
    required int targetKalori,
    required String tipeDiet,
    required String levelAktivitas,
    required List<String> alergi,
    required List<String> kondisiMedis,
    required List<String> obatDikonsumsi,
    required String namaKontakDarurat,
    required String nomorKontakDarurat,
    String? fotoBase64, // Optional photo in base64
  }) async {
    try {
      debugPrint(" Save Profile Health Request:");
      debugPrint("URL: /user/profile-health");
      debugPrint(" Using Bearer token (auto-refresh if expired)");
      debugPrint("Data: $namaLengkap, $email");
      if (fotoBase64 != null) {
        debugPrint(" Photo included (base64 length: ${fotoBase64.length})");
        debugPrint(" Photo preview (first 100 chars): ${fotoBase64.substring(0, 100)}...");
      } else {
        debugPrint(" Photo: NULL - not included");
      }

      // Build request body
      final requestBody = {
        "nama_lengkap": namaLengkap,
        "email": email,
        "jenis_kelamin": jenisKelamin,
        "tanggal_lahir": tanggalLahir,
        "tinggi_badan": tinggiBadan,
        "berat_badan": beratBadan,
        "target_berat": targetBerat,
        "target_kalori": targetKalori,
        "tipe_diet": tipeDiet,
        "level_aktivitas": levelAktivitas,
        "alergi": alergi,
        "kondisi_medis": kondisiMedis,
        "obat_dikonsumsi": obatDikonsumsi,
        "nama_kontak_darurat": namaKontakDarurat,
        "nomor_kontak_darurat": nomorKontakDarurat,
        // Try both field names for compatibility
        "foto": ?fotoBase64,
        "foto_base64": ?fotoBase64,
      };

      debugPrint(" Request body keys: ${requestBody.keys.toList()}");
      debugPrint(" Has 'foto' key: ${requestBody.containsKey('foto')}");
      debugPrint(" Has 'foto_base64' key: ${requestBody.containsKey('foto_base64')}");

      // ApiService automatically adds Bearer token and handles 401 refresh
      // Headers will include: Authorization: Bearer <token>
      // This satisfies the withAuth middleware requirement
      final response = await ApiService.post(
        "/user/profile-health",
        body: requestBody,
      );

      debugPrint(" Save Profile Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Handle nested response structure
        if (responseData['success'] == true) {
          debugPrint(" Profile saved successfully!");
          return {
            "success": true,
            "message": responseData['message'] ?? "Profil kesehatan berhasil disimpan",
            "data": responseData['data'],
          };
        } else {
          debugPrint(" Save failed: ${responseData['message']}");
          return {
            "success": false,
            "message": responseData['message'] ?? "Gagal menyimpan profil",
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint(" HTTP Error ${response.statusCode}: ${errorData['message']}");
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal menyimpan profil",
        };
      }
    } catch (e) {
      debugPrint(" Save Profile Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// PUT - Update Health Profile
  static Future<Map<String, dynamic>> updateProfile({
    String? namaLengkap,
    String? email,
    String? jenisKelamin,
    String? tanggalLahir,
    double? tinggiBadan,
    double? beratBadan,
    double? targetBerat,
    int? targetKalori,
    String? tipeDiet,
    String? levelAktivitas,
    List<String>? alergi,
    List<String>? kondisiMedis,
    List<String>? obatDikonsumsi,
    String? namaKontakDarurat,
    String? nomorKontakDarurat,
  }) async {
    try {
      debugPrint(" Update Profile Health Request:");
      debugPrint("URL: /user/profile-health");
      debugPrint(" Using Bearer token (auto-refresh if expired)");

      // ApiService automatically adds Bearer token and handles 401 refresh
      final response = await ApiService.put(
        "/user/profile-health",
        body: {
          "nama_lengkap": ?namaLengkap,
          "email": ?email,
          "jenis_kelamin": ?jenisKelamin,
          "tanggal_lahir": ?tanggalLahir,
          "tinggi_badan": ?tinggiBadan,
          "berat_badan": ?beratBadan,
          "target_berat": ?targetBerat,
          "target_kalori": ?targetKalori,
          "tipe_diet": ?tipeDiet,
          "level_aktivitas": ?levelAktivitas,
          "alergi": ?alergi,
          "kondisi_medis": ?kondisiMedis,
          "obat_dikonsumsi": ?obatDikonsumsi,
          "nama_kontak_darurat": ?namaKontakDarurat,
          "nomor_kontak_darurat": ?nomorKontakDarurat,
        },
      );

      debugPrint(" Update Profile Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          debugPrint(" Profile updated successfully!");
          return {
            "success": true,
            "message": responseData['message'] ?? "Profil berhasil diupdate",
            "data": responseData['data'],
          };
        } else {
          return {
            "success": false,
            "message": responseData['message'] ?? "Failed to update profile"
          };
        }
      } else {
        debugPrint(" HTTP Error ${response.statusCode}");
        return {"success": false, "message": "Failed to update profile"};
      }
    } catch (e) {
      debugPrint(" Update Profile Error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}

