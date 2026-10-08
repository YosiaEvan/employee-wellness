import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' show Response;
import 'api_service.dart';
import 'local_database_service.dart';
import 'sehat_kpi_service.dart';
import '../components/data_refresh_notifier.dart';

/// Service untuk menyinkronkan data offline (SQLite) ke backend
/// saat koneksi internet tersedia.
class OfflineSyncService {
  static const _storage = FlutterSecureStorage();
  static const _tables = [
    'minum',
    'tidur',
    'sinar_matahari',
    'tarik_napas',
    'makanan',
    'tenang_sessions',
    'stress_checkin',
    'langkah',
    'aktivitas_poin',
  ];
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;
  static Timer? _reconnectTimer;
  static Timer? _retryTimer;
  static Future<Map<String, dynamic>>? _syncTask;
  static final _lifecycleObserver = _OfflineSyncLifecycleObserver();

  /// Retry queued activity automatically when connectivity returns, while the
  /// app is active, and when it resumes after being in the background.
  static void startAutomaticSync() {
    if (_connectivitySubscription != null) return;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          _scheduleSync();
        }
      },
      onError: (Object error) =>
          debugPrint('Connectivity listener error: $error'),
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _retryTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _scheduleSync(),
    );
    _scheduleSync();
  }

  static void stopAutomaticSync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
  }

  static void _scheduleSync() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () async {
      try {
        if (await hasInternet()) await syncAllPending();
      } catch (e) {
        debugPrint('Automatic sync retry failed: $e');
      }
    });
  }

  /// Cek koneksi internet
  static Future<bool> hasInternet() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint(' Error checking connectivity: $e');
      return false;
    }
  }

  // =====================================================
  // SINKRONISASI SEMUA DATA PENDING
  // =====================================================

  /// Sinkronkan semua tabel yang belum tersinkron ke backend.
  static Future<Map<String, dynamic>> syncAllPending() {
    final activeTask = _syncTask;
    if (activeTask != null) return activeTask;
    final task = _performSync();
    late final Future<Map<String, dynamic>> trackedTask;
    trackedTask = task.whenComplete(() {
      if (identical(_syncTask, trackedTask)) _syncTask = null;
    });
    _syncTask = trackedTask;
    return trackedTask;
  }

  static Future<Map<String, dynamic>> _performSync() async {
    if (!await hasInternet()) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet',
        'synced_count': 0,
        'failed_count': 0,
        'rejected_count': 0,
        'total': 0,
      };
    }

    var syncedCount = 0;
    var failedCount = 0;
    var total = 0;

    var rejectedCount = 0;
    final results = await Future.wait(_tables.map(_syncTable));

    for (final r in results) {
      total += r['total'] as int;
      syncedCount += r['synced'] as int;
      failedCount += r['failed'] as int;
      rejectedCount += r['rejected'] as int;
    }

    // Ada data baru tersinkron -> beri sinyal agar UI me-refresh.
    if (syncedCount > 0) {
      DataRefreshNotifier.instance.notifyDataChanged();
    }

    return {
      'success': true,
      'message': 'Sinkronisasi selesai',
      'synced_count': syncedCount,
      'failed_count': failedCount,
      'rejected_count': rejectedCount,
      'total': total,
    };
  }

  /// Sinkronkan semua baris pending di satu tabel
  static Future<Map<String, int>> _syncTable(String table) async {
    try {
      final pending = await LocalDatabaseService.instance.getPending(table);
      var synced = 0;
      var failed = 0;
      var rejected = 0;

      for (final row in pending) {
        final result = await _pushRow(table, row);
        if (result.accepted) {
          synced++;
          await LocalDatabaseService.instance.markSynced(
            table,
            row['id'] as int,
          );
        } else {
          failed++;
          if (result.rejectedReason != null) {
            rejected++;
            await LocalDatabaseService.instance.markRejected(
              table,
              row['id'] as int,
              result.rejectedReason!,
            );
          }
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return {
        'total': pending.length,
        'synced': synced,
        'failed': failed,
        'rejected': rejected,
      };
    } catch (e) {
      debugPrint(' Error syncing table $table: $e');
      return {'total': 0, 'synced': 0, 'failed': 0, 'rejected': 0};
    }
  }

  /// Push satu baris ke endpoint yang sesuai
  static Future<_PushResult> _pushRow(
    String table,
    Map<String, dynamic> row,
  ) async {
    try {
      switch (table) {
        case 'minum':
          final res = await ApiService.post(
            '/user/minum',
            body: {
              'waktu_minum': row['waktu_minum'],
              'tanggal': row['tanggal'],
            },
          );
          return _fromResponse(res);

        case 'tidur':
          final res = await ApiService.post(
            '/user/tidur',
            body: {
              'waktu_tidur': row['waktu_tidur'],
              'waktu_bangun': row['waktu_bangun'],
              'tanggal': row['tanggal'],
            },
          );
          return _fromResponse(res);

        case 'sinar_matahari':
          final res = await ApiService.post(
            '/user/sinar-matahari',
            body: {
              'waktu_selesai': row['waktu_selesai'],
              'tanggal': row['tanggal'],
            },
          );
          return _fromResponse(res);

        case 'tarik_napas':
          final res = await ApiService.post(
            '/user/tarik-napas',
            body: {
              'waktu_selesai': row['waktu_selesai'],
              'tanggal': row['tanggal'],
            },
          );
          return _fromResponse(res);

        case 'makanan':
          final res = await ApiService.post(
            '/user/tracking-kalori',
            body: {
              'id_food_nutrition': row['id_food_nutrition'],
              'jenis_makan': row['jenis_makan'],
              'porsi': row['porsi'],
              'tanggal': row['tanggal'],
            },
          );
          return _fromResponse(res);

        case 'aktivitas_poin':
          // Tanpa minyak/gula/porsi_kalori kini otomatis dari log makanan — jangan sync pending lama, langsung anggap selesai
          if (row['modul'] == 'sehat' &&
              (row['aktivitas'] == 'tanpa_minyak' ||
                  row['aktivitas'] == 'tanpa_gula' ||
                  row['aktivitas'] == 'porsi_kalori')) {
            debugPrint(
              ' Skip offline sync for otomatis ${row['aktivitas']} — dihitung dari makanan',
            );
            return const _PushResult.accepted();
          }
          if (row['modul'] == 'hijau') {
            final res = await ApiService.post(
              '/user/hijau',
              body: {
                'activity_type': row['aktivitas'],
                'description': row['deskripsi'],
                'date': row['tanggal'],
                if (row['kategori'] != null) 'kategori': row['kategori'],
                'points': row['poin'],
                if (row['carbon_saved'] != null)
                  'carbon_saved': row['carbon_saved'],
                // AR verification fields (PromptARHijau §7)
                'metode_verifikasi': row['metode_verifikasi'] ?? 'manual',
                if (row['confidence_score'] != null)
                  'confidence_score': row['confidence_score'],
                if (row['bukti_foto_url'] != null)
                  'bukti_foto_url': row['bukti_foto_url'],
              },
            );
            return _fromResponse(res);
          }
          final res = await ApiService.post(
            '/user/aktivitas',
            body: {
              'modul': row['modul'],
              'aktivitas': row['aktivitas'],
              'tanggal': row['tanggal'],
              if (row['deskripsi'] != null) 'deskripsi': row['deskripsi'],
            },
          );
          return _fromResponse(res);

        case 'tenang_sessions':
          final userId = await _getUserId();
          final res = await ApiService.post(
            '/user/tenang/sessions',
            body: {
              'user_id': userId,
              'kategori': row['kategori'],
              'sub_kategori': row['sub_kategori'],
              'durasi_detik': row['durasi_detik'],
              'selesai_at': row['selesai_at'],
            },
          );
          return _fromResponse(res);

        case 'stress_checkin':
          final userId = await _getUserId();
          final res = await ApiService.post(
            '/user/tenang/stress-checkin',
            body: {
              'user_id': userId,
              'stress_level': row['stress_level'],
              'created_at': row['created_at'],
            },
          );
          return _fromResponse(res);

        case 'langkah':
          final result = await SehatKPIService.updateStepsWithDate(
            tanggal: row['tanggal'],
            totalSteps: row['total_steps'],
          );
          if (result['success'] == true) return const _PushResult.accepted();
          final statusCode = result['statusCode'] as int?;
          return _PushResult.failed(
            rejectedReason:
                statusCode != null && _isPermanentRejection(statusCode)
                ? result['message']?.toString() ?? 'HTTP $statusCode'
                : null,
          );

        default:
          return const _PushResult.failed();
      }
    } catch (e) {
      debugPrint(' Error pushing row ($table): $e');
      return const _PushResult.failed();
    }
  }

  static _PushResult _fromResponse(Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == false) {
          return const _PushResult.failed();
        }
      } catch (_) {}
      return const _PushResult.accepted();
    }
    if (_isPermanentRejection(statusCode)) {
      var message = 'Server menolak data (HTTP $statusCode)';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}
      return _PushResult.failed(rejectedReason: message);
    }
    return const _PushResult.failed();
  }

  static bool _isPermanentRejection(int statusCode) =>
      statusCode == 400 || statusCode == 409 || statusCode == 422;

  // =====================================================
  // AUTO SYNC ON APP START
  // =====================================================

  /// Jalankan sinkronisasi otomatis saat aplikasi dibuka / login
  static Future<void> autoSyncOnAppStart() async {
    try {
      startAutomaticSync();
      if (await hasInternet()) {
        unawaited(
          syncAllPending().then<void>(
            (result) => debugPrint(
              ' Auto sync complete (synced: ${result['synced_count']}, failed: ${result['failed_count']})',
            ),
            onError: (Object error) =>
                debugPrint('Automatic sync failed: $error'),
          ),
        );
      }
    } catch (e) {
      debugPrint(' Error in offline auto sync: $e');
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

class _PushResult {
  final bool accepted;
  final String? rejectedReason;

  const _PushResult.accepted() : accepted = true, rejectedReason = null;
  const _PushResult.failed({this.rejectedReason}) : accepted = false;
}

class _OfflineSyncLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OfflineSyncService._scheduleSync();
    }
  }
}
