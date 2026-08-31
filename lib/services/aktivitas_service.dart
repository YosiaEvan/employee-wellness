import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service pencatatan aktivitas penilaian SEHAT/TENANG (self-report klik).
/// 1 klik = 1 poin, dengan penegakan cap mingguan di backend (409).
/// Offline-first: klik disimpan ke SQLite lokal dahulu, lalu disinkronkan.
class AktivitasService {
  /// POST /user/aktivitas  catat 1 klik.
  /// Mengembalikan { success, statusCode?, message?, data?, tercapai? }.
  static Future<Map<String, dynamic>> recordAktivitas({
    required String modul,
    required String aktivitas,
    String? tanggal,
    String? deskripsi,
  }) async {
    final tgl = tanggal ?? LocalDatabaseService.todayStr();

    // Simpan ke antrean lokal dulu (agar tidak hilang saat offline).
    int? rowId;
    try {
      rowId = await LocalDatabaseService.instance.insert('aktivitas_poin', {
        'modul': modul,
        'aktivitas': aktivitas,
        'kategori': modul,
        'tanggal': tgl,
        'poin': 1,
        'deskripsi': deskripsi,
        'synced': 0,
      });
    } catch (_) {
      rowId = null;
    }

    try {
      final body = <String, dynamic>{
        'modul': modul,
        'aktivitas': aktivitas,
        'tanggal': tgl,
      };
      if (deskripsi != null) body['deskripsi'] = deskripsi;

      final response = await ApiService.post('/user/aktivitas', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (rowId != null) {
          try {
            await LocalDatabaseService.instance
                .markSynced('aktivitas_poin', rowId);
          } catch (_) {}
        }
        final resBody = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          'success': true,
          'data': resBody['data'],
          'tercapai': resBody['tercapai'] ?? false,
          'message': resBody['message'] ?? 'Aktivitas berhasil dicatat',
        };
      }

      // 4xx: ditolak permanen (cap 409 / aktivitas 400) -> hapus antrean lokal
      if (rowId != null) {
        try {
          await LocalDatabaseService.instance.delete(
            'aktivitas_poin',
            where: 'id = ?',
            whereArgs: [rowId],
          );
        } catch (_) {}
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
      // Offline / 5xx -> klik tetap tersimpan di antrean lokal
      if (rowId != null) {
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          'success': true,
          'offline': true,
          'message': 'Tersimpan, akan disinkronkan saat online',
        };
      }
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// GET /user/aktivitas?modul=&tanggal=  daftar klik penilaian user.
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
