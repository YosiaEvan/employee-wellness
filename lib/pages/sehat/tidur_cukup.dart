import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TidurCukup extends StatefulWidget {
  const TidurCukup({super.key});

  @override
  State<TidurCukup> createState() => _TidurCukupState();
}

class _TidurCukupState extends State<TidurCukup> {
  final TextEditingController sleepController = TextEditingController(text: "21:00");
  final TextEditingController wakeController = TextEditingController(text: "05:00");
  final List<Map<String, dynamic>> sleepReports = [];
  final List<String> days = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
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
      initialTime: TimeOfDay(
        hour: current.hour,
        minute: current.minute,
      )
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.hour.toString().padLeft(2, '0') + ":" + picked.minute.toString().padLeft(2, '0');
      });
    }
  }

  int get totalDays => sleepReports.length;
  int get targetReached =>
      sleepReports.where((r) => (r['duration'] ?? 0) >= 7).length;
  double get averageHours => sleepReports.isEmpty
      ? 0
      : sleepReports.fold(0.0, (sum, r) => sum + (r['duration'] ?? 0)) /
        sleepReports.length;

  Future<String> getShortDayName() async {
    await initializeDateFormatting('id_ID', null);
    final now = DateTime.now();
    final fullDayName = DateFormat('EEEE', 'id_ID').format(now);
    return fullDayName.substring(0, 3);
  }

  Future<void> addSleepReport() async {
    final dayName = await getShortDayName();
    setState(() {
      final duration = totalSleep;
      final totalHours =
          duration.inHours + (duration.inMinutes % 60) / 60.0;

      sleepReports.add({
        "day": dayName,
        "sleep": sleepController.text,
        "wake": wakeController.text,
        "duration": totalHours,
      });
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEE', 'id_ID').format(DateTime.now());
    final todayReport = sleepReports.firstWhere(
        (r) => r['day'] == today,
      orElse: () => {}
    );

    return Scaffold(
      backgroundColor: Color(0xffe4f0e4).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Header(),
            BottomHeader(color: Color(0xff715cff), heading: "Tidur Cukup", subHeading: "Istirahat Berkualitas", destination: SehatHomepage(),),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
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
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Icon(
                                    todayReport.isNotEmpty ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.moon,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text(
                                todayReport.isNotEmpty ? "Tidur Hari Ini Tercatat" : "Belum Melaporkan Tidur",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                todayReport.isNotEmpty ? "${todayReport['duration']} jam tidur" : "Laporkan tidur kamu hari ini",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 20,),
                              todayReport.isNotEmpty ? Row(
                                spacing: 12,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xfff7f4ff),
                                        border: Border.all(
                                          color: Color(0xffc6d2ff),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.moon,
                                                size: 20,
                                                color: Color(0xff4f39f6),
                                              ),
                                              SizedBox(width: 12,),
                                              Text(
                                                "Tidur",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xff5f6878),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 12,),
                                          Text(
                                            todayReport['sleep'],
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xfffefbe9),
                                        border: Border.all(
                                          color: Color(0xfffdef87),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.sun,
                                                size: 20,
                                                color: Color(0xff4f39f6),
                                              ),
                                              SizedBox(width: 12,),
                                              Text(
                                                "Bangun",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xff5f6878),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 12,),
                                          Text(
                                            todayReport['wake'],
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  )
                                ],
                              ) : Row(
                                children: [],
                              ),
                              SizedBox(height: 12,),
                              todayReport.isNotEmpty ? Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color(0xffe5fded),
                                          border: Border.all(
                                            color: Color(0xff7bf1a8),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Durasi Tidur",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Color(0xff5f6878),
                                                  ),
                                                ),
                                                SizedBox(height: 12,),
                                                Text(
                                                  "${todayReport['duration'].toString()} jam",
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  todayReport['duration'] > 8 ? FontAwesomeIcons.circleInfo : todayReport['duration'] < 7 ? FontAwesomeIcons.circleInfo : FontAwesomeIcons.circleCheck,
                                                  size: 20,
                                                  color: todayReport['duration'] > 8 ? Colors.green : todayReport['duration'] < 7 ? Colors.orange : Color(0xff00a63e),
                                                ),
                                                SizedBox(width: 12,),
                                                Text(
                                                  todayReport['duration'] > 8 ? "Lebih" : todayReport['duration'] < 7 ? "Kurang" : "Ideal",
                                                  style: TextStyle(
                                                    color: todayReport['duration'] > 8 ? Colors.green : todayReport['duration'] < 7 ? Colors.orange : Color(0xff00a63e),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                      )
                                  ),
                                ],
                              ) : Row(
                                children: [],
                              )
                            ],
                          ),
                          if (todayReport.isNotEmpty)
                          SizedBox(height: 20,),
                          todayReport.isEmpty ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff5039f6), Color(0xff9811fb)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        Duration calculateTotalSleep() {
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

                                        final total = calculateTotalSleep();
                                        final totalHours = total.inHours;
                                        final totalMinutes = total.inMinutes % 60;

                                        return Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Wrap(
                                            runSpacing: 16,
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 60,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(3),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "Laporkan Tidur",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 4,
                                                children: [
                                                  TextField(
                                                    controller: sleepController,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      labelText: "Jam Tidur",
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () async {
                                                      await _pickTime(sleepController);
                                                      setModalState(() {});
                                                    },
                                                  ),
                                                  Text(
                                                    "Rekomendasi: 21:00 (9 malam)",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xff8a909c),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 4,
                                                children: [
                                                  TextField(
                                                    controller: wakeController,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      labelText: "Jam Bangun",
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () async {
                                                      await _pickTime(wakeController);
                                                      setModalState(() {});
                                                    },
                                                  ),
                                                  Text(
                                                    "Untuk tidur 8 jam: 05:00",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xff8a909c),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Color(0xfff2f3ff),
                                                  border: Border.all(
                                                    color: Color(0xffe9d4ff),
                                                    width: 2,
                                                    style: BorderStyle.solid
                                                  ),
                                                  borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  spacing: 12,
                                                  children: [
                                                    Text(
                                                      "Durasi Tidur",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Color(0xff4a5565)
                                                      ),
                                                    ),
                                                    Text(
                                                      "$totalHours jam $totalMinutes menit",
                                                      style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xff6e11b0)
                                                      ),
                                                    ),
                                                    Text(
                                                      totalHours > 8 ? "ℹ️ Lebih dari 8 jam" : totalHours < 7 ? "⚠️ Kurang dari 7 jam" : "✓ Durasi ideal!",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: totalHours > 8 ? Colors.blue : totalHours < 7 ? Colors.orange : Colors.green,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Color(0xff5039f6), Color(0xff9811fb)],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: addSleepReport,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    "Simpan",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    );
                                  }
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.clock,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8,),
                                  Text(
                                    "Laporkan Tidur Hari Ini",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              )
                            ),
                          ) : Text(
                            "Data sudah tercatat untuk hari ini",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff6a7282),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

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
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.arrowTrendUp,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Statistik Mingguan",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xfff1f3ff),
                                    border: Border.all(
                                      color: Color(0xffc6d2ff),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$totalDays",
                                        style: TextStyle(
                                          color: Color(0xff4f39f6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                      Text(
                                        "Malam Tercatat",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xffedfdf4),
                                    border: Border.all(
                                      color: Color(0xffb9f8cf),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$targetReached",
                                        style: TextStyle(
                                          color: Color(0xff00a63e),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                      Text(
                                        "Target Tercapai",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xffecfbfe),
                                    border: Border.all(
                                      color: Color(0xffc3deff),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$averageHours",
                                        style: TextStyle(
                                          color: Color(0xff155dfc),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                      Text(
                                        "Rata-rata Jam",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Target Mingguan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )
                              ),
                              Text(
                                "${sleepReports.length}/7 hari",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                )
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: sleepReports.length / 7,
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
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  final report = sleepReports.firstWhere(
                                    (r) => r['day'] == day,
                                    orElse: () => {},
                                  );

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff9f9fb),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(day,
                                            style: const TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w600)),
                                        report.isEmpty
                                            ? const Text("Belum dilaporkan",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic))
                                            : Text(
                                          "${report['sleep']} - ${report['wake']} (${report['duration']}h)",
                                          style: const TextStyle(
                                              color: Color(0xff6e11b0),
                                              fontWeight: FontWeight.w500
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

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
                          border: Border.all(
                            color: Color(0xffc6d2ff),
                            width: 2,
                            style: BorderStyle.solid,
                          )
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
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.lightbulb,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tips Tidur Berkualitas",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff615fff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Tidur dan bangun di waktu yang sama setiap hari")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff615fff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Hindari kafein 6 jam sebelum tidur")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff615fff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Matikan layar gadget 1 jam sebelum tidur")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff615fff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Buat kamar gelap, sejuh, dan tenang")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff615fff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Hindari makan berat sebelum tidur")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff615fff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Olahraga teratur, tapi tidak dekat waktu tidur")
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

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
                                  child: const Icon(
                                    FontAwesomeIcons.moon,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Rutinitas Tidur Ideal",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xffeef2ff), Color(0xfffaf5ff)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  border: Border.all(
                                    color: Color(0xffc6d2ff),
                                  ),
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "🌙",
                                      style: TextStyle(
                                        fontSize: 32,
                                      ),
                                    ),
                                    SizedBox(width: 12,),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Minum segera setelah bangun",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "21:00",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Redupkan lampu, matikan gadget",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffeef2ff), Color(0xfffaf5ff)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    border: Border.all(
                                      color: Color(0xffc6d2ff),
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "📖",
                                      style: TextStyle(
                                        fontSize: 32,
                                      ),
                                    ),
                                    SizedBox(width: 12,),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Aktivitas Menenangkan",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "21:15",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Baca buku, meditasi, atau stretching ringan",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffeef2ff), Color(0xfffaf5ff)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    border: Border.all(
                                      color: Color(0xffc6d2ff),
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "😴",
                                      style: TextStyle(
                                        fontSize: 32,
                                      ),
                                    ),
                                    SizedBox(width: 12,),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Tidur",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "21:30",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Berbaring dan tutup mata",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffeef2ff), Color(0xfffaf5ff)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    border: Border.all(
                                      color: Color(0xffc6d2ff),
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "☀️",
                                      style: TextStyle(
                                        fontSize: 32,
                                      ),
                                    ),
                                    SizedBox(width: 12,),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Bangun Segar",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "05:00-06:00",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Terbangun setelah 7-8 jam tidur berkualitas",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Manfaat Tidur Cukup
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
                          border: Border.all(
                            color: Color(0xffe9d4ff),
                            width: 2,
                            style: BorderStyle.solid,
                          )
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
                                    color: Color(0xff715cff),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.heart,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Manfaat Tidur Cukup",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffad46ff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Meningkatkan daya ingat dan konsentrasi")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffad46ff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Memperkuat sistem imun tubuh")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffad46ff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Mengatur mood dan kesehatan mental")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffad46ff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Menurunkan risiko penyakit jantung")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffad46ff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Membantu menjaga berat badan ideal")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffad46ff),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Meningkatkan produktivitas juga")
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Navigation to Udara Segar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff625fff), Color(0xffad47ff)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                          onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SehatHomepage()),
                            )
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            "Selesai",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
