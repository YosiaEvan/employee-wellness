import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/module_section_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/sehat/jalan_10000_langkah.dart';
import 'package:employee_wellness/pages/sehat/minum_air_8_gelas.dart';
import 'package:employee_wellness/pages/sehat/pola_makan_sehat.dart';
import 'package:employee_wellness/pages/sehat/sinar_matahari.dart';
import 'package:employee_wellness/pages/sehat/tidur_cukup.dart';
import 'package:employee_wellness/pages/sehat/udara_segar.dart';
import 'package:employee_wellness/pages/sehat/sehat_kpi_dashboard.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SehatHomepage extends StatelessWidget {
  const SehatHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xfffdf2f5).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xfff44336),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ResponsiveContainer(
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SizedBox.square(
                        dimension: 40,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(loc.translate('sehat_title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis),
                          Text(loc.translate('sehat_subtitle'), style: const TextStyle(fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SehatKPIDashboard()),
                        );
                      },
                      child: SizedBox.square(
                        dimension: 40,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const FaIcon(FontAwesomeIcons.chartLine, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ResponsiveContainer(
                  child: Column(
                    children: [
                      ModuleSectionCard(
                        destination: const SinarMatahari(),
                        backgroundColor: const Color(0xfffff7ed),
                        sectionColor: const Color(0xfffb8f00),
                        icon: FontAwesomeIcons.cloudSun,
                        heading: loc.translate('sun_title'),
                        subHeading: loc.translate('sun_subtitle'),
                        description: loc.translate('sun_desc'),
                        targetText: loc.translate('sun_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const Jalan10000Langkah(),
                        backgroundColor: const Color(0xffecfeff),
                        sectionColor: const Color(0xff1b8cfd),
                        icon: FontAwesomeIcons.shoePrints,
                        heading: loc.translate('steps_title'),
                        subHeading: loc.translate('steps_subtitle'),
                        description: loc.translate('steps_desc'),
                        targetText: loc.translate('steps_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const PolaMakanSehat(),
                        backgroundColor: const Color(0xffeefdf5),
                        sectionColor: const Color(0xff00c368),
                        icon: FontAwesomeIcons.appleWhole,
                        heading: loc.translate('diet_title'),
                        subHeading: loc.translate('diet_subtitle'),
                        description: loc.translate('diet_desc'),
                        targetText: loc.translate('diet_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const UdaraSegar(),
                        backgroundColor: const Color(0xffeefaff),
                        sectionColor: const Color(0xff009bf4),
                        icon: FontAwesomeIcons.wind,
                        heading: loc.translate('breath_title'),
                        subHeading: loc.translate('breath_subtitle'),
                        description: loc.translate('breath_desc'),
                        targetText: loc.translate('breath_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const MinumAir8Gelas(),
                        backgroundColor: const Color(0xffedfaff),
                        sectionColor: const Color(0xff00cbf6),
                        icon: FontAwesomeIcons.glassWater,
                        heading: loc.translate('water_title'),
                        subHeading: loc.translate('water_subtitle'),
                        description: loc.translate('water_desc'),
                        targetText: loc.translate('water_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const TidurCukup(),
                        backgroundColor: const Color(0xfff4f4ff),
                        sectionColor: const Color(0xff715cff),
                        icon: FontAwesomeIcons.moon,
                        heading: loc.translate('sleep_title'),
                        subHeading: loc.translate('sleep_subtitle'),
                        description: loc.translate('sleep_desc'),
                        targetText: loc.translate('sleep_target'),
                      ),
                      const SizedBox(height: 20),
                      _buildAboutCard(context),
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

  Widget _buildAboutCard(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
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
                    color: const Color(0xff00c170),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(FontAwesomeIcons.circleInfo, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('about_sehat'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.translate('about_sehat_desc'),
            softWrap: true,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xff00c170), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(loc.translate('sehat_point1'), softWrap: true)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xff00c170), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(loc.translate('sehat_point2'), softWrap: true)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xff00c170), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(loc.translate('sehat_point3'), softWrap: true)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
