import 'package:employee_wellness/config/hijau_scan_points.dart';
import 'package:employee_wellness/pages/hijau/hijau_scan_page.dart';
import 'package:flutter/material.dart';

class ZeroWaste extends StatelessWidget {
  const ZeroWaste({super.key});

  @override
  Widget build(BuildContext context) {
    return const HijauScanPage(
      point: HijauScanPoints.zeroWaste,
      heading: "Zero Waste",
      subHeading: "Kurangi Sampah",
    );
  }
}
