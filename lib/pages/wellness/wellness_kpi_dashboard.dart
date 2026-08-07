import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/services/wellness_kpi_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dashboard Skor KPI Wellness = (%SEHAT × 50%) + (%TENANG × 25%) + (%HIJAU × 25%).
class WellnessKPIDashboard extends StatefulWidget {
  const WellnessKPIDashboard({super.key});

  @override
  State<WellnessKPIDashboard> createState() => _WellnessKPIDashboardState();
}

class _WellnessKPIDashboardState extends State<WellnessKPIDashboard> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFEEFDF5),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00C368),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'KPI Wellness',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C368),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _data == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(FontAwesomeIcons.circleExclamation,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'Skor KPI Wellness tidak tersedia',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pastikan Anda sudah login dan memiliki akses ke API',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C368),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildScoreHero(),
                                const SizedBox(height: 16),
                                _buildDimensionList(),
                                const SizedBox(height: 16),
                                _buildPredikatCard(),
                                const SizedBox(height: 16),
                                _buildFormulaCard(),
                                const SizedBox(height: 24),
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

  Widget _buildScoreHero() {
    final data = _data!;
    final skor = (data['skor_kpi_wellness'] ?? 0).toDouble();
    final predikat = data['predikat'] ?? '-';
    final periode = data['periode'] ?? {};
    final namaBulan = periode['nama_bulan'] ?? '';
    final tahun = periode['tahun'] ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
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
            color: const Color(0xFF00C368).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Skor KPI Wellness',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '$namaBulan $tahun',
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Text(
            '${skor.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              predikat,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionList() {
    final dimensi = _data!['dimensi'] as List<dynamic>? ?? [];
    final maksTotal = _data!['maks_poin_bulan'] ?? 196;

    final config = {
      'sehat': (FontAwesomeIcons.heartPulse, const Color(0xFFfa2c37)),
      'tenang': (FontAwesomeIcons.brain, const Color(0xFF2a7fff)),
      'hijau': (FontAwesomeIcons.leaf, const Color(0xFF00c84f)),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Komponen Dimensi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Total maksimal: $maksTotal poin/bulan',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 12),
          for (final item in dimensi) ...[
            _buildDimensionRow(item, config),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDimensionRow(Map<String, dynamic> item,
      Map<String, (FaIconData, Color)> config) {
    final modul = item['modul'] ?? '';
    final (icon, color) = config[modul] ??
        (FontAwesomeIcons.circleInfo, const Color(0xFF00C368));
    final persen = (item['persen'] ?? 0).toDouble();
    final poin = item['poin_diperoleh'] ?? 0;
    final maks = item['maks_poin_bulan'] ?? 0;
    final bobot = item['bobot_persen'] ?? 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['nama'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$poin/$maks poin · $bobot%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (persen / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${persen.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPredikatCard() {
    final predikat = _data!['predikat'] ?? '-';
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.medal,
              color: Color(0xFF00C368), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Predikat',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  predikat,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C368),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C368).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rumus Perhitungan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            '(%SEHAT × 50%) + (%TENANG × 25%) + (%HIJAU × 25%)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF009B54),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Predikat: ≥90% Sangat Baik · 75–89,9% Baik · 60–74,9% Cukup · <60% Perlu Perbaikan',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }
}
