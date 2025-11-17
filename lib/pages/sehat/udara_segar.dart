import 'dart:async';

import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat/tidur_cukup.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/services/tarik_napas_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UdaraSegar extends StatefulWidget {
  const UdaraSegar({super.key});

  @override
  State<UdaraSegar> createState() => _UdaraSegarState();
}

class _UdaraSegarState extends State<UdaraSegar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  final double minSize = 150;
  final double maxSize = 300;
  final int inhale = 4;
  final int hold = 7;
  final int exhale = 8;

  String phase = "Tekan tombol untuk mulai";
  int seconds = 0;
  Timer? timer;
  bool isRunning = false;
  int cycleCount = 0;

  // Countdown
  bool isCountdown = false;
  int countdownSeconds = 5;

  // API Status
  bool isLoading = true;
  bool sudahTarikNapas = false;
  int hariTarikNapas = 0; // Jumlah hari sudah tarik napas minggu ini
  List<int> weeklyProgress = []; // List untuk tracking hari ke berapa

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: inhale),
    );

    _sizeAnimation = Tween<double>(begin: minSize, end: maxSize)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _cekStatusTarikNapas();
  }

  Future<void> _cekStatusTarikNapas() async {
    setState(() {
      isLoading = true;
    });

    final result = await TarikNapasService.cekTarikNapas();

    print("🔍 DEBUG - Full result: $result");
    print("🔍 DEBUG - result['minggu_ini']: ${result['minggu_ini']}");

    setState(() {
      sudahTarikNapas = result['sudah_tarik_napas'] ?? false;

      // minggu_ini is at root level of response, not inside 'data'
      if (result['minggu_ini'] != null) {
        final mingguIni = result['minggu_ini'];

        // Get jumlah_hari_dilakukan from minggu_ini
        hariTarikNapas = mingguIni['jumlah_hari_dilakukan'] ?? 0;

        print("✅ Found minggu_ini.jumlah_hari_dilakukan: $hariTarikNapas");

        // Build weekly progress list for visual display
        weeklyProgress = List.generate(5, (index) => index < hariTarikNapas ? 1 : 0);
      } else {
        print("⚠️ minggu_ini not found in response");
        hariTarikNapas = 0;
        weeklyProgress = [0, 0, 0, 0, 0];
      }

      isLoading = false;
    });

    print("📊 Status tarik napas: ${sudahTarikNapas ? 'SUDAH' : 'BELUM'}");
    print("📊 Hari tarik napas minggu ini: $hariTarikNapas / 5");
    print("📊 Weekly progress array: $weeklyProgress");
  }

  void startCycle() {
    if (isRunning || sudahTarikNapas) return;

    // Start countdown first
    setState(() {
      isCountdown = true;
      countdownSeconds = 5;
      phase = "Bersiap...";
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        countdownSeconds--;
      });

      if (countdownSeconds == 0) {
        t.cancel();
        setState(() {
          isCountdown = false;
        });
        _startBreathingCycle();
      }
    });
  }

  void _startBreathingCycle() {
    setState(() {
      isRunning = true;
      phase = "Tarik napas";
      seconds = inhale;
    });

    _controller.forward();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        seconds--;
      });

      if (seconds == 0) {
        if (phase == "Tarik napas") {
          setState(() {
            phase = "Tahan napas";
            seconds = hold;
          });
          _controller.stop();
        } else if (phase == "Tahan napas") {
          setState(() {
            phase = "Hembuskan napas";
            seconds = exhale;
          });
          _controller.reverse();
        } else {
          t.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              isRunning = false;
              cycleCount++;

              // After first cycle complete, post to API
              if (cycleCount == 1) {
                _catatTarikNapas();
              }

              stopCycle();
            });
          });
        }
      }
    });
  }

  Future<void> _catatTarikNapas() async {
    final result = await TarikNapasService.catatTarikNapas();

    if (result['success']) {
      // Reload status to get updated weekly count
      await _cekStatusTarikNapas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result['message']}'),
            backgroundColor: Color(0xFF00C368),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mencatat aktivitas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void stopCycle() {
    timer?.cancel();
    _controller.stop();
    setState(() {
      isRunning = false;
      phase = "Tekan tombol untuk mulai";
      seconds = 0;
    });
  }

  void resetCycle() {
    setState(() {
      cycleCount = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe4f0e4).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Header(),
            BottomHeader(color: Color(0xff009bf4), heading: "Udara Segar", subHeading: "Teknik Pernapasan", destination: SehatHomepage(),),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Counter
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Text(
                                isCountdown
                                  ? "⏰"
                                  : phase == "Tarik napas"
                                    ? "🌬️"
                                    : phase == "Tahan napas"
                                      ? "⏸️"
                                      : sudahTarikNapas
                                        ? "✅"
                                        : "🧘‍♂️",
                                style: TextStyle(
                                  fontSize: 52,
                                ),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                isCountdown
                                  ? "Bersiap..."
                                  : sudahTarikNapas
                                    ? "Selesai Hari Ini"
                                    : phase == "Tarik napas"
                                      ? "Tarik napas"
                                      : phase == "Tahan napas"
                                        ? "Tahan napas"
                                        : "Siap Memulai",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isCountdown
                                  ? "Mulai dalam $countdownSeconds detik"
                                  : sudahTarikNapas
                                    ? "Anda sudah melakukan aktivitas ini"
                                    : phase == "Tarik napas"
                                      ? "Hirup udara melalui hidung"
                                      : phase == "Tahan napas"
                                        ? "Tahan napas Anda"
                                        : "Tekan tombol mulai",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20,),
                          AnimatedBuilder(
                            animation: _sizeAnimation,
                            builder: (context, child) {
                              return Container(
                                width: isCountdown ? minSize : _sizeAnimation.value,
                                height: isCountdown ? minSize : _sizeAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCountdown
                                      ? Colors.orange
                                      : sudahTarikNapas
                                        ? Colors.green
                                        : phase == "Tarik napas"
                                          ? Colors.blue
                                          : phase == "Tahan napas"
                                            ? Colors.orange
                                            : Colors.green,
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isCountdown
                                        ? "$countdownSeconds"
                                        : seconds > 0
                                          ? "$seconds"
                                          : "4",
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      isCountdown ? "detik" : "detik",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )
                              );
                            }
                          ),
                          SizedBox(height: 20,),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            decoration: BoxDecoration(
                              color: Color(0xffcefafe),
                              border: Border.all(
                                color: Color(0xff6cecfd),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.arrowsSpin,
                                  color: Color(0xff0092b8),
                                ),
                                SizedBox(width: 12,),
                                Text(
                                  "$cycleCount",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "  siklus selesai",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff007595)
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          isRunning ? Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [Color(0xfff54900), Color(0xffe7000a)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: stopCycle,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.pause,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Jeda",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    )
                                  )
                                )
                              )
                            ],
                          ) : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: sudahTarikNapas
                                      ? LinearGradient(
                                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : LinearGradient(
                                          colors: [Color(0xff135ffa), Color(0xff00b7db)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                  ),
                                  child: ElevatedButton(
                                      onPressed: sudahTarikNapas ? null : startCycle,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        disabledBackgroundColor: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            sudahTarikNapas
                                              ? FontAwesomeIcons.check
                                              : FontAwesomeIcons.play,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6,),
                                          Flexible(
                                            child: Text(
                                              sudahTarikNapas
                                                ? "Selesai Hari Ini"
                                                : "Mulai",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      )
                                  )
                                ),
                              ),
                              SizedBox(width: 12,),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xffd1d5dc),
                                    )
                                  ),
                                  child: ElevatedButton(
                                    onPressed: resetCycle,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.rotateRight,
                                          size: 16,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Reset",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                )
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Target Mingguan
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
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
                                    color: hariTarikNapas >= 5
                                      ? Color(0xFF4CAF50)
                                      : Color(0xff009bf4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    hariTarikNapas >= 5
                                      ? FontAwesomeIcons.trophy
                                      : FontAwesomeIcons.calendar,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hariTarikNapas >= 5
                                        ? "Target Tercapai!"
                                        : "Target Mingguan",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: hariTarikNapas >= 5
                                          ? Color(0xFF4CAF50)
                                          : Colors.black,
                                      ),
                                    ),
                                    if (hariTarikNapas >= 5)
                                      Text(
                                        "Hebat! 🎉",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF388E3C),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$hariTarikNapas dari 5 sesi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${((hariTarikNapas / 5) * 100).toInt()}%",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: hariTarikNapas >= 5
                                        ? Color(0xFF4CAF50)
                                        : Color(0xff009bf4),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 8,),
                              SizedBox(
                                height: 20,
                                child: LinearProgressIndicator(
                                  value: hariTarikNapas / 5,
                                  color: hariTarikNapas >= 5
                                    ? Color(0xFF4CAF50)
                                    : Color(0xff009bf4),
                                  backgroundColor: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for (int i = 0; i < 5; i++)
                                    Flexible(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        margin: EdgeInsets.symmetric(horizontal: 2),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: i < hariTarikNapas
                                            ? Color(0xFFE8F5E9)
                                            : Color(0xfff3f4f6),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: i < hariTarikNapas
                                              ? Color(0xFF4CAF50)
                                              : Color(0xffd1d5dc),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          )
                                        ),
                                        child: i < hariTarikNapas
                                          ? Icon(
                                              FontAwesomeIcons.check,
                                              color: Color(0xFF4CAF50),
                                              size: 20,
                                            )
                                          : Text(
                                              "${i + 1}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Teknik Pernapasan 4-7-8
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
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
                                    color: Color(0xff009bf4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.wind,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Teknik Pernapasan 4-7-8",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [Color(0xffecfeff), Color(0xffcefafe)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  border: Border.all(
                                    color: Color(0xffa2f4fd),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color(0xff00a1c6),
                                          borderRadius: BorderRadius.circular(40),
                                        ),
                                        child: Text(
                                          "4",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Detik Tarik Napas",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff005f78),
                                            ),
                                          ),
                                          Text(
                                            "Hirup udara perlahan melalui hidung",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xff005f78),
                                            ),
                                          ),
                                        ],
                                      )
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [Color(0xffeef5fe), Color(0xffdcebff)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    border: Border.all(
                                      color: Color(0xffbedbff),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    )
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color(0xff1c69ff),
                                          borderRadius: BorderRadius.circular(40),
                                        ),
                                        child: Text(
                                          "7",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Detik Tahan Napas",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff193cb8),
                                              ),
                                            ),
                                            Text(
                                              "Tahan napas dalam perut",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff193cb8),
                                              ),
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [Color(0xfffaf5ff), Color(0xfff3e9ff)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    border: Border.all(
                                      color: Color(0xffe9d4ff),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    )
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 60,
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color(0xffa12eff),
                                          borderRadius: BorderRadius.circular(40),
                                        ),
                                        child: Text(
                                          "8",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Detik Buang Napas",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff6e11b0),
                                              ),
                                            ),
                                            Text(
                                              "Hembuskan perlahan melalui mulut",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff6e11b0),
                                              ),
                                            ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Tantangan Sehat
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffdbeafe), Color(0xffcffafe)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xffa2f4fd),
                            width: 2,
                            style: BorderStyle.solid,
                          )
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
                                    color: Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.lightbulb,
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
                                    "Manfaat Teknik 4-7-8",
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
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00b8db),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Mengurangi stres dan kecemasan")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00b8db),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Membantu tidur lebih nyenyak")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00b8db),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Menurunkan tekanan darah")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00b8db),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Meningkatkan fokus dan konsentrasi")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff00b8db),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Menenangkan sistem saraf")
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Navigation to Udara Segar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff715cff),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                          onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TidurCukup()),
                            )
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            "Lanjut ke Tidur Cukup",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
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
