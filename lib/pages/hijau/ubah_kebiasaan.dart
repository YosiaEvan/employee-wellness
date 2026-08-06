import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_task_card.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UbahKebiasaan extends StatefulWidget {
  const UbahKebiasaan({super.key});

  @override
  State<UbahKebiasaan> createState() => _UbahKebiasaanState();
}

class _UbahKebiasaanState extends State<UbahKebiasaan> {
  final Map<int, bool> _taskStatus = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  final int _streakDays = 5;

  void _toggleTask(int index, String title) {
    setState(() {
      _taskStatus[index] = !(_taskStatus[index] ?? false);
    });

    if (_taskStatus[index] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Kebiasaan '$title' dilakukan hari ini!"),
          backgroundColor: const Color(0xff059669),
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
              color: const Color(0xff10b981),
              heading: "Ubah Kebiasaan",
              subHeading: "Langkah Kecil, Dampak Besar",
              destination: const HijauHomepage(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress & Streak Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff10b981), Color(0xff34d399)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff10b981).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Streak Hari Ini",
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          const FaIcon(FontAwesomeIcons.fire, color: Colors.orangeAccent, size: 20),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "$_streakDays Hari",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${(_progress * 100).toInt()}% Selesai",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${_taskStatus.values.where((v) => v).length} dari ${_taskStatus.length} kebiasaan diubah",
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                      const Text(
                        "Target Kebiasaan Baru",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      HijauTaskCard(
                        icon: FontAwesomeIcons.mugHot,
                        title: "Bawa Tumbler/Mug Sendiri",
                        difficulty: "Mudah",
                        description: "Gunakan botol minum atau gelas sendiri untuk mengurangi pemakaian gelas plastik sekali pakai.",
                        points: 40,
                        benefit: "Kurangi 20 gelas plastik/bulan",
                        isCompleted: _taskStatus[0] ?? false,
                        onSelesai: () => _toggleTask(0, "Bawa Tumbler"),
                        sectionColor: const Color(0xff10b981),
                      ),

                      HijauTaskCard(
                        icon: FontAwesomeIcons.bagShopping,
                        title: "Bawa Tas Belanja Sendiri",
                        difficulty: "Mudah",
                        description: "Selalu siapkan tas belanja kain saat ke supermarket untuk menghindari penggunaan kantong plastik.",
                        points: 50,
                        benefit: "Kurangi 30 kantong plastik/bulan",
                        isCompleted: _taskStatus[1] ?? false,
                        onSelesai: () => _toggleTask(1, "Bawa Tas Belanja"),
                        sectionColor: const Color(0xff10b981),
                      ),

                      HijauTaskCard(
                        icon: FontAwesomeIcons.boxOpen,
                        title: "Bawa Wadah Makan Sendiri",
                        difficulty: "Sedang",
                        description: "Bawa kotak makan sendiri saat membeli makanan di kantin untuk mengurangi sampah kemasan.",
                        points: 80,
                        benefit: "Kurangi timbulan sampah styrofoam",
                        isCompleted: _taskStatus[2] ?? false,
                        onSelesai: () => _toggleTask(2, "Bawa Wadah Makan"),
                        sectionColor: const Color(0xff10b981),
                      ),

                      HijauTaskCard(
                        icon: FontAwesomeIcons.carSide,
                        title: "Carpool atau Transportasi Umum",
                        difficulty: "Sulit",
                        description: "Berbagi kendaraan atau gunakan transportasi publik untuk menekan emisi gas buang kendaraan.",
                        points: 150,
                        benefit: "Kurangi jejak karbon transportasi",
                        isCompleted: _taskStatus[3] ?? false,
                        onSelesai: () => _toggleTask(3, "Transportasi Hijau"),
                        sectionColor: const Color(0xff10b981),
                      ),

                      HijauTaskCard(
                        icon: FontAwesomeIcons.display,
                        title: "Matikan Layar Saat Tidak Dipakai",
                        difficulty: "Mudah",
                        description: "Biasakan mematikan monitor saat meninggalkan meja kerja lebih dari 15 menit.",
                        points: 30,
                        benefit: "Hemat konsumsi listrik kantor",
                        isCompleted: _taskStatus[4] ?? false,
                        onSelesai: () => _toggleTask(4, "Matikan Layar"),
                        sectionColor: const Color(0xff10b981),
                      ),

                      HijauTaskCard(
                        icon: FontAwesomeIcons.fileSignature,
                        title: "Gunakan Dokumen Digital",
                        difficulty: "Sedang",
                        description: "Pilih format PDF atau digital untuk review dokumen tanpa perlu mencetaknya di kertas.",
                        points: 70,
                        benefit: "Hemat penggunaan kertas kantor",
                        isCompleted: _taskStatus[5] ?? false,
                        onSelesai: () => _toggleTask(5, "Dokumen Digital"),
                        sectionColor: const Color(0xff10b981),
                      ),

                      const SizedBox(height: 20),

                      // CTA Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xffecfdf5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xff10b981).withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const FaIcon(FontAwesomeIcons.leaf, color: Color(0xff10b981), size: 40),
                            const SizedBox(height: 16),
                            const Text(
                              "Komitmen Adalah Kunci",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff065f46),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Kebiasaan kecil yang dilakukan secara konsisten akan memberikan dampak luar biasa bagi lingkungan kita.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                              softWrap: true,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff10b981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Lanjutkan Konsistensi",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
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
            ),
          ],
        ),
      ),
    );
  }
}
