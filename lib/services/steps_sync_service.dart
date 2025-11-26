import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/steps_database.dart';
import 'sehat_kpi_service.dart';

/// Service untuk mengelola sinkronisasi data langkah dari lokal ke server
class StepsSyncService {
  static final StepsSyncService instance = StepsSyncService._init();
  static final StepsDatabase _db = StepsDatabase.instance;

  StepsSyncService._init();

  // ====================================kan=================
  // SAVE STEPS LOCALLY
  // =====================================================

  /// Simpan data langkah ke database lokal
  Future<bool> saveStepsLocally({
    required String tanggal,
    required int totalSteps,
  }) async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();

      if (userId == null) {
        print('❌ User ID not found, cannot save steps');
        return false;
      }

      await _db.insertOrUpdateSteps(
        userId: userId,
        tanggal: tanggal,
        totalSteps: totalSteps,
      );

      print('✅ Steps saved locally: $totalSteps steps on $tanggal');
      return true;
    } catch (e) {
      print('❌ Error saving steps locally: $e');
      return false;
    }
  }

  // =====================================================
  // GET LOCAL STEPS
  // =====================================================

  /// Ambil data langkah dari database lokal untuk tanggal tertentu
  Future<Map<String, dynamic>?> getLocalSteps(String tanggal) async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();
      if (userId == null) return null;

      return await _db.getStepsByDate(
        userId: userId,
        tanggal: tanggal,
      );
    } catch (e) {
      print('❌ Error getting local steps: $e');
      return null;
    }
  }

  /// Ambil data langkah untuk range tanggal
  Future<List<Map<String, dynamic>>> getLocalStepsInRange({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();
      if (userId == null) return [];

      return await _db.getStepsInRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('❌ Error getting steps in range: $e');
      return [];
    }
  }

  // =====================================================
  // SYNC TO SERVER
  // =====================================================

  /// Cek koneksi internet
  Future<bool> hasInternet() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
             connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      return false;
    }
  }

  /// Sinkronkan satu record ke server
  Future<bool> syncSingleRecord({
    required String tanggal,
    required int totalSteps,
  }) async {
    try {
      print('🔄 Syncing $tanggal: $totalSteps steps to server...');

      // Call API to update steps
      final result = await SehatKPIService.updateStepsWithDate(
        tanggal: tanggal,
        totalSteps: totalSteps,
      );

      if (result['success'] == true) {
        final userId = await StepsDatabase.getCurrentUserId();
        if (userId != null) {
          // Mark as synced in local DB
          await _db.markAsSynced(userId: userId, tanggal: tanggal);
        }
        print('✅ Synced successfully: $tanggal');
        return true;
      } else {
        print('❌ Failed to sync $tanggal: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error syncing single record: $e');
      return false;
    }
  }

  /// Sinkronkan semua data yang belum disinkronkan
  Future<Map<String, dynamic>> syncAllUnsynced() async {
    try {
      print('📊 Starting sync all unsynced records...');

      // Check internet connection
      if (!await hasInternet()) {
        return {
          'success': false,
          'message': 'Tidak ada koneksi internet',
          'synced_count': 0,
          'failed_count': 0,
          'total': 0,
        };
      }

      final userId = await StepsDatabase.getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'User ID tidak ditemukan',
          'synced_count': 0,
          'failed_count': 0,
          'total': 0,
        };
      }

      // Get all unsynced records
      final unsyncedRecords = await _db.getUnsyncedSteps(userId);

      if (unsyncedRecords.isEmpty) {
        print('✅ No unsynced records found');
        return {
          'success': true,
          'message': 'Tidak ada data yang perlu disinkronkan',
          'synced_count': 0,
          'failed_count': 0,
          'total': 0,
        };
      }

      print('📊 Found ${unsyncedRecords.length} unsynced records');

      int syncedCount = 0;
      int failedCount = 0;
      final syncedDates = <String>[];
      final syncedDetails = <Map<String, dynamic>>[];

      // Sync each record
      for (var record in unsyncedRecords) {
        final tanggal = record['tanggal'] as String;
        final totalSteps = record['total_steps'] as int;

        final success = await syncSingleRecord(
          tanggal: tanggal,
          totalSteps: totalSteps,
        );

        if (success) {
          syncedCount++;
          syncedDates.add(tanggal);
          syncedDetails.add({
            'tanggal': tanggal,
            'total_steps': totalSteps,
          });
        } else {
          failedCount++;
        }

        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('✅ Sync completed: $syncedCount synced, $failedCount failed');

      return {
        'success': syncedCount > 0,
        'message': syncedCount > 0
            ? 'Berhasil sinkronkan $syncedCount dari ${unsyncedRecords.length} record'
            : 'Gagal sinkronkan data',
        'synced_count': syncedCount,
        'failed_count': failedCount,
        'total': unsyncedRecords.length,
        'synced_dates': syncedDates,
        'synced_details': syncedDetails,
      };
    } catch (e) {
      print('❌ Error in syncAllUnsynced: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'synced_count': 0,
        'failed_count': 0,
        'total': 0,
      };
    }
  }

  /// Get data langkah kemarin (untuk notifikasi)
  Future<Map<String, dynamic>?> getYesterdaySteps() async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();
      if (userId == null) return null;

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = yesterday.toIso8601String().split('T')[0];

      final data = await _db.getStepsByDate(
        userId: userId,
        tanggal: yesterdayDate,
      );

      return data;
    } catch (e) {
      print('❌ Error getting yesterday steps: $e');
      return null;
    }
  }

  /// Auto sync - dipanggil saat app start atau periodic
  Future<Map<String, dynamic>> autoSync() async {
    try {
      print('🔄 Auto sync triggered...');

      // Check if has internet
      if (!await hasInternet()) {
        print('⚠️ No internet, skipping auto sync');
        return {
          'success': false,
          'message': 'Tidak ada koneksi internet',
          'synced_count': 0,
          'failed_count': 0,
          'total': 0,
        };
      }

      // Sync all unsynced
      return await syncAllUnsynced();
    } catch (e) {
      print('❌ Error in auto sync: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'synced_count': 0,
        'failed_count': 0,
        'total': 0,
      };
    }
  }

  // =====================================================
  // STATISTICS & INFO
  // =====================================================

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();
      if (userId == null) {
        return {
          'total_records': 0,
          'synced_records': 0,
          'unsynced_records': 0,
        };
      }

      return await _db.getStatistics(userId);
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'total_records': 0,
        'synced_records': 0,
        'unsynced_records': 0,
      };
    }
  }

  /// Get count of unsynced records
  Future<int> getUnsyncedCount() async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();
      if (userId == null) return 0;

      return await _db.getUnsyncedCount(userId);
    } catch (e) {
      print('❌ Error getting unsynced count: $e');
      return 0;
    }
  }

  // =====================================================
  // CLEANUP
  // =====================================================

  /// Cleanup old synced data (older than 90 days)
  Future<void> cleanupOldData() async {
    try {
      final deletedCount = await _db.deleteOldSyncedSteps();
      print('🗑️ Cleaned up $deletedCount old synced records');
    } catch (e) {
      print('❌ Error cleaning up old data: $e');
    }
  }

  /// Clear all user data (for logout)
  Future<void> clearAllUserData() async {
    try {
      final userId = await StepsDatabase.getCurrentUserId();
      if (userId != null) {
        await _db.deleteUserSteps(userId);
        print('✅ All user steps data cleared');
      }
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }
}

