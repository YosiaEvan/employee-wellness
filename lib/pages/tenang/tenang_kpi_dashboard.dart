import 'package:employee_wellness/components/auto_refresh_mixin.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/tenang_kpi_service.dart';
import '../../components/header.dart';
import '../../components/data_refresh_notifier.dart';

class TenangKPIDashboard extends StatefulWidget {
  const TenangKPIDashboard({super.key});

  @override
  State<TenangKPIDashboard> createState() => _TenangKPIDashboardState();
}

class _TenangKPIDashboardState extends State<TenangKPIDashboard> with AutoRefreshMixin<TenangKPIDashboard> {
  bool isLoading = true;
  Map<String, dynamic>? dailyKPI;
  Map<String, dynamic>? weeklyKPI;
  Map<String, dynamic>? monthlyKPI;

  @override
  void initState() {
    super.initState();
    DataRefreshNotifier.instance.addListener(_onDataChanged);
    loadKPIData();
    startAutoRefresh(refresh: loadKPIData);
  }

  void _onDataChanged() {
    if (mounted) loadKPIData();
  }

  @override
  void dispose() {
    DataRefreshNotifier.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> loadKPIData() async {
    setState(() => isLoading = true);
    final dailyResult = await TenangKPIService.getDailyKPI();
    final weeklyResult = await TenangKPIService.getWeeklyKPI();
    final monthlyResult = await TenangKPIService.getMonthlyKPI();

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
      backgroundColor: const Color(0xFFEEF3FF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TenangKPIDetail()),
          );
        },
        backgroundColor: const Color(0xFF2C7EFF),
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
                      foregroundColor: const Color(0xFF2C7EFF),
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
                      color: Color(0xFF2C7EFF),
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
                                  backgroundColor: const Color(0xFF2C7EFF),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadKPIData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: ResponsiveContainer(
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
          colors: [Color(0xFF2C7EFF), Color(0xFF1A5CC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C7EFF).withValues(alpha: 0.3),
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
              Text(
                'KPI Tenang - $bulan $tahun',
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
                  const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    '$tercapaiTotal / $targetTotal',
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
          if (ringkasan['rata_stress'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Rata-rata stres: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  '${ringkasan['rata_stress']}/5',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: aktivitas.map((item) {
              final kode = item['aktivitas']?.toString() ?? '';
              final style = _tenangPointStyle(kode);
              return _buildWeeklyPoinItem(
                item['nama']?.toString() ?? kode,
                (item['tercapai'] as num?)?.toInt() ?? 0,
                (item['target_per_minggu'] as num?)?.toInt() ?? 0,
                style.icon,
                style.color,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Minggu Ini', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '$tercapaiTotal / $targetTotal (${progressPersen.toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C7EFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({FaIconData icon, Color color}) _tenangPointStyle(String kode) {
    switch (kode) {
      case 'tahan_emosi':
        return (icon: FontAwesomeIcons.handHoldingHeart, color: const Color(0xFF7141FC));
      case 'ekspresi_sehat':
        return (icon: FontAwesomeIcons.music, color: const Color(0xFFF20868));
      case 'harmoni_keluarga':
        return (icon: FontAwesomeIcons.houseUser, color: Colors.amber);
      case 'akui_emosi':
        return (icon: FontAwesomeIcons.comments, color: const Color(0xff00a896));
      case 'kendali_diri':
        return (icon: FontAwesomeIcons.shieldHalved, color: const Color(0xFF2C7EFF));
      case 'koneksi_sosial':
        return (icon: FontAwesomeIcons.users, color: const Color(0xff00c368));
      default:
        return (icon: FontAwesomeIcons.heartPulse, color: const Color(0xFF2C7EFF));
    }
  }

  Widget _buildWeeklyPoinItem(String label, int poin, int maxPoin, FaIconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          maxPoin > 0 ? '$poin/$maxPoin' : '$poin',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildTodayCard() {
    if (dailyKPI == null) return const SizedBox();

    final aktivitas = dailyKPI!['aktivitas'] as List<dynamic>? ?? [];

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
          ...aktivitas.map((item) {
            final kode = item['aktivitas']?.toString() ?? item['kode']?.toString() ?? '';
            final selesai = item['selesai'] == true || (item['tercapai'] as num?)?.toInt() == 1;
            final style = _tenangPointStyle(kode);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selesai ? style.color.withValues(alpha: 0.2) : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(style.icon, color: selesai ? style.color : Colors.grey, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['nama']?.toString() ?? kode,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: selesai ? Colors.black87 : Colors.grey),
                    ),
                  ),
                  FaIcon(
                    selesai ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circle,
                    color: selesai ? const Color(0xFF2C7EFF) : Colors.grey.shade300,
                    size: 20,
                  ),
                ],
              ),
            );
          }),
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
                FaIcon(FontAwesomeIcons.table, color: const Color(0xFF2C7EFF), size: 20),
                const SizedBox(width: 8),
                const Text('Tabel KPI Tenang 360\u00B0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFEEF3FF)),
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
                  DataCell(Text(total['tercapai']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C7EFF)))),
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
      DataCell(Text(tercapai, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C7EFF)))),
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

class TenangKPIDetail extends StatefulWidget {
  const TenangKPIDetail({super.key});

  @override
  State<TenangKPIDetail> createState() => _TenangKPIDetailState();
}

class _TenangKPIDetailState extends State<TenangKPIDetail>
    with SingleTickerProviderStateMixin, AutoRefreshMixin<TenangKPIDetail> {
  late TabController _tabController;
  bool isLoading = true;

  Map<String, dynamic>? dailyKPI;
  Map<String, dynamic>? weeklyKPI;
  Map<String, dynamic>? monthlyKPI;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    DataRefreshNotifier.instance.addListener(_onDataChanged);
    loadAllKPIData();
    startAutoRefresh(refresh: loadAllKPIData);
  }

  void _onDataChanged() {
    if (mounted) loadAllKPIData();
  }

  @override
  void dispose() {
    DataRefreshNotifier.instance.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadAllKPIData() async {
    setState(() => isLoading = true);
    final dailyResult = await TenangKPIService.getDailyKPI();
    final weeklyResult = await TenangKPIService.getWeeklyKPI();
    final monthlyResult = await TenangKPIService.getMonthlyKPI();
    if (!mounted) return;
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
      backgroundColor: const Color(0xFFEEF3FF),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: FaIcon(FontAwesomeIcons.arrowLeft),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2C7EFF),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Detail KPI Tenang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C7EFF))),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C7EFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF2C7EFF).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Harian'), Tab(text: 'Mingguan'), Tab(text: 'Bulanan')],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: loadAllKPIData,
                      child: TabBarView(
                        controller: _tabController,
                        children: [_buildDailyView(), _buildWeeklyView(), _buildMonthlyView()],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HARIAN
  // =====================================================
  Widget _buildDailyView() {
    if (dailyKPI == null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Data harian tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi')),
        ]),
      );
    }
    final tanggal = dailyKPI!['tanggal'] ?? '';
    final ringkasan = dailyKPI!['ringkasan'] ?? {};
    final aktivitas = dailyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final aktivitasSelesai = ringkasan['aktivitas_selesai'] ?? 0;
    final totalAktivitas = ringkasan['total_aktivitas'] ?? 6;
    final progressPersen = (ringkasan['progress_persen'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2C7EFF), Color(0xFF1A5CC8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF2C7EFF).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              FaIcon(FontAwesomeIcons.calendarDay, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(_formatTanggal(tanggal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Aktivitas Selesai', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('$aktivitasSelesai / $totalAktivitas', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('${progressPersen.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progressPersen / 100, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Detail Aktivitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...aktivitas.map((item) => _buildDailyActivityCard(item as Map<String, dynamic>)),
      ]),
    );
  }

  Widget _buildDailyActivityCard(Map<String, dynamic> activity) {
    final kode = (activity['aktivitas'] ?? activity['kode'] ?? '').toString();
    final nama = activity['nama']?.toString() ?? kode;
    final selesai = activity['selesai'] == true || (activity['tercapai'] as num?)?.toInt() == 1;
    final bobot = activity['bobot'] ?? '';
    final keterangan = activity['keterangan'] ?? activity['nama_lengkap'] ?? '';
    final style = _tenangPointStyle(kode);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selesai ? const Color(0xFF2C7EFF) : Colors.grey.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: style.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(style.icon, color: style.color, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Bobot: $bobot', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            if (keterangan.toString().isNotEmpty) Text(keterangan.toString(), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Icon(selesai ? Icons.check_circle : Icons.cancel, color: selesai ? const Color(0xFF2C7EFF) : Colors.grey, size: 32),
        ]),
      ]),
    );
  }

  // =====================================================
  // MINGGUAN
  // =====================================================
  Widget _buildWeeklyView() {
    if (weeklyKPI == null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Data mingguan tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi')),
        ]),
      );
    }
    final periode = weeklyKPI!['periode'] ?? {};
    final ringkasan = weeklyKPI!['ringkasan'] ?? {};
    final aktivitas = weeklyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final mingguKe = periode['minggu_ke'] ?? 0;
    final bulan = periode['bulan'] ?? 0;
    final tahun = periode['tahun'] ?? 0;
    final tanggalMulai = periode['tanggal_mulai'] ?? '';
    final tanggalAkhir = periode['tanggal_akhir'] ?? '';
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? ringkasan['total_poin'] ?? 0;
    final targetTotal = ringkasan['target_total_hari'] ?? ringkasan['maks_poin_minggu'] ?? 10;
    final progressPersen = (ringkasan['progress_persen'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5B5BF6), Color(0xFF3B3BCE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF5B5BF6).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              FaIcon(FontAwesomeIcons.calendarWeek, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text('Minggu Ke-$mingguKe - ${_getBulanIndonesia(bulan)} $tahun', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            ]),
            const SizedBox(height: 8),
            Text('$tanggalMulai - $tanggalAkhir', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('$tercapaiTotal / $targetTotal poin', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text('${progressPersen.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressPersen / 100, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Detail Aktivitas Minggu Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...aktivitas.map((item) => _buildWeeklyActivityCard(item as Map<String, dynamic>)),
      ]),
    );
  }

  Widget _buildWeeklyActivityCard(Map<String, dynamic> activity) {
    final kode = (activity['aktivitas'] ?? activity['kode'] ?? '').toString();
    final nama = activity['nama']?.toString() ?? kode;
    final targetPerMinggu = (activity['target_per_minggu'] as num?)?.toInt() ?? 0;
    final tercapai = (activity['tercapai'] as num?)?.toInt() ?? 0;
    final progressPersen = (activity['progress_persen'] as num?)?.toDouble() ?? 0;
    final bobot = activity['bobot'] ?? '';
    final selesai = tercapai >= targetPerMinggu && targetPerMinggu > 0;
    final style = _tenangPointStyle(kode);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selesai ? const Color(0xFF5B5BF6) : Colors.grey.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: style.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(style.icon, color: style.color, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Target: $targetPerMinggu/minggu  Bobot: $bobot', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ])),
          Icon(selesai ? Icons.check_circle : Icons.pending, color: selesai ? const Color(0xFF5B5BF6) : Colors.grey, size: 32),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('$tercapai poin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C7EFF)))]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('${progressPersen.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5B5BF6)))]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressPersen / 100, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(style.color))),
      ]),
    );
  }

  // =====================================================
  // BULANAN
  // =====================================================
  Widget _buildMonthlyView() {
    if (monthlyKPI == null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Data bulanan tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi')),
        ]),
      );
    }
    final periode = monthlyKPI!['periode'] ?? {};
    final ringkasan = monthlyKPI!['ringkasan'] ?? {};
    final aktivitas = monthlyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final namaBulan = periode['nama_bulan'] ?? _getBulanIndonesia(periode['bulan'] ?? 0);
    final tahun = periode['tahun'] ?? 0;
    final jumlahMinggu = periode['jumlah_minggu'] ?? 0;
    final jumlahHari = periode['jumlah_hari'] ?? 0;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? ringkasan['total_poin'] ?? 0;
    final targetTotal = ringkasan['target_total_hari'] ?? ringkasan['maks_poin_bulan'] ?? 40;
    final progressPersen = (ringkasan['progress_persen'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00A896), Color(0xFF00897B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF00A896).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [FaIcon(FontAwesomeIcons.calendarDays, color: Colors.white, size: 24), const SizedBox(width: 12), Expanded(child: Text('$namaBulan $tahun', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))]),
            const SizedBox(height: 8),
            Text('$jumlahMinggu minggu  $jumlahHari hari', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)), Text('$tercapaiTotal / $targetTotal poin', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text('${progressPersen.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressPersen / 100, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Detail Aktivitas Bulan Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...aktivitas.map((item) => _buildMonthlyActivityCard(item as Map<String, dynamic>)),
      ]),
    );
  }

  Widget _buildMonthlyActivityCard(Map<String, dynamic> activity) {
    final kode = (activity['aktivitas'] ?? '').toString();
    final nama = activity['nama']?.toString() ?? kode;
    final targetPerBulan = (activity['target_per_bulan'] as num?)?.toInt() ?? 0;
    final tercapai = (activity['tercapai'] as num?)?.toInt() ?? 0;
    final progressPersen = (activity['progress_persen'] as num?)?.toDouble() ?? 0;
    final bobot = activity['bobot'] ?? '';
    final style = _tenangPointStyle(kode);
    final selesai = tercapai >= targetPerBulan && targetPerBulan > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selesai ? const Color(0xFF00A896) : Colors.grey.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: style.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(style.icon, color: style.color, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text('Target: $targetPerBulan/bulan  Bobot: $bobot', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])),
          Icon(selesai ? Icons.check_circle : Icons.pending, color: selesai ? const Color(0xFF00A896) : Colors.grey, size: 32),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('$tercapai poin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C7EFF)))]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('${progressPersen.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00A896)))]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressPersen / 100, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(style.color))),
      ]),
    );
  }

  String _formatTanggal(String tanggal) {
    try {
      if (tanggal.isEmpty) return '-';
      final d = DateTime.parse(tanggal);
      const bulanList = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      const hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      return '${hariList[d.weekday - 1]}, ${d.day} ${bulanList[d.month - 1]} ${d.year}';
    } catch (_) {
      return tanggal;
    }
  }

  String _getBulanIndonesia(int bulan) {
    const bulanList = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return bulan > 0 && bulan <= 12 ? bulanList[bulan] : '';
  }

  ({FaIconData icon, Color color}) _tenangPointStyle(String kode) {
    switch (kode) {
      case 'tahan_emosi':
        return (icon: FontAwesomeIcons.handHoldingHeart, color: const Color(0xFF7141FC));
      case 'ekspresi_sehat':
        return (icon: FontAwesomeIcons.music, color: const Color(0xFFF20868));
      case 'harmoni_keluarga':
        return (icon: FontAwesomeIcons.houseUser, color: Colors.amber);
      case 'akui_emosi':
        return (icon: FontAwesomeIcons.comments, color: const Color(0xff00a896));
      case 'kendali_diri':
        return (icon: FontAwesomeIcons.shieldHalved, color: const Color(0xFF2C7EFF));
      case 'koneksi_sosial':
        return (icon: FontAwesomeIcons.users, color: const Color(0xff00c368));
      default:
        return (icon: FontAwesomeIcons.heartPulse, color: const Color(0xFF2C7EFF));
    }
  }
}
