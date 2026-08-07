import 'package:employee_wellness/config/hijau_scan_points.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

/// Kartu titik scan HIJAU: animasi (video) + wawasan + tombol konfirmasi
/// "Sudah ..." yang menghasilkan 1 poin (cap 1/minggu per aktivitas).
class HijauScanCard extends StatefulWidget {
  final HijauScanPoint point;
  final bool doneThisWeek;
  final bool loading;
  final VoidCallback onConfirm;
  final int weekCount;
  final int monthCount;

  const HijauScanCard({
    super.key,
    required this.point,
    required this.doneThisWeek,
    required this.loading,
    required this.onConfirm,
    this.weekCount = 0,
    this.monthCount = 0,
  });

  @override
  State<HijauScanCard> createState() => _HijauScanCardState();
}

class _HijauScanCardState extends State<HijauScanCard> {
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _videoFailed = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    final asset = widget.point.videoAsset;
    if (asset != null) {
      _controller = VideoPlayerController.asset(asset)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _videoReady = true);
          _controller!.setLooping(true);
          _controller!.play();
          setState(() => _playing = true);
        }).catchError((Object e) {
          if (!mounted) return;
          setState(() => _videoFailed = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (!_videoReady || c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _playing = false;
      } else {
        c.play();
        _playing = true;
      }
    });
  }

  bool get _useVideo => widget.point.videoAsset != null && !_videoFailed;

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaArea(point),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(point.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  point.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.doneThisWeek)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: point.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.circleCheck, size: 14, color: point.color),
                      const SizedBox(width: 6),
                      Text(
                        'Selesai minggu ini',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: point.color),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsight(point),
          const SizedBox(height: 16),
          _buildProgressRow(point),
          const SizedBox(height: 20),
          _buildConfirmButton(point),
          const SizedBox(height: 10),
          Text(
            'Satu klik = satu laporan = 1 poin. Maksimal 1 poin per minggu untuk '
            'aktivitas ini (4 poin per bulan).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaArea(HijauScanPoint point) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_useVideo && _videoReady && _controller != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              _FallbackAnimation(point: point),
            if (_useVideo && _videoReady)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _togglePlay,
                  child: Center(
                    child: _playing
                        ? null
                        : Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 22),
                          ),
                  ),
                ),
              ),
            if (_videoFailed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Animasi segera hadir', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsight(HijauScanPoint point) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: point.softColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: point.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.lightbulb, size: 16, color: point.color),
              const SizedBox(width: 8),
              Text(
                'Tahukah Anda?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: point.color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            point.insight,
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(HijauScanPoint point) {
    return Row(
      children: [
        _buildProgressChip('Minggu ini', widget.weekCount, 1, point.color, FontAwesomeIcons.calendarWeek),
        const SizedBox(width: 12),
        _buildProgressChip('Bulan ini', widget.monthCount, 4, point.color, FontAwesomeIcons.calendarDays),
      ],
    );
  }

  Widget _buildProgressChip(String label, int nilai, int target, Color color, FaIconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$nilai/$target',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(HijauScanPoint point) {
    final done = widget.doneThisWeek;
    final busy = widget.loading;

    Widget child;
    if (busy) {
      child = SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
      );
    } else if (done) {
      child = const Text('✔ Selesai minggu ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(point.confirmLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('+1 Poin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (done || busy) ? null : widget.onConfirm,
        icon: done
            ? const FaIcon(FontAwesomeIcons.circleCheck, size: 18)
            : const FaIcon(FontAwesomeIcons.camera, size: 18),
        label: child,
        style: ElevatedButton.styleFrom(
          backgroundColor: done ? point.color : point.color,
          disabledBackgroundColor: point.color.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _FallbackAnimation extends StatefulWidget {
  final HijauScanPoint point;
  const _FallbackAnimation({required this.point});

  @override
  State<_FallbackAnimation> createState() => _FallbackAnimationState();
}

class _FallbackAnimationState extends State<_FallbackAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [point.color.withValues(alpha: 0.9), point.color.withValues(alpha: 0.6)],
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: 0.92 + (0.08 * t),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: FaIcon(point.icon, size: 56, color: point.color),
              ),
            ),
          ),
        );
      },
    );
  }
}
