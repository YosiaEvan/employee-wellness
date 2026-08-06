import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/module_section_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/hijau/hemat_energi.dart';
import 'package:employee_wellness/pages/hijau/hijau_kpi_dashboard.dart';
import 'package:employee_wellness/pages/hijau/zero_waste.dart';
import 'package:employee_wellness/pages/hijau/konservasi_air.dart';
import 'package:employee_wellness/pages/hijau/gaya_hidup_hijau.dart';
import 'package:employee_wellness/pages/hijau/ajak_orang_lain.dart';
import 'package:employee_wellness/pages/hijau/ubah_kebiasaan.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HijauHomepage extends StatelessWidget {
  const HijauHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff059669), Color(0xff34D399)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
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
                        Text(loc.translate('hijau_title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(loc.translate('hijau_subtitle'), style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HijauKPIDashboard()),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ResponsiveContainer(
                  child: Column(
                    children: [
                      ModuleSectionCard(
                        destination: const HematEnergi(),
                        backgroundColor: const Color(0xffecfdf5),
                        sectionColor: const Color(0xff059669),
                        icon: FontAwesomeIcons.bolt,
                        heading: loc.translate('energy_title'),
                        subHeading: loc.translate('energy_subtitle'),
                        description: loc.translate('energy_desc'),
                        targetText: loc.translate('energy_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const ZeroWaste(),
                        backgroundColor: const Color(0xfff0fdf4),
                        sectionColor: const Color(0xff16a34a),
                        icon: FontAwesomeIcons.recycle,
                        heading: loc.translate('waste_title'),
                        subHeading: loc.translate('waste_subtitle'),
                        description: loc.translate('waste_desc'),
                        targetText: loc.translate('waste_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const KonservasiAir(),
                        backgroundColor: const Color(0xfff0f9ff),
                        sectionColor: const Color(0xff0ea5e9),
                        icon: FontAwesomeIcons.droplet,
                        heading: loc.translate('water_cons_title'),
                        subHeading: loc.translate('water_cons_subtitle'),
                        description: loc.translate('water_cons_desc'),
                        targetText: loc.translate('water_cons_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const GayaHidupHijau(),
                        backgroundColor: const Color(0xfff7fee7),
                        sectionColor: const Color(0xff15803d),
                        icon: FontAwesomeIcons.leaf,
                        heading: loc.translate('lifestyle_title'),
                        subHeading: loc.translate('lifestyle_subtitle'),
                        description: loc.translate('lifestyle_desc'),
                        targetText: loc.translate('lifestyle_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const UbahKebiasaan(),
                        backgroundColor: const Color(0xffecfdf5),
                        sectionColor: const Color(0xff10b981),
                        icon: FontAwesomeIcons.arrowsRotate,
                        heading: loc.translate('habit_title'),
                        subHeading: loc.translate('habit_subtitle'),
                        description: loc.translate('habit_desc'),
                        targetText: loc.translate('habit_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const AjakOrangLain(),
                        backgroundColor: const Color(0xfffffbeb),
                        sectionColor: const Color(0xfff59e0b),
                        icon: FontAwesomeIcons.userPlus,
                        heading: loc.translate('invite_title'),
                        subHeading: loc.translate('invite_subtitle'),
                        description: loc.translate('invite_desc'),
                        targetText: loc.translate('invite_target'),
                      ),
                      const SizedBox(height: 20),
                      _buildComingSoonCard(context),
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

  Widget _buildComingSoonCard(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.leaf, size: 40, color: Colors.green.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            loc.translate('coming_soon'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate('coming_soon_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
