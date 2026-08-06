import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/module_section_card.dart';
import 'package:employee_wellness/pages/hijau/hemat_energi.dart';
import 'package:employee_wellness/pages/hijau/hijau_kpi_dashboard.dart';
import 'package:employee_wellness/pages/hijau/zero_waste.dart';
import 'package:employee_wellness/pages/hijau/konservasi_air.dart';
import 'package:employee_wellness/pages/hijau/gaya_hidup_hijau.dart';
import 'package:employee_wellness/pages/hijau/ajak_orang_lain.dart';
import 'package:employee_wellness/pages/hijau/ubah_kebiasaan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HijauHomepage extends StatelessWidget {
  const HijauHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff059669), Color(0xff34D399)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: FaIcon(FontAwesomeIcons.arrowLeft, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("HIJAU 360\u00B0", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text("Lingkungan Berkelanjutan", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HijauKPIDashboard()),
                      );
                    },
                    child: SizedBox.square(
                      dimension: 40,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: FaIcon(FontAwesomeIcons.chartLine, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ModuleSectionCard(
                      destination: const HematEnergi(),
                      backgroundColor: const Color(0xffecfdf5),
                      sectionColor: const Color(0xff059669),
                      icon: FontAwesomeIcons.bolt,
                      heading: "Hemat Energi",
                      subHeading: "Efisiensi Sumber Daya",
                      description: "Langkah kecil harian untuk mengurangi emisi karbon.",
                      targetText: "4 tugas harian",
                    ),
                    const SizedBox(height: 20),
                    ModuleSectionCard(
                      destination: const ZeroWaste(),
                      backgroundColor: const Color(0xfff0fdf4),
                      sectionColor: const Color(0xff16a34a),
                      icon: FontAwesomeIcons.recycle,
                      heading: "Zero Waste",
                      subHeading: "Manajemen Sampah",
                      description: "Kelola konsumsi dan limbah untuk lingkungan lebih bersih.",
                      targetText: "8 tugas harian",
                    ),
                    const SizedBox(height: 20),
                    ModuleSectionCard(
                      destination: const KonservasiAir(),
                      backgroundColor: const Color(0xfff0f9ff),
                      sectionColor: const Color(0xff0ea5e9),
                      icon: FontAwesomeIcons.droplet,
                      heading: "Konservasi Air",
                      subHeading: "Manajemen Air Bersih",
                      description: "Jaga setiap tetes air dengan penggunaan yang bijak.",
                      targetText: "3 tugas harian",
                    ),
                    const SizedBox(height: 20),
                    ModuleSectionCard(
                      destination: const GayaHidupHijau(),
                      backgroundColor: const Color(0xfff7fee7),
                      sectionColor: const Color(0xff15803d),
                      icon: FontAwesomeIcons.leaf,
                      heading: "Gaya Hidup Hijau",
                      subHeading: "Harmoni dengan Alam",
                      description: "Integrasikan kebiasaan ramah lingkungan dalam keseharian.",
                      targetText: "4 misi selesai",
                    ),
                    const SizedBox(height: 20),
                    ModuleSectionCard(
                      destination: const UbahKebiasaan(),
                      backgroundColor: const Color(0xffecfdf5),
                      sectionColor: const Color(0xff10b981),
                      icon: FontAwesomeIcons.arrowsRotate,
                      heading: "Ubah Kebiasaan",
                      subHeading: "Langkah Kecil Berkelanjutan",
                      description: "Mulai perjalanan Anda mengubah kebiasaan lama menjadi ramah lingkungan.",
                      targetText: "Streak 5 hari",
                    ),
                    const SizedBox(height: 20),
                    ModuleSectionCard(
                      destination: const AjakOrangLain(),
                      backgroundColor: const Color(0xfffffbeb),
                      sectionColor: const Color(0xfff59e0b),
                      icon: FontAwesomeIcons.userPlus,
                      heading: "Ajak Orang Lain",
                      subHeading: "Kolaborasi Sosial",
                      description: "Bagikan semangat hidup sehat dan kumpulkan poin bersama teman.",
                      targetText: "+75 poin/teman",
                    ),
                    const SizedBox(height: 20),
                    _buildComingSoonCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.leaf, size: 40, color: Colors.green.withOpacity(0.2)),
          SizedBox(height: 12),
          Text(
            "Fitur Lainnya Segera Hadir",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Manajemen sampah, efisiensi air, dan lainnya sedang dikembangkan.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
