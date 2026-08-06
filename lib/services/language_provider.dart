import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('id', 'ID');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language_code') ?? 'id';
    String countryCode = prefs.getString('country_code') ?? 'ID';
    _currentLocale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  void changeLanguage(Locale locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    notifyListeners();
  }
}
