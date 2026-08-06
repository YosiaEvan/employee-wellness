import 'package:audioplayers/audioplayers.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/tenang/mindfulness_kesadaran.dart';
import 'package:employee_wellness/services/tenang_service.dart';
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
      _audioPlayer.play(AssetSource('sounds/done.wav'));

      // Kirim data sesi ke backend
      TenangService.recordSession(
        kategori: TenangKategori.mindfulness,
        subKategori: TenangSubKategori.pancaIndra,
        durasiDetik: 5 * 60,
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
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff0090ec),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
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
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const FaIcon(
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
                          const Text(
                            "5 Panca Indra",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Langkah ${_currentStep + 1} dari 5",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox.square(
                        dimension: 40,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const FaIcon(
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
              child: ResponsiveContainer(
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
                                      alignment: Alignment.center,
                                      width: 140,
                                      height: 140,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff0090ec),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.eye,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Lihat",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
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
                                      alignment: Alignment.center,
                                      width: 140,
                                      height: 140,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff0090ec),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.hand,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Sentuh",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
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
                                      alignment: Alignment.center,
                                      width: 140,
                                      height: 140,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff0090ec),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.earListen,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Dengar",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
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
                                      alignment: Alignment.center,
                                      width: 140,
                                      height: 140,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff0090ec),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.wind,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Cium",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
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
                                      alignment: Alignment.center,
                                      width: 140,
                                      height: 140,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff0090ec),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.mugSaucer,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Rasa",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
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
                                      alignment: Alignment.center,
                                      width: 160,
                                      height: 160,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff00d477),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.check,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  const Text(
                                    "Sesi Selesai 🎉",
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 320),
                                    child: const Text(
                                      "Selamat! Anda telah menyelesaikan sesi Body Scan. Bagaimana perasaan Anda sekarang?",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

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
                                                MaterialPageRoute(builder: (context) => const MindfulnessKesadaran()),
                                              ),
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff0090ed),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
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

                                          const SizedBox(height: 16),

                                          // Continue to Manajemen Stress button
                                          GestureDetector(
                                            onTap: () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const MindfulnessKesadaran()),
                                              ),
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  )),
                                              child: const Text(
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
                                      )),
                                ],
                              ),
                          }),
                          (_currentStep < totalStep)
                              ? Column(
                                  children: [
                                    const SizedBox(height: 40),
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
                                    const SizedBox(height: 40),
                                    GestureDetector(
                                      onTap: addStep,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0090ec),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
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
                              : const Text(""),
                        ],
                      )
                    ],
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
