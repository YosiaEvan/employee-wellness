import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/module_section_card.dart';
import 'package:employee_wellness/pages/sehat/jalan_10000_langkah.dart';
import 'package:employee_wellness/pages/sehat/minum_air_8_gelas.dart';
import 'package:employee_wellness/pages/sehat/pola_makan_sehat.dart';
import 'package:employee_wellness/pages/sehat/sinar_matahari.dart';
import 'package:employee_wellness/pages/sehat/tidur_cukup.dart';
import 'package:employee_wellness/pages/sehat/udara_segar.dart';
import 'package:employee_wellness/pages/sehat/sehat_kpi_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SehatHomepage extends StatefulWidget {
  const SehatHomepage({super.key});

  @override
  State<SehatHomepage> createState() => _SehatHomepageState();
}

class _SehatHomepageState extends State<SehatHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffdf2f5).withValues(alpha: 0.98),
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
                color: Color(0xfff44336),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SEHAT 360\u00B0",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Zona Vitalitas Menyeluruh",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )
                        ],
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
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.chartLine,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "6",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Modul",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "85%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Progress",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "24",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Sesi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Sinar Matahari
                    ModuleSectionCard(destination: SinarMatahari(), backgroundColor: Color(0xfffff7ed), sectionColor: Color(0xfffb8f00), icon: FontAwesomeIcons.cloudSun, heading: "Sinar Matahari", subHeading: "Energi Alami", description: "Berjemur untuk vitamin D dan kesehatan tulang", targetText: "15 menit/hari"),

                    SizedBox(height: 20,),

                    // Jalan 10.000 Langkah
                    ModuleSectionCard(destination: Jalan10000Langkah(), backgroundColor: Color(0xffecfeff), sectionColor: Color(0xff1b8cfd), icon: FontAwesomeIcons.shoePrints, heading: "Jalan 10.000 Langkah", subHeading: "Aktivitas Fisik", description: "Mencapai target langkah harian untuk kesehatan optimal", targetText: "10.000 langkah"),

                    SizedBox(height: 20,),

                    // Pola Makan Sehat
                    ModuleSectionCard(destination: PolaMakanSehat(), backgroundColor: Color(0xffeefdf5), sectionColor: Color(0xff00c368), icon: FontAwesomeIcons.appleWhole, heading: "Pola Makan Sehat", subHeading: "Nutrisi Seimbang", description: "Tracking nutrisi harian dengan target tanpa minyak & gula", targetText: "2000 kkal/hari"),

                    SizedBox(height: 20,),

                    // Udara Segar
                    ModuleSectionCard(destination: UdaraSegar(), backgroundColor: Color(0xffeefaff), sectionColor: Color(0xff009bf4), icon: FontAwesomeIcons.wind, heading: "Udara Segar", subHeading: "Teknik Pernapasan", description: "Pernapasan 4-7-8 dengan AR untuk relaksasi & fokus", targetText: "5x seminggu"),

                    SizedBox(height: 20,),

                    // Minum Air 8 Gelas
                    ModuleSectionCard(destination: MinumAir8Gelas(), backgroundColor: Color(0xffedfaff), sectionColor: Color(0xff00cbf6), icon: FontAwesomeIcons.glassWater, heading: "Minum Air 8 Gelas", subHeading: "Hidrasi Optimal", description: "Tracking konsumsi ar harian untuk tubuh terhidrasi", targetText: "8 gelas/hari"),

                    SizedBox(height: 20,),

                    // Tidur Cukup
                    ModuleSectionCard(destination: TidurCukup(), backgroundColor: Color(0xfff4f4ff), sectionColor: Color(0xff715cff), icon: FontAwesomeIcons.moon, heading: "Tidur Cukup", subHeading: "Istirahat Berkualitas", description: "Tidur 7-8 jam mulai jam 9 malam untuk pemulihan optimal", targetText: "7-8 jam/hari"),

                    SizedBox(height: 20,),

                    // Information
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                                    "Tentang SEHAT 360\u00B0",
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
                            "Program kesehatan komprehensif yang dirancang khusus untuk meningkatkan kualitas hidup karyawan melalui aktivitas yang mudah dan menyenangkan.",
                          ),
                          SizedBox(height: 12,),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 8,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00c170),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Pantau progress kesehatan Anda")
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 8,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00c170),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Dapatkan tips personal setiap hari")
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 8,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00c170),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Raih pencapaian dan rewards")
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
