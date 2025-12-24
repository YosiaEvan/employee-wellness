import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/quick_relief_technique_card.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/relaksasi_otot_progresif.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/strategi_coping.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/teknik_grounding.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/teknik_pernapasan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeknikQuickRelief extends StatefulWidget {
  const TeknikQuickRelief({super.key});

  @override
  State<TeknikQuickRelief> createState() => _TeknikQuickReliefState();
}

class _TeknikQuickReliefState extends State<TeknikQuickRelief> {
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
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xfff20868),
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
                              "Teknik Quick Relief",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Atasi Stres dengan Cepat",
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
                          // CTA
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
                                          FontAwesomeIcons.bolt,
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
                                          "Teknik Cepat",
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
                                  "Pilih teknik yang dapat membantu meredakan stres dalam hitungan menit.",
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20,),

                          // Teknik 4-7-8
                          QuickReliefTechniqueCard(destination: TeknikPernapasan(), sectionColor: Color(0xff008eed), icon: FontAwesomeIcons.wind, heading: "Teknik 4-7-8", targetText: "⏱️ 2 Menit"),

                          SizedBox(height: 20,),

                          // Teknik 4-7-8
                          QuickReliefTechniqueCard(destination: TeknikGrounding(), sectionColor: Color(0xff7c42fd), icon: FontAwesomeIcons.brain, heading: "Teknik Grounding 5-4-3-2-1", targetText: "⏱️ 3 Menit"),

                          SizedBox(height: 20,),

                          // Relaksasi Otot Progresif
                          QuickReliefTechniqueCard(destination: RelaksasiOtotProgresif(), sectionColor: Color(0xff00a884), icon: FontAwesomeIcons.spa, heading: "Relaksasi Otot Progresif", targetText: "⏱️ 5 Menit"),

                          SizedBox(height: 20,),

                          // Long-Term Strategy Button
                          GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StrategiCoping()),
                              ),
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                )
                              ),
                              child: Text(
                                "Lihat Strategi Jangka Panjang",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                  )
              ),
            ],
          )
      ),
    );
  }
}
