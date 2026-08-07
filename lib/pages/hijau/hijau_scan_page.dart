import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_scan_card.dart';
import 'package:employee_wellness/config/hijau_scan_points.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:employee_wellness/services/hijau_kpi_service.dart';
import 'package:employee_wellness/services/hijau_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Halaman titik scan HIJAU 360°.
/// User menonton animasi (video), membaca wawasan, lalu menekan tombol
/// konfirmasi "Sudah ..." = 1 klik = 1 laporan = 1 poin (cap 1/minggu).
class HijauScanPage extends StatefulWidget {
  final HijauScanPoint point;
  final String heading;
  final String subHeading;

  const HijauScanPage({
    super.key,
    required this.point,
    required this.heading,
    required this.subHeading,
  });

  @override
  State<HijauScanPage> createState() => _HijauScanPageState();
}

class _HijauScanPageState extends State<HijauScanPage> {
  bool _loadingKpi = true;
  bool _recording = false;
  int _weekCount = 0;
  int _monthCount = 0;
  bool _doneThisWeek = false;

  HijauScanPoint get point => widget.point;

  @override
  void initState() {
    super.initState();
    _loadKpi();
  }

  Future<void> _loadKpi() async {
    setState(() => _loadingKpi = true);
    final weekly = await HijauKPIService.getWeeklyKPI();
    final monthly = await HijauKPIService.getMonthlyKPI();
    if (!mounted) return;

    setState(() {
      if (weekly['success'] == true) {
        final list = (weekly['data']?['aktivitas'] as List<dynamic>? ?? []);
        final item = _findByKode(list, point.kode);
        _weekCount = (item?['tercapai'] as num?)?.toInt() ?? 0;
        _doneThisWeek = _weekCount >= 1;
      }
      if (monthly['success'] == true) {
        final list = (monthly['data']?['aktivitas'] as List<dynamic>? ?? []);
        final item = _findByKode(list, point.kode);
        _monthCount = (item?['tercapai'] as num?)?.toInt() ?? 0;
      }
      _loadingKpi = false;
    });
  }

  Map<String, dynamic>? _findByKode(List<dynamic> list, String kode) {
    for (final item in list) {
      if (item is Map<String, dynamic> &&
          (item['aktivitas'] ?? item['kode']).toString() == kode) {
        return item;
      }
    }
    return null;
  }

  Future<void> _confirm() async {
    if (_recording) return;
    setState(() => _recording = true);

    final result = await HijauService.recordGreenActivity(
      activityType: point.kode,
      description: point.title,
      points: 1,
      category: point.kategori,
    );

    if (!mounted) return;
    setState(() => _recording = false);

    final ok = result['success'] == true;
    final message = result['message']?.toString();
    final isCapReached = result['statusCode'] == 409;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? '✅ ${point.title} tercatat. +1 poin!'
                : (message?.isNotEmpty == true
                    ? '⚠️ $message'
                    : '⚠️ Gagal mencatat. Coba lagi.'),
          ),
          backgroundColor: ok
              ? point.color
              : (isCapReached ? Colors.orange.shade700 : Colors.red),
          duration: const Duration(seconds: 3),
        ),
      );

    if (ok || isCapReached) {
      _loadKpi();
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
              color: point.color,
              heading: widget.heading,
              subHeading: widget.subHeading,
              destination: const HijauHomepage(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadKpi,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBanner(),
                      const SizedBox(height: 16),
                      HijauScanCard(
                        point: point,
                        doneThisWeek: _doneThisWeek,
                        loading: _recording,
                        onConfirm: _confirm,
                        weekCount: _weekCount,
                        monthCount: _monthCount,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: _loadKpi,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(
                            _loadingKpi ? 'Memuat data...' : 'Muat ulang status',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
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

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: point.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: point.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: point.color, shape: BoxShape.circle),
            child: FaIcon(point.icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _doneThisWeek
                  ? 'Kamu sudah meraih poin ${point.title} minggu ini. '
                      'Kembali pekan depan untuk poin baru!'
                  : 'Scan & lakukan aksi hijau ini. Satu laporan per minggu '
                      '= +1 poin. Kumpulkan hingga 4 poin sebulan.',
              style: TextStyle(fontSize: 13.5, height: 1.4, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
