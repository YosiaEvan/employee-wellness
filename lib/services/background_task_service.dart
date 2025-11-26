import 'dart:async';
import 'steps_sync_service.dart';

/// Service untuk mengelola background tasks
/// Note: WorkManager removed - using Timer for now
class BackgroundTaskService {
  static final BackgroundTaskService instance = BackgroundTaskService._init();

  BackgroundTaskService._init();

  Timer? _periodicSyncTimer;
  Timer? _cleanupTimer;

  /// Initialize background tasks using Timer
  Future<void> initialize() async {
    try {
      print('✅ Background task service initialized (using Timer)');
    } catch (e) {
      print('❌ Error initializing background tasks: $e');
    }
  }

  /// Register periodic sync task (runs every 6 hours using Timer)
  Future<void> registerPeriodicSync() async {
    try {
      // Cancel existing timer if any
      _periodicSyncTimer?.cancel();

      // Create periodic timer
      _periodicSyncTimer = Timer.periodic(
        const Duration(hours: 6),
        (timer) async {
          print('🔄 Periodic sync task triggered');
          try {
            final syncService = StepsSyncService.instance;
            final result = await syncService.autoSync();
            print("✅ Periodic sync completed: ${result['message']}");
            print("📊 Synced: ${result['synced_count']}, Failed: ${result['failed_count']}");
          } catch (e) {
            print('❌ Periodic sync error: $e');
          }
        },
      );

      print('✅ Periodic sync task registered (every 6 hours)');
    } catch (e) {
      print('❌ Error registering periodic sync: $e');
    }
  }

  /// Register one-time sync task (immediate)
  Future<void> registerOneTimeSync() async {
    try {
      print('🔄 One-time sync task triggered');
      final syncService = StepsSyncService.instance;
      final result = await syncService.autoSync();
      print("✅ One-time sync completed: ${result['message']}");
    } catch (e) {
      print('❌ Error in one-time sync: $e');
    }
  }

  /// Register cleanup task (weekly using Timer)
  Future<void> registerCleanupTask() async {
    try {
      // Cancel existing timer if any
      _cleanupTimer?.cancel();

      // Create periodic timer for cleanup
      _cleanupTimer = Timer.periodic(
        const Duration(days: 7),
        (timer) async {
          print('🗑️ Cleanup task triggered');
          try {
            final syncService = StepsSyncService.instance;
            await syncService.cleanupOldData();
            print("✅ Cleanup completed");
          } catch (e) {
            print('❌ Cleanup error: $e');
          }
        },
      );

      print('✅ Cleanup task registered (weekly)');
    } catch (e) {
      print('❌ Error registering cleanup task: $e');
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    try {
      _periodicSyncTimer?.cancel();
      _cleanupTimer?.cancel();
      _periodicSyncTimer = null;
      _cleanupTimer = null;
      print('✅ All background tasks cancelled');
    } catch (e) {
      print('❌ Error cancelling tasks: $e');
    }
  }

  /// Cancel specific task
  Future<void> cancelTask(String taskName) async {
    try {
      if (taskName == 'syncStepsTask') {
        _periodicSyncTimer?.cancel();
        _periodicSyncTimer = null;
      } else if (taskName == 'cleanupTask') {
        _cleanupTimer?.cancel();
        _cleanupTimer = null;
      }
      print('✅ Task $taskName cancelled');
    } catch (e) {
      print('❌ Error cancelling task: $e');
    }
  }
}



