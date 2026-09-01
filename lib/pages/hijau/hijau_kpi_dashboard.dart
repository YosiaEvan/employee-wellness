import 'package:employee_wellness/components/auto_refresh_mixin.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/hijau_kpi_service.dart';
import '../../components/header.dart';
import '../../components/data_refresh_notifier.dart';

class HijauKPIDashboard extends StatefulWidget {
  const HijauKPIDashboard({super.key});

  @override
  State<HijauKPIDashboard> createState() => _HijauKPIDashboardState();
}

/// Daftar 5 aktivitas HIJAU 360 (kode kanonik backend).
const List<({String kode, String label, FaIconData icon, Color color})> _hijauItems = [
  (kode: 'hemat_air', label: 'Hemat Air', icon: FontAwesomeIcons.droplet, color: Color(0xff0ea5e9)),
  (kode: 'hemat_listrik', label: 'Listrik', icon: FontAwesomeIcons.bolt, color: Color(0xff059669)),
  (kode: 'gaya_hidup_hijau', label: 'Hijau', icon: FontAwesomeIcons.leaf, color: Color(0xff16a34a)),
  (kode: 'ajak_orang_lain', label: 'Ajak', icon: FontAwesomeIcons.userPlus, color: Color(0xfff59e0b)),
  (kode: 'ubah_kebiasaan', label: 'Kebiasaan', icon: FontAwesomeIcons.arrowsRotate, color: Color(0xff10b981)),
];

class _HijauKPIDashboardState extends State<HijauKPIDashboard> {
  bool isLoading = true;
  Map<String, dynamic>? dailyKPI;
  Map<String, dynamic>? weeklyKPI;
  Map<String, dynamic>? monthlyKPI;

  @override
  void initState() {
    super.initState();
    DataRefreshNotifier.instance.addListener(_onDataChanged);
    loadKPIData();
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
    final maksPoin = ringkasan['maks_poin_bulan'];

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
                Text('${ringkasan['total_poin']} / $maksPoin', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

    Map<String, dynamic> getAktivitas(String kode) {
      try {
        return aktivitas.firstWhere(
          (a) => (a['aktivitas'] ?? a['kode']).toString() == kode,
          orElse: () => {'tercapai': 0, 'target_per_minggu': 0},
        );
      } catch (e) {
        return {'tercapai': 0, 'target_per_minggu': 0};
      }
    }

    final firstRow = _hijauItems.take(3).toList();
    final secondRow = _hijauItems.skip(3).toList();

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
              for (final item in firstRow)
                _buildWeeklyPoinItem(
                  item.label,
                  getAktivitas(item.kode)['tercapai'] ?? 0,
                  getAktivitas(item.kode)['target_per_minggu'] ?? 1,
                  item.icon,
                  item.color,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in secondRow)
                _buildWeeklyPoinItem(
                  item.label,
                  getAktivitas(item.kode)['tercapai'] ?? 0,
                  getAktivitas(item.kode)['target_per_minggu'] ?? 1,
                  item.icon,
                  item.color,
                ),
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
          (a) => (a['kode'] ?? a['aktivitas']).toString() == kode,
          orElse: () => {'selesai': false},
        );
      } catch (e) {
        return {'selesai': false};
      }
    }

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
          for (final item in _hijauItems)
            _buildTodayItem(item.label, getAktivitas(item.kode)['selesai'] ?? false, item.icon, item.color),
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

class HijauKPIDetail extends StatefulWidget {
  const HijauKPIDetail({super.key});

  @override
  State<HijauKPIDetail> createState() => _HijauKPIDetailState();
}

