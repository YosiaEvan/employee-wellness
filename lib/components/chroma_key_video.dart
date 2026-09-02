import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Overlay animasi landscape transparan di atas stream kamera AR.
///
/// WebP ber-alpha diputar frame-per-frame: hanya frame aktif yang dirender,
/// frame sebelumnya langsung di-dispose (tidak ditumpuk), dan pemutaran
/// dimatikan saat widget tidak berjalan (app inactive / dispose).
/// Hanya video landscape animasi ini yang di-chroma; video lain
/// (keran.mp4 / listrik.mp4) diputar normal tanpa chroma.
class ChromaKeyVideo extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ChromaKeyVideo({
    super.key,
    this.assetPath = 'assets/videos/animasi_transparent.webp',
    this.width = 128,
    this.height = 72,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<ChromaKeyVideo> createState() => _ChromaKeyVideoState();
}

class _ChromaKeyVideoState extends State<ChromaKeyVideo> with WidgetsBindingObserver {
  static const Duration _fallbackFrameDuration = Duration(milliseconds: 66);

  ui.Codec? _codec;
  ui.Image? _frame;
  Timer? _timer;
  Duration _frameDuration = _fallbackFrameDuration;
  bool _loadingCodec = false;
  bool _advancing = false;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _running = true;
    _loadCodec();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _running = false;
    _cancelTimer();
    _codec?.dispose();
    _codec = null;
    _frame?.dispose();
    _frame = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resume();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _stop();
    }
  }

  Future<void> _loadCodec() async {
    if (_loadingCodec) return;
    _loadingCodec = true;
    try {
      final bundle = DefaultAssetBundle.of(context);
      final data = await bundle.load(widget.assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      if (!mounted || !_running) {
        codec.dispose();
        return;
      }
      _codec?.dispose();
      _codec = codec;
      _nextFrame();
    } catch (e) {
      debugPrint('[ChromaKeyVideo] load error: $e');
    } finally {
      _loadingCodec = false;
    }
  }

  void _resume() {
    if (!_running) {
      _running = true;
      if (mounted) setState(() {});
    }
    if (_codec == null) {
      _loadCodec();
    } else {
      _nextFrame();
    }
  }

  void _stop() {
    _running = false;
    _cancelTimer();
    final old = _frame;
    _frame = null;
    old?.dispose();
    if (mounted) setState(() {});
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _nextFrame() async {
    if (_advancing || !_running) return;
    final codec = _codec;
    if (codec == null) return;
    _advancing = true;
    try {
      final info = await codec.getNextFrame();
      if (!mounted || !_running) {
        info.image.dispose();
        return;
      }
      final previous = _frame;
      if (info.duration > Duration.zero) _frameDuration = info.duration;
      setState(() {
        _frame = info.image;
      });
      previous?.dispose();
      _cancelTimer();
      _timer = Timer(_frameDuration, _nextFrame);
    } catch (e) {
      debugPrint('[ChromaKeyVideo] frame error: $e');
      _codec?.dispose();
      _codec = null;
      _loadCodec();
    } finally {
      _advancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _frame == null
            ? const SizedBox.shrink()
            : RawImage(
                image: _frame,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
      ),
    );
  }
}
