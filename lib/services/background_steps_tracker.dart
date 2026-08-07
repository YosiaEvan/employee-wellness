import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'steps_sync_service.dart';
import 'langkah_service.dart';

/// Service untuk tracking langkah di background dengan sinkronisasi terpusat
class BackgroundStepsTracker {
  static StreamSubscription<StepCount>? _stepCountSubscription;
  static StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  static final ValueNotifier<int> stepsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<String> statusNotifier = ValueNotifier<String>('Initializing...');

  static int _baselineSteps = 0;
  static String _currentDate = '';
  static Timer? _saveTimer;
  static bool _isInitialized = false;

  static final StepsSyncService _syncService = StepsSyncService.instance;

  static bool get isInitialized => _isInitialized;
  static int get todaySteps => stepsNotifier.value;
  static String get currentDate => _currentDate;

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
      statusNotifier.value = 'Requesting permissions...';

      // 1. Request permissions
      bool hasPermission = await _requestPermissions();
      if (!hasPermission) {
        statusNotifier.value = 'Permission denied';
        print('❌ Activity recognition permission not granted');
        return false;
      }

      // 2. Set current date
      _currentDate = DateTime.now().toIso8601String().split('T')[0];

      // 3. Load today's steps from local storage
      await _loadStoredData();

      // 4. Start listening to pedometer
      await _startListening();

      // 5. Start periodic save timer
      _startPeriodicSave();

      _isInitialized = true;
      print('✅ Background steps tracker initialized. Today: $_currentDate, Steps: ${stepsNotifier.value}');
      return true;
    } catch (e) {
      statusNotifier.value = 'Error: $e';
      print('❌ Error initializing tracker: $e');
      return false;
    }
  }

  static Future<bool> _requestPermissions() async {
    // Android 10+ needs ACTIVITY_RECOGNITION
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) return true;
    
    // Check again in case it was already granted
    return await Permission.activityRecognition.isGranted;
  }

  static Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved steps for today
      int savedSteps = await LangkahService.getTodaySteps();
      stepsNotifier.value = savedSteps;

      // Load baseline
      _baselineSteps = prefs.getInt('baseline_steps_$_currentDate') ?? 0;
      
      print('📊 Loaded steps: $savedSteps, baseline: $_baselineSteps');
    } catch (e) {
      print('❌ Error loading stored data: $e');
    }
  }

  static Future<void> _startListening() async {
    try {
      await _stepCountSubscription?.cancel();
      await _pedestrianStatusSubscription?.cancel();

      statusNotifier.value = 'Connecting to sensors...';

      // Start Step Count Stream
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (error) {
          print('❌ Pedometer error: $error');
          statusNotifier.value = 'Error: $error';
        },
        cancelOnError: false,
      );

      // Start Pedestrian Status Stream
      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        (PedestrianStatus event) {
          statusNotifier.value = event.status;
          print('🚶 Status: ${event.status}');
        },
        onError: (error) {
          print('❌ Status error: $error');
          // Don't overwrite main status if it's just pedestrian status error
        },
        cancelOnError: false,
      );

      print('✅ Pedometer streams active');
    } catch (e) {
      statusNotifier.value = 'Sensor init failed';
      print('❌ Error starting listeners: $e');
    }
  }

  // =====================================================
  // PEDOMETER CALLBACKS
  // =====================================================

  static void _onStepCount(StepCount event) async {
    try {
      final now = DateTime.now().toIso8601String().split('T')[0];
      final rawSteps = event.steps;

      // 1. Handle New Day
      if (now != _currentDate) {
        print('📅 Day changed: $now');
        await _saveStepsToDatabase(); // Save last day data
        
        _currentDate = now;
        _baselineSteps = rawSteps;
        stepsNotifier.value = 0;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('baseline_steps_$_currentDate', _baselineSteps);
        await LangkahService.resetLocalData();
        return;
      }

      // 2. Set Baseline if not set (resilient logic)
      // If _baselineSteps is 0, or rawSteps is less than baseline (reboot)
      if (_baselineSteps <= 0 || rawSteps < _baselineSteps) {
        _baselineSteps = rawSteps - stepsNotifier.value;
        if (_baselineSteps < 0) _baselineSteps = rawSteps;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('baseline_steps_$_currentDate', _baselineSteps);
        print('📏 Baseline set/reset: $_baselineSteps (raw: $rawSteps, saved: ${stepsNotifier.value})');
      }

      // 3. Calculate Steps
      int calculatedSteps = rawSteps - _baselineSteps;

      // 4. Update memory if sensor is ahead, OR adapt baseline if memory is ahead
      if (calculatedSteps > stepsNotifier.value) {
        stepsNotifier.value = calculatedSteps;
        // Periodic save to shared preferences via LangkahService
        await LangkahService.saveTodaySteps(stepsNotifier.value);
      } else if (stepsNotifier.value > calculatedSteps) {
        // Jika data di memori (dari API/Prefs) lebih besar dari sensor,
        // sesuaikan baseline agar hitungan sensor melanjutkan data yang ada.
        _baselineSteps = rawSteps - stepsNotifier.value;
        if (_baselineSteps < 0) _baselineSteps = rawSteps;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('baseline_steps_$_currentDate', _baselineSteps);
        print('📏 Baseline adjusted to match memory: $_baselineSteps (Target: ${stepsNotifier.value})');
      }

    } catch (e) {
      print('❌ Error in _onStepCount: $e');
    }
  }

  // =====================================================
  // SAVE & SYNC
  // =====================================================

  static Future<void> _saveStepsToDatabase() async {
    if (stepsNotifier.value <= 0) return;

    try {
      await LangkahService.saveTodaySteps(stepsNotifier.value);
      await _syncService.saveStepsLocally(
        tanggal: _currentDate,
        totalSteps: stepsNotifier.value,
      );
    } catch (e) {
      print('❌ Save error: $e');
    }
  }

  static void _startPeriodicSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      await _saveStepsToDatabase();
    });
  }

  // =====================================================
  // MANUAL ACTIONS
  // =====================================================

  /// Get sync statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    return await _syncService.getSyncStatistics();
  }

  /// Get unsynced count
  static Future<int> getUnsyncedCount() async {
    return await _syncService.getUnsyncedCount();
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

  /// Update langkah dari sumber eksternal (misal API)
  static void updateStepsExternally(int steps) {
    if (steps > stepsNotifier.value) {
      stepsNotifier.value = steps;
      print('📊 Steps updated externally: $steps');
    }
  }

  // =====================================================
  // STOP TRACKER
  // =====================================================

  static Future<void> stop() async {
    await _saveStepsToDatabase();
    await _stepCountSubscription?.cancel();
    await _pedestrianStatusSubscription?.cancel();
    _saveTimer?.cancel();
    _isInitialized = false;
    statusNotifier.value = 'Stopped';
    print('🛑 Tracker stopped');
  }
}
