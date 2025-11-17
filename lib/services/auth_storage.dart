import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk menyimpan credentials dan token
class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyToken = 'auth_token';
  static const String _keyRememberMe = 'remember_me';

  /// Save credentials (encrypted)
  static Future<void> saveCredentials({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    if (rememberMe) {
      await _storage.write(key: _keyEmail, value: email);
      await _storage.write(key: _keyPassword, value: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, true);
    }
  }

  /// Get saved credentials
  static Future<Map<String, String>?> getCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (!rememberMe) return null;

      final email = await _storage.read(key: _keyEmail);
      final password = await _storage.read(key: _keyPassword);

      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if has saved credentials
  static Future<bool> hasCredentials() async {
    final creds = await getCredentials();
    return creds != null;
  }

  /// Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Clear all auth data
  static Future<void> clearAll() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRememberMe);
  }

  /// Clear token only (keep credentials)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}

