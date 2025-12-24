import 'dart:async';
import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/services/langkah_service.dart';
import 'package:employee_wellness/services/steps_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class Jalan10000Langkah extends StatefulWidget {
  const Jalan10000Langkah({super.key});

  @override
  State<Jalan10000Langkah> createState() => _Jalan10000LangkahState();
}

class _Jalan10000LangkahState extends State<Jalan10000Langkah> {
  int _totalSteps = 0;
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _subscription;
  double progressValue = 0;
  int _remainingSteps = 10000;
  int _initialSteps = 0;

  // Timer untuk sync periodik ke API
  Timer? _syncTimer;
  DateTime? _lastSyncTime;

  // Yesterday's steps notification
  int? _yesterdaySteps;
  bool _showYesterdayNotification = false;
  bool _isLoadingYesterday = true;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
    _loadYesterdaySteps();
    // Auto-start tracking di background
    _autoStartTracking();
  }

  /// Load data langkah kemarin untuk notifikasi
  Future<void> _loadYesterdaySteps() async {
    try {
      setState(() {
        _isLoadingYesterday = true;
      });

      final syncService = StepsSyncService.instance;
      final yesterdayData = await syncService.getYesterdaySteps();

      if (yesterdayData != null && mounted) {
        final steps = yesterdayData['total_steps'] as int?;
        final wasSynced = yesterdayData['is_synced'] == 1;

        if (steps != null && steps > 0 && wasSynced) {
          setState(() {
            _yesterdaySteps = steps;
            _showYesterdayNotification = true;
            _isLoadingYesterday = false;
          });

          print('📊 Yesterday steps loaded: $steps');
        } else {
          setState(() {
            _isLoadingYesterday = false;
          });
        }
      } else {
        setState(() {
          _isLoadingYesterday = false;
        });
      }
    } catch (e) {
      print('❌ Error loading yesterday steps: $e');
      setState(() {
        _isLoadingYesterday = false;
      });
    }
  }

  /// Auto-start pedometer tracking
  Future<void> _autoStartTracking() async {
    // Request permission dulu
    final status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      startListening();
    } else {
      // Tetap coba request ulang
      await Permission.activityRecognition.request();
      if (await Permission.activityRecognition.isGranted) {
        startListening();
      }
    }
  }

  /// Initialize steps dengan cek apakah hari sudah berganti
  Future<void> _initializeSteps() async {
    // Cek apakah hari sudah berganti
    final shouldReset = await LangkahService.shouldResetToday();

    if (shouldReset) {

      // PENTING: Simpan data kemarin ke queue sebelum reset
      final yesterdaySteps = await LangkahService.getTodaySteps();
      if (yesterdaySteps > 0) {
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        final yesterdayDate = yesterday.toIso8601String().split('T')[0];

        await LangkahService.saveDailyRecordToQueue(
          tanggal: yesterdayDate,
          jumlahLangkah: yesterdaySteps,
        );
      }

      // Reset local data untuk hari baru
      await LangkahService.resetLocalData();
      await LangkahService.saveLastSyncDate();

      setState(() {
        _totalSteps = 0;
        _initialSteps = 0;
        progressValue = 0;
        _remainingSteps = 10000;
      });
    } else {
      // Load data dari local storage
      final savedSteps = await LangkahService.getTodaySteps();
      final savedInitial = await LangkahService.getInitialSteps();

      setState(() {
        _totalSteps = savedSteps;
        _initialSteps = savedInitial;
        progressValue = _totalSteps / 10000;
        _remainingSteps = 10000 - _totalSteps;
      });
    }

    // Load data dari API untuk sinkronisasi
    _loadFromAPI();

    // Coba sync pending records (background)
    _attemptBackgroundSync();
  }

  /// Load data dari API
  Future<void> _loadFromAPI() async {
    final result = await LangkahService.getStatusLangkah();

    if (result['success'] && result['hari_ini'] != null) {
      final hariIni = result['hari_ini'];
      final apiSteps = hariIni['jumlah_langkah'] ?? 0;

      // Gunakan data dari API jika lebih besar
      if (apiSteps > _totalSteps) {
        setState(() {
          _totalSteps = apiSteps;
          progressValue = _totalSteps / 10000;
          _remainingSteps = 10000 - _totalSteps;
        });

        await LangkahService.saveTodaySteps(_totalSteps);
      }
    }
  }

  /// Attempt to sync pending records in background (silent)
  Future<void> _attemptBackgroundSync() async {
    try {
      final result = await LangkahService.syncPendingRecords();

      if (result['synced'] > 0) {
      }

      if (result['failed'] > 0) {
      }
    } catch (e) {
      // Silent fail, tidak ganggu user
    }
  }

  void startListening() {

    _stepCountStream = Pedometer.stepCountStream;
    _subscription = _stepCountStream!.listen(
      (StepCount stepCount) async {
        // Jika ini pertama kali, simpan sebagai initial steps
        if (_initialSteps == 0) {
          _initialSteps = stepCount.steps;
          await LangkahService.saveInitialSteps(_initialSteps);
        }

        // Calculate steps hari ini
        final todaySteps = stepCount.steps - _initialSteps;

        setState(() {
          _totalSteps = todaySteps;
          progressValue = _totalSteps / 10000;
          _remainingSteps = 10000 - _totalSteps;
        });

        // Save to local storage
        await LangkahService.saveTodaySteps(_totalSteps);

        // Auto-sync ke API setiap 30 detik
        _autoSyncToAPI();

      },
      onError: (error) {
      }
    );

    // Start timer untuk periodic sync (setiap 30 detik)
    _syncTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _syncToAPI();
    });
  }

  /// Auto-sync dengan debounce
  void _autoSyncToAPI() {
    final now = DateTime.now();

    // Sync hanya jika sudah 30 detik sejak last sync
    if (_lastSyncTime == null ||
        now.difference(_lastSyncTime!).inSeconds >= 30) {
      _syncToAPI();
      _lastSyncTime = now;
    }
  }

  /// Sync ke API (sekarang save ke queue untuk background sync)
  Future<void> _syncToAPI() async {
    if (_totalSteps > 0) {
      // Menggunakan updateLangkahLocal yang akan save ke queue
      // dan coba sync di background
      await LangkahService.updateLangkahLocal(jumlahLangkah: _totalSteps);
    }
  }

  void stopListening() async {
    _subscription?.cancel();
    _syncTimer?.cancel();

    // Sync terakhir sebelum stop
    await _syncToAPI();

  }

  @override
  void dispose() {
    stopListening();
    _syncTimer?.cancel();

    // Save data hari ini ke queue sebelum dispose
    if (_totalSteps > 0) {
      _saveCurrentDayToQueue();
    }

    super.dispose();
  }

  /// Save current day data to queue
  Future<void> _saveCurrentDayToQueue() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await LangkahService.saveDailyRecordToQueue(
      tanggal: today,
      jumlahLangkah: _totalSteps,
    );
  }

  /// Build widget notifikasi untuk langkah kemarin
  Widget _buildYesterdayNotification() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayFormatted = "${yesterday.day}/${yesterday.month}/${yesterday.year}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              FontAwesomeIcons.chartLine,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.circleCheck,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Data Tersinkronisasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Langkah Kemarin',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${_yesterdaySteps!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'langkah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  yesterdayFormatted,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.xmark,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _showYesterdayNotification = false;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffecfdff).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Header(),
            BottomHeader(color: Color(0xff1b8cfd), heading: "Jalan 10.000 Langkah", subHeading: "Aktivitas Fisik", destination: SehatHomepage(),),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Yesterday Steps Notification
                    if (_showYesterdayNotification && _yesterdaySteps != null)
                      _buildYesterdayNotification(),

                    if (_showYesterdayNotification && _yesterdaySteps != null)
                      SizedBox(height: 16),

                    // Counter
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffecf5ff), Color(0xffe4fafe)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight
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
                      ),
                      child: Column(
                        children: [
                          SizedBox.square(
                            dimension: 80,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xff1e89fe),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.shoePrints,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "$_totalSteps",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "langkah hari ini",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 20,),
                          SizedBox(
                            height: 20,
                            child: LinearProgressIndicator(
                              value: progressValue,
                              color: Colors.blue,
                              backgroundColor: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "${(progressValue * 100).toStringAsFixed(2)}% dari target",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xffbedbff),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.bullseye,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8,),
                                    Text(
                                      "$_remainingSteps langkah lagi",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Text(
                                  "Target: 10.000 langkah",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Status Info - Auto Tracking
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xffe0e0e0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.circleCheck,
                            size: 20,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8,),
                          Text(
                            "Tracking berjalan otomatis di background",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Manfaat Jalan 10.000 Langkah
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
                                    color: Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.personWalking,
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
                                    "Manfaat Jalan 10.000 Langkah",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffeff6ff),
                              border: Border.all(
                                  color: Color(0xffbedbff),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "❤️",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Meningkatkan kesehatan jantung",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffeff6ff),
                              border: Border.all(
                                  color: Color(0xffbedbff),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "🔥",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Membakar kalori dan menurunkan berat badan",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffeff6ff),
                              border: Border.all(
                                  color: Color(0xffbedbff),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "🦴",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Memperkuat tulang dan otot",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffeff6ff),
                              border: Border.all(
                                  color: Color(0xffbedbff),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "😊",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Meningkatkan mood dan mengurangi stres",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffeff6ff),
                              border: Border.all(
                                  color: Color(0xffbedbff),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "🧠",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Meningkatkan fungsi otak dan konsentrasi",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),
                    
                    // Tips Mencapai 10.000 Langkah
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffcffafe), Color(0xffdbeafe)]
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
                          color: Color(0xffa2f4fd),
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
                                    color: Color(0xff1e89fe),
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
                                    "Tips Mencapai 10.000 Langkah",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Parkir kendaraan lebih jauh dari tujuan")
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Gunakan tangga daripada lift")
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Jalan-jalan saat istirahat makan siang")
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Ajak rekan kerja jalan bersama")
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // CTA
                    // Container(
                    //   padding: EdgeInsets.all(20),
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //       color: Color(0xfffef3ca),
                    //       borderRadius: BorderRadius.circular(20),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.grey.withOpacity(0.4),
                    //           spreadRadius: 2,
                    //           blurRadius: 8,
                    //           offset: Offset(2, 4),
                    //         ),
                    //       ],
                    //       border: Border.all(
                    //         color: Color(0xffffdf20),
                    //         width: 2,
                    //         style: BorderStyle.solid,
                    //       )
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       SizedBox.square(
                    //         dimension: 80,
                    //         child: Container(
                    //           padding: EdgeInsets.all(8),
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //             color: Color(0xffffe09d),
                    //             borderRadius: BorderRadius.circular(40),
                    //           ),
                    //           child: Text(
                    //             "🙋‍♂️",
                    //             style: TextStyle(
                    //               fontSize: 40,
                    //             ),
                    //             textAlign: TextAlign.center,
                    //           ),
                    //         ),
                    //       ),
                    //       SizedBox(height: 12,),
                    //       Column(
                    //         children: [
                    //           Text(
                    //             "Siap untuk berjemur?",
                    //             style: TextStyle(
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //           Text(
                    //             "Konfirmasi aktivitas berjemur Anda hari ini",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       SizedBox(height: 20,),
                    //       isSunbathe ? Column(
                    //         children: [
                    //           Text(
                    //             "Tubuhmu berterima kasih atas sinar energi alami ini!",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //           SizedBox(height: 12,),
                    //           Text(
                    //             "⭐⭐⭐⭐⭐",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //           SizedBox(height: 12,),
                    //           Container(
                    //             padding: EdgeInsets.all(16),
                    //             decoration: BoxDecoration(
                    //                 color: Color(0xffdbfce7),
                    //                 borderRadius: BorderRadius.circular(20),
                    //                 border: Border.all(
                    //                   color: Color(0xff7bf1a8),
                    //                   width: 2,
                    //                   style: BorderStyle.solid,
                    //                 )
                    //             ),
                    //             child: Column(
                    //               children: [
                    //                 Row(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   children: [
                    //                     Icon(
                    //                       FontAwesomeIcons.circleCheck,
                    //                       size: 20,
                    //                       color: Color(0xff00a63e),
                    //                     ),
                    //                     SizedBox(width: 8,),
                    //                     Text(
                    //                       "Selamat!",
                    //                       style: TextStyle(
                    //                         fontSize: 20,
                    //                         fontWeight: FontWeight.bold,
                    //                         color: Color(0xff00a63e),
                    //                       ),
                    //                     )
                    //                   ],
                    //                 ),
                    //                 SizedBox(height: 12,),
                    //                 Text(
                    //                   "Kamu mendapatkan 1 poin kesehatan",
                    //                   style: TextStyle(
                    //                     fontSize: 16,
                    //                     color: Color(0xff00a63e),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           SizedBox(height: 20,),
                    //           Container(
                    //             decoration: BoxDecoration(
                    //                 gradient: LinearGradient(
                    //                   colors: [Color(0xff00c951), Color(0xff00bba6)],
                    //                   begin: Alignment.centerLeft,
                    //                   end: Alignment.centerRight,
                    //                 ),
                    //                 borderRadius: BorderRadius.circular(20)
                    //             ),
                    //             child: ElevatedButton(
                    //                 onPressed: () {},
                    //                 style: ElevatedButton.styleFrom(
                    //                   padding: EdgeInsets.all(16),
                    //                   backgroundColor: Colors.transparent,
                    //                   shadowColor: Colors.transparent,
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.circular(20),
                    //                   ),
                    //                 ),
                    //                 child: Text(
                    //                   "Lanjut ke Jalan 10.000 Langkah",
                    //                   style: TextStyle(
                    //                     fontSize: 20,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.white,
                    //                   ),
                    //                 )
                    //             ),
                    //           )
                    //         ],
                    //       ) : Container(
                    //         decoration: BoxDecoration(
                    //             gradient: LinearGradient(
                    //               colors: [Color(0xfff0b000), Color(0xffff6a00)],
                    //               begin: Alignment.centerLeft,
                    //               end: Alignment.centerRight,
                    //             ),
                    //             borderRadius: BorderRadius.circular(20)
                    //         ),
                    //         child: ElevatedButton(
                    //             onPressed: sunbathe,
                    //             style: ElevatedButton.styleFrom(
                    //               padding: EdgeInsets.all(16),
                    //               backgroundColor: Colors.transparent,
                    //               shadowColor: Colors.transparent,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               "☀️ Saya Sudah Berjemur",
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.white,
                    //               ),
                    //             )
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
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
