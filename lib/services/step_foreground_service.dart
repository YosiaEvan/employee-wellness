import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'background_steps_tracker.dart';

/// Service latar depan untuk pelacakan langkah.
///
/// Tujuan: langkah tetap terhitung meski aplikasi ditutup / di-swipe dari
/// recent apps. Service ini berjalan sebagai foreground service (Android)
/// sehingga proses aplikasi tidak dimatikan oleh sistem, dan isolate
/// background menjalankan `BackgroundStepsTracker` untuk tetap membaca
/// sensor langkah, menyimpan ke SQLite, lalu sinkron ke backend.
class StepForegroundService {
  static const String channelId = 'step_tracker_channel';
  static const String channelName = 'Pelacak Langkah';
  static const int notificationId = 112233;
  static bool _configured = false;

  /// Daftarkan service (panggil SEKALI saat aplikasi dimulai).
  static Future<void> initialize() async {
    if (_configured) return;
    _configured = true;

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: stepTrackerServiceHandler,
        autoStart: false,
        // Mulai otomatis lagi setelah perangkat reboot.
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
          await BackgroundStepsTracker.initialize(requestPermission: false);
          await BackgroundStepsTracker.syncNow();
          return true;
        },
      ),
    );
  }

  /// Mulai service latar depan (dipanggil setelah login sukses).
  static Future<void> start() async {
    await initialize();
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    if (running) {
      print('✅ Step foreground service sudah berjalan');
      return;
    }
    print('🚀 Starting step foreground service...');
    await service.startService();
  }

  /// Hentikan service (dipanggil saat logout).
  static Future<void> stop() async {
    try {
      final service = FlutterBackgroundService();
      service.invoke('stopService');
      print('🛑 Step foreground service stopped');
    } catch (e) {
      print('❌ Error stopping step foreground service: $e');
    }
  }

  /// Cek apakah service sedang berjalan.
  static Future<bool> isRunning() async {
    try {
      return await FlutterBackgroundService().isRunning();
    } catch (e) {
      return false;
    }
  }
}

/// Handler yang berjalan di isolate latar belakang.
/// `vm:entry-point` wajib agar isolate dapat memanggil fungsi ini.
@pragma('vm:entry-point')
Future<void> stepTrackerServiceHandler(ServiceInstance service) async {
  print('⚙️ Step foreground service handler started');

  // Pastikan tracking berjalan di isolate background.
  await BackgroundStepsTracker.initialize(requestPermission: false);

  // Dengarkan perintah berhenti.
  service.on('stopService').listen((args) async {
    print('🛑 Stop command received, stopping tracker...');
    await BackgroundStepsTracker.stop();
    service.stopSelf();
  });

  // Kirim notifikasi ke sistem setelah siap (beberapa perangkat memerlukan
  // pemanggilan ini agar foreground service diakui oleh sistem).
  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();
    try {
      await service.setForegroundNotificationInfo(
        title: StepForegroundService.channelName,
        content: 'Langkahmu sedang dihitung di latar belakang',
      );
    } catch (e) {
      print('⚠️ Error setting notification info: $e');
    }
  }

  // Timer fallback sinkronisasi berkala bila tracker belum punya timer.
  Timer.periodic(const Duration(minutes: 30), (_) async {
    await BackgroundStepsTracker.syncNow();
  });
}
