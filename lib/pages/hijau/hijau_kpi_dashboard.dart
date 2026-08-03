import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/hijau_kpi_service.dart';
import '../../components/header.dart';

class HijauKPIDashboard extends StatefulWidget {
  const HijauKPIDashboard({super.key});

  @override
  State<HijauKPIDashboard> createState() => _HijauKPIDashboardState();
}

class _HijauKPIDashboardState extends State<HijauKPIDashboard> {
  bool isLoading = true;
  Map<String, dynamic>? dailyKPI;
  Map<String, dynamic>? weeklyKPI;
  Map<String, dynamic>? monthlyKPI;

  @override
  void initState() {
    super.initState();
    loadKPIData();
  }

  Future<void> loadKPIData() async {
    setState(() => isLoading = true);
    final dailyResult = await HijauKPIService.getDailyKPI();
    final weeklyResult = await HijauKPIService.getWeeklyKPI();
    final monthlyResult = await HijauKPIService.getMonthlyKPI();

    setState(() {
      if (dailyResult['success'] == true) dailyKPI = dailyResult['data'];
      if (weeklyResult['success'] == true) weeklyKPI = weeklyResult['data'];
      if (monthlyResult['success'] == true) monthlyKPI = monthlyResult['data'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFDF5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HijauKPIDetail()),
          );
        },
        backgroundColor: const Color(0xFF00C368),
        icon: FaIcon(FontAwesomeIcons.chartLine, color: Colors.white),
        label: const Text(
          'Lihat Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
                    icon: FaIcon(FontAwesomeIcons.arrowLeft),
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
                    'KPI Dashboard',
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (dailyKPI == null && weeklyKPI == null && monthlyKPI == null)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('Data KPI tidak tersedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Pastikan Anda sudah login dan memiliki akses ke API', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: loadKPIData,
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
                          onRefresh: loadKPIData,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMonthlyCard(),
                                const SizedBox(height: 16),
                                _buildWeeklyCard(),
                                const SizedBox(height: 16),
                                _buildTodayCard(),
                                const SizedBox(height: 16),
                                _buildKPITable(),
                                const SizedBox(height: 100),
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

  Widget _buildMonthlyCard() {
    if (monthlyKPI == null) return const SizedBox();

    final periode = monthlyKPI!['periode'];
    final ringkasan = monthlyKPI!['ringkasan'];
    final targetTotal = ringkasan['target_total_hari'] ?? 0;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? 0;
    final progressPersen = (ringkasan['progress_persen'] ?? 0).toDouble();
    final bulan = _getBulanIndonesia(periode['bulan']);
    final tahun = periode['tahun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C368), Color(0xFF009B54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C368).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.trophy, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text('KPI Hijau - $bulan $tahun', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('$tercapaiTotal / $targetTotal', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${progressPersen.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (ringkasan['total_poin'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Total poin: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('${ringkasan['total_poin']}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPersen / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard() {
    if (weeklyKPI == null) return const SizedBox();

    final periode = weeklyKPI!['periode'];
    final ringkasan = weeklyKPI!['ringkasan'];
    final aktivitas = weeklyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final targetTotal = ringkasan['target_total_hari'] ?? 0;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? 0;
    final progressPersen = (ringkasan['progress_persen'] ?? 0).toDouble();
    final mingguKe = periode['minggu_ke'];

    Map<String, dynamic> getAktivitas(String nama) {
      try {
        return aktivitas.firstWhere(
          (a) => a['nama'].toString().toLowerCase().contains(nama.toLowerCase()),
          orElse: () => {'tercapai': 0, 'target_per_minggu': 0},
        );
      } catch (e) {
        return {'tercapai': 0, 'target_per_minggu': 0};
      }
    }

    final transportasi = getAktivitas('Transportasi');
    final plastik = getAktivitas('Plastik');
    final listrik = getAktivitas('Listrik');
    final daurUlang = getAktivitas('Daur Ulang');

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
          Text('Minggu Ke-$mingguKe', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeeklyPoinItem('Transportasi', transportasi['tercapai'] ?? 0, transportasi['target_per_minggu'] ?? 5, FontAwesomeIcons.bicycle, Colors.green),
              _buildWeeklyPoinItem('Plastik', plastik['tercapai'] ?? 0, plastik['target_per_minggu'] ?? 5, FontAwesomeIcons.recycle, Colors.teal),
              _buildWeeklyPoinItem('Listrik', listrik['tercapai'] ?? 0, listrik['target_per_minggu'] ?? 5, FontAwesomeIcons.bolt, Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeeklyPoinItem('Daur Ulang', daurUlang['tercapai'] ?? 0, daurUlang['target_per_minggu'] ?? 5, FontAwesomeIcons.trashArrowUp, Colors.blue),
              if (ringkasan['total_poin'] != null)
                _buildWeeklyPoinItem('Poin', ringkasan['total_poin'] ?? 0, 0, FontAwesomeIcons.star, Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEFDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Minggu Ini', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('$tercapaiTotal / $targetTotal (${progressPersen.toStringAsFixed(0)}%)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C368))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPoinItem(String label, int poin, int maxPoin, FaIconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: FaIcon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(maxPoin > 0 ? '$poin/$maxPoin' : '$poin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTodayCard() {
    if (dailyKPI == null) return const SizedBox();

    final aktivitas = dailyKPI!['aktivitas'] as List<dynamic>? ?? [];

    Map<String, dynamic> getAktivitas(String kode) {
      try {
        return aktivitas.firstWhere(
          (a) => a['kode'].toString().toLowerCase() == kode.toLowerCase(),
          orElse: () => {'selesai': false},
        );
      } catch (e) {
        return {'selesai': false};
      }
    }

    final transportasi = getAktivitas('transportasi');
    final plastik = getAktivitas('plastik');
    final listrik = getAktivitas('listrik');
    final daurUlang = getAktivitas('daur_ulang');

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
          const Text('Aktivitas Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildTodayItem('Transportasi Hijau', transportasi['selesai'] ?? false, FontAwesomeIcons.bicycle, Colors.green),
          _buildTodayItem('Kurangi Plastik', plastik['selesai'] ?? false, FontAwesomeIcons.recycle, Colors.teal),
          _buildTodayItem('Hemat Listrik', listrik['selesai'] ?? false, FontAwesomeIcons.bolt, Colors.amber),
          _buildTodayItem('Daur Ulang', daurUlang['selesai'] ?? false, FontAwesomeIcons.trashArrowUp, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTodayItem(String label, bool done, FaIconData icon, Color color, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: done ? color.withValues(alpha: 0.2) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: done ? color : Colors.grey, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: done ? Colors.black87 : Colors.grey)),
                if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          FaIcon(
            done ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circle,
            color: done ? const Color(0xFF00C368) : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildKPITable() {
    if (monthlyKPI == null) return const SizedBox();

    final aktivitas = monthlyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final total = monthlyKPI!['total'] ?? {};

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.table, color: const Color(0xFF00C368), size: 20),
                const SizedBox(width: 8),
                const Text('Tabel KPI Hijau 360\u00B0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEEFDF5)),
              columns: const [
                DataColumn(label: Text('Aktivitas', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Frekuensi', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Target', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tercapai', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Progress', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Bobot', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...aktivitas.map((item) {
                  return _buildTableRow(
                    item['nama'] ?? '',
                    item['frekuensi_per_minggu'] ?? '-',
                    (item['target_per_bulan'] ?? 0).toString(),
                    (item['tercapai'] ?? 0).toString(),
                    '${(item['progress_persen'] as num?)?.toStringAsFixed(0) ?? '0'}%',
                    item['bobot'] ?? '-',
                  );
                }),
                DataRow(cells: [
                  DataCell(Text(total['nama'] ?? 'TOTAL', style: const TextStyle(fontWeight: FontWeight.bold))),
                  const DataCell(Text('-')),
                  DataCell(Text(total['target_per_bulan']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(total['tercapai']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C368)))),
                  DataCell(Text('${(total['progress_persen'] as num?)?.toStringAsFixed(0) ?? '0'}%', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(total['bobot'] ?? '100%', style: const TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildTableRow(String aktivitas, String frekuensi, String target, String tercapai, String progress, String bobot) {
    return DataRow(cells: [
      DataCell(SizedBox(width: 250, child: Text(aktivitas, style: const TextStyle(fontSize: 12)))),
      DataCell(Text(frekuensi, style: const TextStyle(fontSize: 12))),
      DataCell(Text(target, style: const TextStyle(fontSize: 12))),
      DataCell(Text(tercapai, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00C368)))),
      DataCell(Text(progress, style: const TextStyle(fontSize: 12))),
      DataCell(Text(bobot, style: const TextStyle(fontSize: 12))),
    ]);
  }

  String _getBulanIndonesia(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }
}

class HijauKPIDetail extends StatelessWidget {
  const HijauKPIDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail KPI Hijau'),
        backgroundColor: const Color(0xFF00C368),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.chartLine, size: 48, color: Color(0xFF00C368)),
            SizedBox(height: 16),
            Text('Detail KPI Hijau', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Fitur detail akan segera hadir', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
