import 'package:audioplayers/audioplayers.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MomenSekarang extends StatefulWidget {
  const MomenSekarang({super.key});

  @override
  State<MomenSekarang> createState() => _MomenSekarangState();
}

class _MomenSekarangState extends State<MomenSekarang> with TickerProviderStateMixin {
  bool isComplete = false;
  final List<String> guide = [
    "Sadari pikiran tanpa menilai",
    "Terima emosi apa adanya",
    "Rasakan sensasi tubuh saat ini",
    "Denger suara di sekitar",
    "Kembali ke napas sebagai jangkar",
  ];
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
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
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
              // Header
              const Header(),
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xfffa7200),
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
                              "Momen Sekarang",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "5 Menit Latihan",
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
                      child: !isComplete
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "✨",
                            style: TextStyle(
                              fontSize: 60,
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "Momen Sekarang",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Hadir sepenuhnya di momen ini",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 20,),

                          // Guide
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
                                Text(
                                  "Panduan:",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var entry in guide.asMap().entries) ...[
                                      Row(
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
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff9810fa),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              entry.value,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20,),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isComplete = true;
                                });

                                _audioPlayer.play(
                                  AssetSource('sounds/done.wav'),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xfffa7200),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Selesai Latihan",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ) : Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: const Color(0xff00d477),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.check,
                                  size: 52,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 40,),
                            Text(
                              "Latihan Selesai 🎉",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8,),
                            Text(
                              "Anda telah menyelesaikan latihan Kesadaran Tubuh. Bagaimana perasaan Anda sekarang?",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20,),

                            // Button
                            Column(
                              children: [
                                // Select Another Meditation Button
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MindfulnessKesadaran()),
                                    ),
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xfffa7200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Pilih Latihan Lain",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16,),

                                // Continue to Mindfulness button
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MindfulnessKesadaran()),
                                    ),
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey,
                                        )
                                    ),
                                    child: Text(
                                      "Lanjut ke Manajemen Stres",
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
                          ],
                        ),
                      )
                  )
              ),
            ],
          )
      ),
    );
  }
}
