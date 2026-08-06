import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_task_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HematEnergi extends StatefulWidget {
  const HematEnergi({super.key});

  @override
  State<HematEnergi> createState() => _HematEnergiState();
}

class _HematEnergiState extends State<HematEnergi> {
  final Map<int, bool> _taskStatus = {
    0: false,
    1: false,
    2: false,
    3: false,
  };

  void _toggleTask(int index) {
    setState(() {
      _taskStatus[index] = !(_taskStatus[index] ?? false);
    });
    
    final titles = [
      "Ganti ke Lampu LED",
      "AC Efisien 24 Derajat Celcius",
      "Energi Terbarukan & Hemat Energi",
      "Matikan Layar Saat Tidak Digunakan"
    ];

    if (_taskStatus[index] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Tugas '${titles[index]}' selesai!"),
          backgroundColor: const Color(0xff059669),
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
              color: const Color(0xff059669),
              heading: "Hemat Energi",
              subHeading: "Efisiensi Sumber Daya",
              destination: const HijauHomepage(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffecfdf5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xff34d399).withOpacity(0.3)),
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
                                      color: const Color(0xff059669),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const FaIcon(FontAwesomeIcons.bolt, size: 30, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mengapa Hemat Energi?",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff065f46),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Langkah kecil harian Anda mengurangi emisi karbon.",
                                        style: TextStyle(fontSize: 14, color: Color(0xff047857)),
                                        softWrap: true,
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
                        "Tugas Hari Ini",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.lightbulb,
                        title: "Ganti ke Lampu LED",
                        difficulty: "Mudah",
                        description: "Ganti semua lampu ruangan dengan LED hemat energi untuk pencahayaan yang lebih efisien.",
                        points: 100,
                        benefit: "Hemat 80% energi listrik",
                        isCompleted: _taskStatus[0] ?? false,
                        onSelesai: () => _toggleTask(0),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.temperatureLow,
                        title: "AC Efisien 24 Derajat Celcius",
                        difficulty: "Mudah",
                        description: "Set AC kantor pada suhu optimal 24-26 derajat celcius untuk kenyamanan dan efisiensi energi.",
                        points: 80,
                        benefit: "Hemat 15% tagihan listrik",
                        isCompleted: _taskStatus[1] ?? false,
                        onSelesai: () => _toggleTask(1),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.leaf,
                        title: "Energi Terbarukan & Hemat Energi",
                        difficulty: "Sedang",
                        description: "Matikan peralatan listrik saat tidak digunakan dan pilih peralatan yang ramah lingkungan.",
                        points: 100,
                        benefit: "Mengurangi jejak karbon kantor",
                        isCompleted: _taskStatus[2] ?? false,
                        onSelesai: () => _toggleTask(2),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.desktop,
                        title: "Matikan Layar Saat Tidak Digunakan",
                        difficulty: "Mudah",
                        description: "Jangan tinggalkan komputer menyala saat istirahat atau saat tidak digunakan dalam waktu lama.",
                        points: 90,
                        benefit: "Hemat 50kWh listrik/tahun",
                        isCompleted: _taskStatus[3] ?? false,
                        onSelesai: () => _toggleTask(3),
                      ),
                      const SizedBox(height: 20),
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
