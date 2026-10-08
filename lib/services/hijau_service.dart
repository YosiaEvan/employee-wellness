import 'dart:convert';
import 'api_service.dart';
import 'local_database_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service untuk aktivitas HIJAU (offline-first)
/// Data disimpan ke SQLite lokal terlebih dahulu, lalu disinkronkan ke backend.
class HijauService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;

  /// GET - Ambil aktivitas HIJAU untuk tanggal tertentu
  static Future<Map<String, dynamic>> getHijauData({String? tanggal}) async {
    try {
      final qs = tanggal != null ? '?tanggal=$tanggal' : '';
      final response = await ApiService.get('/user/hijau$qs');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {'success': true, 'data': body};
      }
      return {'success': false, 'message': 'Gagal mengambil data HIJAU'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Alias backward-compatible untuk getHijauData
  static Future<Map<String, dynamic>> getCarbonFootprint({
    String? startDate,
    String? endDate,
  }) => getHijauData(tanggal: startDate);

  /// POST - Catat aktivitas HIJAU ke tabel canonical — dengan verifikasi AR (PromptARHijau §7).
  /// Offline-first: disimpan ke SQLite dulu, lalu disinkronkan.
  /// `metodeVerifikasi`: 'ar_scan' | 'manual' (default manual untuk backward compat)
  /// `confidenceScore`: 0..1 (hanya untuk ar_scan), `buktiFotoUrl`: path/URL foto bukti (opsional, disimpan lokal lalu di-upload saat sync)
  static Future<Map<String, dynamic>> recordGreenActivity({
    required String activityType,
    required String description,
    double? carbonSaved,
    int? points,
    String? category,
    String? metodeVerifikasi,
    double? confidenceScore,
    String? buktiFotoUrl,
  }) async {
    final tgl = LocalDatabaseService.todayStr();
    final metode = metodeVerifikasi == 'ar_scan' ? 'ar_scan' : 'manual';

    // 1. Simpan ke antrean lokal dulu (agar tidak hilang saat offline) — termasuk kolom verifikasi AR
    int? rowId;
    try {
      rowId = await _db.insert('aktivitas_poin', {
        'modul': 'hijau',
        'aktivitas': activityType,
        'kategori': category,
        'tanggal': tgl,
        'poin': points ?? 1,
        'deskripsi': description,
        'carbon_saved': carbonSaved,
        'metode_verifikasi': metode,
        'confidence_score': confidenceScore,
        'bukti_foto_url': buktiFotoUrl,
        'synced': 0,
      });
    } catch (_) {
      // Fallback jika kolom baru belum ada (belum migrasi v5): coba tanpa kolom verifikasi
      try {
        rowId = await _db.insert('aktivitas_poin', {
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
    }

    // 2. Coba push ke server (dengan field verifikasi AR)
    try {
      final body = <String, dynamic>{
        'activity_type': activityType,
        'description': description,
        'date': tgl,
        'metode_verifikasi': metode,
      };
      if (category != null) body['kategori'] = category;
      if (points != null) body['points'] = points;
      if (carbonSaved != null) body['carbon_saved'] = carbonSaved;
      if (confidenceScore != null) body['confidence_score'] = confidenceScore;
      if (buktiFotoUrl != null) body['bukti_foto_url'] = buktiFotoUrl;

      final response = await ApiService.post('/user/hijau', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (rowId != null) {
          try {
            await _db.markSynced('aktivitas_poin', rowId);
          } catch (_) {}
        }
        final body = jsonDecode(response.body);
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          'success': true,
          'data': body['data'],
          'tercapai': body['tercapai'] ?? false,
          'message': body['message'] ?? 'Aktivitas HIJAU berhasil dicatat',
        };
      }

      String message = 'Gagal mencatat aktivitas';
      try {
        final responseData = jsonDecode(response.body);
        message = responseData['message']?.toString() ?? message;
      } catch (_) {}

      // Keep the local record. Validation/cap errors are retained for review;
      // server/network errors stay queued and will be retried automatically.
      if (rowId != null &&
          !const [400, 409, 422].contains(response.statusCode)) {
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          'success': true,
          'offline': true,
          'pending': true,
          'message': 'Tersimpan di perangkat, sinkronisasi akan dicoba kembali',
        };
      }
      if (rowId != null &&
          const [400, 409, 422].contains(response.statusCode)) {
        try {
          await _db.markRejected('aktivitas_poin', rowId, message);
        } catch (_) {}
      }
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': message,
      };
    } catch (e) {
      // Offline -> tetap dianggap berhasil (tersimpan di SQLite)
      if (rowId != null) {
        DataRefreshNotifier.instance.notifyDataChanged();
        return {
          'success': true,
          'offline': true,
          'message': 'Tersimpan offline, akan disinkronkan saat online',
        };
      }
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
