import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'background_steps_tracker.dart';

/// Service latar depan untuk pelacakan langkah.
///
/// Berjalan sebagai foreground service (Android) sehingga proses aplikasi
/// tidak dimatikan oleh sistem. Isolate background menjalankan
/// `BackgroundStepsTracker` untuk membaca sensor langkah, menyimpan ke
/// SQLite, lalu sinkron ke backend.
///
/// PENTING: Hanya foreground service isolate yang mendengarkan pedometer.
/// Main isolate TIDAK boleh memanggil `BackgroundStepsTracker.initialize()`.
///
/// Foreground service bersifat OPTIONAL  jika gagal start (mis. Android 16
/// restriction), app tetap jalan tanpa background tracking.
class StepForegroundService {
  static const String channelId = 'step_tracker_channel';
  static const String channelName = 'Pelacak Langkah';
  static const int notificationId = 112233;
  static bool _configured = false;
  static bool _available = true;

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Daftarkan service (panggil SEKALI saat aplikasi dimulai).
  static Future<void> initialize() async {
    if (_configured) return;
    _configured = true;
    if (!_supported) {
      debugPrint(' Step foreground service tidak didukung di platform ini');
      return;
    }

    try {
      final service = FlutterBackgroundService();
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: stepTrackerServiceHandler,
          autoStart: false,
          autoStartOnBoot: true,
          isForegroundMode: true,
          foregroundServiceTypes: const [AndroidForegroundType.health],
          notificationChannelId: channelId,
          foregroundServiceNotificationId: notificationId,
          initialNotificationTitle: channelName,
          initialNotificationContent:
              'Langkahmu sedang dihitung di latar belakang',
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: (instance) async {},
          onBackground: (instance) async {
            final granted =
                await BackgroundStepsTracker.isStepPermissionGranted(safeForBackground: true);
            if (!granted) return true;
            await BackgroundStepsTracker.initialize(requestPermission: false);
            await BackgroundStepsTracker.syncNow();
            return true;
          },
        ),
      );
      debugPrint(' Foreground service configured');
    } catch (e) {
      debugPrint(' Error configuring foreground service: $e');
      _available = false;
    }
  }

  /// Mulai service latar depan.
  ///
  /// Mengembalikan `true` jika service berhasil dimulai atau tidak didukung.
  /// Mengembalikan `false` jika gagal (app tetap jalan tanpa background
  /// tracking).
  static Future<bool> start() async {
    if (!_supported) return true;
    if (!_available) {
      debugPrint(' Foreground service unavailable, skipping');
      return true; // App tetap jalan
    }

    try {
      // Pastikan ijin sudah diberikan sebelum memulai service latar depan
      final granted = await BackgroundStepsTracker.isStepPermissionGranted();
      if (!granted) {
        debugPrint(' Cannot start foreground service: Activity Recognition permission not granted');
        return false;
      }

      await initialize();
      if (!_available) return true;

      final service = FlutterBackgroundService();
      final running = await service.isRunning();
      if (running) {
        debugPrint(' Step foreground service sudah berjalan');
        return true;
      }

      debugPrint(' Starting step foreground service...');
      await service.startService();
      return true;
    } catch (e) {
      debugPrint(' Error starting foreground service: $e');
      _available = false;
      return true; // App tetap jalan tanpa foreground service
    }
  }

  /// Hentikan service (dipanggil saat logout).
  static Future<void> stop() async {
    if (!_supported || !_available) return;
    try {
      final service = FlutterBackgroundService();
      service.invoke('stopService');
      debugPrint(' Step foreground service stopped');
    } catch (e) {
      debugPrint(' Error stopping step foreground service: $e');
    }
  }

  /// Cek apakah service sedang berjalan.
  static Future<bool> isRunning() async {
    if (!_available) return false;
    try {
      return await FlutterBackgroundService().isRunning();
    } catch (e) {
      return false;
    }
  }
}

/// Handler yang berjalan di isolate latar belakang.
///
///  JANGAN panggil permission_handler di sini!
///    permission_handler butuh Activity context yang hanya ada di main isolate.
///    Permission sudah di-grant oleh main isolate sebelum service start.
@pragma('vm:entry-point')
Future<void> stepTrackerServiceHandler(ServiceInstance service) async {
  debugPrint(' Step foreground service handler started');

  // Set foreground notification DULU (sebelum apapun)
  if (service is AndroidServiceInstance) {
    try {
      await service.setAsForegroundService();
      await service.setForegroundNotificationInfo(
        title: StepForegroundService.channelName,
        content: 'Langkahmu sedang dihitung di latar belakang',
      );
    } catch (e) {
      debugPrint(' Error setting notification info: $e');
    }
  }

  // Relay data langkah dari background  main isolate
  BackgroundStepsTracker.onStepsUpdate = (int steps, String date) {
    try {
      service.invoke('onStepsUpdate', {
        'steps': steps,
        'date': date,
      });
    } catch (_) {}
  };

  // Cek permission dari SharedPreferences (hindari permission_handler di background isolate)
  try {
    final granted = await BackgroundStepsTracker.isStepPermissionGranted(safeForBackground: true);
    if (!granted) {
      debugPrint(' Activity recognition permission not granted in background');
    }
  } catch (e) {
    debugPrint(' Error checking permission in background: $e');
  }

  // Initialize tracker (requestPermission: false karena permission sudah di-grant)
  try {
    await BackgroundStepsTracker.initialize(requestPermission: false);
  } catch (e) {
    debugPrint(' Error initializing tracker in background: $e');
  }

  // Dengarkan perintah berhenti
  service.on('stopService').listen((args) async {
    debugPrint(' Stop command received, stopping tracker...');
    try {
      await BackgroundStepsTracker.stop();
    } catch (_) {}
    service.stopSelf();
  });

  // Dengarkan perintah sync manual dari UI
  service.on('syncNow').listen((args) async {
    debugPrint(' Manual sync requested');
    try {
      await BackgroundStepsTracker.syncNow();
    } catch (_) {}
  });
}
