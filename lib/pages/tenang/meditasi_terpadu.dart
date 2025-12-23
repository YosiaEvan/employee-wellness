import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/meditation_section_card.dart';
import 'package:employee_wellness/pages/tenang/meditasi/body_scan.dart';
import 'package:employee_wellness/pages/tenang/meditasi/loving_kindness.dart';
import 'package:employee_wellness/pages/tenang/meditasi/pernapasan_mindful.dart';
import 'package:employee_wellness/pages/tenang/meditasi/visualisasi_positif.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MeditasiTerpadu extends StatefulWidget {
  const MeditasiTerpadu({super.key});

  @override
  State<MeditasiTerpadu> createState() => _MeditasiTerpaduState();
}

class _MeditasiTerpaduState extends State<MeditasiTerpadu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Header(),
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xff7141fc),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 6),
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
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.arrowLeft,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Column(
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
                              "Pilih Jenis Meditasi Anda",
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
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
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
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Pernapasan Mindful
                        MeditationSectionCard(destination: PernapasanMindful(), sectionColor: Color(0xff0087ef), icon: FontAwesomeIcons.wind, heading: "Pernapasan Mindful", description: "Fokus pada pernapasan untuk menenangkan pikiran.", targetText: "⏱️ 5 menit"),

                        SizedBox(height: 20,),

                        // Body Scan
                        MeditationSectionCard(destination: BodyScan(), sectionColor: Color(0xff7541fc), icon: FontAwesomeIcons.userCheck, heading: "Body Scan", description: "Scan tubuh dari kepala hingga kaki.", targetText: "⏱️ 10 menit"),

                        SizedBox(height: 20,),

                        // Loving Kindness
                        MeditationSectionCard(destination: LovingKindness(), sectionColor: Color(0xffef006d), icon: FontAwesomeIcons.heart, heading: "Loving Kindness", description: "Meditasi kasih sayang untuk diri dan orang lain.", targetText: "⏱️ 15 menit"),

                        SizedBox(height: 20,),

                        // Visualisasi Positif
                        MeditationSectionCard(destination: VisualisasiPositif(), sectionColor: Color(0xfffb7600), icon: FontAwesomeIcons.sunPlantWilt, heading: "Visualisasi Positif", description: "Visualisasi tempat yang menyenangkan.", targetText: "⏱️ 10 menit"),

                        SizedBox(height: 20,),

                        // Information
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: Offset(0, 6),
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
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xff00c170),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        FontAwesomeIcons.circleInfo,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Column(
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
                              SizedBox(height: 12,),
                              Text(
                                "Pilih jenis meditasi yang sesuai dengan kebutuhan Anda saat ini. Setiap sesi dirancang untuk membantu Anda mencapai ketenangan.",
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
              )
            ],
          )
      ),
    );
  }
}
