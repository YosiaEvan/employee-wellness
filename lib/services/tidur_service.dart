import 'dart:convert';
import 'api_service.dart';

/// Service untuk Tidur Cukup
class TidurService {
  /// GET - Cek apakah sudah lapor tidur hari ini
  static Future<Map<String, dynamic>> cekTidurHariIni() async {
    try {
      print("📤 Cek Tidur Hari Ini Request:");
      print("URL: /user/tidur");
      print("🔐 Using Bearer token (auto-refresh if expired)");

      final response = await ApiService.get("/user/tidur");

      print("📥 Cek Tidur Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "sudah_lapor": responseData['sudah_tidur_hari_ini'] ?? false,
          "data": responseData['data_hari_ini'],
          "minggu_ini": responseData['minggu_ini'],
        };
      } else {
        print("❌ HTTP Error ${response.statusCode}");
        return {
          "success": false,
          "sudah_lapor": false,
        };
      }
    } catch (e) {
      print("❌ Cek Tidur Error: $e");
      return {
        "success": false,
        "sudah_lapor": false,
      };
    }
  }

  /// POST - Lapor tidur hari ini
  static Future<Map<String, dynamic>> laporTidur({
    required String jamTidur,
    required String jamBangun,
  }) async {
    try {
      print("📤 Lapor Tidur Request:");
      print("URL: /user/tidur");
      print("🔐 Using Bearer token (auto-refresh if expired)");
      print("🛏️ Jam tidur: $jamTidur");
      print("⏰ Jam bangun: $jamBangun");

      // Convert time strings to timestamps
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));

      // Parse jam tidur (kemarin malam)
      final sleepTimeParts = jamTidur.split(':');
      final sleepTime = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        int.parse(sleepTimeParts[0]),
        int.parse(sleepTimeParts[1]),
      );

      // Parse jam bangun (pagi ini)
      final wakeTimeParts = jamBangun.split(':');
      final wakeTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(wakeTimeParts[0]),
        int.parse(wakeTimeParts[1]),
      );

      print("🛏️ Waktu tidur timestamp: ${sleepTime.toIso8601String()}");
      print("⏰ Waktu bangun timestamp: ${wakeTime.toIso8601String()}");

      final response = await ApiService.post(
        "/user/tidur",
        body: {
          "waktu_tidur": sleepTime.toIso8601String(),
          "waktu_bangun": wakeTime.toIso8601String(),
        },
      );

      print("📥 Lapor Tidur Response: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        return {
          "success": true,
          "message": responseData['message'] ?? "Berhasil mencatat tidur",
          "data": responseData['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal menyimpan data",
        };
      }
    } catch (e) {
      print("❌ Lapor Tidur Error: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}



