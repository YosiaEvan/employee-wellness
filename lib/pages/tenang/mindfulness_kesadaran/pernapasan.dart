import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Pernapasan extends StatefulWidget {
  const Pernapasan({super.key});

  @override
  State<Pernapasan> createState() => _PernapasanState();
}

class _PernapasanState extends State<Pernapasan> with SingleTickerProviderStateMixin {
  final double minSize = 150;
  final double maxSize = 300;
  double currentSize = 150;

  final int inhale = 4;
  final int hold = 7;
  final int exhale = 8;
  final int requiredCycles = 4;

  String phase = "Siap untuk memulai?";
  bool isRunning = false;
  int cycleCount = 0;
  int seconds = 0;

  late final AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> guide = [
    {
      "id": 4,
      "description": "Tarik napas melalui hidung selama 4 detik",
    },
    {
      "id": 7,
      "description": "Tahan napas selama 7 detik",
    },
    {
      "id": 8,
      "description": "Hembuskan melalui mulut selama 8 detik",
    },
  ];

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

  Future<void> _startBreathingCycle() async {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      cycleCount = 0;
    });

    while (cycleCount < requiredCycles && isRunning) {
      setState(() {
        phase = "Tarik Napas";
      });
      await Future.wait([
        _runSecondCounter(inhale, minSize, maxSize),
      ]);

      if (!isRunning) break;

      setState(() {
        phase = "Tahan Napas";
      });
      await _runSecondCounter(hold, maxSize, maxSize);

      if (!isRunning) break;

      setState(() {
        phase = "Hembuskan Napas";
      });
      await Future.wait([
        _runSecondCounter(exhale, maxSize, minSize),
      ]);

      cycleCount++;

      if (cycleCount == requiredCycles) {
        _audioPlayer.play(
          AssetSource('sounds/done.wav'),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      isRunning = false;
      seconds = 0;
    });
  }

  void _stopCycle() {
    setState(() {
      isRunning = false;
      seconds = 0;
      phase = "Siap untuk memulai?";
      currentSize = 150;
    });
  }

  void _resetCycle() {
    setState(() {
      isRunning = false;
      cycleCount = 0;
      seconds = 0;
      phase = "Siap untuk memulai?";
      currentSize = 150;
    });
  }

  Future<void> _runSecondCounter(
      int totalSeconds,
      double start,
      double end,
      ) async {
    for (int i = totalSeconds; i > 0; i--) {
      if (!mounted || !isRunning) return;

      final t = 1 - (i / totalSeconds);
      final eased = Curves.easeInOut.transform(t);

      setState(() {
        seconds = i;
        currentSize = start + (end - start) * eased;
      });

      await Future.delayed(const Duration(seconds: 1));
    }
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
                  color: Color(0xff445ffe),
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
                              "Pernapasan 4-7-8",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Siklus ${cycleCount} dari ${requiredCycles}",
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
                      child: (cycleCount < requiredCycles)
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            phase == "Siap untuk memulai?"
                                ? "🧘"
                                : phase == "Tarik Napas"
                                ? "️⬆️"
                                : phase == "Tahan Napas"
                                ? "⏸️"
                                : "⬇️"
                            ,
                            style: TextStyle(
                              fontSize: 60,
                            ),
                          ),
                          SizedBox(height: 20,),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                            width: currentSize,
                            height: currentSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: phase == "Siap untuk memulai?"
                                ? Colors.orange
                                : phase == "Hembuskan Napas"
                                ? Colors.green
                                : phase == "Tarik Napas"
                                ? Colors.blue
                                : phase == "Tahan Napas"
                                ? Colors.orange
                                : Colors.green,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  seconds > 0 ? "${seconds}" : "",
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  seconds > 0 ? "detik" : "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            )
                          ),
                          SizedBox(height: 20,),
                          Text(
                            phase,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !isRunning ? ElevatedButton(
                                onPressed: isRunning ? null : _startBreathingCycle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff445ffe),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.play,
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Mulai"),
                                  ],
                                ),
                              ) : Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: isRunning ? _stopCycle : null,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.pause,
                                        ),
                                        SizedBox(width: 8,),
                                        Text("Jeda"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16,),
                                  ElevatedButton(
                                    onPressed: isRunning ? _resetCycle : null,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.arrowRotateLeft,
                                        ),
                                        SizedBox(width: 8,),
                                        Text("Reset"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
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
                                  "Cara Berlatih:",
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
                                                "${entry.value["id"]}",
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
                                              entry.value["description"],
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
                              "Anda telah menyelesaikan latihan Pernapasan 4-7-8. Bagaimana perasaan Anda sekarang?",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20,),

                            // Button
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Select Another Training Button
                                  GestureDetector(
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MindfulnessKesadaran()),
                                      ),
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Color(0xff0090ed),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Pilih Latihan Lain",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16,),

                                  // Continue to Manajemen Stress button
                                  GestureDetector(
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MindfulnessKesadaran()),
                                      ),
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey,
                                          )
                                      ),
                                      child: Text(
                                        "Lanjut ke Manajemen Stress",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
