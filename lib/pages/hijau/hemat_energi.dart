import 'package:employee_wellness/config/hijau_scan_points.dart';
import 'package:employee_wellness/pages/hijau/hijau_scan_page.dart';
import 'package:flutter/material.dart';

class HematEnergi extends StatelessWidget {
  const HematEnergi({super.key});

  @override
  Widget build(BuildContext context) {
    return const HijauScanPage(
      point: HijauScanPoints.hematListrik,
      heading: "Hemat Energi",
      subHeading: "Efisiensi Sumber Daya",
    );
  }
}