class _HijauKPIDetailState extends State<HijauKPIDetail>
    with SingleTickerProviderStateMixin, AutoRefreshMixin<HijauKPIDetail> {
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
    final dailyResult = await HijauKPIService.getDailyKPI();
    final weeklyResult = await HijauKPIService.getWeeklyKPI();
    final monthlyResult = await HijauKPIService.getMonthlyKPI();
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
      backgroundColor: const Color(0xFFEEFDF5),
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
                      foregroundColor: const Color(0xFF00C368),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Detail KPI Hijau', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C368))),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00C368),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF00C368).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
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
    final ringkasan = dailyKPI!['ringkasan'] ?? {};
    final aktivitas = dailyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final tanggal = dailyKPI!['tanggal'] ?? '';
    final selesai = ringkasan['aktivitas_selesai'] ?? 0;
    final total = ringkasan['total_aktivitas'] ?? 5;
    final progress = (ringkasan['progress_persen'] ?? 0).toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00C368), Color(0xFF009B54)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF00C368).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [FaIcon(FontAwesomeIcons.calendarDay, color: Colors.white, size: 24), const SizedBox(width: 12), Expanded(child: Text(tanggal.toString().isEmpty ? 'Hari Ini' : tanggal.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Aktivitas Selesai', style: TextStyle(color: Colors.white70, fontSize: 14)), Text('$selesai / $total', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress / 100, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Detail Aktivitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...aktivitas.map((e) => _buildDailyCard(e as Map<String, dynamic>)),
      ]),
    );
  }

  Widget _buildDailyCard(Map<String, dynamic> a) {
    final kode = (a['kode'] ?? a['aktivitas'] ?? '').toString();
    final nama = a['nama']?.toString() ?? kode;
    final selesai = a['selesai'] == true || (a['tercapai'] as num?)?.toInt() == 1;
    final meta = _hijauMeta(kode);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selesai ? const Color(0xFF00C368) : Colors.grey.shade300, width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(meta.icon, color: meta.color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text('Bobot: ${a['bobot'] ?? '-'}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])),
        Icon(selesai ? Icons.check_circle : Icons.cancel, color: selesai ? const Color(0xFF00C368) : Colors.grey, size: 30),
      ]),
    );
  }

  Widget _buildWeeklyView() {
    if (weeklyKPI == null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: Colors.grey), const SizedBox(height: 16), const Text('Data mingguan tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)), const SizedBox(height: 16), ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi'))]));
    }
    final periode = weeklyKPI!['periode'] ?? {};
    final ringkasan = weeklyKPI!['ringkasan'] ?? {};
    final aktivitas = weeklyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final mingguKe = periode['minggu_ke'] ?? 0;
    final bulan = periode['bulan'] ?? 0;
    final tahun = periode['tahun'] ?? 0;
    final target = ringkasan['target_total_hari'] ?? 5;
    final tercapai = ringkasan['tercapai_total_hari'] ?? 0;
    final progress = (ringkasan['progress_persen'] ?? 0).toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [FaIcon(FontAwesomeIcons.calendarWeek, color: Colors.white, size: 24), const SizedBox(width: 12), Expanded(child: Text('Minggu Ke-$mingguKe - ${_getBulanIndonesia(bulan)} $tahun', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)), Text('$tercapai / $target poin', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress / 100, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Detail Aktivitas Minggu Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...aktivitas.map((e) => _buildWeeklyCard(e as Map<String, dynamic>)),
      ]),
    );
  }

  Widget _buildWeeklyCard(Map<String, dynamic> a) {
    final kode = (a['aktivitas'] ?? '').toString();
    final nama = a['nama']?.toString() ?? kode;
    final target = (a['target_per_minggu'] as num?)?.toInt() ?? 0;
    final tercapai = (a['tercapai'] as num?)?.toInt() ?? 0;
    final progress = (a['progress_persen'] as num?)?.toDouble() ?? 0;
    final selesai = tercapai >= target && target > 0;
    final meta = _hijauMeta(kode);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selesai ? const Color(0xFF10B981) : Colors.grey.shade300, width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(meta.icon, color: meta.color, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text('Target: $target/minggu  Bobot: ${a['bobot'] ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])), Icon(selesai ? Icons.check_circle : Icons.pending, color: selesai ? const Color(0xFF10B981) : Colors.grey, size: 30)]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('$tercapai poin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00C368)))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981)))])]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress / 100, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(meta.color))),
      ]),
    );
  }

  Widget _buildMonthlyView() {
    if (monthlyKPI == null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: Colors.grey), const SizedBox(height: 16), const Text('Data bulanan tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)), const SizedBox(height: 16), ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi'))]));
    }
    final periode = monthlyKPI!['periode'] ?? {};
    final ringkasan = monthlyKPI!['ringkasan'] ?? {};
    final aktivitas = monthlyKPI!['aktivitas'] as List<dynamic>? ?? [];
    final namaBulan = periode['nama_bulan'] ?? _getBulanIndonesia(periode['bulan'] ?? 0);
    final tahun = periode['tahun'] ?? 0;
    final target = ringkasan['target_total_hari'] ?? 20;
    final tercapai = ringkasan['tercapai_total_hari'] ?? 0;
    final progress = (ringkasan['progress_persen'] ?? 0).toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [FaIcon(FontAwesomeIcons.calendarDays, color: Colors.white, size: 24), const SizedBox(width: 12), Expanded(child: Text('$namaBulan $tahun', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))]),
            const SizedBox(height: 8),
            Text('${periode['jumlah_minggu'] ?? '-'} minggu · ${periode['jumlah_hari'] ?? '-'} hari', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)), Text('$tercapai / $target poin', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))]), Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress / 100, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Detail Aktivitas Bulan Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...aktivitas.map((e) => _buildMonthlyCard(e as Map<String, dynamic>)),
      ]),
    );
  }

  Widget _buildMonthlyCard(Map<String, dynamic> a) {
    final kode = (a['aktivitas'] ?? '').toString();
    final nama = a['nama']?.toString() ?? kode;
    final target = (a['target_per_bulan'] as num?)?.toInt() ?? 0;
    final tercapai = (a['tercapai'] as num?)?.toInt() ?? 0;
    final progress = (a['progress_persen'] as num?)?.toDouble() ?? 0;
    final selesai = tercapai >= target && target > 0;
    final meta = _hijauMeta(kode);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selesai ? const Color(0xFF059669) : Colors.grey.shade300, width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(meta.icon, color: meta.color, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text('Target: $target/bulan  Bobot: ${a['bobot'] ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])), Icon(selesai ? Icons.check_circle : Icons.pending, color: selesai ? const Color(0xFF059669) : Colors.grey, size: 30)]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('$tercapai poin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00C368)))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669)))])]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress / 100, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(meta.color))),
      ]),
    );
  }

  ({FaIconData icon, Color color}) _hijauMeta(String kode) {
    switch (kode) {
      case 'hemat_air':
        return (icon: FontAwesomeIcons.droplet, color: const Color(0xff0ea5e9));
      case 'hemat_listrik':
        return (icon: FontAwesomeIcons.bolt, color: const Color(0xff059669));
      case 'gaya_hidup_hijau':
        return (icon: FontAwesomeIcons.leaf, color: const Color(0xff16a34a));
      case 'ajak_orang_lain':
        return (icon: FontAwesomeIcons.userPlus, color: const Color(0xfff59e0b));
      case 'ubah_kebiasaan':
        return (icon: FontAwesomeIcons.arrowsRotate, color: const Color(0xff10b981));
      default:
        return (icon: FontAwesomeIcons.leaf, color: const Color(0xFF00C368));
    }
  }

  String _getBulanIndonesia(int bulan) {
    const bulanList = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return bulan > 0 && bulan <= 12 ? bulanList[bulan] : '';
  }
}
