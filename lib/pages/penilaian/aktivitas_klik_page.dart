import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/config/penilaian_points.dart';
import 'package:employee_wellness/services/aktivitas_service.dart';
import 'package:employee_wellness/services/sehat_kpi_service.dart';
import 'package:employee_wellness/services/tenang_kpi_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Halaman klik self-report penilaian SEHAT/TENANG.
/// User membaca deskripsi lalu menekan tombol konfirmasi = 1 klik = 1 poin
/// (dibatasi cap mingguan per aktivitas sesuai `penilaian.md`).
class AktivitasKlikPage extends StatefulWidget {
  final PenilaianPoint point;
  final String heading;
  final String subHeading;
  final Widget destination;

  const AktivitasKlikPage({
    super.key,
    required this.point,
    required this.heading,
    required this.subHeading,
    required this.destination,
  });

  @override
  State<AktivitasKlikPage> createState() => _AktivitasKlikPageState();
}

class _AktivitasKlikPageState extends State<AktivitasKlikPage> {
  bool _loadingKpi = true;
  bool _recording = false;
  int _weekCount = 0;
  int _monthCount = 0;
  bool _doneThisWeek = false;

  PenilaianPoint get point => widget.point;

  // Pola makan tanpa_minyak / tanpa_gula / porsi_kalori kini otomatis dari log makanan — tidak perlu klik manual
  bool get isOtomatis => point.kode == 'tanpa_minyak' || point.kode == 'tanpa_gula' || point.kode == 'porsi_kalori';

  @override
  void initState() {
    super.initState();
    _loadKpi();
  }

  Future<void> _loadKpi() async {
    setState(() => _loadingKpi = true);
    final Map<String, dynamic> weekly;
    final Map<String, dynamic> monthly;
    if (point.modul == 'tenang') {
      weekly = await TenangKPIService.getWeeklyKPI();
      monthly = await TenangKPIService.getMonthlyKPI();
    } else {
      weekly = await SehatKPIService.getWeeklyKPI();
      monthly = await SehatKPIService.getMonthlyKPI();
    }
    if (!mounted) return;

    setState(() {
      final weekItem = _findByKode(weekly['data']?['aktivitas'], point.kode);
      final monthItem = _findByKode(monthly['data']?['aktivitas'], point.kode);
      _weekCount = (weekItem?['tercapai'] as num?)?.toInt() ?? 0;
      _monthCount = (monthItem?['tercapai'] as num?)?.toInt() ?? 0;
      _doneThisWeek = _weekCount >= point.targetPerWeek;
      _loadingKpi = false;
    });
  }

  Map<String, dynamic>? _findByKode(dynamic list, String kode) {
    if (list is! List) return null;
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

    final result = await AktivitasService.recordAktivitas(
      modul: point.modul,
      aktivitas: point.kode,
      deskripsi: point.title,
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
                ? ' ${point.title} tercatat. +1 poin!'
                : (message?.isNotEmpty == true
                    ? ' $message'
                    : ' Gagal mencatat. Coba lagi.'),
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
              destination: widget.destination,
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
                      _buildCard(),
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
    if (isOtomatis) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffeefdf5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff00c368).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.robot, color: Color(0xff00c368), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Otomatis dari log makanan — ${point.targetPerWeek} poin/minggu (maks ${point.targetPerMonth}/bulan). Poin berkurang jika ada makanan mengandung ${point.kode == 'tanpa_minyak' ? 'minyak' : point.kode == 'tanpa_gula' ? 'gula' : 'kalori berlebih'}. Tidak perlu klik manual.',
                style: const TextStyle(fontSize: 12, color: Color(0xff065f46)),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: point.softColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: point.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          FaIcon(
            _doneThisWeek ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleInfo,
            color: point.color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _loadingKpi
                  ? 'Memeriksa status...'
                  : (_doneThisWeek
                      ? 'Aktivitas ini sudah mencapai batas minggu ini (${point.targetPerWeek} poin).'
                      : 'Batas mingguan: ${point.targetPerWeek} poin untuk aktivitas ini.'),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(point.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  point.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: point.softColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(point.description, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressChip('Minggu ini', _weekCount, point.targetPerWeek),
              _buildProgressChip('Bulan ini', _monthCount, point.targetPerMonth),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isOtomatis || _doneThisWeek || _recording) ? null : _confirm,
              icon: _recording
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : FaIcon(
                      isOtomatis ? FontAwesomeIcons.robot : FontAwesomeIcons.circleCheck,
                      size: 18,
                      color: Colors.white,
                    ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  isOtomatis
                      ? 'Otomatis via Log Makanan — Tidak Perlu Klik'
                      : _doneThisWeek
                          ? 'Selesai Minggu Ini'
                          : '${point.confirmLabel} +1 Poin',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOtomatis ? Colors.grey.shade400 : point.color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (isOtomatis) ...[
            const SizedBox(height: 8),
            const Text(
              'Cukup catat makanan harian di halaman Pola Makan Sehat. Sistem otomatis mendeteksi mengandung_minyak / mengandung_gula dari food_nutrition.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Satu klik = satu laporan = 1 poin',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChip(String label, int count, int target) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: point.softColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            '$count / $target',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: point.color,
            ),
          ),
        ],
      ),
    );
  }
}
