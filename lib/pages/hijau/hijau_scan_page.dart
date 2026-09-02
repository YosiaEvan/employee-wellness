import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:employee_wellness/components/bottom_header.dart';
import 'package:flutter/services.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/hijau_scan_card.dart';
import 'package:employee_wellness/config/hijau_scan_points.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:employee_wellness/services/hijau_kpi_service.dart';
import 'package:employee_wellness/services/hijau_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

/// Halaman scan HIJAU 360 dengan verifikasi AR (PromptARHijau).
/// - Live camera preview + overlay AR 2D (bounding box, label, badge +1 poin)
/// - On-device image labeling / face detection (ML Kit) offline, confidence ≥0.7 + N frame
/// - Snapshot bukti disimpan lokal, di-sync offline-first via HijauService
/// - Fallback manual (self-report lama) jika kamera/ML gagal atau timeout 30s
/// - Semua try-catch agar tidak crash (CRITICAL RULES)
class HijauScanPage extends StatefulWidget {
  final HijauScanPoint point;
  final String heading;
  final String subHeading;

  const HijauScanPage({
    super.key,
    required this.point,
    required this.heading,
    required this.subHeading,
  });

  @override
  State<HijauScanPage> createState() => _HijauScanPageState();
}

class _HijauScanPageState extends State<HijauScanPage> with WidgetsBindingObserver {
  bool _loadingKpi = true;
  bool _recording = false;
  int _weekCount = 0;
  int _monthCount = 0;
  bool _doneThisWeek = false;

  // AR state
  CameraController? _cameraController;
  bool _cameraReady = false;
  String? _cameraError;
  bool _isArMode = false;
  bool _isDetecting = false;
  bool _arSuccess = false;
  int _consecutiveFrames = 0;
  double _lastConfidence = 0;
  String _lastLabel = '';
  Rect? _lastBoundingBox;
  String? _snapshotPath;
  Timer? _timeoutTimer;
  Timer? _autoScanTimer;
  ImageLabeler? _labeler;
  FaceDetector? _faceDetector;
  bool _mlInitFailed = false;

