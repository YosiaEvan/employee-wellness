import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/sehat_kpi_service.dart';
import '../../components/header.dart';
import 'package:intl/intl.dart';

class SehatKPIDetail extends StatefulWidget {
  const SehatKPIDetail({super.key});

  @override
  State<SehatKPIDetail> createState() => _SehatKPIDetailState();
}

class _SehatKPIDetailState extends State<SehatKPIDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;

  Map<String, dynamic>? dailyKPI;
  Map<String, dynamic>? weeklyKPI;
  Map<String, dynamic>? monthlyKPI;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadAllKPIData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadAllKPIData() async {
    setState(() => isLoading = true);

    final dailyResult = await SehatKPIService.getDailyKPI();
    final weeklyResult = await SehatKPIService.getWeeklyKPI();
    final monthlyResult = await SehatKPIService.getMonthlyKPI();

    print('🔍 Daily Result: $dailyResult');
    print('🔍 Weekly Result: $weeklyResult');
    print('🔍 Monthly Result: $monthlyResult');

    setState(() {
      if (dailyResult['success'] == true) {
        dailyKPI = dailyResult['data'];
        print('✅ Daily KPI loaded successfully');
      } else {
        print('❌ Daily KPI failed: ${dailyResult['message']}');
      }

      if (weeklyResult['success'] == true) {
        weeklyKPI = weeklyResult['data'];
        print('✅ Weekly KPI loaded successfully');
      } else {
        print('❌ Weekly KPI failed: ${weeklyResult['message']}');
      }

      if (monthlyResult['success'] == true) {
        monthlyKPI = monthlyResult['data'];
        print('✅ Monthly KPI loaded successfully');
      } else {
        print('❌ Monthly KPI failed: ${monthlyResult['message']}');
      }

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
            // Header Component
            const Header(),

            // Back Button & Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(FontAwesomeIcons.arrowLeft),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC9001E),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Detail KPI Sehat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC90028),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC9001E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC90028).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                tabs: const [
                  Tab(text: 'Harian'),
                  Tab(text: 'Mingguan'),
                  Tab(text: 'Bulanan'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar View
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: loadAllKPIData,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDailyView(),
                          _buildWeeklyView(),
                          _buildMonthlyView(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HARIAN VIEW
  // =====================================================
  Widget _buildDailyView() {
    if (dailyKPI == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Data harian tidak tersedia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadAllKPIData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final tanggal = dailyKPI!['tanggal'] ?? '';
    final ringkasan = dailyKPI!['ringkasan'] ?? {};
    final aktivitas = dailyKPI!['aktivitas'] as List<dynamic>? ?? [];

    final aktivitasSelesai = ringkasan['aktivitas_selesai'] ?? 0;
    final totalAktivitas = ringkasan['total_aktivitas'] ?? 6;
    final progressPersen = ringkasan['progress_persen'] ?? 0;
    final maxProgress = ringkasan['max_progress'] ?? 99;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA80032), Color(0xFFAF4C63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA80032).withValues(alpha: 0.3),
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
                    const Icon(FontAwesomeIcons.calendarDay, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      _formatTanggal(tanggal),
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
                          'Aktivitas Selesai',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '$aktivitasSelesai / $totalAktivitas',
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
                    value: progressPersen / maxProgress,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Aktivitas List
          const Text(
            'Detail Aktivitas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...aktivitas.map((item) => _buildDailyActivityCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildDailyActivityCard(Map<String, dynamic> activity) {
    final nama = activity['nama'] ?? '';
    final selesai = activity['selesai'] ?? false;
    final bobot = activity['bobot'] ?? '';
    final frekuensi = activity['frekuensi_per_minggu'] ?? '';
    final hariPerBulan = activity['hari_per_bulan'] ?? 0;
    final keterangan = activity['keterangan'] ?? '';
    final data = activity['data'];
    final target = activity['target'];
    final tercapai = activity['tercapai'];

    IconData icon;
    Color color;

    if (nama.toLowerCase().contains('berjemur')) {
      icon = FontAwesomeIcons.sun;
      color = Colors.orange;
    } else if (nama.toLowerCase().contains('olahraga') || nama.toLowerCase().contains('langkah')) {
      icon = FontAwesomeIcons.personRunning;
      color = Colors.blue;
    } else if (nama.toLowerCase().contains('udara')) {
      icon = FontAwesomeIcons.wind;
      color = Colors.cyan;
    } else if (nama.toLowerCase().contains('minum')) {
      icon = FontAwesomeIcons.glassWater;
      color = Colors.lightBlue;
    } else if (nama.toLowerCase().contains('tidur')) {
      icon = FontAwesomeIcons.bed;
      color = Colors.indigo;
    } else if (nama.toLowerCase().contains('makan')) {
      icon = FontAwesomeIcons.utensils;
      color = Colors.red;
    } else {
      icon = FontAwesomeIcons.check;
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selesai ? const Color(0xFFA80032) : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$frekuensi • $hariPerBulan hari/bulan • Bobot: $bobot',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selesai ? Icons.check_circle : Icons.cancel,
                color: selesai ? const Color(0xFFA80032) : Colors.grey,
                size: 32,
              ),
            ],
          ),

          // Keterangan
          if (keterangan.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selesai ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    selesai ? Icons.info_outline : Icons.warning_amber_rounded,
                    size: 16,
                    color: selesai ? const Color(0xFFA80032) : const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      keterangan,
                      style: TextStyle(
                        fontSize: 12,
                        color: selesai ? const Color(0xFFA80032) : const Color(0xFFF57C00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Target & Tercapai
          if (target != null || tercapai != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (target != null)
                  Column(
                    children: [
                      Text('Target', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      Text('$target', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                if (tercapai != null)
                  Column(
                    children: [
                      Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      Text(
                        '$tercapai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (tercapai is num && target is num && tercapai >= target)
                              ? const Color(0xFFA80032)
                              : const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],

          // Detail Data
          if (data != null && data is Map && data.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildActivityDetailContent(nama, activity, data as Map<String, dynamic>),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityDetailContent(String nama, Map<String, dynamic> activity, Map<String, dynamic> data) {
    // Berjemur
    if (nama.toLowerCase().contains('berjemur')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['waktu_mulai'] != null)
            _buildDetailRow('Waktu Mulai', _formatWaktu(data['waktu_mulai'])),
          if (data['waktu_selesai'] != null)
            _buildDetailRow('Waktu Selesai', _formatWaktu(data['waktu_selesai'])),
          if (data['durasi_menit'] != null)
            _buildDetailRow('Durasi', '${data['durasi_menit']} menit'),
        ],
      );
    }

    // Olahraga / Langkah
    else if (nama.toLowerCase().contains('olahraga') || nama.toLowerCase().contains('langkah')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['jumlah_langkah'] != null)
            _buildDetailRow('Jumlah Langkah', '${data['jumlah_langkah']} langkah'),
          if (data['kalori_terbakar'] != null)
            _buildDetailRow('Kalori Terbakar', '${data['kalori_terbakar']} kcal'),
          if (activity['target'] != null && activity['tercapai'] != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ((activity['tercapai'] as num) / (activity['target'] as num)).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(
                    0xFFA80032)),
              ),
            ),
          ],
        ],
      );
    }

    // Pola Makan
    else if (nama.toLowerCase().contains('makan')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['total_kalori'] != null)
            _buildDetailRow('Total Kalori', '${data['total_kalori']} kcal'),
          if (data['target_kalori_harian'] != null)
            _buildDetailRow('Target Kalori', '${data['target_kalori_harian']} kcal'),
          const SizedBox(height: 8),
          Text('Komposisi Nutrisi:', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (data['karbohidrat'] != null)
            _buildDetailRow('  Karbohidrat', '${data['karbohidrat']}g'),
          if (data['protein'] != null)
            _buildDetailRow('  Protein', '${data['protein']}g'),
          if (data['lemak'] != null)
            _buildDetailRow('  Lemak', '${data['lemak']}g'),
          if (data['serat'] != null)
            _buildDetailRow('  Serat', '${data['serat']}g'),
        ],
      );
    }

    // Hirup Udara Segar
    else if (nama.toLowerCase().contains('udara')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['waktu_mulai'] != null)
            _buildDetailRow('Waktu Mulai', _formatWaktu(data['waktu_mulai'])),
          if (data['waktu_selesai'] != null)
            _buildDetailRow('Waktu Selesai', _formatWaktu(data['waktu_selesai'])),
          if (data['durasi_detik'] != null)
            _buildDetailRow('Durasi', '${data['durasi_detik']} detik (${(data['durasi_detik'] / 60).toStringAsFixed(1)} menit)'),
        ],
      );
    }

    // Minum Air
    else if (nama.toLowerCase().contains('minum')) {
      final target = activity['target'] ?? 8;
      final tercapai = activity['tercapai'] ?? 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress: $tercapai / $target gelas', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${((tercapai / target) * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (tercapai / target).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
        ],
      );
    }

    // Tidur
    else if (nama.toLowerCase().contains('tidur')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity['target_jam'] != null)
            _buildDetailRow('Target', '${activity['target_jam']} jam'),
          if (activity['tercapai_jam'] != null)
            _buildDetailRow('Tercapai', '${activity['tercapai_jam']} jam'),
          if (data['waktu_tidur'] != null)
            _buildDetailRow('Waktu Tidur', _formatWaktu(data['waktu_tidur'])),
          if (data['waktu_bangun'] != null)
            _buildDetailRow('Waktu Bangun', _formatWaktu(data['waktu_bangun'])),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatWaktu(String waktu) {
    try {
      final parts = waktu.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return waktu;
    } catch (e) {
      return waktu;
    }
  }

  // =====================================================
  // MINGGUAN VIEW
  // =====================================================
  Widget _buildWeeklyView() {
    if (weeklyKPI == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Data mingguan tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi')),
          ],
        ),
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

    final aktivitasSelesai = ringkasan['aktivitas_selesai'] ?? 0;
    final totalAktivitas = ringkasan['total_aktivitas'] ?? 6;
    final progressPersen = ringkasan['progress_persen'] ?? 0;
    final targetTotal = ringkasan['target_total_hari'] ?? 0;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
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
                    const Icon(FontAwesomeIcons.calendarWeek, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Minggu Ke-$mingguKe - ${_getBulanIndonesia(bulan)} $tahun',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatTanggalSingkat(tanggalMulai)} - ${_formatTanggalSingkat(tanggalAkhir)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('$tercapaiTotal / $targetTotal hari', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('Aktivitas: $aktivitasSelesai / $totalAktivitas', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('${progressPersen.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
          ),

          const SizedBox(height: 20),
          const Text('Detail Aktivitas Minggu Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...aktivitas.map((item) => _buildWeeklyActivityCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityCard(Map<String, dynamic> activity) {
    final nama = activity['nama'] ?? '';
    final targetPerMinggu = activity['target_per_minggu'] ?? 0;
    final tercapai = activity['tercapai'] ?? 0;
    final selesai = activity['selesai'] ?? false;
    final progressPersen = activity['progress_persen'] ?? 0;
    final bobot = activity['bobot'] ?? '';
    final totalLangkah = activity['total_langkah'];

    IconData icon;
    Color color;

    if (nama.toLowerCase().contains('berjemur')) {
      icon = FontAwesomeIcons.sun;
      color = Colors.orange;
    } else if (nama.toLowerCase().contains('olahraga') || nama.toLowerCase().contains('langkah')) {
      icon = FontAwesomeIcons.personRunning;
      color = Colors.blue;
    } else if (nama.toLowerCase().contains('udara')) {
      icon = FontAwesomeIcons.wind;
      color = Colors.cyan;
    } else if (nama.toLowerCase().contains('minum')) {
      icon = FontAwesomeIcons.glassWater;
      color = Colors.lightBlue;
    } else if (nama.toLowerCase().contains('tidur')) {
      icon = FontAwesomeIcons.bed;
      color = Colors.indigo;
    } else if (nama.toLowerCase().contains('makan')) {
      icon = FontAwesomeIcons.utensils;
      color = Colors.green;
    } else {
      icon = FontAwesomeIcons.check;
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selesai ? const Color(0xFF4A90E2) : Colors.grey.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Target: $targetPerMinggu hari • Bobot: $bobot', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(selesai ? Icons.check_circle : Icons.pending, color: selesai ? const Color(0xFF4A90E2) : Colors.grey, size: 32),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text('$tercapai hari', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(
                      0xFFA80032))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text('${progressPersen.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2))),
                ],
              ),
            ],
          ),
          if (totalLangkah != null) ...[
            const SizedBox(height: 8),
            Text('Total Langkah: ${totalLangkah.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPersen / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BULANAN VIEW
  // =====================================================
  Widget _buildMonthlyView() {
    if (monthlyKPI == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Data bulanan tidak tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tarik ke bawah untuk refresh', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loadAllKPIData, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final periode = monthlyKPI!['periode'] ?? {};
    final ringkasan = monthlyKPI!['ringkasan'] ?? {};
    final aktivitas = monthlyKPI!['aktivitas'] as List<dynamic>? ?? [];

    final namaBulan = periode['nama_bulan'] ?? '';
    final tahun = periode['tahun'] ?? 0;
    final jumlahMinggu = periode['jumlah_minggu'] ?? 0;
    final jumlahHari = periode['jumlah_hari'] ?? 0;

    final aktivitasSelesai = ringkasan['aktivitas_selesai'] ?? 0;
    final totalAktivitas = ringkasan['total_aktivitas'] ?? 6;
    final progressPersen = ringkasan['progress_persen'] ?? 0;
    final targetTotal = ringkasan['target_total_hari'] ?? 0;
    final tercapaiTotal = ringkasan['tercapai_total_hari'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.3),
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
                    const Icon(FontAwesomeIcons.calendarDays, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Text('$namaBulan $tahun', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$jumlahMinggu minggu • $jumlahHari hari', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tercapai / Target', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('$tercapaiTotal / $targetTotal hari', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('Aktivitas: $aktivitasSelesai / $totalAktivitas', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('${progressPersen.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
          ),

          const SizedBox(height: 20),
          const Text('Detail Aktivitas Bulan Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...aktivitas.map((item) => _buildMonthlyActivityCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyActivityCard(Map<String, dynamic> activity) {
    final nama = activity['nama'] ?? '';
    final targetPerBulan = activity['target_per_bulan'] ?? 0;
    final tercapai = activity['tercapai'] ?? 0;
    final selesai = activity['selesai'] ?? false;
    final progressPersen = activity['progress_persen'] ?? 0;
    final bobot = activity['bobot'] ?? '';
    final tanggalAktivitas = activity['tanggal_aktivitas'] as List<dynamic>? ?? [];
    final totalLangkah = activity['total_langkah'];
    final rataRataLangkah = activity['rata_rata_langkah'];
    final rataRataDurasiJam = activity['rata_rata_durasi_jam'];

    IconData icon;
    Color color;

    if (nama.toLowerCase().contains('berjemur')) {
      icon = FontAwesomeIcons.sun;
      color = Colors.orange;
    } else if (nama.toLowerCase().contains('olahraga') || nama.toLowerCase().contains('langkah')) {
      icon = FontAwesomeIcons.personRunning;
      color = Colors.blue;
    } else if (nama.toLowerCase().contains('udara')) {
      icon = FontAwesomeIcons.wind;
      color = Colors.cyan;
    } else if (nama.toLowerCase().contains('minum')) {
      icon = FontAwesomeIcons.glassWater;
      color = Colors.lightBlue;
    } else if (nama.toLowerCase().contains('tidur')) {
      icon = FontAwesomeIcons.bed;
      color = Colors.indigo;
    } else if (nama.toLowerCase().contains('makan')) {
      icon = FontAwesomeIcons.utensils;
      color = Colors.green;
    } else {
      icon = FontAwesomeIcons.check;
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selesai ? const Color(0xFFFF9800) : Colors.grey.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Target: $targetPerBulan hari • Bobot: $bobot', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(selesai ? Icons.check_circle : Icons.pending, color: selesai ? const Color(0xFFFF9800) : Colors.grey, size: 32),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tercapai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text('$tercapai hari', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(
                      0xFFA80032))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Progress', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text('${progressPersen.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
                ],
              ),
            ],
          ),
          if (totalLangkah != null || rataRataLangkah != null || rataRataDurasiJam != null) ...[
            const SizedBox(height: 8),
            if (totalLangkah != null)
              Text('Total Langkah: ${totalLangkah.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            if (rataRataLangkah != null)
              Text('Rata-rata: ${rataRataLangkah.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} langkah/hari', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            if (rataRataDurasiJam != null)
              Text('Rata-rata Tidur: $rataRataDurasiJam jam/hari', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPersen / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (tanggalAktivitas.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('Tanggal Aktivitas (${tanggalAktivitas.length} hari):', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tanggalAktivitas.map((tgl) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(_formatTanggalSingkat(tgl), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Helper Functions
  String _formatTanggal(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  String _formatTanggalSingkat(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('d MMM', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  String _getBulanIndonesia(int bulan) {
    const bulanList = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return bulan > 0 && bulan <= 12 ? bulanList[bulan] : '';
  }
}

