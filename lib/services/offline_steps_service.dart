import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sehat_kpi_service.dart';

/// Service untuk menyimpan data langkah offline dan sinkronisasi otomatis
class OfflineStepsService {
  static const _storage = FlutterSecureStorage();
  static const String _stepsPrefix = 'offline_steps_';
  static const String _lastSyncKey = 'last_sync_date';

  // =====================================================
  // SIMPAN LANGKAH HARIAN (OFFLINE)
  // =====================================================

  /// Simpan data langkah untuk tanggal tertentu
  static Future<void> saveSteps({
    required String tanggal, // Format: YYYY-MM-DD
    required int totalSteps,
    int? kaloriTerbakar,
  }) async {
    try {
      final key = '$_stepsPrefix$tanggal';
      final data = {
        'tanggal': tanggal,
        'total_steps': totalSteps,
        'kalori_terbakar': kaloriTerbakar,
        'synced': false,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storage.write(key: key, value: jsonEncode(data));
      print('✅ Steps saved offline for $tanggal: $totalSteps steps');
    } catch (e) {
      print('❌ Error saving steps offline: $e');
    }
  }

  /// Ambil data langkah untuk tanggal tertentu
  static Future<Map<String, dynamic>?> getSteps(String tanggal) async {
    try {
      final key = '$_stepsPrefix$tanggal';
      final data = await _storage.read(key: key);

      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      print('❌ Error getting steps: $e');
      return null;
    }
  }

  /// Ambil semua data langkah yang belum disinkronkan
  static Future<List<Map<String, dynamic>>> getUnsyncedSteps() async {
    try {
      final allKeys = await _storage.readAll();
      final unsyncedSteps = <Map<String, dynamic>>[];

      for (var entry in allKeys.entries) {
        if (entry.key.startsWith(_stepsPrefix)) {
          final data = jsonDecode(entry.value);
          if (data['synced'] == false) {
            unsyncedSteps.add(data);
          }
        }
      }

      return unsyncedSteps;
    } catch (e) {
      print('❌ Error getting unsynced steps: $e');
      return [];
    }
  }

  // =====================================================
  // SINKRONISASI KE SERVER
  // =====================================================

  /// Cek apakah ada koneksi internet
  static Future<bool> hasInternetConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      return false;
    }
  }

  /// Sinkronkan satu data langkah ke server
  static Future<bool> syncStepsToServer(Map<String, dynamic> stepData) async {
    try {
      final tanggal = stepData['tanggal'];
      final totalSteps = stepData['total_steps'];

      print('🔄 Syncing steps for $tanggal: $totalSteps steps');

      final result = await SehatKPIService.updateSteps(totalSteps);

      if (result['success'] == true) {
        // Mark as synced
        await _markAsSynced(tanggal);
        print('✅ Steps synced successfully for $tanggal');
        return true;
      } else {
        print('❌ Failed to sync steps for $tanggal: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error syncing steps: $e');
      return false;
    }
  }

  /// Sinkronkan semua data langkah yang belum disinkronkan
  static Future<Map<String, dynamic>> syncAllUnsyncedSteps() async {
    try {
      // Cek koneksi internet
      if (!await hasInternetConnection()) {
        return {
          'success': false,
          'message': 'Tidak ada koneksi internet',
          'synced_count': 0,
          'failed_count': 0,
        };
      }

      final unsyncedSteps = await getUnsyncedSteps();

      if (unsyncedSteps.isEmpty) {
        return {
          'success': true,
          'message': 'Tidak ada data yang perlu disinkronkan',
          'synced_count': 0,
          'failed_count': 0,
        };
      }

      int syncedCount = 0;
      int failedCount = 0;

      print('📊 Found ${unsyncedSteps.length} unsynced steps records');

      for (var stepData in unsyncedSteps) {
        final success = await syncStepsToServer(stepData);
        if (success) {
          syncedCount++;
        } else {
          failedCount++;
        }
      }

      // Update last sync date
      await _storage.write(
        key: _lastSyncKey,
        value: DateTime.now().toIso8601String(),
      );

      return {
        'success': true,
        'message': 'Sinkronisasi selesai',
        'synced_count': syncedCount,
        'failed_count': failedCount,
        'total': unsyncedSteps.length,
      };
    } catch (e) {
      print('❌ Error syncing all steps: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'synced_count': 0,
        'failed_count': 0,
      };
    }
  }

  /// Mark data sebagai sudah disinkronkan
  static Future<void> _markAsSynced(String tanggal) async {
    try {
      final key = '$_stepsPrefix$tanggal';
      final data = await _storage.read(key: key);

      if (data != null) {
        final stepData = jsonDecode(data);
        stepData['synced'] = true;
        stepData['synced_at'] = DateTime.now().toIso8601String();

        await _storage.write(key: key, value: jsonEncode(stepData));
      }
    } catch (e) {
      print('❌ Error marking as synced: $e');
    }
  }

  /// Get last sync date
  static Future<String?> getLastSyncDate() async {
    try {
      return await _storage.read(key: _lastSyncKey);
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // HAPUS DATA (UNTUK LOGOUT)
  // =====================================================

  /// Hapus semua data langkah offline
  static Future<void> clearAllStepsData() async {
    try {
      final allKeys = await _storage.readAll();

      for (var key in allKeys.keys) {
        if (key.startsWith(_stepsPrefix) || key == _lastSyncKey) {
          await _storage.delete(key: key);
        }
      }

      print('✅ All offline steps data cleared');
    } catch (e) {
      print('❌ Error clearing steps data: $e');
    }
  }

  // =====================================================
  // AUTO SYNC ON APP START
  // =====================================================

  /// Jalankan sinkronisasi otomatis saat aplikasi dibuka
  static Future<void> autoSyncOnAppStart() async {
    try {
      print('🔄 Running auto sync on app start...');

      if (await hasInternetConnection()) {
        final result = await syncAllUnsyncedSteps();
        print('📊 Auto sync result: ${result['message']}');
        print('📊 Synced: ${result['synced_count']}, Failed: ${result['failed_count']}');
      } else {
        print('⚠️ No internet connection, skipping auto sync');
      }
    } catch (e) {
      print('❌ Error in auto sync: $e');
    }
  }
}

