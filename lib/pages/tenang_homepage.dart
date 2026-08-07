import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/module_section_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/config/penilaian_points.dart';
import 'package:employee_wellness/pages/penilaian/aktivitas_klik_page.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress.dart';
import 'package:employee_wellness/pages/tenang/meditasi_terpadu.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran.dart';
import 'package:employee_wellness/pages/tenang/tenang_kpi_dashboard.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TenangHomepage extends StatelessWidget {
  const TenangHomepage({super.key});

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
                color: Color(0xff2c7eff),
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
                          Text(loc.translate('tenang_title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis),
                          Text(loc.translate('tenang_subtitle'), style: const TextStyle(fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TenangKPIDashboard()),
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
                        destination: const MeditasiTerpadu(),
                        backgroundColor: Colors.white,
                        sectionColor: const Color(0xff7141fc),
                        icon: FontAwesomeIcons.spa,
                        heading: loc.translate('meditation_title'),
                        subHeading: loc.translate('meditation_subtitle'),
                        description: loc.translate('meditation_desc'),
                        targetText: loc.translate('meditation_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const MindfulnessKesadaran(),
                        backgroundColor: Colors.white,
                        sectionColor: const Color(0xff008fed),
                        icon: FontAwesomeIcons.brain,
                        heading: loc.translate('mindfulness_title'),
                        subHeading: loc.translate('mindfulness_subtitle'),
                        description: loc.translate('mindfulness_desc'),
                        targetText: loc.translate('mindfulness_target'),
                      ),
                      const SizedBox(height: 20),
                      ModuleSectionCard(
                        destination: const ManajemenStress(),
                        backgroundColor: Colors.white,
                        sectionColor: const Color(0xfff20868),
                        icon: FontAwesomeIcons.faceSmileBeam,
                        heading: loc.translate('stress_title'),
                        subHeading: loc.translate('stress_subtitle'),
                        description: loc.translate('stress_desc'),
                        targetText: loc.translate('stress_target'),
                      ),
                      const SizedBox(height: 20),
                      ..._buildPenilaianCards(context),
                      const SizedBox(height: 20),
                      _buildTipsCard(context),
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

  List<Widget> _buildPenilaianCards(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final map = <String, (Color, FaIconData, Color)>{
      'tahan_emosi': (const Color(0xff7141fc), FontAwesomeIcons.handHoldingHeart, const Color(0xfff0ecff)),
      'ekspresi_sehat': (const Color(0xfff20868), FontAwesomeIcons.music, const Color(0xffffecf5)),
      'harmoni_keluarga': (const Color(0xfff59e0b), FontAwesomeIcons.houseUser, const Color(0xfffff8e1)),
      'akui_emosi': (const Color(0xff00a896), FontAwesomeIcons.comments, const Color(0xffe6faf7)),
      'kendali_diri': (const Color(0xff2c7eff), FontAwesomeIcons.shieldHalved, const Color(0xffe8f0ff)),
      'koneksi_sosial': (const Color(0xff00c368), FontAwesomeIcons.users, const Color(0xffeefdf5)),
    };

    return TenangPenilaianPoints.semua.map((point) {
      final (color, icon, soft) = map[point.kode] ?? (const Color(0xff2c7eff), FontAwesomeIcons.heartPulse, const Color(0xffe8f0ff));
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ModuleSectionCard(
          destination: AktivitasKlikPage(
            point: point,
            heading: loc.translate('tenang_title'),
            subHeading: 'Penilaian 360°',
            destination: const TenangHomepage(),
          ),
          backgroundColor: Colors.white,
          sectionColor: color,
          icon: icon,
          heading: point.title,
          subHeading: 'Self-report klik',
          description: point.description,
          targetText: '${point.targetPerWeek}x/minggu',
        ),
      );
    }).toList();
  }

  Widget _buildTipsCard(BuildContext context) {
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
                      loc.translate('mental_tips'),
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
            loc.translate('mental_tips_desc'),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
