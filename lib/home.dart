import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/homepage_indicator.dart';
import 'package:employee_wellness/pages/health_profile.dart';
import 'package:employee_wellness/services/profile_check_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isProfileComplete = false;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    print("🏠 HomePage initState() called");
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    setState(() => isLoadingProfile = true);
    final isComplete = await ProfileCheckService.checkProfileComplete();
    setState(() {
      isProfileComplete = isComplete;
      isLoadingProfile = false;
    });
    print("📊 Profile status - Complete: $isComplete");
  }

  @override
  Widget build(BuildContext context) {
    print("🏠 HomePage build() called");
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Datang!",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Geser untuk menjelajahi program wellness dan temukan yang sesuai dengan kebutuhan Anda.",
                            style: TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
                          ),
                        ],
                      ),
                    ),

                    if (!isLoadingProfile && !isProfileComplete)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HealthProfile()),
                          ).then((_) => _checkProfileCompletion());
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xfffff8ed),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox.square(
                                    dimension: 60,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xfff67200),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.person, size: 36, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Profil Kesehatan", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                        Text("Lengkapi biodata kesehatan Anda", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                        Text("Untuk rekomendasi program yang personal", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Color(0xfff67200)), // ✅
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.circleInfo, size: 12, color: Color(0xfff67200)), // ✅
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Segera lengkapi untuk mendapatkan rekomendasi terbaik",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (isLoadingProfile)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xfff67200)),
                        ),
                      ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Indicator(),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, size: 12, color: Colors.grey),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text("Geser untuk melihat modul lainnya", style: TextStyle(color: Colors.grey)),
                                ),
                                Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}