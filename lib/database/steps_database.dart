import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple database untuk menyimpan data langkah menggunakan SharedPreferences
/// Alternatif sementara sebelum SQLite diimplementasikan
class StepsDatabase {
  static final StepsDatabase instance = StepsDatabase._init();

  StepsDatabase._init();

  static const String _keyPrefix = 'steps_record_';

  // =====================================================
  // INSERT / UPDATE
  // =====================================================

  /// Simpan atau update data langkah untuk user dan tanggal tertentu
  Future<int> insertOrUpdateSteps({
    required String userId,
    required String tanggal,
    required int totalSteps,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyPrefix}${userId}_$tanggal';

      final data = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'user_id': userId,
        'tanggal': tanggal,
        'total_steps': totalSteps,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await prefs.setString(key, jsonEncode(data));
      print('💾 Saved steps: $key -> $totalSteps steps');

      return data['id'] as int;
    } catch (e) {
      print('❌ Error inserting steps: $e');
      rethrow;
    }
  }

  // =====================================================
  // QUERY
  // =====================================================

  /// Ambil data langkah untuk user dan tanggal tertentu
  Future<Map<String, dynamic>?> getStepsByDate({
    required String userId,
    required String tanggal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyPrefix}${userId}_$tanggal';
      final dataStr = prefs.getString(key);

      if (dataStr != null) {
        return jsonDecode(dataStr);
      }
      return null;
    } catch (e) {
      print('❌ Error getting steps: $e');
      return null;
    }
  }

  /// Ambil semua data yang belum disinkronkan untuk user tertentu
  Future<List<Map<String, dynamic>>> getUnsyncedSteps(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final unsyncedSteps = <Map<String, dynamic>>[];

      for (var key in keys) {
        if (key.startsWith('${_keyPrefix}$userId')) {
          final dataStr = prefs.getString(key);
          if (dataStr != null) {
            final data = jsonDecode(dataStr);
            if (data['is_synced'] == 0) {
              unsyncedSteps.add(data);
            }
          }
        }
      }

      // Sort by date
      unsyncedSteps.sort((a, b) =>
        (a['tanggal'] as String).compareTo(b['tanggal'] as String)
      );

      return unsyncedSteps;
    } catch (e) {
      print('❌ Error getting unsynced steps: $e');
      return [];
    }
  }

  /// Ambil data langkah untuk range tanggal tertentu
  Future<List<Map<String, dynamic>>> getStepsInRange({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final stepsInRange = <Map<String, dynamic>>[];

      for (var key in keys) {
        if (key.startsWith('${_keyPrefix}$userId')) {
          final dataStr = prefs.getString(key);
          if (dataStr != null) {
            final data = jsonDecode(dataStr);
            final tanggal = data['tanggal'] as String;

            if (tanggal.compareTo(startDate) >= 0 &&
                tanggal.compareTo(endDate) <= 0) {
              stepsInRange.add(data);
            }
          }
        }
      }

      // Sort by date descending
      stepsInRange.sort((a, b) =>
        (b['tanggal'] as String).compareTo(a['tanggal'] as String)
      );

      return stepsInRange;
    } catch (e) {
      print('❌ Error getting steps in range: $e');
      return [];
    }
  }

  /// Ambil semua data langkah untuk user
  Future<List<Map<String, dynamic>>> getAllSteps(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final allSteps = <Map<String, dynamic>>[];

      for (var key in keys) {
        if (key.startsWith('${_keyPrefix}$userId')) {
          final dataStr = prefs.getString(key);
          if (dataStr != null) {
            allSteps.add(jsonDecode(dataStr));
          }
        }
      }

      // Sort by date descending
      allSteps.sort((a, b) =>
        (b['tanggal'] as String).compareTo(a['tanggal'] as String)
      );

      return allSteps;
    } catch (e) {
      print('❌ Error getting all steps: $e');
      return [];
    }
  }

  // =====================================================
  // UPDATE
  // =====================================================

  /// Mark data sebagai sudah disinkronkan
  Future<int> markAsSynced({
    required String userId,
    required String tanggal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyPrefix}${userId}_$tanggal';
      final dataStr = prefs.getString(key);

      if (dataStr != null) {
        final data = jsonDecode(dataStr);
        data['is_synced'] = 1;
        data['synced_at'] = DateTime.now().toIso8601String();

        await prefs.setString(key, jsonEncode(data));
        print('✅ Marked as synced: $key');
        return 1;
      }
      return 0;
    } catch (e) {
      print('❌ Error marking as synced: $e');
      return 0;
    }
  }

  /// Mark multiple records as synced
  Future<void> markMultipleAsSynced({
    required String userId,
    required List<String> tanggalList,
  }) async {
    for (var tanggal in tanggalList) {
      await markAsSynced(userId: userId, tanggal: tanggal);
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  /// Hapus data langkah untuk user tertentu
  Future<int> deleteUserSteps(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int deleteCount = 0;

      for (var key in keys) {
        if (key.startsWith('${_keyPrefix}$userId')) {
          await prefs.remove(key);
          deleteCount++;
        }
      }

      print('🗑️ Deleted $deleteCount records for user $userId');
      return deleteCount;
    } catch (e) {
      print('❌ Error deleting user steps: $e');
      return 0;
    }
  }

  /// Hapus data yang sudah lama (lebih dari 90 hari dan sudah disinkronkan)
  Future<int> deleteOldSyncedSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final cutoffDateStr = cutoffDate.toIso8601String().split('T')[0];
      int deleteCount = 0;

      for (var key in keys) {
        if (key.startsWith(_keyPrefix)) {
          final dataStr = prefs.getString(key);
          if (dataStr != null) {
            final data = jsonDecode(dataStr);
            final tanggal = data['tanggal'] as String;
            final isSynced = data['is_synced'] as int;

            if (tanggal.compareTo(cutoffDateStr) < 0 && isSynced == 1) {
              await prefs.remove(key);
              deleteCount++;
            }
          }
        }
      }

      print('🗑️ Deleted $deleteCount old synced records');
      return deleteCount;
    } catch (e) {
      print('❌ Error deleting old steps: $e');
      return 0;
    }
  }

  // =====================================================
  // STATISTICS
  // =====================================================

  /// Get total unsynced records count
  Future<int> getUnsyncedCount(String userId) async {
    try {
      final unsyncedSteps = await getUnsyncedSteps(userId);
      return unsyncedSteps.length;
    } catch (e) {
      print('❌ Error getting unsynced count: $e');
      return 0;
    }
  }

  /// Get statistics untuk user
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    try {
      final allSteps = await getAllSteps(userId);
      final unsyncedSteps = await getUnsyncedSteps(userId);

      final syncedCount = allSteps.length - unsyncedSteps.length;

      return {
        'total_records': allSteps.length,
        'synced_records': syncedCount,
        'unsynced_records': unsyncedSteps.length,
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'total_records': 0,
        'synced_records': 0,
        'unsynced_records': 0,
      };
    }
  }

  // =====================================================
  // UTILITY
  // =====================================================

  /// Get current user ID from SharedPreferences
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id') ?? prefs.getString('email');
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Close database (no-op for SharedPreferences)
  Future<void> close() async {
    // No-op for SharedPreferences
  }
}

