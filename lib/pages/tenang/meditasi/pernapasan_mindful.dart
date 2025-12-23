import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/tenang/meditasi_terpadu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PernapasanMindful extends StatefulWidget {
  const PernapasanMindful({super.key});

  @override
  State<PernapasanMindful> createState() => _PernapasanMindfulState();
}

enum SessionStatus { idle, running, paused, finished }

class _PernapasanMindfulState extends State<PernapasanMindful> with TickerProviderStateMixin {
  late AnimationController _controller;
  static const int totalSeconds = 5 * 60;
  int _remainingSeconds = totalSeconds;
  Timer? _timer;
  SessionStatus _status = SessionStatus.idle;
  final List<String> guide = [
    "Duduk nyaman dengan punggung tegak",
    "Tutup mata perlahan",
    "Rasakan napas masuk dan keluar",
    "Jika pikiran mengembara, kembalikan fokus",
    "Lanjutkan hingga timer selesai",
  ];
  late final AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  void startTimer() {
    if (_status == SessionStatus.finished) return;

    _timer?.cancel();

    setState(() {
      _status = SessionStatus.running;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _controller.value = 1 - (_remainingSeconds / totalSeconds);
        });
      } else {
        timer.cancel();
        _onSesionComplete();
        setState(() {
          _status = SessionStatus.finished;
        });
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      _status = SessionStatus.paused;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = totalSeconds;
      _controller.value = 0;
      _status = SessionStatus.idle;
    });
  }

  String get timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _onSesionComplete() async {
    await _audioPlayer.play(
      AssetSource('sounds/done.wav'),
    );

    setState(() {
      _status = SessionStatus.finished;
    });
  }

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 5),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
              Header(),
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xff0087ef),
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
                              "Pernapasan Mindful",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "5 menit sesi",
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
                    child: _status == SessionStatus.finished
                      ? Padding(
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
                              "Sesi Selesai 🎉",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8,),
                            Text(
                              "Selamat! Anda telah menyelesaikan sesi Pernapasan Mindful. Bagaimana perasaan Anda sekarang?",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20,),

                            // Button
                            Column(
                              children: [
                                // Retry Session Button
                                GestureDetector(
                                  onTap: resetTimer,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xff0087ef),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Ulangi Sesi",
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

                                // Select Another Meditation Button
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MeditasiTerpadu()),
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
                                      "Pilih Meditasi Lain",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
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
                                      MaterialPageRoute(builder: (context) => MeditasiTerpadu()),
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
                                      "Lanjut ke Mindfulness",
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
                      ) : Column(
                      children: [
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress Ring
                              Positioned.fill(
                                child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return CircularProgressIndicator(
                                        value: _controller.value,
                                        strokeWidth: 10,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor: AlwaysStoppedAnimation(Color(0xff0087ef)),
                                      );
                                    }
                                ),
                              ),

                              // Center Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "🌬️",
                                    style: TextStyle(
                                      fontSize: 100,
                                    ),
                                  ),
                                  SizedBox(height: 8,),
                                  Text(
                                    timerText,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4,),
                                  Text(
                                    (_status == SessionStatus.idle) || (_status == SessionStatus.paused)
                                        ? "Siap memulai"
                                        : _status == SessionStatus.running
                                        ? "Bermeditasi..."
                                        : "Sesi Selesai",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 40,),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Reset Button
                            OutlinedButton.icon(
                              onPressed: resetTimer,
                              icon: Icon(FontAwesomeIcons.rotateLeft),
                              label: Text("Reset"),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                foregroundColor: Color(0xff0087ef),
                                side: BorderSide(color: Color(0xff0087ef)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),

                            SizedBox(width: 16,),

                            // Play Button
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_status == SessionStatus.running) {
                                  pauseTimer();
                                } else {
                                  startTimer();
                                }
                              },
                              icon: Icon(
                                _status == SessionStatus.running
                                    ? FontAwesomeIcons.pause
                                    : FontAwesomeIcons.play,
                              ),
                              label: Text(
                                _status == SessionStatus.running ? "Pause" : "Mulai",
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                backgroundColor: Color(0xff0087ef),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
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
                      ],
                    ),
                  )
              ),
            ],
          )
      ),
    );
  }
}
