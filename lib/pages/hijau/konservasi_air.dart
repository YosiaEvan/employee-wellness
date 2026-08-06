import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_task_card.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KonservasiAir extends StatefulWidget {
  const KonservasiAir({super.key});

  @override
  State<KonservasiAir> createState() => _KonservasiAirState();
}

class _KonservasiAirState extends State<KonservasiAir> {
  final Map<int, bool> _taskStatus = {};

  void _toggleTask(int index, String title) {
    setState(() {
      _taskStatus[index] = !(_taskStatus[index] ?? false);
    });

    if (_taskStatus[index] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Tugas '$title' selesai!"),
          backgroundColor: const Color(0xff0ea5e9),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
            BottomHeader(
              color: const Color(0xff0ea5e9),
              heading: "Konservasi Air",
              subHeading: "Manajemen Air Bersih",
              destination: const HijauHomepage(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xfff0f9ff),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffbae6fd).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff0ea5e9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const FaIcon(FontAwesomeIcons.droplet, size: 30, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Pentingnya Hemat Air",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff075985),
                                      ),
                                    ),
                                    Text(
                                      "Air adalah sumber kehidupan. Mari jaga setiap tetesnya dengan bijak.",
                                      style: TextStyle(fontSize: 14, color: Color(0xff0369a1)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Misi Konservasi Air",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HijauTaskCard(
                      sectionColor: const Color(0xff0ea5e9),
                      icon: FontAwesomeIcons.faucetDrip,
                      title: "Tutup Keran Rapat Setelah Pakai",
                      difficulty: "Mudah",
                      description: "Pastikan keran air tertutup sempurna setelah mencuci tangan, wudhu, atau membersihkan peralatan.",
                      points: 50,
                      benefit: "Hemat hingga 15 liter air per menit",
                      isCompleted: _taskStatus[0] ?? false,
                      onSelesai: () => _toggleTask(0, "Tutup Keran Rapat"),
                    ),
                    HijauTaskCard(
                      sectionColor: const Color(0xff0ea5e9),
                      icon: FontAwesomeIcons.wrench,
                      title: "Laporkan Kebocoran Air",
                      difficulty: "Sedang",
                      description: "Segera lapor ke bagian maintenance jika melihat pipa, keran, atau toilet yang bocor di area kantor.",
                      points: 100,
                      benefit: "Cegah pemborosan ribuan liter air per bulan",
                      isCompleted: _taskStatus[1] ?? false,
                      onSelesai: () => _toggleTask(1, "Laporkan Kebocoran"),
                    ),
                    HijauTaskCard(
                      sectionColor: const Color(0xff0ea5e9),
                      icon: FontAwesomeIcons.water,
                      title: "Gunakan Air Seperlunya",
                      difficulty: "Mudah",
                      description: "Gunakan volume air secukupnya dan tidak membiarkan air mengalir terus-menerus saat tidak digunakan.",
                      points: 40,
                      benefit: "Menjaga keberlanjutan cadangan air tanah",
                      isCompleted: _taskStatus[2] ?? false,
                      onSelesai: () => _toggleTask(2, "Gunakan Air Seperlunya"),
                    ),
                    const SizedBox(height: 20),
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
