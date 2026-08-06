import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/meditation_section_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran/kesadaran_tubuh.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran/momen_sekarang.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran/panca_indra.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran/pernapasan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MindfulnessKesadaran extends StatelessWidget {
  const MindfulnessKesadaran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Header(),
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff008fed),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox.square(
                            dimension: 40,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.arrowLeft,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Mindfulness",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Latihan Kesadaran Penuh",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                        SizedBox.square(
                          dimension: 40,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.brain,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ResponsiveContainer(
                      child: Column(
                        children: [
                        // Pernapasan
                        const MeditationSectionCard(destination: Pernapasan(), sectionColor: Color(0xff445ffe), icon: FontAwesomeIcons.wind, heading: "Pernapasan 4-7-8", description: "Teknik pernapasan untuk relaksasi instan.", targetText: "⏱️ 5 menit"),

                        const SizedBox(height: 20,),

                        // Panca Indra
                        const MeditationSectionCard(destination: PancaIndra(), sectionColor: Color(0xff7541fc), icon: FontAwesomeIcons.eye, heading: "Teknik 5-4-3-2-1", description: "Gunakan panca indra untuk kembali ke momen ini.", targetText: "⏱️ 5 menit"),

                        const SizedBox(height: 20,),

                        // Momen Sekarang
                        const MeditationSectionCard(destination: MomenSekarang(), sectionColor: Color(0xfff20868), icon: FontAwesomeIcons.clock, heading: "Momen Sekarang", description: "Latihan hadir sepenuhnya di saat ini.", targetText: "⏱️ 5 menit"),

                        const SizedBox(height: 20,),

                        // Kesadaran Tubuh
                        const MeditationSectionCard(destination: KesadaranTubuh(), sectionColor: Color(0xff00bca8), icon: FontAwesomeIcons.userCheck, heading: "Kesadaran Tubuh", description: "Rasakan sensasi tubuh Anda secara mendalam.", targetText: "⏱️ 5 menit"),

                        const SizedBox(height: 20,),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
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
                                  const SizedBox(width: 20,),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Apa itu Mindfulness?",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12,),
                              const Text(
                                "Mindfulness adalah latihan untuk hadir sepenuhnya di saat ini tanpa menghakimi. Ini membantu mengurangi kecemasan dan meningkatkan fokus.",
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
          )
      ),
    );
  }
}
