import 'package:audioplayers/audioplayers.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/tenang/manajemen_stress.dart';
import 'package:employee_wellness/services/tenang_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StrategiCoping extends StatefulWidget {
  const StrategiCoping({super.key});

  @override
  State<StrategiCoping> createState() => _StrategiCopingState();
}

class _StrategiCopingState extends State<StrategiCoping> with TickerProviderStateMixin {
  final List<String> physical = [
    "Olahraga ringan 15-30 menit",
    "Jalan kaki di luar ruangan",
    "Yoga atau stretching",
    "Mandi air hangat",
  ];
  final List<String> mental = [
    "Tulis jurnal perasaan",
    "Praktik gratitude",
    "Meditasi 10 menit",
    "Dengarkan musik tenang",
  ];
  final List<String> social = [
    "Berbicara dengan teman",
    "Bergabung dengan support group",
    "Minta bantuan profesional",
    "Quality time dengan orang terdekat",
  ];
  bool isComplete = false;
  late final AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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
                color: Color(0xfff20768),
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
                          Text("Strategi Coping", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text("Manajemen Jangka Panjang", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                child: ResponsiveContainer(
                  child: !isComplete
                      ? Column(
                        children: [
                          // Strategic
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
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00c170),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: FaIcon(FontAwesomeIcons.bullseye, size: 36, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Strategi Holistik", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text("Terapkan strategi ini secara konsisten untuk mengelola stres jangka panjang."),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Physics
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
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: FaIcon(FontAwesomeIcons.heart, size: 36, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Fisik", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: physical.asMap().entries.map((entry) {
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
                          // Mental
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
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: FaIcon(FontAwesomeIcons.lightbulb, size: 36, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Mental", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: mental.asMap().entries.map((entry) {
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
                          // Social
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
                                Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: FaIcon(FontAwesomeIcons.comment, size: 36, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Sosial", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: social.asMap().entries.map((entry) {
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
                          GestureDetector(
                            onTap: () {
                              setState(() => isComplete = true);
                              _audioPlayer.play(AssetSource('sounds/done.wav'));

                              // Kirim data sesi ke backend
                              TenangService.recordSession(
                                kategori: TenangKategori.manajemenStress,
                                subKategori: TenangSubKategori.strategiCoping,
                                durasiDetik: 10 * 60,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xfff20768),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("Selesai", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white), textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Color(0xff00d477),
                                  shape: BoxShape.circle,
                                ),
                                child: FaIcon(FontAwesomeIcons.check, size: 52, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 40),
                            Text("Sesi Selesai 🎉", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            Text(
                              "Anda sudah mempelajari berbagai teknik dan strategi manajemen stres. Praktikkan secara rutin untuk hasil optimal!",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManajemenStress())),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff20768),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text("Ulangi Sesi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white), textAlign: TextAlign.center),
                                  ),
                                ),
                                SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManajemenStress())),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Text("Lanjut ke Konseling Virtual", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}