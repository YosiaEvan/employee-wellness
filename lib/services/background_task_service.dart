import 'package:flutter/foundation.dart';
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
      debugPrint('âœ… Background task service initialized (using Timer)');
    } catch (e) {
      debugPrint('âŒ Error initializing background tasks: $e');
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
          debugPrint('ðŸ”„ Periodic sync task triggered');
          try {
            final syncService = StepsSyncService.instance;
            final result = await syncService.autoSync();
            debugPrint("âœ… Periodic sync completed: ${result['message']}");
            debugPrint("ðŸ“Š Synced: ${result['synced_count']}, Failed: ${result['failed_count']}");
          } catch (e) {
            debugPrint('âŒ Periodic sync error: $e');
          }
        },
      );

      debugPrint('âœ… Periodic sync task registered (every 6 hours)');
    } catch (e) {
      debugPrint('âŒ Error registering periodic sync: $e');
    }
  }

  /// Register one-time sync task (immediate)
  Future<void> registerOneTimeSync() async {
    try {
      debugPrint('ðŸ”„ One-time sync task triggered');
      final syncService = StepsSyncService.instance;
      final result = await syncService.autoSync();
      debugPrint("âœ… One-time sync completed: ${result['message']}");
    } catch (e) {
      debugPrint('âŒ Error in one-time sync: $e');
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
          debugPrint('ðŸ—‘ï¸ Cleanup task triggered');
          try {
            final syncService = StepsSyncService.instance;
            await syncService.cleanupOldData();
            debugPrint("âœ… Cleanup completed");
          } catch (e) {
            debugPrint('âŒ Cleanup error: $e');
          }
        },
      );

      debugPrint('âœ… Cleanup task registered (weekly)');
    } catch (e) {
      debugPrint('âŒ Error registering cleanup task: $e');
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    try {
      _periodicSyncTimer?.cancel();
      _cleanupTimer?.cancel();
      _periodicSyncTimer = null;
      _cleanupTimer = null;
      debugPrint('âœ… All background tasks cancelled');
    } catch (e) {
      debugPrint('âŒ Error cancelling tasks: $e');
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
      debugPrint('âœ… Task $taskName cancelled');
    } catch (e) {
      debugPrint('âŒ Error cancelling task: $e');
    }
  }
}



