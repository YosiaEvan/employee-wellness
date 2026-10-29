import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk mendeteksi dan menangani mode hemat baterai.
///
/// Fitur battery optimization HANYA relevan untuk Android.
/// Semua method mengecek Platform.isAndroid sebelum melakukan apapun
/// sehingga aman dipanggil di iOS tanpa crash.
class BatteryOptimizationService {
  static const _channel = MethodChannel('com.employee_wellness/battery');

  static Future<bool> isBatterySaverEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isBatterySaverEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint(' Error checking battery saver: $e');
      return false;
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      debugPrint(' Error checking battery optimization: $e');
      return false;
    }
  }

  static Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    } catch (e) {
      debugPrint(' Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  static Future<bool> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
      return true;
    } catch (e) {
      debugPrint(' Error opening battery optimization settings: $e');
      return false;
    }
  }

  static Future<bool> openAutoStartSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      await _channel.invokeMethod('openAutoStartSettings');
      return true;
    } catch (e) {
      debugPrint(' Error opening autostart settings: $e');
      return false;
    }
  }

  static Future<bool> openAppBatterySettings() async {
    if (!Platform.isAndroid) return false;
    try {
      await _channel.invokeMethod('openAppBatterySettings');
      return true;
    } catch (e) {
      debugPrint(' Error opening app battery settings: $e');
      return false;
    }
  }

  static Future<bool> ensureBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    final batterySaverActive = await isBatterySaverEnabled();
    final isUnrestricted = await isIgnoringBatteryOptimizations();
    return !batterySaverActive && isUnrestricted;
  }

  static Future<void> showBatterySaverDialog(
    BuildContext context, {
    VoidCallback? onDismissed,
  }) async {
    if (!Platform.isAndroid) return;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.battery_saver, color: Colors.orange, size: 36),
        ),
        title: const Text(
          'Mode Hemat Baterai Aktif',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Perangkat Anda sedang dalam mode hemat baterai. '
              'Ini akan menghentikan pelacakan langkah kaki di latar belakang.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Atur ke "Unrestricted" (Tidak Terbatas)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Langkah tetap terhitung meski app di background',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); onDismissed?.call(); },
            child: const Text('Nanti Saja'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppBatterySettings();
              onDismissed?.call();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Buka Pengaturan'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF30B762)),
          ),
        ],
      ),
    );
  }

  static Future<void> showAutoStartDialog(BuildContext context) async {
    if (!Platform.isAndroid) return;
    try {
      final result = await _channel.invokeMethod<String>('getDeviceManufacturer');
      final manufacturer = result?.toLowerCase() ?? '';
      final needsAutoStart = manufacturer.contains('xiaomi') ||
          manufacturer.contains('huawei') ||
          manufacturer.contains('honor') ||
          manufacturer.contains('vivo') ||
          manufacturer.contains('oppo') ||
          manufacturer.contains('realme') ||
          manufacturer.contains('oneplus');
      if (!needsAutoStart) return;
      if (!context.mounted) return;
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.power_settings_new, color: Colors.red, size: 36),
          ),
          title: const Text(
            'Izin Auto-Start Diperlukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Perangkat $manufacturer memerlukan izin Auto-Start agar aplikasi dapat berjalan di latar belakang.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text('Cara mengatur:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text(
                      '1. Buka Pengaturan\n2. Aplikasi â†’ Kelola Aplikasi\n3. Cari "Employee Wellness"\n4. Aktifkan "Mulai otomatis"',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Lewati'),
            ),
            FilledButton.icon(
              onPressed: () async { Navigator.of(ctx).pop(); await openAutoStartSettings(); },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Buka Pengaturan'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF30B762)),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint(' Error detecting manufacturer: $e');
    }
  }

  /// Cek dan tampilkan dialog jika perlu.
  /// Pada iOS, method ini langsung return tanpa melakukan apapun.
  static Future<void> checkAndGuideIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;
    if (!context.mounted) return;

    final batterySaverActive = await isBatterySaverEnabled();
    if (batterySaverActive && context.mounted) {
      await showBatterySaverDialog(context);
      return;
    }

    final isUnrestricted = await isIgnoringBatteryOptimizations();
    if (!isUnrestricted && context.mounted) {
      final granted = await requestIgnoreBatteryOptimizations();
      if (!granted && context.mounted) {
        await showBatterySaverDialog(context);
      }
    }

    if (context.mounted) {
      await showAutoStartDialog(context);
    }
  }
}
