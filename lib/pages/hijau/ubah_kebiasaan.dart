import 'package:employee_wellness/config/hijau_scan_points.dart';
import 'package:employee_wellness/pages/hijau/hijau_scan_page.dart';
import 'package:flutter/material.dart';

class UbahKebiasaan extends StatelessWidget {
  const UbahKebiasaan({super.key});

  @override
  Widget build(BuildContext context) {
    return const HijauScanPage(
      point: HijauScanPoints.ubahKebiasaan,
      heading: "Ubah Kebiasaan",
      subHeading: "Menjadi Refleks Harian",
    );
  }
}
