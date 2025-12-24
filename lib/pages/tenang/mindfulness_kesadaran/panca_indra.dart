import 'package:audioplayers/audioplayers.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PancaIndra extends StatefulWidget {
  const PancaIndra({super.key});

  @override
  State<PancaIndra> createState() => _PancaIndraState();
}

class _PancaIndraState extends State<PancaIndra> with TickerProviderStateMixin {
  int _currentStep = 0;
  int totalStep = 5;
  late final AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  void addStep() {
    setState(() {
      _currentStep++;
    });

    if (_currentStep == totalStep) {
      _audioPlayer.play(
        AssetSource('sounds/done.wav'),
      );
    }
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
                  color: Color(0xff0090ec),
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
                              "5 Panca Indra",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Langkah ${_currentStep + 1} dari 5",
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
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              child: switch (_currentStep) {
                                0 => Column(
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0090ec),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.eye,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Text(
                                      "Lihat",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "5 hal yang dapat Anda lihat di sekitar",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                1 => Column(
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0090ec),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.hand,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Text(
                                      "Sentuh",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "4 hal yang dapat Anda sentuh",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                2 => Column(
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0090ec),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.earListen,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Text(
                                      "Dengar",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "3 suara yang dapat Anda dengar",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                3 => Column(
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0090ec),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.wind,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Text(
                                      "Cium",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "2 aroma yang dapat Anda cium",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                4 => Column(
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0090ec),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.coffee,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Text(
                                      "Rasa",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "1 rasa di mulut Anda",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                _ => Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 160,
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
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 320),
                                      child: Text(
                                        "Selamat! Anda telah menyelesaikan sesi Body Scan. Bagaimana perasaan Anda sekarang?",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),
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
                                      )
                                    ),
                                  ],
                                ),
                              }
                          ),
                          (_currentStep < totalStep) ?
                              Column(
                                children: [
                                  SizedBox(height: 40,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(totalStep, (index) {
                                      final bool isActive = index == _currentStep;

                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: isActive ? 32 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isActive ? const Color(0xff00b8db) : Colors.grey,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 40,),
                                  GestureDetector(
                                    onTap: addStep,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Color(0xff0090ec),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Lanjut",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          : Text(""),
                        ],
                      )
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
