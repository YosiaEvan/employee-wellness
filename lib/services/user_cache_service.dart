import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_service.dart';

class UserCacheService {
  // Singleton pattern
  static final UserCacheService _instance = UserCacheService._internal();
  factory UserCacheService() => _instance;
  UserCacheService._internal();

  // Cache keys
  static const String _cacheKeyName = 'cached_user_name';
  static const String _cacheKeyPhoto = 'cached_user_photo';
  static const String _cacheKeyPhotoType = 'cached_user_photo_type';
  static const String _cacheKeyTimestamp = 'cached_user_timestamp';
  static const int _cacheDurationMinutes = 30;

  // In-memory cache
  String? _cachedName;
  String? _cachedPhotoUrl;
  String? _cachedPhotoBase64;
  DateTime? _cacheTimestamp;
  bool _isLoading = false;

  // Get user data with caching
  Future<Map<String, dynamic>> getUserData({bool forceRefresh = false}) async {
    // If force refresh, clear memory cache
    if (forceRefresh) {
      _cachedName = null;
      _cachedPhotoUrl = null;
      _cachedPhotoBase64 = null;
      _cacheTimestamp = null;
    }

    // Check memory cache first
    if (_cachedName != null && !_isCacheExpired()) {
      print("✅ User data from memory cache");
      return {
        'nama_lengkap': _cachedName,
        'foto_url': _cachedPhotoUrl,
        'foto_base64': _cachedPhotoBase64,
      };
    }

    // Check if already loading
    if (_isLoading) {
      print("⏳ Already loading user data, waiting...");
      // Wait a bit and return current cache
      await Future.delayed(const Duration(milliseconds: 100));
      return {
        'nama_lengkap': _cachedName ?? "Employee Wellness",
        'foto_url': _cachedPhotoUrl,
        'foto_base64': _cachedPhotoBase64,
      };
    }

    _isLoading = true;

    try {
      // Try to load from SharedPreferences
      final cachedData = await _loadFromPreferences();

      if (cachedData != null && !forceRefresh) {
        _cachedName = cachedData['nama_lengkap'];
        _cachedPhotoUrl = cachedData['foto_url'];
        _cachedPhotoBase64 = cachedData['foto_base64'];
        _cacheTimestamp = DateTime.now();
        print("✅ User data from SharedPreferences cache");
        _isLoading = false;
        return cachedData;
      }

      // Fetch from API
      final result = await UserProfileService.getUserNameAndPhoto();

      if (result['success'] == true) {
        final nama = result['nama_lengkap'] ?? "Employee Wellness";
        final foto = result['foto_url'];
        String? photoUrl;
        String? photoBase64;

        if (foto != null && foto.isNotEmpty) {
          if (foto.startsWith('/9j/') ||
              foto.startsWith('iVBOR') ||
              foto.startsWith('data:image')) {
            photoBase64 = foto.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '');
          } else if (foto.startsWith('http://') || foto.startsWith('https://')) {
            photoUrl = foto;
          } else {
            photoBase64 = foto;
          }
        }

        // Save to both memory and preferences
        _cachedName = nama;
        _cachedPhotoUrl = photoUrl;
        _cachedPhotoBase64 = photoBase64;
        _cacheTimestamp = DateTime.now();

        await _saveToPreferences(nama, photoUrl, photoBase64);

        print("✅ User data loaded from API and cached");
        _isLoading = false;

        return {
          'nama_lengkap': nama,
          'foto_url': photoUrl,
          'foto_base64': photoBase64,
        };
      } else {
        _isLoading = false;
        return {
          'nama_lengkap': _cachedName ?? "Employee Wellness",
          'foto_url': _cachedPhotoUrl,
          'foto_base64': _cachedPhotoBase64,
        };
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
      _isLoading = false;
      return {
        'nama_lengkap': _cachedName ?? "Employee Wellness",
        'foto_url': _cachedPhotoUrl,
        'foto_base64': _cachedPhotoBase64,
      };
    }
  }

  bool _isCacheExpired() {
    if (_cacheTimestamp == null) return true;
    final difference = DateTime.now().difference(_cacheTimestamp!).inMinutes;
    return difference > _cacheDurationMinutes;
  }

  Future<Map<String, dynamic>?> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheKeyTimestamp);

      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime).inMinutes;

      if (difference > _cacheDurationMinutes) {
        print("⚠️ Cache expired ($difference minutes old)");
        return null;
      }

      final name = prefs.getString(_cacheKeyName);
      if (name == null) return null;

      final photoType = prefs.getString(_cacheKeyPhotoType);
      final photo = prefs.getString(_cacheKeyPhoto);

      return {
        'nama_lengkap': name,
        'foto_url': photoType == 'url' ? photo : null,
        'foto_base64': photoType == 'base64' ? photo : null,
      };
    } catch (e) {
      print("❌ Error loading from preferences: $e");
      return null;
    }
  }

  Future<void> _saveToPreferences(String name, String? photoUrl, String? photoBase64) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyName, name);
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);

      if (photoUrl != null) {
        await prefs.setString(_cacheKeyPhoto, photoUrl);
        await prefs.setString(_cacheKeyPhotoType, 'url');
      } else if (photoBase64 != null) {
        await prefs.setString(_cacheKeyPhoto, photoBase64);
        await prefs.setString(_cacheKeyPhotoType, 'base64');
      } else {
        await prefs.remove(_cacheKeyPhoto);
        await prefs.remove(_cacheKeyPhotoType);
      }

      print("✅ User data saved to preferences");
    } catch (e) {
      print("❌ Error saving to preferences: $e");
    }
  }

  Future<void> clearCache() async {
    try {
      // Clear memory cache
      _cachedName = null;
      _cachedPhotoUrl = null;
      _cachedPhotoBase64 = null;
      _cacheTimestamp = null;

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyName);
      await prefs.remove(_cacheKeyPhoto);
      await prefs.remove(_cacheKeyPhotoType);
      await prefs.remove(_cacheKeyTimestamp);

      print("✅ User cache cleared");
    } catch (e) {
      print("❌ Error clearing cache: $e");
    }
  }

  // Get cached name immediately (no async)
  String? getCachedName() => _cachedName;

  // Get cached photo URL immediately (no async)
  String? getCachedPhotoUrl() => _cachedPhotoUrl;

  // Get cached photo base64 immediately (no async)
  String? getCachedPhotoBase64() => _cachedPhotoBase64;
}

