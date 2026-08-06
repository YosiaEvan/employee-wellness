import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_task_card.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GayaHidupHijau extends StatefulWidget {
  const GayaHidupHijau({super.key});

  @override
  State<GayaHidupHijau> createState() => _GayaHidupHijauState();
}

class _GayaHidupHijauState extends State<GayaHidupHijau> {
  final Map<int, bool> _taskStatus = {
    0: false,
    1: false,
    2: false,
    3: false,
  };

  void _toggleTask(int index, String title) {
    setState(() {
      _taskStatus[index] = !(_taskStatus[index] ?? false);
    });

    if (_taskStatus[index] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Tugas '$title' selesai!"),
          backgroundColor: const Color(0xff15803d),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  double get _progress {
    int completed = _taskStatus.values.where((v) => v).length;
    return completed / _taskStatus.length;
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
              color: const Color(0xff15803d),
              heading: "Gaya Hidup Hijau",
              subHeading: "Harmoni dengan Alam",
              destination: const HijauHomepage(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xff15803d), const Color(0xff22c55e)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Progress Gaya Hidup",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${(_progress * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${_taskStatus.values.where((v) => v).length} dari ${_taskStatus.length} misi selesai",
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      "Misi Harian Hijau",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    HijauTaskCard(
                      sectionColor: const Color(0xff15803d),
                      icon: FontAwesomeIcons.recycle,
                      title: "Daur Ulang di Rumah & Kantor",
                      difficulty: "Sedang",
                      description: "Pisahkan sampah organik, anorganik, dan B3 untuk memudahkan proses daur ulang.",
                      points: 80,
                      benefit: "Mengurangi beban TPA hingga 60%",
                      isCompleted: _taskStatus[0] ?? false,
                      onSelesai: () => _toggleTask(0, "Daur Ulang"),
                    ),
                    
                    HijauTaskCard(
                      sectionColor: const Color(0xff15803d),
                      icon: FontAwesomeIcons.leaf,
                      title: "Energi Terbarukan & Hemat Energi",
                      difficulty: "Mudah",
                      description: "Matikan lampu dan cabut charger saat tidak digunakan untuk efisiensi energi.",
                      points: 60,
                      benefit: "Menghemat tagihan listrik bulanan",
                      isCompleted: _taskStatus[1] ?? false,
                      onSelesai: () => _toggleTask(1, "Hemat Energi"),
                    ),
                    
                    HijauTaskCard(
                      sectionColor: const Color(0xff15803d),
                      icon: FontAwesomeIcons.ban,
                      title: "Kurangi Penggunaan Plastik",
                      difficulty: "Mudah",
                      description: "Gunakan kemasan ramah lingkungan dan hindari sedotan plastik sekali pakai.",
                      points: 70,
                      benefit: "Melindungi ekosistem laut",
                      isCompleted: _taskStatus[2] ?? false,
                      onSelesai: () => _toggleTask(2, "Kurangi Plastik"),
                    ),
                    
                    HijauTaskCard(
                      sectionColor: const Color(0xff15803d),
                      icon: FontAwesomeIcons.seedling,
                      title: "Buat Ruang Hijau",
                      difficulty: "Sedang",
                      description: "Tanam minimal satu tanaman indoor di meja kerja atau di halaman rumah.",
                      points: 100,
                      benefit: "Udara lebih segar dan mengurangi stress",
                      isCompleted: _taskStatus[3] ?? false,
                      onSelesai: () => _toggleTask(3, "Buat Ruang Hijau"),
                    ),

                    const SizedBox(height: 20),

                    // CTA Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xfff0fdf4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xff15803d).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Jadikan Hijau Sebagai Budaya",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff15803d),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Setiap tindakan kecil Anda sangat berharga bagi masa depan bumi kita.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff15803d),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Saya Berkomitmen Hidup Hijau",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
