// ignore_for_file: use_null_aware_elements
import 'dart:convert';
import '../models/tenang_model.dart';
import 'api_service.dart';
import 'auth_storage.dart';

/// Konstanta kategori & sub-kategori agar tidak typo di seluruh kode
class TenangKategori {
  static const String meditasi = 'meditasi';
  static const String mindfulness = 'mindfulness';
  static const String manajemenStress = 'manajemen_stress';
}

class TenangSubKategori {
  // Meditasi Terpadu
  static const String pernapasanMindful = 'pernapasan_mindful';
  static const String bodyScan = 'body_scan';
  static const String lovingKindness = 'loving_kindness';
  static const String visualisasiPositif = 'visualisasi_positif';

  // Mindfulness & Kesadaran
  static const String pancaIndra = 'panca_indra';
  static const String pernapasan478 = 'pernapasan_4_7_8';
  static const String kesadaranTubuh = 'kesadaran_tubuh';
  static const String momenSekarang = 'momen_sekarang';

  // Manajemen Stress
  static const String teknikPernapasan = 'teknik_pernapasan';
  static const String teknikGrounding = 'teknik_grounding';
  static const String relaksasiOtotProgresif = 'relaksasi_otot_progresif';
  static const String strategiCoping = 'strategi_coping';
}

/// Service utama untuk Modul Tenang
/// Menggunakan ApiService agar token otomatis di-refresh jika expired.
class TenangService {
  // =====================================================
  // DASHBOARD
  // =====================================================

  /// Ambil statistik & riwayat sesi terbaru untuk halaman utama Tenang
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await ApiService.get('/user/tenang/dashboard');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'stats': TenangStats.fromJson(body['data']?['stats'] ?? {}),
          'recent_sessions': (body['data']?['recent_sessions'] as List? ?? [])
              .map((e) => TenangSession.fromJson(e as Map<String, dynamic>))
              .toList(),
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  // =====================================================
  // SESI
  // =====================================================

  /// Catat sesi yang sudah selesai.
  /// Dipanggil dari tiap halaman sesi saat [_onSessionComplete].
  static Future<Map<String, dynamic>> recordSession({
    required String kategori,
    required String subKategori,
    required int durasiDetik,
  }) async {
    try {
      final userId = await _getUserId();

      final response = await ApiService.post(
        '/user/tenang/sessions',
        body: {
          'user_id': userId,
          'kategori': kategori,
          'sub_kategori': subKategori,
          'durasi_detik': durasiDetik,
          'selesai_at': DateTime.now().toIso8601String(),
        },
      );      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Sesi berhasil dicatat',
          'data': body['data'],
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  /// Ambil riwayat sesi user (opsional: filter by kategori & rentang tanggal)
  static Future<Map<String, dynamic>> getSessionHistory({
    String? kategori,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (kategori != null) 'kategori': kategori,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiService.get('/user/tenang/sessions?$query');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final sessions = (body['data'] as List? ?? [])
            .map((e) => TenangSession.fromJson(e as Map<String, dynamic>))
            .toList();
        return {
          'success': true,
          'sessions': sessions,
          'total': body['meta']?['total'] ?? sessions.length,
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  // =====================================================
  // STRESS CHECK-IN
  // =====================================================

  /// Catat level stres user (dari slider di ManajemenStress)
  static Future<Map<String, dynamic>> recordStressLevel({
    required int stressLevel,
  }) async {
    try {
      final userId = await _getUserId();

      final response = await ApiService.post(
        '/user/tenang/stress-checkin',
        body: {
          'user_id': userId,
          'stress_level': stressLevel,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Level stres berhasil dicatat',
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  /// Ambil riwayat stress check-in (opsional: rentang tanggal)
  static Future<Map<String, dynamic>> getStressHistory({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint =
          '/user/tenang/stress-checkin${query.isNotEmpty ? '?$query' : ''}';
      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final checkins = (body['data'] as List? ?? [])
            .map((e) => StressCheckIn.fromJson(e as Map<String, dynamic>))
            .toList();
        return {
          'success': true,
          'checkins': checkins,
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  // =====================================================
  // TARGET KESEHATAN MENTAL
  // =====================================================

  /// Ambil target meditasi harian user
  static Future<Map<String, dynamic>> getGoals() async {
    try {
      final response = await ApiService.get('/user/tenang/goals');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'data': body['data'],
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  /// Update target meditasi / jurnal / rencana manajemen stres
  static Future<Map<String, dynamic>> updateGoals({
    int? dailyMeditationMinutes,
    int? weeklySessionTarget,
    String? stressManagementPlan,
  }) async {
    try {
      final response = await ApiService.put(
        '/user/tenang/goals',
        body: {
          if (dailyMeditationMinutes != null)
            'daily_meditation_minutes': dailyMeditationMinutes,
          if (weeklySessionTarget != null)
            'weekly_session_target': weeklySessionTarget,
          if (stressManagementPlan != null)
            'stress_management_plan': stressManagementPlan,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Target berhasil diperbarui',
        };
      }

      return _errorFromStatus(response.statusCode, response.body);
    } catch (e) {
      return _networkError(e);
    }
  }

  // =====================================================
  // HELPER PRIVATE
  // =====================================================

  static Future<String?> _getUserId() async {
    final prefs = await _getPrefs();
    return prefs['user_id'] ?? prefs['email'];
  }

  static Future<Map<String, String?>> _getPrefs() async {
    // Membaca user_id dari shared preferences via AuthStorage
    final token = await AuthStorage.getToken();
    // Decode JWT payload untuk dapat user_id tanpa import tambahan
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decoded = jsonDecode(utf8.decode(base64.decode(normalized)));
          final userId = decoded['id']?.toString() ??
              decoded['user_id']?.toString() ??
              decoded['userId']?.toString() ??
              decoded['sub']?.toString();
          return {'user_id': userId};
        }
      } catch (_) {}
    }
    return {'user_id': null};
  }

  static Map<String, dynamic> _errorFromStatus(int statusCode, String body) {
    if (statusCode == 401) {
      return {
        'success': false,
        'message': 'Sesi telah berakhir, silakan login kembali',
        'needsReauth': true,
      };
    }
    try {
      final decoded = jsonDecode(body);
      return {
        'success': false,
        'message': decoded['message'] ?? 'Terjadi kesalahan server ($statusCode)',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan server ($statusCode)',
      };
    }
  }

  static Map<String, dynamic> _networkError(dynamic error) => {
        'success': false,
        'message': 'Gagal terhubung ke server: $error',
      };
}
