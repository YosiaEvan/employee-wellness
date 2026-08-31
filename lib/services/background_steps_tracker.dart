import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_database_service.dart';
import 'sehat_kpi_service.dart';

/// Hasil dari permintaan ijin Activity Recognition.
enum StepPermissionStatus { granted, denied, permanentlyDenied }

/// Service untuk tracking langkah di background dengan SQLite database.
///
/// Hanya boleh dijalankan di SATU isolate (foreground service isolate).
/// Main isolate TIDAK boleh memanggil `initialize()` karena Pedometer
/// menggunakan EventChannel yang hanya bisa didengarkan satu kali.
class BackgroundStepsTracker {
  static StreamSubscription<StepCount>? _stepCountStream;
  static StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  static int _todaySteps = 0;
  static int _baselineSteps = 0;
  static int _accumulatedSteps = 0;
  static int _lastRawSteps = -1;
  static String _currentDate = '';
  static Timer? _syncTimer;
  static Timer? _saveTimer;
  static bool _isInitialized = false;
  static bool _isListening = false;
  static StepPermissionStatus _permissionStatus = StepPermissionStatus.denied;

  /// Callback untuk mengirim data langkah ke parent (mis. foreground service).
  static void Function(int steps, String date)? onStepsUpdate;

  // =====================================================
  // PERMISSIONS
  // =====================================================

