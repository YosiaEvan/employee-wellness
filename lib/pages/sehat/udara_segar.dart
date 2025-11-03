import 'dart:async';

import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat/tidur_cukup.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: inhale),
    );

    _sizeAnimation = Tween<double>(begin: minSize, end: maxSize)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void startCycle() {
    if (isRunning) return;
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
              stopCycle();
              cycleCount++;
            });
          });
        }
      }
    });
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
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(0xff009bf4),
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
                            "Udara Segar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Teknik Pernapasan",
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
                            FontAwesomeIcons.house,
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
                                phase == "Tarik napas" ? "🌬️" : phase == "Tahan napas" ? "⏸️" : "🧘‍♂️",
                                style: TextStyle(
                                  fontSize: 52,
                                ),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                phase == "Tarik napas" ? "Tarik napas" : phase == "Tahan napas" ? "Tahan napas" : "Siap Memulai",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                phase == "Tarik napas" ? "Hirup udara melalui hidung" : phase == "Tahan napas" ? "Tahan napas Anda" : "Tekan tombol mulai",
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
                                width: _sizeAnimation.value,
                                height: _sizeAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: phase == "Tarik napas"
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
                                      seconds > 0 ? "$seconds" : "4",
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "detik",
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
                                    gradient: LinearGradient(
                                      colors: [Color(0xff135ffa), Color(0xff00b7db)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                      onPressed: startCycle,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.play,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8,),
                                          Text(
                                            "Mulai",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
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
                                    color: Color(0xff009bf4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.calendar,
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
                                    "Target Mingguan",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                                    "0 dari 5 sesi",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "0%",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 8,),
                              SizedBox(
                                height: 20,
                                child: LinearProgressIndicator(
                                  value: 0,
                                  color: Color(0xff009bf4),
                                  backgroundColor: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox.square(
                                    dimension: 60,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff3f4f6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffd1d5dc),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        )
                                      ),
                                      child: Text(
                                        "1",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.square(
                                    dimension: 60,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff3f4f6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffd1d5dc),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        )
                                      ),
                                      child: Text(
                                        "2",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.square(
                                    dimension: 60,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff3f4f6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffd1d5dc),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        )
                                      ),
                                      child: Text(
                                        "3",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.square(
                                    dimension: 60,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff3f4f6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffd1d5dc),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        )
                                      ),
                                      child: Text(
                                        "4",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox.square(
                                    dimension: 60,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff3f4f6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffd1d5dc),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        )
                                      ),
                                      child: Text(
                                        "5",
                                        style: TextStyle(
                                          fontSize: 16,
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
