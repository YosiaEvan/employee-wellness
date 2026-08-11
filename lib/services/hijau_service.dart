import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';
import 'local_database_service.dart';

class HijauService {
  static Future<String?> _getToken() => AuthStorage.getToken();

  static Future<Map<String, dynamic>> _request(String path) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan", "needsReauth": true};
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      }
      return {"success": false};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getHijauData() =>
      _request('/user/hijau');

  static Future<Map<String, dynamic>> getCarbonFootprint({String? startDate, String? endDate}) =>
      _request('/user/hijau');

  static Future<Map<String, dynamic>> recordGreenActivity({
    required String activityType, required String description,
    double? carbonSaved, int? points, String? category,
  }) async {
    final tgl = LocalDatabaseService.todayStr();

    // Simpan ke antrean lokal dulu (agar tidak hilang saat offline).
    int? rowId;
    try {
      rowId = await LocalDatabaseService.instance.insert('aktivitas_poin', {
        'modul': 'hijau',
        'aktivitas': activityType,
        'kategori': category,
        'tanggal': tgl,
        'poin': points ?? 1,
        'deskripsi': description,
        'carbon_saved': carbonSaved,
        'synced': 0,
      });
    } catch (_) {
      rowId = null;
    }

    try {
      final token = await _getToken();
      if (token == null) return {"success": false, "needsReauth": true};
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/hijau'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "activity_type": activityType,
          "description": description,
          "date": DateTime.now().toIso8601String(),
          "kategori": ?category,
          "points": ?points,
          "carbon_saved": ?carbonSaved,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (rowId != null) {
          try {
            await LocalDatabaseService.instance
                .markSynced('aktivitas_poin', rowId);
          } catch (_) {}
        }
        return {"success": true, "data": jsonDecode(response.body)};
      }
      // 4xx: ditolak permanen (cap 409 / 400) -> hapus antrean lokal
      if (rowId != null) {
        try {
          await LocalDatabaseService.instance.delete(
            'aktivitas_poin',
            where: 'id = ?',
            whereArgs: [rowId],
          );
        } catch (_) {}
      }
      String message = "Gagal mencatat aktivitas";
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}
      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": message,
      };
    } catch (e) {
      // Offline / 5xx -> scan tetap tersimpan di antrean lokal
      if (rowId != null) {
        return {
          "success": true,
          "offline": true,
          "message": "Tersimpan, akan disinkronkan saat online",
        };
      }
      return {"success": false, "message": "Error: $e"};
    }
  }
}
