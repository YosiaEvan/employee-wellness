import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'steps_sync_service.dart';

/// Hasil dari permintaan ijin Activity Recognition.
enum StepPermissionStatus { granted, denied, permanentlyDenied }

/// Service untuk tracking langkah di background dengan SQLite database
class BackgroundStepsTracker {
  static StreamSubscription<StepCount>? _stepCountStream;
  static StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  static int _todaySteps = 0;
  static int _baselineSteps = 0; // Baseline untuk hari ini
  static int _accumulatedSteps = 0; // Langkah yang dipertahankan saat sensor reset
  static int _lastRawSteps = -1; // Nilai raw terakhir (untuk deteksi reboot)
  static String _currentDate = '';
  static Timer? _syncTimer;
  static Timer? _saveTimer;
  static bool _isInitialized = false;
  static bool _isListening = false;
  static StepPermissionStatus _permissionStatus = StepPermissionStatus.denied;

  static final StepsSyncService _syncService = StepsSyncService.instance;

  // =====================================================
  // PERMISSIONS
  // =====================================================

  /// Minta ijin Activity Recognition dengan aman (tidak crash).
  ///
  /// Catatan: `ignoreBatteryOptimizations` TIDAK diminta via `request()`
  /// karena pada sebagian perangkat (termasuk Android 16) intent khusus
  /// tersebut tidak tersedia dan dapat melempar exception yang mematikan app.
  static Future<StepPermissionStatus> requestStepPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      _permissionStatus = switch (status) {
        PermissionStatus.granted ||
        PermissionStatus.limited => StepPermissionStatus.granted,
        PermissionStatus.permanentlyDenied => StepPermissionStatus.permanentlyDenied,
        _ => StepPermissionStatus.denied,
      };
      print('👣 Activity recognition permission: $_permissionStatus');
      return _permissionStatus;
    } catch (e) {
      print('❌ Error requesting activity recognition permission: $e');
      _permissionStatus = StepPermissionStatus.denied;
      return _permissionStatus;
    }
  }

  /// Cek status ijin saat ini tanpa menampilkan dialog.
  static Future<bool> isStepPermissionGranted() async {
    try {
      return await Permission.activityRecognition.isGranted;
    } catch (e) {
      print('❌ Error checking activity recognition permission: $e');
      return false;
    }
  }

  static bool get isPermissionPermanentlyDenied =>
      _permissionStatus == StepPermissionStatus.permanentlyDenied;

  static StepPermissionStatus get permissionStatus => _permissionStatus;

  // =====================================================
  // INITIALIZE TRACKER
  // =====================================================

  /// Inisialisasi pedometer dan mulai tracking.
  static Future<bool> initialize({bool requestPermission = true}) async {
    if (_isInitialized) {
      // Sudah di-initialize, pastikan masih listening bila ijin ada.
      if (_isListening) return true;
      return ensureTracking();
    }

    try {
      print('🚀 Initializing background steps tracker...');

      _currentDate = DateTime.now().toIso8601String().split('T')[0];
      await _loadTodaySteps();

      if (requestPermission) {
        final status = await requestStepPermission();
        if (status != StepPermissionStatus.granted) {
          print('❌ Activity recognition permission not granted, tracking paused');
          _isInitialized = true;
          _isListening = false;
          return false;
        }
      } else {
        final granted = await isStepPermissionGranted();
        if (!granted) {
          print('❌ Activity recognition permission not granted, tracking paused');
          _isInitialized = true;
          _isListening = false;
          return false;
        }
      }

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
      _isInitialized = true;
      return false;
    }
  }

  /// Pastikan tracking aktif (stream pedometer terdaftar).
  /// Aman dipanggil berulang kali.
  static Future<bool> ensureTracking() async {
    if (_isListening) return true;
    try {
      final granted = await isStepPermissionGranted();
      if (!granted) return false;

      if (_currentDate.isEmpty) {
        _currentDate = DateTime.now().toIso8601String().split('T')[0];
      }
      await _loadTodaySteps();
      await _startListening();
      _startPeriodicSave();
      _startPeriodicSync();
      return true;
    } catch (e) {
      print('❌ Error ensuring tracking: $e');
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

      // Load baseline/accumulated dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _baselineSteps = prefs.getInt('baseline_steps_$_currentDate') ?? 0;
      _accumulatedSteps = prefs.getInt('accumulated_steps_$_currentDate') ?? 0;
      _lastRawSteps = prefs.getInt('last_raw_steps_$_currentDate') ?? -1;

      print('📊 Baseline: $_baselineSteps, Accumulated: $_accumulatedSteps');
    } catch (e) {
      print('❌ Error loading today steps: $e');
      _todaySteps = 0;
      _baselineSteps = 0;
      _accumulatedSteps = 0;
      _lastRawSteps = -1;
    }
  }

  /// Simpan baseline/accumulated ke SharedPreferences
  static Future<void> _saveBaseline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('baseline_steps_$_currentDate', _baselineSteps);
      await prefs.setInt('accumulated_steps_$_currentDate', _accumulatedSteps);
      await prefs.setInt('last_raw_steps_$_currentDate', _lastRawSteps);
    } catch (e) {
      print('❌ Error saving baseline: $e');
    }
  }

  /// Start listening to pedometer
  static Future<void> _startListening() async {
    try {
      // Cancel existing streams (hindari double-listener ke EventChannel yang sama)
      await _stepCountStream?.cancel();
      await _pedestrianStatusStream?.cancel();
      _stepCountStream = null;
      _pedestrianStatusStream = null;

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

      _isListening = true;
      print('✅ Started listening to pedometer');
    } catch (e) {
      print('❌ Error starting pedometer: $e');
      _isListening = false;
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
        _accumulatedSteps = 0;
        _todaySteps = 0;
        _lastRawSteps = rawSteps;

        await _saveBaseline();

        print('🔄 Reset for new day, baseline: $_baselineSteps');
        return;
      }

      // Deteksi sensor reset (reboot) saat app hidup
      if (_lastRawSteps > rawSteps) {
        print('⚠️ Sensor reset detected (raw decreased). Preserving accumulated steps.');
        _accumulatedSteps = _todaySteps;
        _baselineSteps = rawSteps;
        await _saveBaseline();
        return;
      }
      _lastRawSteps = rawSteps;

      // Kalibrasi baseline pertama kali
      if (_baselineSteps == 0) {
        final candidate = rawSteps - _todaySteps;
        if (candidate >= 0) {
          _baselineSteps = candidate;
        } else {
          // Sensor sudah reset sebelum event pertama. Pertahankan langkah hari ini.
          _accumulatedSteps = _todaySteps;
          _baselineSteps = rawSteps;
        }
        await _saveBaseline();
      }

      // Hitung langkah hari ini
      final delta = rawSteps - _baselineSteps;
      if (delta < 0) {
        // Baseline masih salah (mis. restart setelah reboot). Rekalibrasi.
        _accumulatedSteps = _todaySteps;
        _baselineSteps = rawSteps;
        await _saveBaseline();
      } else {
        _todaySteps = _accumulatedSteps + delta;
      }

      print('👣 Steps: $_todaySteps (raw: $rawSteps, baseline: $_baselineSteps, acc: $_accumulatedSteps)');

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

      // Persist last raw steps agar deteksi reboot tetap akurat saat app restart
      await _saveBaseline();

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
  static bool get isListening => _isListening;

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
      _accumulatedSteps = 0;
      _lastRawSteps = -1;
      _isInitialized = false;
      _isListening = false;

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
        if (key.startsWith('baseline_steps_') ||
            key.startsWith('accumulated_steps_') ||
            key.startsWith('last_raw_steps_')) {
          await prefs.remove(key);
        }
      }

      print('✅ All steps data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