  /// Minta ijin Activity Recognition dengan aman (tidak crash).
  static Future<StepPermissionStatus> requestStepPermission() async {
    try {
      // Tampilkan dialog izin jika belum pernah diminta.
      await Permission.activityRecognition.request();
      // Baca status terkini sebagai sumber kebenaran. Penting bagi device yang
      // mengizinkan lewat Settings (mis. Infinix/Android 16): `request()` bisa
      // mengembalikan status lama, sehingga kita verifikasi ulang via `status`.
      final status = await Permission.activityRecognition.status;
      _permissionStatus = switch (status) {
        PermissionStatus.granted ||
        PermissionStatus.limited => StepPermissionStatus.granted,
        PermissionStatus.permanentlyDenied => StepPermissionStatus.permanentlyDenied,
        _ => StepPermissionStatus.denied,
      };
      
      // Save status to SharedPreferences so background isolate can read it safely
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('step_permission_granted', _permissionStatus == StepPermissionStatus.granted);
      } catch (e) {
        debugPrint(' Error saving permission status to SharedPreferences: $e');
      }
      
      debugPrint(' Activity recognition permission: $_permissionStatus');
      return _permissionStatus;
    } catch (e) {
      debugPrint(' Error requesting activity recognition permission: $e');
      _permissionStatus = StepPermissionStatus.denied;
      return _permissionStatus;
    }
  }

  /// Cek status ijin saat ini tanpa menampilkan dialog.
  ///
  /// [safeForBackground] jika true, akan membaca cache status dari SharedPreferences
  /// untuk menghindari crash akibat penggunaan permission_handler di background isolate.
  static Future<bool> isStepPermissionGranted({bool safeForBackground = false}) async {
    if (safeForBackground) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final granted = prefs.getBool('step_permission_granted') ?? false;
        debugPrint(' [Background] Checking cached step permission: $granted');
        return granted;
      } catch (e) {
        debugPrint(' [Background] Error checking cached step permission: $e');
        return false;
      }
    }

    try {
      final granted = await Permission.activityRecognition.isGranted;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('step_permission_granted', granted);
      } catch (_) {}
      return granted;
    } catch (e) {
      debugPrint(' Error checking activity recognition permission: $e');
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
  ///
  /// [requestPermission]  jika true, akan menampilkan dialog izin.
  /// Jika false, hanya cek izin yang sudah ada.
  static Future<bool> initialize({bool requestPermission = true}) async {
    if (_isInitialized) {
      if (_isListening) return true;
      return ensureTracking(safeForBackground: !requestPermission);
    }

    try {
      debugPrint(' Initializing background steps tracker...');

      _currentDate = DateTime.now().toIso8601String().split('T')[0];
      await _loadTodaySteps();

      if (requestPermission) {
        final status = await requestStepPermission();
        if (status != StepPermissionStatus.granted) {
          debugPrint(' Activity recognition permission not granted, tracking paused');
          _isInitialized = true;
          _isListening = false;
          return false;
        }
      } else {
        final granted = await isStepPermissionGranted(safeForBackground: true);
        if (!granted) {
          debugPrint(' Activity recognition permission not granted, tracking paused');
          _isInitialized = true;
          _isListening = false;
          return false;
        }
      }

      await _startListening();
      _startPeriodicSave();
      _startPeriodicSync();
      await _syncToServer();

      _isInitialized = true;
      debugPrint(' Background steps tracker initialized');
      debugPrint(' Today: $_currentDate, Steps: $_todaySteps');

      return true;
    } catch (e) {
      debugPrint(' Error initializing tracker: $e');
      _isInitialized = true;
      return false;
    }
  }

  /// Pastikan tracking aktif (stream pedometer terdaftar).
  static Future<bool> ensureTracking({bool safeForBackground = false}) async {
    if (_isListening) return true;
    try {
      final granted = await isStepPermissionGranted(safeForBackground: safeForBackground);
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
      debugPrint(' Error ensuring tracking: $e');
      return false;
    }
  }

  /// Load today's steps from SQLite
  static Future<void> _loadTodaySteps() async {
    try {
      final localData = await LocalDatabaseService.instance.getLangkah(_currentDate);
      if (localData != null) {
        _todaySteps = localData['total_steps'] ?? 0;
        debugPrint(' Loaded stored steps for today: $_todaySteps');
      } else {
        _todaySteps = 0;
        debugPrint(' No stored steps for today, starting from 0');
      }

      // Load baseline/accumulated dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _baselineSteps = prefs.getInt('baseline_steps_$_currentDate') ?? 0;
      _accumulatedSteps = prefs.getInt('accumulated_steps_$_currentDate') ?? 0;
      _lastRawSteps = prefs.getInt('last_raw_steps_$_currentDate') ?? -1;

      debugPrint(' Baseline: $_baselineSteps, Accumulated: $_accumulatedSteps');
    } catch (e) {
      debugPrint(' Error loading today steps: $e');
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
      debugPrint(' Error saving baseline: $e');
    }
  }

  /// Start listening to pedometer
  static Future<void> _startListening() async {
    try {
      await _stepCountStream?.cancel();
      await _pedestrianStatusStream?.cancel();
      _stepCountStream = null;
      _pedestrianStatusStream = null;

      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      _isListening = true;
      debugPrint(' Started listening to pedometer');
    } catch (e) {
      debugPrint(' Error starting pedometer: $e');
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

      // Date changed
      if (currentDate != _currentDate) {
        debugPrint(' New day detected: $currentDate');
        await _saveStepsToDatabase();
        _currentDate = currentDate;
        _baselineSteps = rawSteps;
        _accumulatedSteps = 0;
        _todaySteps = 0;
        _lastRawSteps = rawSteps;
        await _saveBaseline();
        debugPrint(' Reset for new day, baseline: $_baselineSteps');
        return;
      }

      // Sensor reset (reboot)
      if (_lastRawSteps > rawSteps) {
        debugPrint(' Sensor reset detected (raw decreased). Preserving accumulated steps.');
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
          _accumulatedSteps = _todaySteps;
          _baselineSteps = rawSteps;
        }
        await _saveBaseline();
      }

      final delta = rawSteps - _baselineSteps;
      if (delta < 0) {
        _accumulatedSteps = _todaySteps;
        _baselineSteps = rawSteps;
        await _saveBaseline();
      } else {
        _todaySteps = _accumulatedSteps + delta;
      }

      // Notify parent (foreground service) of update
      onStepsUpdate?.call(_todaySteps, _currentDate);

      debugPrint(' Steps: $_todaySteps (raw: $rawSteps, baseline: $_baselineSteps, acc: $_accumulatedSteps)');
    } catch (e) {
      debugPrint(' Error in _onStepCount: $e');
    }
  }

  static void _onStepCountError(Object error) {
    debugPrint(' Step count error: $error');
  }

  static void _onPedestrianStatusChanged(PedestrianStatus event) {
    debugPrint(' Pedestrian status: ${event.status}');
  }

  static void _onPedestrianStatusError(Object error) {
    debugPrint(' Pedestrian status error: $error');
  }

  // =====================================================
  // SAVE & SYNC
  // =====================================================

  /// Simpan langkah ke SQLite
  static Future<void> _saveStepsToDatabase() async {
    try {
      if (_todaySteps <= 0) return;

      await LocalDatabaseService.instance.upsertLangkah(
        tanggal: _currentDate,
        totalSteps: _todaySteps,
      );

      await _saveBaseline();
      debugPrint(' Saved $_todaySteps steps to database');
    } catch (e) {
      debugPrint(' Error saving steps: $e');
    }
  }

  /// Sync ke server
  static Future<void> _syncToServer() async {
    try {
      if (_todaySteps <= 0) return;

      final result = await SehatKPIService.updateStepsWithDate(
        tanggal: _currentDate,
        totalSteps: _todaySteps,
      );

      if (result['success'] == true) {
        await LocalDatabaseService.instance.markSyncedByDate('langkah', _currentDate);
        debugPrint(' Synced $_todaySteps steps to server');
      }
    } catch (e) {
      debugPrint(' Error syncing steps: $e');
    }
  }

  /// Start periodic save (every 2 minutes)
  static void _startPeriodicSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      debugPrint(' Periodic save triggered');
      await _saveStepsToDatabase();
    });
  }

  /// Start periodic sync (every 30 minutes)
  static void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      debugPrint(' Periodic sync triggered');
      await _saveStepsToDatabase();
      await _syncToServer();
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

  static Future<void> saveNow() async {
    await _saveStepsToDatabase();
  }

  static Future<Map<String, dynamic>> syncNow() async {
    try {
      await _saveStepsToDatabase();
      await _syncToServer();
      return {'success': true, 'message': 'Sync completed'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // =====================================================
  // STOP TRACKER
  // =====================================================

  static Future<void> stop() async {
    try {
      await _saveStepsToDatabase();
      await _stepCountStream?.cancel();
      await _pedestrianStatusStream?.cancel();
      _syncTimer?.cancel();
      _saveTimer?.cancel();

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

      debugPrint(' Background steps tracker stopped');
    } catch (e) {
      debugPrint(' Error stopping tracker: $e');
    }
  }

  // =====================================================
  // CLEANUP
  // =====================================================

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith('baseline_steps_') ||
            key.startsWith('accumulated_steps_') ||
            key.startsWith('last_raw_steps_')) {
          await prefs.remove(key);
        }
      }
      debugPrint(' All steps data cleared');
    } catch (e) {
      debugPrint(' Error clearing data: $e');
    }
  }
}
