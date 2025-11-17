import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/pages/health_profile.dart';
import 'package:employee_wellness/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String namaLengkap = "Employee Wellness";
  String? fotoUrl;
  String? fotoBase64; // Store base64 string
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final result = await UserProfileService.getUserNameAndPhoto();

    if (result['success'] == true) {
      setState(() {
        namaLengkap = result['nama_lengkap'] ?? "Employee Wellness";

        // Check if foto_url is a URL or base64 string
        final foto = result['foto_url'];

        if (foto != null && foto.isNotEmpty) {
          // Check if it's a base64 string (starts with / or data:image)
          if (foto.startsWith('/9j/') ||
              foto.startsWith('iVBOR') ||
              foto.startsWith('data:image')) {
            print("📷 Photo is base64 format");
            // Remove data:image prefix if exists
            fotoBase64 = foto.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '');
          } else if (foto.startsWith('http://') || foto.startsWith('https://')) {
            print("📷 Photo is URL format");
            fotoUrl = foto;
          } else {
            print("📷 Photo format unknown, treating as base64");
            fotoBase64 = foto;
          }
        }

        isLoading = false;
      });

      print("✅ User data loaded:");
      print("   - Name: $namaLengkap");
      print("   - Has URL: ${fotoUrl != null}");
      print("   - Has Base64: ${fotoBase64 != null}");
      if (fotoBase64 != null) {
        print("   - Base64 length: ${fotoBase64!.length}");
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    try {
      final response = await http.post(
          Uri.parse("http://10.0.2.2:8000/api/logout"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}",
          }
      );

      if (response.statusCode == 200) {
        await prefs.remove("token");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout berhasil")),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage())
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal logout token: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Avatar - Show photo from base64 or URL, otherwise show default icon
              CircleAvatar(
                radius: 20,
                backgroundColor: (fotoBase64 != null || fotoUrl != null)
                    ? Colors.transparent
                    : Colors.grey.withValues(alpha: 0.80),
                backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
                child: fotoBase64 != null
                    ? ClipOval(
                        child: Image.memory(
                          base64Decode(fotoBase64!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("❌ Error loading base64 image: $error");
                            return const Icon(Icons.person, color: Colors.white, size: 24);
                          },
                        ),
                      )
                    : (fotoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 24)
                        : null),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaLengkap,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "Kesehatan & Kebahagiaan Karyawan",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                  ),
                ],
              ),

              const SizedBox(width: 10),

              PopupMenuButton<String>(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 50),
                onSelected: (value) {
                  if (value == 'profile') {
                    // Navigate to Health Profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HealthProfile()),
                    ).then((_) {
                      // Refresh user data when returning from profile page
                      _loadUserData();
                    });
                  } else if (value == 'logout') {
                    logout(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: SizedBox(
                      width: 191,
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.circleUser, size: 20, color: Colors.blue),
                          SizedBox(width: 12),
                          Text("Profil Kesehatan"),
                        ],
                      ),
                    )
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: SizedBox(
                      width: 191,
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 12),
                          Text("Keluar"),
                        ],
                      ),
                    )
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
