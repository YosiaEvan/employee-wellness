import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/strategi_coping.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress/teknik_quick_relief.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeknikGrounding extends StatelessWidget {
  TeknikGrounding({super.key});

  final List<String> guide = [
    "Sebutkan 5 hal yang Anda lihat",
    "Sebutkan 4 hal yang Anda sentuh",
    "Sebutkan 3 hal yang Anda dengar",
    "Sebutkan 2 hal yang Anda cium",
    "Sebutkan 1 hal yang Anda rasakan",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff7c42fd),
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
                        onTap: () => Navigator.pop(context),
                        child: SizedBox.square(
                          dimension: 40,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: FaIcon(FontAwesomeIcons.arrowLeft, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Teknik Grounding 5-4-3-2-1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text("3 Menit", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                      SizedBox.square(
                        dimension: 40,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: FaIcon(FontAwesomeIcons.brain, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("🧠", style: TextStyle(fontSize: 100)),
                          SizedBox(height: 8),
                          Text("Teknik Grounding 5-4-3-2-1", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Langkah-langkah:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: guide.asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff3e8ff),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${entry.key + 1}",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff9810fa)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(entry.value, style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StrategiCoping())),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xff7c42fd),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("Lihat Strategi Lainnya", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white), textAlign: TextAlign.center),
                          ),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeknikQuickRelief())),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                            child: Text("Pilih Teknik Lain", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                          ),
                        ),
                      ],
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