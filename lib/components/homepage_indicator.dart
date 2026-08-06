import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/main_feature.dart';
import 'package:employee_wellness/home.dart';
import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/pages/tenang_homepage.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Indicator extends StatefulWidget {
  const Indicator({super.key});

  @override
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
  final PageController _pageController = PageController();
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return ResponsiveContainer(
      child: Column(
        children: [
          // Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(3, (index) {
              final bool isActive = index == activeIndex;
  
              return GestureDetector(
                onTap: () {
                  setState(() {
                    activeIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF00C951) : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }),
          ),
  
          const SizedBox(height: 20),
  
          SizedBox(
            height: 660,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  activeIndex = index;
                });
              },
              children: [
                // Sehat
                _buildModuleCard(
                  color: const Color(0xFFFEF2F2),
                  icon: Icons.favorite_border_outlined,
                  iconBgColor: Colors.red,
                  title: loc.translate('sehat_title'),
                  subtitle: loc.translate('sehat_subtitle'),
                  welcomeText: loc.translate('sehat_welcome'),
                  description: loc.translate('sehat_desc_full'),
                  arTitle: loc.translate('ar_ready'),
                  arSubtitle: loc.translate('ar_subtitle_sehat'),
                  arIcon: "🥽",
                  arGradient: const [Color(0xFFb047ff), Color(0xFFf5349c)],
                  features: [
                    MainFeature(color: Colors.red, text: loc.translate('fitness_exp')),
                    MainFeature(color: Colors.red, text: loc.translate('realtime_monitor')),
                    MainFeature(color: Colors.red, text: loc.translate('virtual_coach')),
                    MainFeature(color: Colors.red, text: loc.translate('nutrition_guide')),
                  ],
                  buttonText: loc.translate('enter_sehat'),
                  buttonGradient: const [Color(0xFFfa2c37), Color(0xFFf63399)],
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SehatHomepage())),
                ),
                
                // Tenang
                _buildModuleCard(
                  color: const Color(0xFFEFF6FF),
                  icon: FontAwesomeIcons.brain,
                  iconBgColor: Colors.blue,
                  title: loc.translate('tenang_title'),
                  subtitle: loc.translate('tenang_subtitle'),
                  welcomeText: loc.translate('tenang_welcome'),
                  description: loc.translate('tenang_desc_full'),
                  arTitle: loc.translate('tenang_ar_title'),
                  arSubtitle: loc.translate('tenang_ar_subtitle'),
                  arIcon: "🧘‍♂️",
                  arGradient: const [Color(0xFF2e7eff), Color(0xFFac49ff)],
                  features: [
                    MainFeature(color: Colors.blue, text: loc.translate('daily_meditation')),
                    MainFeature(color: Colors.blue, text: loc.translate('online_counseling')),
                    MainFeature(color: Colors.blue, text: loc.translate('stress_management')),
                    MainFeature(color: Colors.blue, text: loc.translate('mood_tracking')),
                  ],
                  buttonText: loc.translate('enter_tenang'),
                  buttonGradient: const [Color(0xFF2a7fff), Color(0xFF00b9db)],
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TenangHomepage())),
                ),
  
                // Hijau
                _buildModuleCard(
                  color: const Color(0xFFf0fdf4),
                  icon: FontAwesomeIcons.leaf,
                  iconBgColor: Colors.green,
                  title: loc.translate('hijau_title'),
                  subtitle: loc.translate('hijau_subtitle'),
                  welcomeText: loc.translate('hijau_welcome'),
                  description: loc.translate('hijau_desc_full'),
                  arTitle: loc.translate('hijau_ar_title'),
                  arSubtitle: loc.translate('tenang_ar_subtitle'), // Using same subtitle for now as placeholder or update if needed
                  arIcon: "🌿",
                  arGradient: const [Color(0xFF00ca52), Color(0xFF00eda2)],
                  features: [
                    MainFeature(color: Colors.green, text: loc.translate('carbon_tracker')),
                    MainFeature(color: Colors.green, text: loc.translate('workplace_tips')),
                    MainFeature(color: Colors.green, text: loc.translate('eco_challenges')),
                    MainFeature(color: Colors.green, text: loc.translate('sustainability_rewards')),
                  ],
                  buttonText: loc.translate('explore_hijau'),
                  buttonGradient: const [Color(0xFF00c84f), Color(0xFF00be7e)],
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HijauHomepage())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required Color color,
    required dynamic icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String welcomeText,
    required String description,
    required String arTitle,
    required String arSubtitle,
    required String arIcon,
    required List<Color> arGradient,
    required List<Widget> features,
    required String buttonText,
    required List<Color> buttonGradient,
    required VoidCallback onPressed,
  }) {
    final loc = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 60,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: icon is IconData 
                      ? Icon(icon, size: 36, color: Colors.white)
                      : FaIcon(icon, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                Text(
                  welcomeText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: arGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    arIcon,
                    style: const TextStyle(
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    arTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    arSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('main_features_label'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: buttonGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
