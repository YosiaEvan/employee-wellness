import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/meditation_section_card.dart';
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
              Header(),
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xff008fed),
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
                              "Mindfulness & Kesadaran",
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
                        // 5 Panca Indra
                        MeditationSectionCard(destination: PancaIndra(), sectionColor: Color(0xff0090ec), icon: FontAwesomeIcons.eye, heading: "5 Panca Indra", description: "Latihan kesadaran menggunakan kelima panca indra", targetText: "⏱️ 5 menit"),

                        SizedBox(height: 20,),

                        // Pernapasan 4-7-8
                        MeditationSectionCard(destination: Pernapasan(), sectionColor: Color(0xff445ffe), icon: FontAwesomeIcons.wind, heading: "Pernapasan 4-7-8", description: "Teknik pernapasan untuk menenangkan sistem saraf", targetText: "⏱️ 5 menit"),

                        SizedBox(height: 20,),

                        // Kesadaran Tubuh
                        MeditationSectionCard(destination: KesadaranTubuh(), sectionColor: Color(0xffcb3bbd), icon: FontAwesomeIcons.userCheck, heading: "Kesadaran Tubuh", description: "Scan dan rasakan setiap bagian tubuh", targetText: "⏱️ 7 menit"),

                        SizedBox(height: 20,),

                        // Kesadaran Tubuh
                        MeditationSectionCard(destination: MomenSekarang(), sectionColor: Color(0xfffa7200), icon: FontAwesomeIcons.hourglass, heading: "Momen Sekarang", description: "Hadir sepenuhnya di momen ini", targetText: "⏱️ 5 menit"),

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
                                        "Latihan Mindfulness",
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
                                "Mindfulness membantu Anda lebih hadir dan sadar di setiap momen. Pilih latihan yang sesuai dengan waktu Anda.",
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
