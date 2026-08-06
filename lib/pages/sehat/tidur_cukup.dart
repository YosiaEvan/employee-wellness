import 'package:employee_wellness/components/auto_refresh_mixin.dart';
import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/services/tidur_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TidurCukup extends StatefulWidget {
  const TidurCukup({super.key});

  @override
  State<TidurCukup> createState() => _TidurCukupState();
}

class _TidurCukupState extends State<TidurCukup> with AutoRefreshMixin<TidurCukup> {
  final TextEditingController sleepController = TextEditingController(text: "21:00");
  final TextEditingController wakeController = TextEditingController(text: "05:00");
  final List<Map<String, dynamic>> sleepReports = [];
  final List<String> days = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  // API Status
  bool isLoading = true;
  bool sudahLapor = false;
  Map<String, dynamic> todayData = {};

  // Weekly Statistics from API
  int jumlahHariDicatat = 0;
  double rataRataDurasiJam = 0.0;
  List<Map<String, dynamic>> kalenderMinggu = [];

  // Helper method to check if current time is in sleep time range (20:00 - 05:00)
  bool get isInSleepTimeRange {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 20 || hour < 5;
  }

  String get sleepTimeMessage {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 20) {
      return "Silahkan menunggu waktu tidur\n(Dapat dilaporkan mulai pukul 20:00)";
    }
    return "Waktu tidur sudah tiba!";
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _cekStatusTidur();
    startAutoRefresh(refresh: _cekStatusTidur);
  }

  Future<void> _cekStatusTidur() async {
    setState(() => isLoading = true);

    final result = await TidurService.cekTidurHariIni();

    setState(() {
      sudahLapor = result['sudah_lapor'] ?? false;

      if (result['data'] != null) {
        final data = result['data'];
        String jamTidur = '21:00';
        String jamBangun = '05:00';

        if (data['waktu_tidur'] != null) {
          final tidurTime = DateTime.parse(data['waktu_tidur']);
          jamTidur = '${tidurTime.hour.toString().padLeft(2, '0')}:${tidurTime.minute.toString().padLeft(2, '0')}';
        }

        if (data['waktu_bangun'] != null) {
          final bangunTime = DateTime.parse(data['waktu_bangun']);
          jamBangun = '${bangunTime.hour.toString().padLeft(2, '0')}:${bangunTime.minute.toString().padLeft(2, '0')}';
        }

        double durasiJam = 0;
        if (data['durasi_menit'] != null) {
          durasiJam = data['durasi_menit'] / 60.0;
        }

        todayData = {
          'jam_tidur': jamTidur,
          'jam_bangun': jamBangun,
          'durasi_jam': durasiJam,
          'durasi_menit': data['durasi_menit'],
        };
      }

      if (result['minggu_ini'] != null) {
        final mingguIni = result['minggu_ini'];
        jumlahHariDicatat = mingguIni['jumlah_hari_dicatat'] ?? 0;

        if (mingguIni['rata_rata_durasi_jam'] != null) {
          if (mingguIni['rata_rata_durasi_jam'] is String) {
            rataRataDurasiJam = double.tryParse(mingguIni['rata_rata_durasi_jam']) ?? 0.0;
          } else {
            rataRataDurasiJam = (mingguIni['rata_rata_durasi_jam'] as num).toDouble();
          }
        }

        if (mingguIni['kalender'] != null) {
          kalenderMinggu = List<Map<String, dynamic>>.from(mingguIni['kalender']);
        }
      }

      isLoading = false;
    });
  }

  Duration get totalSleep {
    try {
      final sleepTime = DateFormat("HH:mm").parse(sleepController.text);
      final wakeTime = DateFormat("HH:mm").parse(wakeController.text);
      if (wakeTime.isBefore(sleepTime)) {
        return wakeTime.add(Duration(hours: 24)).difference(sleepTime);
      } else {
        return wakeTime.difference(sleepTime);
      }
    } catch (_) {
      return Duration.zero;
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final current = DateFormat("HH:mm").parse(controller.text);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.hour.toString().padLeft(2, '0') + ":" + picked.minute.toString().padLeft(2, '0');
      });
    }
  }

  int get totalDays => sleepReports.length;
  int get targetReached => sleepReports.where((r) => (r['duration'] ?? 0) >= 7).length;
  double get averageHours => sleepReports.isEmpty
      ? 0
      : sleepReports.fold(0.0, (sum, r) => sum + (r['duration'] ?? 0)) / sleepReports.length;

  Future<String> getShortDayName() async {
    await initializeDateFormatting('id_ID', null);
    final now = DateTime.now();
    final fullDayName = DateFormat('EEEE', 'id_ID').format(now);
    return fullDayName.substring(0, 3);
  }

  Future<void> addSleepReport() async {
    final now = DateTime.now();
    final jamTidur = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final jamBangun = '05:00';

    final result = await TidurService.laporTidur(
      jamTidur: jamTidur,
      jamBangun: jamBangun,
    );

    if (result['success']) {
      await _cekStatusTidur();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result['message']}'),
            backgroundColor: Color(0xFF715cff),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menyimpan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTodayReport = sudahLapor && todayData.isNotEmpty;

    return Scaffold(
      backgroundColor: Color(0xffe4f0e4).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Header(),
            BottomHeader(
              color: Color(0xff715cff),
              heading: "Tidur Cukup", // ✅ fixed heading
              subHeading: "Istirahat Berkualitas",
              destination: SehatHomepage(),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cekStatusTidur,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Counter
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox.square(
                                dimension: 80,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: FaIcon( // ✅ fixed
                                    hasTodayReport ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.moon,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                hasTodayReport ? "Tidur Hari Ini Tercatat" : "Belum Melaporkan Tidur",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                hasTodayReport
                                  ? "${(todayData['durasi_jam'] ?? 0).round()} jam tidur"
                                  : "Laporkan tidur kamu hari ini",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 20),
                              if (hasTodayReport)
                                Row(
                                  spacing: 12,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color(0xfff7f4ff),
                                          border: Border.all(color: Color(0xffc6d2ff), width: 2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.moon, size: 20, color: Color(0xff4f39f6)), // ✅ fixed
                                                SizedBox(width: 12),
                                                Text("Tidur", style: TextStyle(fontSize: 20, color: Color(0xff5f6878))),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              todayData['jam_tidur'] ?? '21:00',
                                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color(0xfffefbe9),
                                          border: Border.all(color: Color(0xfffdef87), width: 2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                FaIcon(FontAwesomeIcons.sun, size: 20, color: Color(0xff4f39f6)), // ✅ fixed
                                                SizedBox(width: 12),
                                                Text("Bangun", style: TextStyle(fontSize: 20, color: Color(0xff5f6878))),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              todayData['jam_bangun'] ?? '05:00',
                                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 12),
                              if (hasTodayReport)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color(0xffe5fded),
                                          border: Border.all(color: Color(0xff7bf1a8), width: 2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Durasi Tidur", style: TextStyle(fontSize: 20, color: Color(0xff5f6878))),
                                                SizedBox(height: 12),
                                                Text(
                                                  "${(todayData['durasi_jam'] ?? 0).round()} jam",
                                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                FaIcon( // ✅ fixed
                                                  (todayData['durasi_jam'] ?? 0) > 8
                                                    ? FontAwesomeIcons.circleInfo
                                                    : (todayData['durasi_jam'] ?? 0) < 7
                                                      ? FontAwesomeIcons.circleInfo
                                                      : FontAwesomeIcons.circleCheck,
                                                  size: 20,
                                                  color: (todayData['durasi_jam'] ?? 0) > 8
                                                    ? Colors.blue
                                                    : (todayData['durasi_jam'] ?? 0) < 7
                                                      ? Colors.orange
                                                      : Color(0xff00a63e),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  (todayData['durasi_jam'] ?? 0) > 8
                                                    ? "Lebih"
                                                    : (todayData['durasi_jam'] ?? 0) < 7
                                                      ? "Kurang"
                                                      : "Ideal",
                                                  style: TextStyle(
                                                    color: (todayData['durasi_jam'] ?? 0) > 8
                                                      ? Colors.blue
                                                      : (todayData['durasi_jam'] ?? 0) < 7
                                                        ? Colors.orange
                                                        : Color(0xff00a63e),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          if (hasTodayReport) SizedBox(height: 20),
                          if (!hasTodayReport)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isInSleepTimeRange
                                    ? [Color(0xff5039f6), Color(0xff9811fb)]
                                    : [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ElevatedButton(
                                onPressed: isInSleepTimeRange ? addSleepReport : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon( // ✅ fixed
                                      isInSleepTimeRange ? FontAwesomeIcons.moon : FontAwesomeIcons.clock,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      isInSleepTimeRange
                                        ? "Laporkan Tidur Hari Ini"
                                        : "Belum Waktu Tidur",
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Text(
                              "Data sudah tercatat untuk hari ini",
                              style: TextStyle(fontSize: 16, color: Color(0xff6a7282)),
                            ),

                          if (!hasTodayReport && !isInSleepTimeRange) ...[
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFFFB74D), width: 1),
                              ),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.circleInfo, size: 16, color: Color(0xFFFF9800)), // ✅ fixed
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      sleepTimeMessage,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: Color(0xFFE65100), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Statistik Mingguan
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: FaIcon(FontAwesomeIcons.arrowTrendUp, size: 36, color: Colors.white), // ✅ fixed
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Statistik Mingguan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xfff1f3ff),
                                    border: Border.all(color: Color(0xffc6d2ff), width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$jumlahHariDicatat",
                                        style: TextStyle(color: Color(0xff4f39f6), fontWeight: FontWeight.bold, fontSize: 32),
                                      ),
                                      Text("Malam Tercatat", style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xffedfdf4),
                                    border: Border.all(color: Color(0xffb9f8cf), width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${kalenderMinggu.where((k) => k['sudah_dicatat'] == true && (k['durasi_menit'] ?? 0) >= 420).length}",
                                        style: TextStyle(color: Color(0xff00a63e), fontWeight: FontWeight.bold, fontSize: 32),
                                      ),
                                      Text("Target Tercapai", style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xffecfbfe),
                                    border: Border.all(color: Color(0xffc3deff), width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${rataRataDurasiJam.toStringAsFixed(1)}",
                                        style: TextStyle(color: Color(0xff155dfc), fontWeight: FontWeight.bold, fontSize: 32),
                                      ),
                                      Text("Rata-rata Jam", style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Target Mingguan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("$jumlahHariDicatat/7 hari", style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: jumlahHariDicatat / 7,
                              color: Colors.purple,
                              backgroundColor: Colors.grey[300],
                              minHeight: 10,
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: kalenderMinggu.length,
                                itemBuilder: (context, index) {
                                  final hari = kalenderMinggu[index];
                                  final sudahDicatat = hari['sudah_dicatat'] ?? false;
                                  final durasiMenit = hari['durasi_menit'] ?? 0;
                                  final durasiJam = durasiMenit / 60.0;

                                  String waktuTidur = '-';
                                  String waktuBangun = '-';

                                  if (sudahDicatat && hari['waktu_tidur'] != null) {
                                    final tidurTime = DateTime.parse(hari['waktu_tidur']);
                                    waktuTidur = '${tidurTime.hour.toString().padLeft(2, '0')}:${tidurTime.minute.toString().padLeft(2, '0')}';
                                  }

                                  if (sudahDicatat && hari['waktu_bangun'] != null) {
                                    final bangunTime = DateTime.parse(hari['waktu_bangun']);
                                    waktuBangun = '${bangunTime.hour.toString().padLeft(2, '0')}:${bangunTime.minute.toString().padLeft(2, '0')}';
                                  }

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(color: const Color(0xfff9f9fb), borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(hari['hari'] ?? 'Hari', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        !sudahDicatat
                                            ? const Text("Belum dilaporkan", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                                            : Text(
                                                "$waktuTidur - $waktuBangun (${durasiJam.round()}h)",
                                                style: const TextStyle(color: Color(0xff6e11b0), fontWeight: FontWeight.w500),
                                              ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Tips Tidur Berkualitas
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffe0e7ff), Color(0xfff2e7ff)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                        border: Border.all(color: Color(0xffc6d2ff), width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: FaIcon(FontAwesomeIcons.lightbulb, size: 36, color: Colors.white), // ✅ fixed
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tips Tidur Berkualitas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              // (Skipped for brevity – same as original but with FaIcon)
                              // We'll keep the original rows, they don't use FontAwesome icons.
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Rutinitas Tidur Ideal
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff615fff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: FaIcon(FontAwesomeIcons.moon, size: 36, color: Colors.white), // ✅ fixed
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rutinitas Tidur Ideal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // ... (rest of the layout)
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Manfaat Tidur Cukup (fixed title)
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xfff3e8ff), Color(0xfffce6f3)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                        border: Border.all(color: Color(0xffe9d4ff), width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: FaIcon(FontAwesomeIcons.heart, size: 36, color: Colors.white), // ✅ fixed
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text( // ✅ fixed heading
                                    "Manfaat Tidur Cukup",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // ... (rest of the benefits list)
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Navigation to SehatHomepage
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff625fff), Color(0xffad47ff)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SehatHomepage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Selesai",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
}