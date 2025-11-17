import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/api_config.dart';
import 'auth_storage.dart';
import 'auth_service.dart';

/// Wrapper untuk HTTP requests dengan auto-refresh token
class ApiService {
  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // Check if connected to any network
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print("⚠️ No network connection");
        return false;
      }

      print("✅ Network connection available");
      // Jika ada network connection, return true
      // Kita tidak bisa guarantee internet access tanpa actual request
      // Jadi lebih baik return true dan biarkan HTTP request yang handle error
      return true;
    } catch (e) {
      print("⚠️ Error checking connectivity: $e");
      // Jika error, assume ada koneksi dan biarkan HTTP request yang handle
      return true;
    }
  }

  /// Handle HTTP errors with user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return "Tidak ada koneksi internet. Pastikan Anda terhubung ke jaringan.";
    } else if (error is TimeoutException) {
      return "Koneksi timeout. Periksa koneksi internet Anda.";
    } else if (error is FormatException) {
      return "Format data tidak valid dari server.";
    } else if (error is http.ClientException) {
      if (error.message.contains('Failed host lookup')) {
        return "Server tidak dapat dijangkau. Periksa koneksi internet Anda.";
      }
      return "Gagal terhubung ke server: ${error.message}";
    }
    return "Terjadi kesalahan: ${error.toString()}";
  }

  /// GET request dengan auto-refresh token
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    // First attempt
    final response = await _makeRequest(
      () async {
        final headers = await _getHeaders(additionalHeaders);
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
        );
      },
    );

    // If 401 (Unauthorized), refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await _refreshTokenAndRetry();
      if (refreshed) {
        // Retry request with new token
        final headers = await _getHeaders(additionalHeaders);
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
        );
      }
    }

    return response;
  }

  /// POST request dengan auto-refresh token
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    // First attempt
    final response = await _makeRequest(
      () async {
        final headers = await _getHeaders(additionalHeaders);
        return await http.post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      },
    );

    // If 401, refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await _refreshTokenAndRetry();
      if (refreshed) {
        // Retry request with new token
        final headers = await _getHeaders(additionalHeaders);
        return await http.post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return response;
  }

  /// PUT request dengan auto-refresh token
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    // First attempt
    final response = await _makeRequest(
      () async {
        final headers = await _getHeaders(additionalHeaders);
        return await http.put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      },
    );

    // If 401, refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await _refreshTokenAndRetry();
      if (refreshed) {
        // Retry request with new token
        final headers = await _getHeaders(additionalHeaders);
        return await http.put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return response;
  }

  /// DELETE request dengan auto-refresh token
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    // First attempt
    final response = await _makeRequest(
      () async {
        final headers = await _getHeaders(additionalHeaders);
        return await http.delete(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
        );
      },
    );

    // If 401, refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await _refreshTokenAndRetry();
      if (refreshed) {
        // Retry request with new token
        final headers = await _getHeaders(additionalHeaders);
        return await http.delete(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
        );
      }
    }

    return response;
  }

  // =====================================================
  // PRIVATE METHODS
  // =====================================================

  /// Get headers dengan token
  static Future<Map<String, String>> _getHeaders(
    Map<String, String>? additionalHeaders,
  ) async {
    final token = await AuthStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };

    // Log headers for debugging (token truncated for security)
    if (token != null) {
      print('🔐 Request headers include: Authorization: Bearer ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No token found - request will be unauthorized');
    }

    return headers;
  }

  /// Make request
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunc,
  ) async {
    try {
      return await requestFunc();
    } catch (e) {
      // Return error response
      return http.Response(
        jsonEncode({
          'success': false,
          'message': 'Network error: $e',
        }),
        500,
      );
    }
  }

  /// Refresh token dan retry
  static Future<bool> _refreshTokenAndRetry() async {
    try {
      print('🔄 Token expired, refreshing...');

      final newToken = await AuthService.refreshToken();

      if (newToken != null) {
        print('✅ Token refreshed successfully');
        return true;
      } else {
        print('❌ Failed to refresh token, credentials not found');
        return false;
      }
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return false;
    }
  }
}
