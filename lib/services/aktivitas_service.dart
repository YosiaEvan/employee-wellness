import 'dart:convert';
import 'api_service.dart';

/// Service pencatatan aktivitas penilaian SEHAT/TENANG (self-report klik).
/// 1 klik = 1 poin, dengan penegakan cap mingguan di backend (409).
class AktivitasService {
  /// POST /user/aktivitas — catat 1 klik.
  /// Mengembalikan { success, statusCode?, message?, data? }.
  static Future<Map<String, dynamic>> recordAktivitas({
    required String modul,
    required String aktivitas,
    String? tanggal,
    String? deskripsi,
  }) async {
    try {
      final response = await ApiService.post(
        '/user/aktivitas',
        body: {
          'modul': modul,
          'aktivitas': aktivitas,
          if (tanggal != null) 'tanggal': tanggal,
          if (deskripsi != null) 'deskripsi': deskripsi,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      String message = 'Gagal mencatat aktivitas';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': message,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// GET /user/aktivitas?modul=&tanggal= — daftar klik penilaian user.
  static Future<Map<String, dynamic>> getAktivitas({
    required String modul,
    String? tanggal,
  }) async {
    try {
      final qs = tanggal != null ? '&tanggal=$tanggal' : '';
      final response = await ApiService.get('/user/aktivitas?modul=$modul$qs');
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Gagal mengambil aktivitas (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
