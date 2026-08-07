import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/language_provider.dart';
import '../services/app_localizations.dart';
import '../services/background_steps_tracker.dart';
import '../services/step_foreground_service.dart';
import '../components/responsive_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _bgStepsKey = 'bg_step_tracking_enabled';
  bool _bgStepsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadBgStepsPref();
  }

  Future<void> _loadBgStepsPref() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_bgStepsKey) ?? true;
    if (mounted) setState(() => _bgStepsEnabled = enabled);
  }

  Future<void> _toggleBgSteps(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bgStepsKey, value);
    if (mounted) setState(() => _bgStepsEnabled = value);

    if (value) {
      // Minta ijin aktivitas fisik + notifikasi, lalu mulai service
      await BackgroundStepsTracker.requestStepPermission();
      try {
        await Permission.notification.request();
      } catch (_) {}
      await BackgroundStepsTracker.initialize();
      await StepForegroundService.start();
    } else {
      await StepForegroundService.stop();
      await BackgroundStepsTracker.stop();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '✅ Pelacak langkah latar belakang AKTIF'
                : '⏸️ Pelacak langkah latar belakang dimatikan',
          ),
          backgroundColor: value ? const Color(0xFF00C368) : Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(loc.translate('settings_title')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(loc.translate('language_setting')),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildLanguageItem(
                          context,
                          title: "Bahasa Indonesia",
                          subtitle: "Indonesian",
                          localeCode: 'id',
                          currentLocale: languageProvider.currentLocale.languageCode,
                          onTap: () => languageProvider.changeLanguage(const Locale('id', 'ID')),
                        ),
                        Divider(height: 1, color: Colors.grey.shade100),
                        _buildLanguageItem(
                          context,
                          title: "English",
                          subtitle: "English",
                          localeCode: 'en',
                          currentLocale: languageProvider.currentLocale.languageCode,
                          onTap: () => languageProvider.changeLanguage(const Locale('en', 'US')),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pelacak langkah latar belakang
                  _buildSectionTitle(
                    languageProvider.currentLocale.languageCode == 'id'
                        ? 'Pelacak Langkah Latar Belakang'
                        : 'Background Step Tracker',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _bgStepsEnabled,
                          onChanged: _toggleBgSteps,
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C368).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(FontAwesomeIcons.shoePrints, color: Color(0xFF00C368)),
                          ),
                          title: Text(
                            languageProvider.currentLocale.languageCode == 'id'
                                ? 'Hitung langkah saat aplikasi ditutup'
                                : 'Count steps when the app is closed',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            languageProvider.currentLocale.languageCode == 'id'
                                ? 'Menjalankan service latar depan agar langkah tetap terhitung '
                                    'dan tersinkron meski aplikasi dimatikan.'
                                : 'Runs a foreground service so steps keep being counted and '
                                    'synced even when the app is killed.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          activeColor: const Color(0xFF00C368),
                        ),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FaIcon(FontAwesomeIcons.circleInfo, size: 16, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  languageProvider.currentLocale.languageCode == 'id'
                                      ? 'Setelah dinyalakan, aplikasi menampilkan notifikasi kecil '
                                          '"Pelacak Langkah Aktif" agar Android mengizinkan service '
                                          'terus berjalan di latar belakang.'
                                      : 'Once enabled, the app shows a small "Step Tracker Active" '
                                          'notification so Android allows the service to keep '
                                          'running in the background.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section for Translation feature mentioned by user
                  _buildSectionTitle("Fitur Terjemahan (Translate)"),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.robot, size: 18, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text(
                                languageProvider.currentLocale.languageCode == 'id'
                                  ? "Auto-Translate Konten"
                                  : "Content Auto-Translate",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.currentLocale.languageCode == 'id'
                              ? "Aplikasi akan otomatis menerjemahkan konten dinamis ke bahasa pilihan Anda."
                              : "The app will automatically translate dynamic content to your preferred language.",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            value: true, // Mock value, could be saved in prefs later
                            onChanged: (val) {
                              // Logic to enable/disable translation features
                            },
                            title: Text(
                              languageProvider.currentLocale.languageCode == 'id'
                                ? "Aktifkan Terjemahan AI"
                                : "Enable AI Translation",
                              style: const TextStyle(fontSize: 14)
                            ),
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String localeCode,
    required String currentLocale,
    required VoidCallback onTap,
  }) {
    bool isSelected = localeCode == currentLocale;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          FontAwesomeIcons.language,
          size: 18,
          color: isSelected ? Colors.green : Colors.grey.shade400,
        ),
      ),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? Colors.green.shade700 : Colors.black87,
      )),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
    );
  }
}
