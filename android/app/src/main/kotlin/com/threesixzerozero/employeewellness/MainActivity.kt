package com.threesixzerozero.employeewellness

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.employee_wellness/battery"

    // Must match the notificationChannelId used in lib/services/step_foreground_service.dart
    private val STEP_CHANNEL_ID = "step_tracker_channel"
    private val STEP_CHANNEL_NAME = "Pelacak Langkah"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createStepNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isBatterySaverEnabled" -> {
                        result.success(isBatterySaverEnabled())
                    }
                    "openBatteryOptimizationSettings" -> {
                        result.success(openBatteryOptimizationSettings())
                    }
                    "openAutoStartSettings" -> {
                        result.success(openAutoStartSettings())
                    }
                    "openAppBatterySettings" -> {
                        result.success(openAppBatterySettings())
                    }
                    "getDeviceManufacturer" -> {
                        result.success(getDeviceManufacturer())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @SuppressLint("BatteryLife")
    private fun isBatterySaverEnabled(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            powerManager.isPowerSaveMode
        } else {
            false
        }
    }

    @SuppressLint("BatteryLife")
    private fun openBatteryOptimizationSettings(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            true
        } catch (e: Exception) {
            // Fallback: buka general settings
            try {
                val intent = Intent(Settings.ACTION_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun openAppBatterySettings(): Boolean {
        return try {
            val intent = Intent().apply {
                action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                data = Uri.fromParts("package", packageName, null)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun openAutoStartSettings(): Boolean {
        return try {
            // Coba intent spesifik OEM
            val intents = mutableListOf<Intent>()

            // Xiaomi
            intents.add(Intent().apply {
                component = android.content.ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })

            // Huawei
            intents.add(Intent().apply {
                component = android.content.ComponentName(
                    "com.huawei.systemmanager",
                    "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })

            // Vivo
            intents.add(Intent().apply {
                component = android.content.ComponentName(
                    "com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })

            // Oppo / Realme / OnePlus
            intents.add(Intent().apply {
                component = android.content.ComponentName(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.startupapp.StartupAppListActivity"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })

            intents.add(Intent().apply {
                component = android.content.ComponentName(
                    "com.oppo.safe",
                    "com.oppo.safe.permission.startup.StartupAppListActivity"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })

            // Samsung
            intents.add(Intent().apply {
                component = android.content.ComponentName(
                    "com.samsung.android.lool",
                    "com.samsung.android.sm.battery.ui.BatteryActivity"
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })

            // Coba jalankan intent satu per satu
            for (intent in intents) {
                try {
                    startActivity(intent)
                    return true
                } catch (_: Exception) {
                    // Coba intent berikutnya
                }
            }

            // Fallback: buka battery optimization settings
            openBatteryOptimizationSettings()
        } catch (e: Exception) {
            false
        }
    }

    private fun getDeviceManufacturer(): String {
        return Build.MANUFACTURER
    }

    /**
     * Membuat notification channel untuk foreground service langkah.
     *
     * PENTING: flutter_background_service (versi lama) TIDAK membuat channel
     * jika notificationChannelId diset pada konfigurasi, sehingga startForeground
     * melempar CannotPostForegroundServiceNotificationException dan app crash.
     * Channel harus dibuat secara eksplisit di sini dengan id yang sama.
     */
    private fun createStepNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                STEP_CHANNEL_ID,
                STEP_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Notifikasi pelacak langkah berjalan di latar belakang"
                setShowBadge(false)
            }
            getSystemService(Context.NOTIFICATION_SERVICE)
                .let { it as NotificationManager }
                .createNotificationChannel(channel)
        }
    }
}
