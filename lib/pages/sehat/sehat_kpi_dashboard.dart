import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/sehat_kpi_service.dart';
import '../../components/header.dart';

/// Halaman KPI Dashboard Sehat
/// Menampilkan tabel poin dan progress bulanan
class SehatKPIDashboard extends StatefulWidget {
  const SehatKPIDashboard({super.key});

  @override
  State<SehatKPIDashboard> createState() => _SehatKPIDashboardState();
}

class _SehatKPIDashboardState extends State<SehatKPIDashboard> {
  bool isLoading = true;
  Map<String, dynamic>? weeklyKPI;
  Map<String, dynamic>? monthlyKPI;
  Map<String, dynamic>? todayActivities;

  @override
  void initState() {
    super.initState();
    loadKPIData();
  }

  Future<void> loadKPIData() async {
    setState(() => isLoading = true);

    final weeklyResult = await SehatKPIService.getWeeklyKPI();
    final monthlyResult = await SehatKPIService.getMonthlyKPI();
    final todayResult = await SehatKPIService.getTodayActivities();

    setState(() {
      if (weeklyResult['success']) weeklyKPI = weeklyResult['data'];
      if (monthlyResult['success']) monthlyKPI = monthlyResult['data'];
      if (todayResult['success']) todayActivities = todayResult['data'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFDF4),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
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

    final totalPoin = monthlyKPI!['total_poin'] ?? 0;
    final maxPoin = monthlyKPI!['max_poin'] ?? 1;
    final persentase = monthlyKPI!['persentase_pencapaian'] ?? 0;
    final bulan = _getBulanIndonesia(monthlyKPI!['bulan']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C97A), Color(0xFF00A86B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C97A).withValues(alpha: 0.3),
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
                'KPI Sehat - $bulan ${monthlyKPI!['tahun']}',
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
                    'Total Poin',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '$totalPoin / $maxPoin',
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
                  '${persentase.toStringAsFixed(1)}%',
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
              value: persentase / 100,
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

    final totalPoin = weeklyKPI!['total_poin'] ?? 0;
    final persentase = weeklyKPI!['persentase_pencapaian'] ?? 0;

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
            'Minggu Ini',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeeklyPoinItem(
                'Berjemur',
                weeklyKPI!['poin_berjemur'] ?? 0,
                20,
                FontAwesomeIcons.sun,
                Colors.orange,
              ),
              _buildWeeklyPoinItem(
                'Olahraga',
                weeklyKPI!['poin_olahraga'] ?? 0,
                20,
                FontAwesomeIcons.personRunning,
                Colors.blue,
              ),
              _buildWeeklyPoinItem(
                'Udara',
                weeklyKPI!['poin_udara'] ?? 0,
                20,
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
                weeklyKPI!['poin_minum'] ?? 0,
                28,
                FontAwesomeIcons.glassWater,
                Colors.lightBlue,
              ),
              _buildWeeklyPoinItem(
                'Tidur',
                weeklyKPI!['poin_tidur'] ?? 0,
                28,
                FontAwesomeIcons.bed,
                Colors.indigo,
              ),
              _buildWeeklyPoinItem(
                'Makan',
                weeklyKPI!['poin_makan'] ?? 0,
                36,
                FontAwesomeIcons.utensils,
                Colors.green,
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
                  'Total Poin Minggu Ini',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$totalPoin / 152 (${persentase.toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C97A),
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
    if (todayActivities == null) return const SizedBox();

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
            todayActivities!['berjemur_done'] ?? false,
            FontAwesomeIcons.sun,
            Colors.orange,
          ),
          _buildTodayItem(
            'Jalan 10.000 Langkah',
            todayActivities!['langkah_target_tercapai'] ?? false,
            FontAwesomeIcons.personRunning,
            Colors.blue,
            subtitle: '${todayActivities!['langkah_total'] ?? 0} langkah',
          ),
          _buildTodayItem(
            'Hirup Udara Segar',
            todayActivities!['hirup_udara_done'] ?? false,
            FontAwesomeIcons.wind,
            Colors.cyan,
            subtitle: '${todayActivities!['hirup_udara_count'] ?? 0}/5 kali',
          ),
          _buildTodayItem(
            'Minum Air 8 Gelas',
            todayActivities!['minum_air_done'] ?? false,
            FontAwesomeIcons.glassWater,
            Colors.lightBlue,
            subtitle: '${todayActivities!['minum_air_count'] ?? 0}/8 gelas',
          ),
          _buildTodayItem(
            'Tidur Cukup',
            todayActivities!['tidur_done'] ?? false,
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
            color: done ? const Color(0xFF00C97A) : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  // KPI Table
  Widget _buildKPITable() {
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
                const Icon(FontAwesomeIcons.table, color: Color(0xFF00C97A), size: 20),
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
                DataColumn(label: Text('Poin', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('%', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                _buildTableRow('Berjemur (07.00-09.00 / 15.00-17.00)', '1x/minggu', '1', '20', '13%'),
                _buildTableRow('Olahraga 10.000 langkah', '5x/minggu', '5', '20', '13%'),
                _buildTableRow('Pola makan sehat', '2 hari tanpa minyak, 2 hari tanpa gula, 5x sesuai kalori', '9', '36', '24%'),
                _buildTableRow('Hirup udara segar (teknik 4-4-8)', '5x/minggu', '5', '20', '13%'),
                _buildTableRow('Minum 8 gelas air', '7x/minggu', '7', '28', '18%'),
                _buildTableRow('Tidur 7-8 jam (≤21.00 mulai)', '7x/minggu', '7', '28', '18%'),
                DataRow(
                  cells: [
                    const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('-')),
                    const DataCell(Text('-')),
                    const DataCell(Text('152', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C97A)))),
                    const DataCell(Text('100%', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildTableRow(String aktivitas, String frekuensi, String target, String poin, String persen) {
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
        DataCell(Text(poin, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        DataCell(Text(persen, style: const TextStyle(fontSize: 12))),
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

