import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'steps_sync_service.dart';

/// Service untuk tracking langkah di background dengan SQLite database
class BackgroundStepsTracker {
  static StreamSubscription<StepCount>? _stepCountStream;
  static StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  static int _todaySteps = 0;
  static int _baselineSteps = 0; // Baseline untuk hari ini
  static String _currentDate = '';
  static Timer? _syncTimer;
  static Timer? _saveTimer;
  static bool _isInitialized = false;

  static final StepsSyncService _syncService = StepsSyncService.instance;

  // =====================================================
  // INITIALIZE TRACKER
  // =====================================================

  /// Inisialisasi pedometer dan mulai tracking
  static Future<bool> initialize() async {
    if (_isInitialized) {
      print('⚠️ Tracker already initialized');
      return true;
    }

    try {
      print('🚀 Initializing background steps tracker...');

      // Request permission
      final permissionStatus = await Permission.activityRecognition.request();

      if (!permissionStatus.isGranted) {
        print('❌ Activity recognition permission denied');
        return false;
      }

      // Get current date
      _currentDate = DateTime.now().toIso8601String().split('T')[0];

      // Load today's steps from local database
      await _loadTodaySteps();

      // Start listening to pedometer
      await _startListening();

      // Start periodic save timer (every 2 minutes)
      _startPeriodicSave();

      // Start periodic sync timer (every 30 minutes)
      _startPeriodicSync();

      // Run initial sync
      _syncService.autoSync();

      _isInitialized = true;
      print('✅ Background steps tracker initialized');
      print('📊 Today: $_currentDate, Steps: $_todaySteps');

      return true;
    } catch (e) {
      print('❌ Error initializing tracker: $e');
      return false;
    }
  }

  /// Load today's steps from database
  static Future<void> _loadTodaySteps() async {
    try {
      final localData = await _syncService.getLocalSteps(_currentDate);

      if (localData != null) {
        _todaySteps = localData['total_steps'] ?? 0;
        print('📊 Loaded stored steps for today: $_todaySteps');
      } else {
        _todaySteps = 0;
        print('📊 No stored steps for today, starting from 0');
      }

      // Load baseline from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _baselineSteps = prefs.getInt('baseline_steps_$_currentDate') ?? 0;

    } catch (e) {
      print('❌ Error loading today steps: $e');
      _todaySteps = 0;
      _baselineSteps = 0;
    }
  }

  /// Start listening to pedometer
  static Future<void> _startListening() async {
    try {
      // Cancel existing streams
      await _stepCountStream?.cancel();
      await _pedestrianStatusStream?.cancel();

      // Listen to step count
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      // Listen to pedestrian status
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      print('✅ Started listening to pedometer');
    } catch (e) {
      print('❌ Error starting pedometer: $e');
    }
  }

  // =====================================================
  // PEDOMETER CALLBACKS
  // =====================================================

  static void _onStepCount(StepCount event) async {
    try {
      final currentDate = DateTime.now().toIso8601String().split('T')[0];
      final rawSteps = event.steps;

      // Check if date changed (new day)
      if (currentDate != _currentDate) {
        print('📅 New day detected: $currentDate');

        // Save yesterday's final steps
        await _saveStepsToDatabase();

        // Reset for new day
        _currentDate = currentDate;
        _baselineSteps = rawSteps;
        _todaySteps = 0;

        // Save baseline
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('baseline_steps_$_currentDate', _baselineSteps);

        print('🔄 Reset for new day, baseline: $_baselineSteps');
        return;
      }

      // Calculate today's steps (raw steps - baseline)
      if (_baselineSteps == 0) {
        // First time today, set baseline
        _baselineSteps = rawSteps - _todaySteps;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('baseline_steps_$_currentDate', _baselineSteps);
      }

      // Update step count
      final calculatedSteps = rawSteps - _baselineSteps;
      if (calculatedSteps >= 0) {
        _todaySteps = calculatedSteps;
      }

      print('👣 Steps: $_todaySteps (raw: $rawSteps, baseline: $_baselineSteps)');

    } catch (e) {
      print('❌ Error in _onStepCount: $e');
    }
  }

  static void _onStepCountError(error) {
    print('❌ Step count error: $error');
  }

  static void _onPedestrianStatusChanged(PedestrianStatus event) {
    print('🚶 Pedestrian status: ${event.status}');
  }

  static void _onPedestrianStatusError(error) {
    print('❌ Pedestrian status error: $error');
  }

  // =====================================================
  // SAVE & SYNC
  // =====================================================

  /// Simpan langkah ke database lokal
  static Future<void> _saveStepsToDatabase() async {
    try {
      if (_todaySteps <= 0) {
        print('⚠️ Skipping save: steps is 0');
        return;
      }

      await _syncService.saveStepsLocally(
        tanggal: _currentDate,
        totalSteps: _todaySteps,
      );

      print('💾 Saved $_todaySteps steps to database');
    } catch (e) {
      print('❌ Error saving steps: $e');
    }
  }

  /// Start periodic save (every 2 minutes)
  static void _startPeriodicSave() {
    _saveTimer?.cancel();

    _saveTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      print('⏰ Periodic save triggered');
      await _saveStepsToDatabase();
    });
  }

  /// Start periodic sync (every 30 minutes)
  static void _startPeriodicSync() {
    _syncTimer?.cancel();

    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      print('⏰ Periodic sync triggered');
      await _syncService.autoSync();
    });
  }

  // =====================================================
  // GETTERS
  // =====================================================

  static int get todaySteps => _todaySteps;
  static String get currentDate => _currentDate;
  static bool get isInitialized => _isInitialized;

  // =====================================================
  // MANUAL ACTIONS
  // =====================================================

  /// Save current steps immediately
  static Future<void> saveNow() async {
    await _saveStepsToDatabase();
  }

  /// Force sync now (manual trigger)
  static Future<Map<String, dynamic>> syncNow() async {
    try {
      // Save current steps first
      await _saveStepsToDatabase();

      // Then sync all unsynced data
      return await _syncService.syncAllUnsynced();
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get sync statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    return await _syncService.getSyncStatistics();
  }

  /// Get unsynced count
  static Future<int> getUnsyncedCount() async {
    return await _syncService.getUnsyncedCount();
  }

  // =====================================================
  // STOP TRACKER
  // =====================================================

  /// Stop tracking (untuk logout)
  static Future<void> stop() async {
    try {
      // Save current steps before stopping
      await _saveStepsToDatabase();

      // Cancel streams
      await _stepCountStream?.cancel();
      await _pedestrianStatusStream?.cancel();

      // Cancel timers
      _syncTimer?.cancel();
      _saveTimer?.cancel();

      // Reset variables
      _stepCountStream = null;
      _pedestrianStatusStream = null;
      _syncTimer = null;
      _saveTimer = null;
      _todaySteps = 0;
      _baselineSteps = 0;
      _isInitialized = false;

      print('✅ Background steps tracker stopped');
    } catch (e) {
      print('❌ Error stopping tracker: $e');
    }
  }

  // =====================================================
  // CLEANUP
  // =====================================================

  /// Clear all user data (for logout)
  static Future<void> clearAllData() async {
    try {
      await _syncService.clearAllUserData();

      // Clear SharedPreferences baseline
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith('baseline_steps_')) {
          await prefs.remove(key);
        }
      }

      print('✅ All steps data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}

