import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/sehat_kpi_service.dart';
import '../../components/header.dart';
import 'sehat_kpi_detail.dart';

/// Halaman KPI Dashboard Sehat
/// Menampilkan tabel poin dan progress bulanan
class SehatKPIDashboard extends StatefulWidget {
  const SehatKPIDashboard({super.key});

  @override
  State<SehatKPIDashboard> createState() => _SehatKPIDashboardState();
}

class _SehatKPIDashboardState extends State<SehatKPIDashboard> {
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

    final dailyResult = await SehatKPIService.getDailyKPI();
    final weeklyResult = await SehatKPIService.getWeeklyKPI();
    final monthlyResult = await SehatKPIService.getMonthlyKPI();


    setState(() {
      if (dailyResult['success'] == true) {
        dailyKPI = dailyResult['data'];
      } else {
      }

      if (weeklyResult['success'] == true) {
        weeklyKPI = weeklyResult['data'];
      } else {
      }

      if (monthlyResult['success'] == true) {
        monthlyKPI = monthlyResult['data'];
      } else {
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFDF4),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SehatKPIDetail()),
          );
        },
        backgroundColor: const Color(0xFFC90028),
        icon: const Icon(FontAwesomeIcons.chartLine, color: Colors.white),
        label: const Text(
          'Lihat Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            // Back Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(FontAwesomeIcons.arrowLeft),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC90028),
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
                      color: Color(0xFFC90028),
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
                              const Text(
                                'Data KPI tidak tersedia',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pastikan Anda sudah login dan memiliki akses ke API',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: loadKPIData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC90028),
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

  // Monthly Summary Card
  Widget _buildMonthlyCard() {
    if (monthlyKPI == null) return const SizedBox();

    final periode = monthlyKPI!['periode'];
    final ringkasan = monthlyKPI!['ringkasan'];

    final targetTotal = ringkasan['target_total_hari'] ?? 152;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? 0;
    final progressPersen = ringkasan['progress_persen'] ?? 0;
    final bulan = _getBulanIndonesia(periode['bulan']);
    final tahun = periode['tahun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC9001E), Color(0xFFA80032)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC90017).withValues(alpha: 0.3),
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
              const Icon(FontAwesomeIcons.trophy, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'KPI Sehat - $bulan $tahun',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tercapai / Target',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '$tercapaiTotal / $targetTotal hari',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progressPersen.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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

  // Weekly Summary Card
  Widget _buildWeeklyCard() {
    if (weeklyKPI == null) return const SizedBox();

    final periode = weeklyKPI!['periode'];
    final ringkasan = weeklyKPI!['ringkasan'];
    final aktivitas = weeklyKPI!['aktivitas'] as List<dynamic>? ?? [];

    final targetTotal = ringkasan['target_total_hari'] ?? 34;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? 0;
    final progressPersen = ringkasan['progress_persen'] ?? 0;
    final mingguKe = periode['minggu_ke'];

    // Extract individual activity data
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

    final berjemur = getAktivitas('Berjemur');
    final olahraga = getAktivitas('Olahraga');
    final udara = getAktivitas('udara');
    final minum = getAktivitas('Minum');
    final tidur = getAktivitas('Tidur');
    final makan = getAktivitas('makan');

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
          Text(
            'Minggu Ke-$mingguKe',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeeklyPoinItem(
                'Berjemur',
                berjemur['tercapai'] ?? 0,
                berjemur['target_per_minggu'] ?? 1,
                FontAwesomeIcons.sun,
                Colors.orange,
              ),
              _buildWeeklyPoinItem(
                'Olahraga',
                olahraga['tercapai'] ?? 0,
                olahraga['target_per_minggu'] ?? 5,
                FontAwesomeIcons.personRunning,
                Colors.blue,
              ),
              _buildWeeklyPoinItem(
                'Udara',
                udara['tercapai'] ?? 0,
                udara['target_per_minggu'] ?? 5,
                FontAwesomeIcons.wind,
                Colors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeeklyPoinItem(
                'Minum',
                minum['tercapai'] ?? 0,
                minum['target_per_minggu'] ?? 7,
                FontAwesomeIcons.glassWater,
                Colors.lightBlue,
              ),
              _buildWeeklyPoinItem(
                'Tidur',
                tidur['tercapai'] ?? 0,
                tidur['target_per_minggu'] ?? 7,
                FontAwesomeIcons.bed,
                Colors.indigo,
              ),
              _buildWeeklyPoinItem(
                'Makan',
                makan['tercapai'] ?? 0,
                makan['target_per_minggu'] ?? 9,
                FontAwesomeIcons.utensils,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Minggu Ini',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$tercapaiTotal / $targetTotal (${progressPersen.toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC9001E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPoinItem(
    String label,
    int poin,
    int maxPoin,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          '$poin/$maxPoin',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Today's Activities Card
  Widget _buildTodayCard() {
    if (dailyKPI == null) return const SizedBox();

    final aktivitas = dailyKPI!['aktivitas'] as List<dynamic>? ?? [];

    // Helper function to get activity data
    Map<String, dynamic> getAktivitas(String nama) {
      try {
        return aktivitas.firstWhere(
          (a) => a['nama'].toString().toLowerCase().contains(nama.toLowerCase()),
          orElse: () => {'selesai': false, 'data': {}},
        );
      } catch (e) {
        return {'selesai': false, 'data': {}};
      }
    }

    final berjemur = getAktivitas('Berjemur');
    final olahraga = getAktivitas('Olahraga');
    final udara = getAktivitas('udara');
    final minum = getAktivitas('Minum');
    final tidur = getAktivitas('Tidur');

    // Extract detailed data
    final olahragaData = olahraga['data'] ?? {};
    final udaraData = udara['data'] ?? {};
    final minumData = minum['data'] ?? {};

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
          const Text(
            'Aktivitas Hari Ini',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTodayItem(
            'Berjemur',
            berjemur['selesai'] ?? false,
            FontAwesomeIcons.sun,
            Colors.orange,
          ),
          _buildTodayItem(
            'Jalan 10.000 Langkah',
            olahraga['selesai'] ?? false,
            FontAwesomeIcons.personRunning,
            Colors.blue,
            subtitle: '${olahragaData['total_langkah'] ?? 0} langkah',
          ),
          _buildTodayItem(
            'Hirup Udara Segar',
            udara['selesai'] ?? false,
            FontAwesomeIcons.wind,
            Colors.cyan,
            subtitle: '${udaraData['count'] ?? 0}/5 kali',
          ),
          _buildTodayItem(
            'Minum Air 8 Gelas',
            minum['selesai'] ?? false,
            FontAwesomeIcons.glassWater,
            Colors.lightBlue,
            subtitle: '${minumData['count'] ?? 0}/8 gelas',
          ),
          _buildTodayItem(
            'Tidur Cukup',
            tidur['selesai'] ?? false,
            FontAwesomeIcons.bed,
            Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayItem(
    String label,
    bool done,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
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
            child: Icon(
              icon,
              color: done ? color : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: done ? Colors.black87 : Colors.grey,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            done ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circle,
            color: done ? const Color(0xFFC90028) : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  // KPI Table
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
                const Icon(FontAwesomeIcons.table, color: Color(0xFFC90028), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Tabel KPI Sehat 360°',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEDFDF4)),
              columns: const [
                DataColumn(label: Text('Aktivitas', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Frekuensi', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Target', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tercapai', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Progress', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Bobot', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                // Dynamic rows from API
                ...aktivitas.map((item) {
                  final nama = item['nama'] ?? '';
                  final frekuensi = item['frekuensi_per_minggu'] ?? '-';
                  final target = item['target_per_bulan'] ?? 0;
                  final tercapai = item['tercapai'] ?? 0;
                  final progress = item['progress_persen'] ?? 0;
                  final bobot = item['bobot'] ?? '-';

                  return _buildTableRow(
                    nama,
                    frekuensi,
                    target.toString(),
                    tercapai.toString(),
                    '${progress.toStringAsFixed(0)}%',
                    bobot,
                  );
                }).toList(),
                // Total row
                DataRow(
                  cells: [
                    DataCell(Text(total['nama'] ?? 'TOTAL', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('-')),
                    DataCell(Text(total['target_per_bulan']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(total['tercapai']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(
                        0xFFC90028)))),
                    DataCell(Text('${total['progress_persen']?.toStringAsFixed(0) ?? '0'}%', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(total['bobot'] ?? '100%', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildTableRow(String aktivitas, String frekuensi, String target, String tercapai, String progress, String bobot) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 250,
            child: Text(aktivitas, style: const TextStyle(fontSize: 12)),
          ),
        ),
        DataCell(Text(frekuensi, style: const TextStyle(fontSize: 12))),
        DataCell(Text(target, style: const TextStyle(fontSize: 12))),
        DataCell(Text(tercapai, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(
            0xFFC90028)))),
        DataCell(Text(progress, style: const TextStyle(fontSize: 12))),
        DataCell(Text(bobot, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  String _getBulanIndonesia(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }
}

