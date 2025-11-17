import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Service untuk tracking Jalan 10.000 Langkah dengan Offline Queue
class LangkahService {
  static const String _lastSyncDateKey = 'last_sync_date';
  static const String _todayStepsKey = 'today_steps';
  static const String _initialStepsKey = 'initial_steps';
  static const String _pendingQueueKey = 'pending_langkah_queue'; // Queue untuk data yang belum terkirim

  /// GET - Ambil data langkah hari ini dari API
  static Future<Map<String, dynamic>> getStatusLangkah() async {
    try {
      print("📤 Get Status Langkah Request:");
      print("URL: /user/langkah");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get("/user/langkah");

      print("📥 Get Status Langkah Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "hari_ini": responseData['hari_ini'],
          "minggu_ini": responseData['minggu_ini'],
        };
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {
          "success": false,
        };
      }
    } catch (e) {
      print("❌ Get Status Langkah Error: $e");
      return {
        "success": false,
      };
    }
  }


  /// Check apakah hari sudah berganti (untuk auto-reset)
  static Future<bool> shouldResetToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncDate = prefs.getString(_lastSyncDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    print("📅 Last sync date: $lastSyncDate");
    print("📅 Today date: $today");

    if (lastSyncDate == null || lastSyncDate != today) {
      print("✅ Hari sudah berganti, perlu reset!");
      return true;
    }

    print("ℹ️ Masih hari yang sama, tidak perlu reset");
    return false;
  }

  /// Simpan tanggal terakhir sync
  static Future<void> saveLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_lastSyncDateKey, today);
    print("💾 Saved last sync date: $today");
  }

  /// Simpan langkah hari ini ke local storage
  static Future<void> saveTodaySteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todayStepsKey, steps);
  }

  /// Ambil langkah hari ini dari local storage
  static Future<int> getTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayStepsKey) ?? 0;
  }

  /// Simpan initial steps (dari sensor saat app pertama buka)
  static Future<void> saveInitialSteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_initialStepsKey, steps);
  }

  /// Ambil initial steps
  static Future<int> getInitialSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_initialStepsKey) ?? 0;
  }

  /// Reset all local data (untuk hari baru)
  static Future<void> resetLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todayStepsKey);
    await prefs.remove(_initialStepsKey);
    print("🔄 Local data reset untuk hari baru");
  }

  /// Simpan data harian ke queue (untuk sync nanti)
  static Future<void> saveDailyRecordToQueue({
    required String tanggal,
    required int jumlahLangkah,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil queue yang ada
    final queueJson = prefs.getString(_pendingQueueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    // Cek apakah tanggal sudah ada di queue
    final existingIndex = queue.indexWhere((item) => item['tanggal'] == tanggal);

    if (existingIndex != -1) {
      // Update data yang sudah ada
      queue[existingIndex] = {
        'tanggal': tanggal,
        'jumlah_langkah': jumlahLangkah,
        'created_at': DateTime.now().toIso8601String(),
      };
      print("📝 Updated existing record in queue: $tanggal -> $jumlahLangkah langkah");
    } else {
      // Tambah record baru
      queue.add({
        'tanggal': tanggal,
        'jumlah_langkah': jumlahLangkah,
        'created_at': DateTime.now().toIso8601String(),
      });
      print("📝 Added new record to queue: $tanggal -> $jumlahLangkah langkah");
    }

    // Simpan kembali ke storage
    await prefs.setString(_pendingQueueKey, jsonEncode(queue));
    print("💾 Queue size: ${queue.length} records");
  }

  /// Ambil semua pending records dari queue
  static Future<List<Map<String, dynamic>>> getPendingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_pendingQueueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    return queue.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /// Hapus record dari queue setelah berhasil di-sync
  static Future<void> removeFromQueue(String tanggal) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_pendingQueueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    // Hapus record dengan tanggal tertentu
    queue.removeWhere((item) => item['tanggal'] == tanggal);

    await prefs.setString(_pendingQueueKey, jsonEncode(queue));
    print("✅ Removed from queue: $tanggal");
  }

  /// Clear seluruh queue
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingQueueKey);
    print("🗑️ Queue cleared");
  }

  /// Sync semua pending records ke API (background process)
  static Future<Map<String, dynamic>> syncPendingRecords() async {
    print("🔄 Starting background sync...");

    final queue = await getPendingQueue();

    if (queue.isEmpty) {
      print("ℹ️ No pending records to sync");
      return {
        "success": true,
        "synced": 0,
        "failed": 0,
      };
    }

    int synced = 0;
    int failed = 0;

    for (var record in queue) {
      final tanggal = record['tanggal'];
      final jumlahLangkah = record['jumlah_langkah'];

      print("📤 Syncing: $tanggal -> $jumlahLangkah langkah");

      try {
        final response = await ApiService.post(
          "/user/langkah",
          body: {
            "jumlah_langkah": jumlahLangkah,
            "tanggal": tanggal,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Berhasil, hapus dari queue
          await removeFromQueue(tanggal);
          synced++;
          print("✅ Synced: $tanggal");
        } else {
          failed++;
          print("❌ Failed to sync: $tanggal (HTTP ${response.statusCode})");
        }
      } catch (e) {
        failed++;
        print("❌ Error syncing $tanggal: $e");
        // Tidak hapus dari queue, akan di-retry nanti
      }
    }

    print("📊 Sync complete: $synced synced, $failed failed");

    return {
      "success": true,
      "synced": synced,
      "failed": failed,
    };
  }

  /// Update langkah hari ini (save ke queue, tidak langsung POST)
  static Future<Map<String, dynamic>> updateLangkahLocal({
    required int jumlahLangkah,
    String? tanggal,
  }) async {
    final date = tanggal ?? DateTime.now().toIso8601String().split('T')[0];

    // Simpan ke queue untuk di-sync nanti
    await saveDailyRecordToQueue(
      tanggal: date,
      jumlahLangkah: jumlahLangkah,
    );

    // Coba sync sekarang jika ada koneksi
    // (akan skip jika tidak ada koneksi, tidak throw error)
    try {
      await syncPendingRecords();
    } catch (e) {
      print("⚠️ Sync failed (no connection?): $e");
      // Tidak masalah, akan di-sync nanti
    }

    return {
      "success": true,
      "message": "Data tersimpan lokal",
    };
  }

  /// POST - Update langkah hari ini ke API (deprecated, gunakan updateLangkahLocal)
  static Future<Map<String, dynamic>> updateLangkah({
    required int jumlahLangkah,
  }) async {
    // Redirect ke updateLangkahLocal untuk offline queue support
    return await updateLangkahLocal(jumlahLangkah: jumlahLangkah);
  }
}
