import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/meditation_section_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/tenang/meditasi/body_scan.dart';
import 'package:employee_wellness/pages/tenang/meditasi/loving_kindness.dart';
import 'package:employee_wellness/pages/tenang/meditasi/pernapasan_mindful.dart';
import 'package:employee_wellness/pages/tenang/meditasi/visualisasi_positif.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MeditasiTerpadu extends StatelessWidget {
  const MeditasiTerpadu({super.key});

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
                  color: const Color(0xff7141fc),
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
                              "Meditasi Terpadu",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Pilih Sesi Meditasi",
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
                        // Pernapasan Mindful
                        const MeditationSectionCard(destination: PernapasanMindful(), sectionColor: Color(0xff0087ef), icon: FontAwesomeIcons.wind, heading: "Pernapasan Mindful", description: "Fokus pada pernapasan untuk menenangkan pikiran.", targetText: "⏱️ 5 menit"),

                        const SizedBox(height: 20,),

                        // Body Scan
                        const MeditationSectionCard(destination: BodyScan(), sectionColor: Color(0xff7541fc), icon: FontAwesomeIcons.userCheck, heading: "Body Scan", description: "Scan tubuh dari kepala hingga kaki.", targetText: "⏱️ 10 menit"),

                        const SizedBox(height: 20,),

                        // Loving Kindness
                        const MeditationSectionCard(destination: LovingKindness(), sectionColor: Color(0xfff20868), icon: FontAwesomeIcons.heart, heading: "Loving Kindness", description: "Kembangkan rasa kasih sayang pada diri sendiri.", targetText: "⏱️ 10 menit"),

                        const SizedBox(height: 20,),

                        // Visualisasi Positif
                        const MeditationSectionCard(destination: VisualisasiPositif(), sectionColor: Color(0xff00bca8), icon: FontAwesomeIcons.eye, heading: "Visualisasi Positif", description: "Bayangkan tempat yang tenang dan damai.", targetText: "⏱️ 10 menit"),

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
                                        "Mulai Sesi Meditasi",
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
                                "Pilih jenis meditasi yang sesuai dengan kebutuhan Anda saat ini. Setiap sesi dirancang untuk membantu Anda mencapai ketenangan.",
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
