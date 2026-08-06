import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/language_provider.dart';
import '../services/app_localizations.dart';
import '../components/responsive_container.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
