import 'dart:async';
import 'package:employee_wellness/components/auto_refresh_mixin.dart';
import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/services/background_steps_tracker.dart';
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

class _Jalan10000LangkahState extends State<Jalan10000Langkah> with AutoRefreshMixin<Jalan10000Langkah> {
  int _totalSteps = 0;
  double progressValue = 0;
  int _remainingSteps = 10000;

  // Yesterday's steps notification
  int? _yesterdaySteps;
  bool _showYesterdayNotification = false;
  bool _isLoadingYesterday = true;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
    _loadYesterdaySteps();
    // Gunakan listener dari tracker terpusat
    BackgroundStepsTracker.stepsNotifier.addListener(_onTrackerUpdate);
    // Pastikan tracker aktif
    _autoStartTracking();
  }

  void _onTrackerUpdate() {
    if (mounted) {
      setState(() {
        _totalSteps = BackgroundStepsTracker.todaySteps;
        progressValue = _totalSteps / 10000;
        _remainingSteps = 10000 - _totalSteps;
      });
    }
  }

  @override
  void dispose() {
    BackgroundStepsTracker.stepsNotifier.removeListener(_onTrackerUpdate);
    // Save data hari ini ke queue sebelum dispose
    if (_totalSteps > 0) {
      _saveCurrentDayToQueue();
    }
    super.dispose();
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
          setState(() => _isLoadingYesterday = false);
        }
      } else {
        setState(() => _isLoadingYesterday = false);
      }
    } catch (e) {
      print('❌ Error loading yesterday steps: $e');
      if (mounted) setState(() => _isLoadingYesterday = false);
    }
  }

  /// Auto-start pedometer tracking
  Future<void> _autoStartTracking() async {
    if (!BackgroundStepsTracker.isInitialized) {
      await BackgroundStepsTracker.initialize();
    }
    // Update data awal dari tracker
    _onTrackerUpdate();
  }

  /// Initialize steps
  Future<void> _initializeSteps() async {
    // Load data awal dari storage
    final savedSteps = await LangkahService.getTodaySteps();
    setState(() {
      _totalSteps = savedSteps;
      progressValue = _totalSteps / 10000;
      _remainingSteps = 10000 - _totalSteps;
    });

    // Sync with background tracker data
    if (BackgroundStepsTracker.todaySteps > _totalSteps) {
       _onTrackerUpdate();
    }

    // Load data dari API untuk sinkronisasi
    _loadFromAPI();

    // Coba sync pending records
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
        BackgroundStepsTracker.updateStepsExternally(_totalSteps);
      }
    }
  }

  /// Attempt to sync pending records in background (silent)
  Future<void> _attemptBackgroundSync() async {
    try {
      await LangkahService.syncPendingRecords();
    } catch (e) {
      // Silent fail
    }
  }

  /// Sync data ke API
  Future<void> _syncToAPI() async {
    if (_totalSteps > 0) {
      await LangkahService.updateLangkahLocal(jumlahLangkah: _totalSteps);
      try {
        await StepsSyncService.instance.saveStepsLocally(
          tanggal: DateTime.now().toIso8601String().split('T')[0],
          totalSteps: _totalSteps,
        );
      } catch (e) {
        print('⚠️ Failed to sync to StepsDatabase: $e');
      }
    }
  }

  void stopListening() async {
    // Sync terakhir sebelum stop
    await _syncToAPI();
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
            child: const FaIcon(
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
                    const FaIcon(
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
            icon: const FaIcon(
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
              child: RefreshIndicator(
                onRefresh: _initializeSteps,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                child: ResponsiveContainer(
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
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xff1e89fe),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const FaIcon(
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
                                    FaIcon(
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
                    ValueListenableBuilder<String>(
                      valueListenable: BackgroundStepsTracker.statusNotifier,
                      builder: (context, status, _) {
                        bool isWalking = status == 'walking';
                        bool isError = status.toLowerCase().contains('error') || status.toLowerCase().contains('denied');

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isError ? Colors.red[50] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isError ? Colors.red[200]! : const Color(0xffe0e0e0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                isError 
                                    ? FontAwesomeIcons.circleExclamation 
                                    : (isWalking ? FontAwesomeIcons.personWalking : FontAwesomeIcons.circleCheck),
                                size: 20,
                                color: isError ? Colors.red : (isWalking ? Colors.blue : Colors.green),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isError ? "Error: $status" : "Status: $status (Tracking Aktif)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isError ? Colors.red : (isWalking ? Colors.blue : Colors.green),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
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
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const FaIcon(
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
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const FaIcon(
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
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    const Expanded(
                                      child: Text(
                                        "Parkir kendaraan lebih jauh dari tujuan",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
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
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    const Expanded(
                                      child: Text(
                                        "Gunakan tangga daripada lift",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
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
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    const Expanded(
                                      child: Text(
                                        "Jalan-jalan saat istirahat makan siang",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
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
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    const Expanded(
                                      child: Text(
                                        "Ajak rekan kerja jalan bersama",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
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
}
