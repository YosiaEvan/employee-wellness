import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/homepage_indicator.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/components/wellness_score_card.dart';
import 'package:employee_wellness/pages/health_profile.dart';
import 'package:employee_wellness/services/profile_check_service.dart';
import 'package:employee_wellness/services/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('welcome_title'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.translate('welcome_desc'),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
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
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xfffff8ed),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff67200),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.person, size: 36, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(loc.translate('health_profile_title'), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                          Text(loc.translate('health_profile_subtitle'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                          Text(loc.translate('health_profile_desc'), style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Color(0xfff67200)), // ✅
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.circleInfo, size: 12, color: Color(0xfff67200)), // ✅
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        loc.translate('health_profile_alert'),
                                        style: const TextStyle(fontSize: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xfff67200)),
                          ),
                        ),

                      const WellnessScoreCard(),
  
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            const Indicator(),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back, size: 12, color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(loc.translate('swipe_instruction'), style: const TextStyle(color: Colors.grey)),
                                  ),
                                  const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
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
            ),
          ],
        ),
      ),
    );
  }
}