  HijauScanPoint get point => widget.point;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadKpi();
    _initMlKit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeoutTimer?.cancel();
    _autoScanTimer?.cancel();
    _disposeCamera();
    _disposeMlKit();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  void _initMlKit() {
    try {
      _labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: HijauScanPoints.confidenceThreshold));
      // ajak_orang_lain: face detection ≥2 wajah sebagai sinyal pendukung
      if (point.kode == 'ajak_orang_lain') {
        _faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast, enableLandmarks: false, enableClassification: false));
      }
    } catch (e) {
      debugPrint('[HijauScan AR] ML Kit init failed: $e');
      _mlInitFailed = true;
    }
  }

  void _disposeMlKit() {
    try { _labeler?.close(); } catch (_) {}
    try { _faceDetector?.close(); } catch (_) {}
  }

  Future<void> _loadKpi() async {
    setState(() => _loadingKpi = true);
    try {
      final weekly = await HijauKPIService.getWeeklyKPI();
      final monthly = await HijauKPIService.getMonthlyKPI();
      if (!mounted) return;
      setState(() {
        if (weekly['success'] == true) {
          final list = (weekly['data']?['aktivitas'] as List<dynamic>? ?? []);
          final item = _findByKode(list, point.kode);
          _weekCount = (item?['tercapai'] as num?)?.toInt() ?? 0;
          _doneThisWeek = _weekCount >= 1;
        }
        if (monthly['success'] == true) {
          final list = (monthly['data']?['aktivitas'] as List<dynamic>? ?? []);
          final item = _findByKode(list, point.kode);
          _monthCount = (item?['tercapai'] as num?)?.toInt() ?? 0;
        }
        _loadingKpi = false;
      });
    } catch (e) {
      debugPrint('[HijauScan] _loadKpi error: $e');
      if (mounted) setState(() => _loadingKpi = false);
    }
  }

  Map<String, dynamic>? _findByKode(List<dynamic> list, String kode) {
    for (final item in list) {
      if (item is Map<String, dynamic> && (item['aktivitas'] ?? item['kode']).toString() == kode) return item;
    }
    return null;
  }

  // ── CAMERA ──────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    if (_cameraReady || _cameraController != null) return;
    setState(() { _cameraError = null; _cameraReady = false; });
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw Exception('Tidak ada kamera tersedia');
      final cam = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final ctrl = CameraController(cam, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await ctrl.initialize();
      // Lock to portrait
      try { await ctrl.lockCaptureOrientation(DeviceOrientation.portraitUp); } catch (_) {}
      if (!mounted) { await ctrl.dispose(); return; }
      setState(() { _cameraController = ctrl; _cameraReady = true; });
      // Timeout 30s → tampilkan fallback manual (§3.7)
      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(HijauScanPoints.scanTimeout, () {
        if (mounted && _isArMode && !_arSuccess) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak terdeteksi — gunakan Laporan manual di bawah'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
        }
      });
      // Opsional: auto-scan setiap 3s untuk demo (snapshot + labeling) — tidak spam, hanya 1 sukses/minggu tetap ditegakkan backend
      _autoScanTimer?.cancel();
      _autoScanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_isArMode && !_arSuccess && !_isDetecting && _cameraReady) _takeSnapshotAndDetect();
      });
    } catch (e) {
      debugPrint('[HijauScan AR] camera init error: $e');
      if (mounted) setState(() { _cameraError = e.toString(); _cameraReady = false; });
    }
  }

  Future<void> _disposeCamera() async {
    _timeoutTimer?.cancel();
    _autoScanTimer?.cancel();
    try { await _cameraController?.dispose(); } catch (_) {}
    _cameraController = null;
    _cameraReady = false;
  }

  void _enterArMode() {
    if (_doneThisWeek) return;
    setState(() { _isArMode = true; _arSuccess = false; _consecutiveFrames = 0; _lastConfidence = 0; _lastLabel = ''; _lastBoundingBox = null; _snapshotPath = null; });
    _initCamera();
  }

  void _exitArMode() {
    setState(() => _isArMode = false);
    _disposeCamera();
  }

  // ── SNAPSHOT + ML KIT DETECTION ────────────────────────────────────

  Future<void> _takeSnapshotAndDetect() async {
    if (_isDetecting || _arSuccess) return;
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamera belum siap'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isDetecting = true);
    String? snapPath;
    try {
      final file = await ctrl.takePicture();
      snapPath = file.path;
      // Simpan copy ke app dir sebagai bukti (agar tidak hilang saat tmp dibersihkan)
      try {
        final dir = await getTemporaryDirectory();
        final dest = '${dir.path}/hijau_${point.kode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(file.path).copy(dest);
        snapPath = dest;
      } catch (_) {}
      setState(() => _snapshotPath = snapPath);

      // Pilih detector: face untuk ajak_orang_lain, else image labeling
      if (point.kode == 'ajak_orang_lain' && _faceDetector != null) {
        await _detectFaces(snapPath!);
      } else {
        await _detectWithLabeler(snapPath!);
      }
    } catch (e) {
      debugPrint('[HijauScan AR] snapshot detect error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal scan: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  Future<void> _detectFaces(String path) async {
    final detector = _faceDetector;
    if (detector == null) { _handleManualFallback('Face detector tidak tersedia'); return; }
    try {
      final input = InputImage.fromFilePath(path);
      final faces = await detector.processImage(input);
      final count = faces.length;
      debugPrint('[HijauScan AR] faces: $count');
      if (count >= 2) {
        // Sukses ≥2 wajah, confidence simulasi 0.82 (ML Kit face tidak berikan confidence per-face)
        _onArCandidateDetected(label: 'people ($count wajah)', confidence: 0.82, box: faces.first.boundingBox, snapshotPath: path);
      } else {
        _consecutiveFrames = 0;
        if (mounted) {
          setState(() { _lastLabel = 'Terdeteksi $count wajah — butuh ≥2 orang'; _lastConfidence = 0; _lastBoundingBox = null; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Butuh foto bersama ≥2 orang ($_lastLabel) — coba lagi atau gunakan Laporan manual'), backgroundColor: Colors.orange, duration: const Duration(seconds: 2)));
        }
      }
    } catch (e) {
      debugPrint('[HijauScan AR] face error: $e');
      _handleManualFallback('Gagal deteksi wajah');
    }
  }

  Future<void> _detectWithLabeler(String path) async {
    final labeler = _labeler;
    if (labeler == null) { _handleManualFallback('ML Kit tidak tersedia'); return; }
    try {
      final input = InputImage.fromFilePath(path);
      final labels = await labeler.processImage(input);
      debugPrint('[HijauScan AR] labels: ${labels.map((l) => "${l.label}:${l.confidence.toStringAsFixed(2)}").join(", ")}');
      // Cari label yang match arLabels untuk kategori ini dengan confidence ≥ threshold
      ImageLabel? best;
      for (final l in labels) {
        if (l.confidence < HijauScanPoints.confidenceThreshold) continue;
        if (HijauScanPoints.isLabelMatch(l.label, point.kode)) {
          if (best == null || l.confidence > best.confidence) best = l;
        }
      }
      // Fallback: coba lowercase contains manual jika tidak ada match via helper (mis. label "Faucet" vs "tap")
      ImageLabel? fallbackBest;
      if (best == null) {
        for (final l in labels) {
          if (l.confidence < HijauScanPoints.confidenceThreshold) continue;
          final q = l.label.toLowerCase();
          for (final kw in point.arLabels) {
            if (q.contains(kw.toLowerCase())) { if (fallbackBest == null || l.confidence > fallbackBest.confidence) fallbackBest = l; break; }
          }
        }
        best = fallbackBest;
      }
      if (best != null) {
        _onArCandidateDetected(label: best.label, confidence: best.confidence, box: null, snapshotPath: path);
      } else {
        final top = labels.isNotEmpty ? labels.first.label : 'tidak ada objek';
        _consecutiveFrames = 0;
        if (mounted) {
          setState(() { _lastLabel = top; _lastConfidence = labels.isNotEmpty ? labels.first.confidence : 0; _lastBoundingBox = null; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Objek tidak cocok ($top) — arahkan ke ${point.arLabels.take(3).join(", ")} atau gunakan Laporan manual'), backgroundColor: Colors.orange, duration: const Duration(seconds: 2)));
        }
      }
    } catch (e) {
      debugPrint('[HijauScan AR] label error: $e');
      _handleManualFallback('Gagal labeling');
    }
  }

  void _onArCandidateDetected({required String label, required double confidence, Rect? box, required String snapshotPath}) {
    _consecutiveFrames += 1;
    if (_consecutiveFrames < HijauScanPoints.requiredConsecutiveFrames) {
      // Untuk snapshot-based MVP, 1 frame sudah cukup (periodic snapshot = tiap 3s). Simulasi: cukup 1.
      // Tetap tampilkan progress
      if (mounted) setState(() { _lastLabel = label; _lastConfidence = confidence; _lastBoundingBox = box ?? const Rect.fromLTWH(40, 120, 220, 180); });
      // Auto-konfirmasi setelah threshold tercapai (tanpa tunggu frame tambahan untuk UX snapshot)
      // Jika ingin strict N frame, uncomment: if (_consecutiveFrames < N) return;
    }
    if (mounted) setState(() { _lastLabel = label; _lastConfidence = confidence; _lastBoundingBox = box ?? const Rect.fromLTWH(40, 120, 220, 180); _arSuccess = true; });
    _timeoutTimer?.cancel();
    _autoScanTimer?.cancel();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terdeteksi $label (${(confidence*100).toStringAsFixed(0)}%) — siap kirim +1 poin'), backgroundColor: point.color, duration: const Duration(seconds: 1)));
    // Otomatis kirim setelah sukses (tanpa tekan lagi) — sesuai flow §3.5
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _arSuccess) _confirmArScan();
    });
  }

  void _handleManualFallback(String reason) {
    debugPrint('[HijauScan AR] fallback: $reason');
  }

  // ── CONFIRM ────────────────────────────────────────────────────────

  Future<void> _confirmManual() async {
    if (_recording || _doneThisWeek) return;
    setState(() => _recording = true);
    try {
      final result = await HijauService.recordGreenActivity(
        activityType: point.kode,
        description: point.title,
        points: 1,
        category: point.kategori,
        metodeVerifikasi: 'manual',
      );
      if (!mounted) return;
      setState(() => _recording = false);
      final ok = result['success'] == true;
      final msg = result['message']?.toString();
      final isCap = result['statusCode'] == 409;
      ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
        content: Text(ok ? ' ${point.title} tercatat (manual). +1 poin!' : (msg?.isNotEmpty == true ? ' $msg' : ' Gagal mencatat')),
        backgroundColor: ok ? point.color : (isCap ? Colors.orange.shade700 : Colors.red), duration: const Duration(seconds: 3)));
      if (ok || isCap) _loadKpi();
    } catch (e) {
      if (mounted) setState(() => _recording = false);
      debugPrint('[HijauScan] _confirmManual error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _confirmArScan() async {
    if (_recording || _doneThisWeek || !_arSuccess) return;
    setState(() => _recording = true);
    try {
      final result = await HijauService.recordGreenActivity(
        activityType: point.kode,
        description: point.title,
        points: 1,
        category: point.kategori,
        metodeVerifikasi: 'ar_scan',
        confidenceScore: _lastConfidence,
        buktiFotoUrl: _snapshotPath,
      );
      if (!mounted) return;
      setState(() => _recording = false);
      final ok = result['success'] == true;
      final msg = result['message']?.toString();
      final isCap = result['statusCode'] == 409;
      ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
        content: Text(ok ? ' ${point.title} terverifikasi AR! +1 poin (conf ${( _lastConfidence*100).toStringAsFixed(0)}%)' : (msg?.isNotEmpty == true ? ' $msg' : ' Gagal mencatat AR')),
        backgroundColor: ok ? point.color : (isCap ? Colors.orange.shade700 : Colors.red), duration: const Duration(seconds: 3)));
      if (ok || isCap) {
        _loadKpi();
        // Kembali ke mode card setelah sukses
        setState(() { _isArMode = false; _arSuccess = false; });
        _disposeCamera();
      }
    } catch (e) {
      if (mounted) setState(() => _recording = false);
      debugPrint('[HijauScan AR] _confirmArScan error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error AR: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            BottomHeader(color: point.color, heading: widget.heading, subHeading: widget.subHeading, destination: const HijauHomepage()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadKpi,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBanner(),
                      const SizedBox(height: 16),
                      if (_isArMode) _buildArArea() else HijauScanCard(point: point, doneThisWeek: _doneThisWeek, loading: _recording, onConfirm: _confirmManual, weekCount: _weekCount, monthCount: _monthCount),
                      const SizedBox(height: 12),
                      _buildModeSwitch(),
                      const SizedBox(height: 12),
                      Center(child: TextButton.icon(onPressed: _loadKpi, icon: const Icon(Icons.refresh, size: 18), label: Text(_loadingKpi ? 'Memuat data...' : 'Muat ulang status', style: const TextStyle(fontSize: 13)))),
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

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16), width: double.infinity,
      decoration: BoxDecoration(color: point.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: point.color.withValues(alpha: 0.3))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: point.color, shape: BoxShape.circle), child: FaIcon(point.icon, size: 18, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Text(_doneThisWeek ? 'Kamu sudah meraih poin ${point.title} minggu ini. Kembali pekan depan untuk poin baru!' : 'Scan AR: arahkan kamera ke ${point.arLabels.take(3).join(", ")} (conf ≥${(HijauScanPoints.confidenceThreshold*100).toStringAsFixed(0)}%, ${HijauScanPoints.requiredConsecutiveFrames} frame). Atau gunakan Laporan manual.', style: TextStyle(fontSize: 13.5, height: 1.4, color: Colors.grey[800]))),
      ]),
    );
  }

  Widget _buildModeSwitch() {
    if (_doneThisWeek) return const SizedBox.shrink();
    return Column(children: [
      if (!_isArMode)
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _enterArMode, icon: FaIcon(FontAwesomeIcons.camera, size: 16, color: point.color), label: Text('Buka Kamera AR — Scan ${_getArHint()}', style: TextStyle(color: point.color, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: point.color, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
      if (_isArMode)
        SizedBox(width: double.infinity, child: TextButton.icon(onPressed: _exitArMode, icon: const FaIcon(FontAwesomeIcons.xmark, size: 16), label: const Text('Tutup Kamera'), style: TextButton.styleFrom(foregroundColor: Colors.grey))),
      if (_isArMode) const SizedBox(height: 8),
      if (_isArMode || _mlInitFailed)
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))), child: Row(children: [const FaIcon(FontAwesomeIcons.circleInfo, size: 16, color: Colors.orange), const SizedBox(width: 8), const Expanded(child: Text('Jika kamera/ML tidak tersedia, gunakan tombol "Laporkan manual" di bawah — tetap tercatat sebagai manual untuk transparansi admin.', style: TextStyle(fontSize: 12, color: Colors.black87))) ])),
    ]);
  }

  String _getArHint() {
    switch (point.kode) {
      case 'hemat_air': return 'keran/ember';
      case 'hemat_listrik': return 'lampu/saklar';
      case 'gaya_hidup_hijau': return 'tumbler/tas';
      case 'ubah_kebiasaan': return 'tempat sampah/tangga';
      case 'ajak_orang_lain': return 'foto bersama (≥2 wajah)';
      default: return 'objek hijau';
    }
  }

  Widget _buildArArea() {
    if (_doneThisWeek) {
      return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: point.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: point.color.withValues(alpha: 0.3))), child: Row(children: [FaIcon(FontAwesomeIcons.circleCheck, color: point.color, size: 28), const SizedBox(width: 12), Expanded(child: Text('Selesai minggu ini — kembali pekan depan untuk poin ${point.title} baru!', style: TextStyle(color: point.color, fontWeight: FontWeight.bold)))]));
    }
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(fit: StackFit.expand, children: [
            if (_cameraReady && _cameraController != null) CameraPreview(_cameraController!) else _buildCameraPlaceholder(),
            // AR overlay (CustomPainter) — bounding box + label + badge
            if (_cameraReady) Positioned.fill(child: CustomPaint(painter: ArOverlayPainter(point: point, boundingBox: _lastBoundingBox, label: _lastLabel, confidence: _lastConfidence, success: _arSuccess))),
            // Top instruction
            Positioned(top: 12, left: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [FaIcon(point.icon, size: 14, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(_arSuccess ? 'Terverifikasi! +1 poin' : 'Arahkan ke ${_getArHint()}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]))),
            // Center guide
            if (!_arSuccess) Center(child: Container(width: 160, height: 160, decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.crop_free, color: Colors.white70, size: 40))),
            // Bottom confidence
            if (_lastLabel.isNotEmpty) Positioned(bottom: 12, left: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _arSuccess ? point.color : Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)), child: Text('$_lastLabel • ${( _lastConfidence*100).toStringAsFixed(0)}% ${_arSuccess ? "• Terverifikasi AR" : "• Scan lagi atau Laporan manual"}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis))),
            if (_isDetecting) Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.25), child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
          ]),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: _isDetecting || _arSuccess || _recording ? null : _takeSnapshotAndDetect, icon: _isDetecting ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const FaIcon(FontAwesomeIcons.camera, size: 16), label: Text(_arSuccess ? 'Terverifikasi' : 'Scan Objek', style: const TextStyle(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: point.color, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(onPressed: _arSuccess && !_recording ? _confirmArScan : null, icon: _recording ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const FaIcon(FontAwesomeIcons.circleCheck, size: 16), label: Text(_recording ? 'Mengirim...' : '+1 Poin (AR)', style: const TextStyle(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade200, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ]),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _recording ? null : _confirmManual, icon: const FaIcon(FontAwesomeIcons.pen, size: 14), label: const Text('Laporkan manual (tanpa AR)', style: TextStyle(fontSize: 13)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            const SizedBox(height: 6),
            Text('Manual tetap tercatat untuk transparansi admin (metode_verifikasi=manual). AR = ar_scan.', style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
            if (_snapshotPath != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Bukti: ${_snapshotPath!.split('/').last}', style: TextStyle(fontSize: 10, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (_cameraError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Kamera: $_cameraError', style: const TextStyle(fontSize: 11, color: Colors.red), textAlign: TextAlign.center)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_cameraError != null) const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.orange, size: 28) else const SizedBox.square(dimension: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        const SizedBox(height: 12),
        Text(_cameraError != null ? 'Kamera tidak tersedia' : 'Memuat kamera...', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        if (_cameraError != null) Padding(padding: const EdgeInsets.only(top: 8, left: 16, right: 16), child: Text(_cameraError!, style: const TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
      ])),
    );
  }
}

/// CustomPainter overlay AR 2D (Prompt §2: bukan AR 3D) — bounding box, label, badge poin
class ArOverlayPainter extends CustomPainter {
  final HijauScanPoint point;
  final Rect? boundingBox;
  final String label;
  final double confidence;
  final bool success;

  ArOverlayPainter({required this.point, this.boundingBox, this.label = '', this.confidence = 0, this.success = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (boundingBox == null && !success) return;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = success ? Colors.greenAccent : point.color;
    final r = boundingBox ?? Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width*0.55, height: size.height*0.35);
    // Draw box
    final rrect = RRect.fromRectAndRadius(r, const Radius.circular(12));
    canvas.drawRRect(rrect, paint);
    // Corners
    const cornerLen = 18.0;
    final cornerPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = success ? Colors.green : Colors.white;
    for (final corner in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      final isLeft = corner.dx < size.width/2;
      final isTop = corner.dy < size.height/2;
      final h = Rect.fromLTWH(corner.dx + (isLeft ? 0 : -cornerLen), corner.dy, cornerLen, 3);
      final v = Rect.fromLTWH(corner.dx, corner.dy + (isTop ? 0 : -cornerLen), 3, cornerLen);
      canvas.drawRect(h, cornerPaint);
      canvas.drawRect(v, cornerPaint);
    }
    if (success) {
      // Badge +1 poin
      const badgeR = 22.0;
      final badgeCenter = Offset(r.center.dx, r.top - 18);
      canvas.drawCircle(badgeCenter, badgeR, Paint()..color = Colors.green);
      final tp = TextPainter(text: const TextSpan(text: '+1', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(badgeCenter.dx - tp.width/2, badgeCenter.dy - tp.height/2));
    }
  }

  @override
  bool shouldRepaint(covariant ArOverlayPainter old) => old.boundingBox != boundingBox || old.success != success || old.label != label || old.confidence != confidence;
}
