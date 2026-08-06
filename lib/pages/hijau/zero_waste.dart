import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_task_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ZeroWaste extends StatefulWidget {
  const ZeroWaste({super.key});

  @override
  State<ZeroWaste> createState() => _ZeroWasteState();
}

class _ZeroWasteState extends State<ZeroWaste> {
  final Map<int, bool> _taskStatus = {};

  void _toggleTask(int index, String title) {
    setState(() {
      _taskStatus[index] = !(_taskStatus[index] ?? false);
    });

    if (_taskStatus[index] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Tugas '$title' selesai!"),
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
              heading: "Zero Waste",
              subHeading: "Manajemen Sampah",
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
                          color: const Color(0xfff0fdf4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xff86efac).withOpacity(0.3)),
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
                                      color: const Color(0xff16a34a),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const FaIcon(FontAwesomeIcons.recycle, size: 30, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Gaya Hidup Bebas Sampah",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff166534),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Kelola konsumsi dan limbah Anda untuk lingkungan yang lebih bersih.",
                                        style: TextStyle(fontSize: 14, color: Color(0xff15803d)),
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
                        "Misi Zero Waste",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.fileLines,
                        title: "Hari Tanpa Kertas",
                        difficulty: "Sedang",
                        description: "Gunakan dokumen digital secara penuh untuk semua keperluan kerja Anda hari ini.",
                        points: 75,
                        benefit: "Selamatkan 1 pohon per bulan",
                        isCompleted: _taskStatus[0] ?? false,
                        onSelesai: () => _toggleTask(0, "Hari Tanpa Kertas"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.bottleWater,
                        title: "Botol Minum Sendiri",
                        difficulty: "Mudah",
                        description: "Bawa botol minum sendiri dan hindari membeli air dalam kemasan plastik sekali pakai.",
                        points: 50,
                        benefit: "Kurangi 30 botol plastik per bulan",
                        isCompleted: _taskStatus[1] ?? false,
                        onSelesai: () => _toggleTask(1, "Botol Minum Sendiri"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.trashCan,
                        title: "Daur Ulang di Rumah & Kantor",
                        difficulty: "Sedang",
                        description: "Pisahkan sampah kertas dan sampah plastik/logam ke tempat sampah yang benar.",
                        points: 80,
                        benefit: "Memudahkan proses pengolahan limbah",
                        isCompleted: _taskStatus[2] ?? false,
                        onSelesai: () => _toggleTask(2, "Daur Ulang di Rumah & Kantor"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.ban,
                        title: "Kurangi Penggunaan Plastik",
                        difficulty: "Mudah",
                        description: "Hindari penggunaan sedotan, sendok, atau kantong plastik sekali pakai.",
                        points: 60,
                        benefit: "Mengurangi sampah plastik laut",
                        isCompleted: _taskStatus[3] ?? false,
                        onSelesai: () => _toggleTask(3, "Kurangi Penggunaan Plastik"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.bagShopping,
                        title: "Bawa Tas Belanja Sendiri",
                        difficulty: "Mudah",
                        description: "Selalu sediakan tas belanja kain saat berbelanja untuk menghindari kantong plastik.",
                        points: 80,
                        benefit: "Kurangi 150 kantong plastik/bulan",
                        isCompleted: _taskStatus[4] ?? false,
                        onSelesai: () => _toggleTask(4, "Bawa Tas Belanja Sendiri"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.box,
                        title: "Bawa Wadah Makan Sendiri",
                        difficulty: "Sedang",
                        description: "Gunakan wadah makan berulang saat membeli makanan take-away untuk menghindari styrofoam.",
                        points: 120,
                        benefit: "Kurangi 200 wadah styrofoam/tahun",
                        isCompleted: _taskStatus[5] ?? false,
                        onSelesai: () => _toggleTask(5, "Bawa Wadah Makan Sendiri"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.bus,
                        title: "Carpool atau Transportasi Umum",
                        difficulty: "Sulit",
                        description: "Gunakan transportasi umum atau berbagi kendaraan dengan rekan kerja untuk mengurangi emisi.",
                        points: 200,
                        benefit: "Kurangi 500Kg CO2/tahun",
                        isCompleted: _taskStatus[6] ?? false,
                        onSelesai: () => _toggleTask(6, "Carpool atau Transportasi Umum"),
                      ),
                      HijauTaskCard(
                        icon: FontAwesomeIcons.laptop,
                        title: "Gunakan Dokumen Digital",
                        difficulty: "Sedang",
                        description: "Optimalkan penggunaan cloud storage dan email daripada mencetak dokumen fisik.",
                        points: 110,
                        benefit: "Selamatkan 2 pohon/tahun",
                        isCompleted: _taskStatus[7] ?? false,
                        onSelesai: () => _toggleTask(7, "Gunakan Dokumen Digital"),
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
