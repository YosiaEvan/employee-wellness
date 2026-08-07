import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'local_database_service.dart';
import 'sehat_kpi_service.dart';

/// Service untuk menyinkronkan data offline (SQLite) ke backend
/// saat koneksi internet tersedia.
class OfflineSyncService {
  static const _storage = FlutterSecureStorage();

  /// Cek koneksi internet
  static Future<bool> hasInternet() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      return false;
    }
  }

  // =====================================================
  // SINKRONISASI SEMUA DATA PENDING
  // =====================================================

  /// Sinkronkan semua tabel yang belum tersinkron ke backend.
  static Future<Map<String, dynamic>> syncAllPending() async {
    if (!await hasInternet()) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet',
        'synced_count': 0,
        'failed_count': 0,
        'total': 0,
      };
    }

    var syncedCount = 0;
    var failedCount = 0;
    var total = 0;

    final results = await Future.wait([
      _syncTable('minum'),
      _syncTable('tidur'),
      _syncTable('sinar_matahari'),
      _syncTable('tarik_napas'),
      _syncTable('makanan'),
      _syncTable('tenang_sessions'),
      _syncTable('stress_checkin'),
      _syncTable('langkah'),
    ]);

    for (final r in results) {
      total += r['total'] as int;
      syncedCount += r['synced'] as int;
      failedCount += r['failed'] as int;
    }

    return {
      'success': true,
      'message': 'Sinkronisasi selesai',
      'synced_count': syncedCount,
      'failed_count': failedCount,
      'total': total,
    };
  }

  /// Sinkronkan semua baris pending di satu tabel
  static Future<Map<String, int>> _syncTable(String table) async {
    try {
      final pending = await LocalDatabaseService.instance.getPending(table);
      var synced = 0;
      var failed = 0;

      for (final row in pending) {
        final ok = await _pushRow(table, row);
        if (ok) {
          synced++;
          await LocalDatabaseService.instance.markSynced(table, row['id'] as int);
        } else {
          failed++;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return {'total': pending.length, 'synced': synced, 'failed': failed};
    } catch (e) {
      print('❌ Error syncing table $table: $e');
      return {'total': 0, 'synced': 0, 'failed': 0};
    }
  }

  /// Push satu baris ke endpoint yang sesuai
  static Future<bool> _pushRow(String table, Map<String, dynamic> row) async {
    try {
      switch (table) {
        case 'minum':
          final res = await ApiService.post('/user/minum', body: {
            'waktu_minum': row['waktu_minum'],
          });
          return _resolve(res.statusCode);

        case 'tidur':
          final res = await ApiService.post('/user/tidur', body: {
            'waktu_tidur': row['waktu_tidur'],
            'waktu_bangun': row['waktu_bangun'],
          });
          return _resolve(res.statusCode);

        case 'sinar_matahari':
          final res = await ApiService.post('/user/sinar-matahari', body: {
            'waktu_selesai': row['waktu_selesai'],
          });
          return _resolve(res.statusCode);

        case 'tarik_napas':
          final res = await ApiService.post('/user/tarik-napas', body: {
            'waktu_selesai': row['waktu_selesai'],
          });
          return _resolve(res.statusCode);

        case 'makanan':
          final res = await ApiService.post('/user/tracking-kalori', body: {
            'id_food_nutrition': row['id_food_nutrition'],
            'jenis_makan': row['jenis_makan'],
            'porsi': row['porsi'],
          });
          return _resolve(res.statusCode);

        case 'tenang_sessions':
          final userId = await _getUserId();
          final res = await ApiService.post('/user/tenang/sessions', body: {
            'user_id': userId,
            'kategori': row['kategori'],
            'sub_kategori': row['sub_kategori'],
            'durasi_detik': row['durasi_detik'],
            'selesai_at': row['selesai_at'],
          });
          return _resolve(res.statusCode);

        case 'stress_checkin':
          final userId = await _getUserId();
          final res = await ApiService.post('/user/tenang/stress-checkin', body: {
            'user_id': userId,
            'stress_level': row['stress_level'],
            'created_at': row['created_at'],
          });
          return _resolve(res.statusCode);

        case 'langkah':
          final result = await SehatKPIService.updateStepsWithDate(
            tanggal: row['tanggal'],
            totalSteps: row['total_steps'],
          );
          return result['success'] == true;

        default:
          return false;
      }
    } catch (e) {
      print('❌ Error pushing row ($table): $e');
      return false;
    }
  }

  static bool _isSuccess(int statusCode) =>
      statusCode == 200 || statusCode == 201;

  /// 4xx artinya ditolak permanen oleh server -> anggap selesai agar tidak
  /// retry selamanya. 5xx/network error -> retry nanti.
  static bool _resolve(int statusCode) {
    if (_isSuccess(statusCode)) return true;
    if (statusCode >= 400 && statusCode < 500) {
      print('⚠️ Pending record ditolak server (status $statusCode), dilewati');
      return true;
    }
    return false;
  }

  // =====================================================
  // AUTO SYNC ON APP START
  // =====================================================

  /// Jalankan sinkronisasi otomatis saat aplikasi dibuka / login
  static Future<void> autoSyncOnAppStart() async {
    try {
      print('🔄 Running offline sync on app start...');
      if (await hasInternet()) {
        final result = await syncAllPending();
        print(
            '📊 Sync result: ${result['message']} (synced: ${result['synced_count']}, failed: ${result['failed_count']})');
      } else {
        print('⚠️ No internet connection, skipping auto sync');
      }
    } catch (e) {
      print('❌ Error in offline auto sync: $e');
    }
  }

  // =====================================================
  // HELPER
  // =====================================================

  /// Ambil user_id dari JWT token (fallback ke email)
  static Future<String?> _getUserId() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decoded = jsonDecode(utf8.decode(base64.decode(normalized)));
          return decoded['id']?.toString() ??
              decoded['user_id']?.toString() ??
              decoded['userId']?.toString() ??
              decoded['sub']?.toString();
        }
      }
    } catch (_) {}
    return null;
  }
}
