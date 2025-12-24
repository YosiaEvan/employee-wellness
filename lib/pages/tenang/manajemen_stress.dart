import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/teknik_quick_relief.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManajemenStress extends StatefulWidget {
  const ManajemenStress({super.key});

  @override
  State<ManajemenStress> createState() => _ManajemenStressState();
}

class _ManajemenStressState extends State<ManajemenStress> {
  double stressValue = 3;

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
                              "Manajemen Stress",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Kelola Stress & Kecemasan",
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
                                          FontAwesomeIcons.message,
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
                                          "Cek Level Stres Anda",
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
                                  "Geser slider untuk menunjukkan seberapa stres yang Anda rasakan saat ini.",
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20,),

                          // Slider
                          Container(
                            padding: EdgeInsets.all(20),
                            width: double.infinity,
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
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: stressValue == 1
                                      ? Color(0xff00d477)
                                      : stressValue == 2
                                      ? Color(0xff3dd141)
                                      : stressValue == 3
                                      ? Color(0xfffea800)
                                      : stressValue == 4
                                      ? Color(0xfffe5030)
                                      : Color(0xfff0003d),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    stressValue == 1
                                      ? FontAwesomeIcons.faceSmileBeam
                                      : stressValue == 2
                                      ? FontAwesomeIcons.faceSmile
                                      : stressValue == 3
                                      ? FontAwesomeIcons.faceMeh
                                      : stressValue == 4
                                      ? FontAwesomeIcons.faceSadTear
                                      : FontAwesomeIcons.faceTired,
                                    size: 52,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Text(
                                  stressValue == 1
                                      ? "Sangat Rendah"
                                      : stressValue == 2
                                      ? "Rendah"
                                      : stressValue == 3
                                      ? "Sedang"
                                      : stressValue == 4
                                      ? "Tinggi"
                                      : "Sangat Tinggi",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4,),
                                Text(
                                  "Level Stres: ${stressValue.toInt()}/5",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Slider(
                                  value: stressValue,
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: stressValue.toInt().toString(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      stressValue = newValue;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Rendah", style: TextStyle(fontSize: 16),),
                                      Text("Tinggi", style: TextStyle(fontSize: 16),),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20,),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TeknikQuickRelief()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xfff20868),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Lihat Teknik Relief",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ),
                                )
                              ],
                            ),
                          ),

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
                                          FontAwesomeIcons.info,
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
                                          "Kapan Harus Cari Bantuan?",
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
                                  "Jika stres berlangsung lama dan mengganggu aktivitas, segera konsultasi dengan profesional kesehatan mental.",
                                ),
                              ],
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
