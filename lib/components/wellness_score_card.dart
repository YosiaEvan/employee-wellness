import 'package:employee_wellness/pages/wellness/wellness_kpi_dashboard.dart';
import 'package:employee_wellness/services/wellness_kpi_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Kartu ringkas Skor KPI Wellness di beranda. Ketuk untuk buka dashboard penuh.
class WellnessScoreCard extends StatefulWidget {
  const WellnessScoreCard({super.key});

  @override
  State<WellnessScoreCard> createState() => _WellnessScoreCardState();
}

class _WellnessScoreCardState extends State<WellnessScoreCard> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await WellnessKPIService.getMonthlyWellness();
    if (!mounted) return;
    setState(() {
      if (result['success'] == true) _data = result['data'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WellnessKPIDashboard()),
        ).then((_) => _load());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C368), Color(0xFF009B54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C368).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _loading
            ? const Row(
                children: [
                  SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Menghitung skor...',
                      style: TextStyle(color: Colors.white70)),
                ],
              )
            : _data == null
                ? const Row(
                    children: [
                      FaIcon(FontAwesomeIcons.circleExclamation,
                          color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Skor KPI Wellness belum tersedia. Ketuk untuk mencoba lagi.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : _buildContent(_data!),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final skor = (data['skor_kpi_wellness'] ?? 0).toDouble();
    final predikat = data['predikat'] ?? '-';
    final periode = data['periode'] ?? {};
    final namaBulan = periode['nama_bulan'] ?? '';
    final tahun = periode['tahun'] ?? '';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const FaIcon(FontAwesomeIcons.heartPulse,
              color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skor KPI Wellness',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 2),
              Text(
                '$namaBulan $tahun',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${skor.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· $predikat',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const FaIcon(FontAwesomeIcons.chevronRight,
            size: 14, color: Colors.white70),
      ],
    );
  }
}
