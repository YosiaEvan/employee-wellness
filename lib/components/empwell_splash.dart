import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One-shot EmpWell logo reveal shown while the app completes cold-start setup.
class EmpWellSplash extends StatefulWidget {
  const EmpWellSplash({super.key});

  @override
  State<EmpWellSplash> createState() => _EmpWellSplashState();
}

class _EmpWellSplashState extends State<EmpWellSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _blueArc;
  late final Animation<double> _orangeFigure;
  late final Animation<double> _greenLeaf;
  late final Animation<double> _wordmark;
  late final Animation<double> _finalLogo;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _blueArc = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.02, 0.64, curve: Curves.easeInOutCubic),
    );
    _orangeFigure = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.68, curve: Curves.easeOutCubic),
    );
    _greenLeaf = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.80, curve: Curves.easeOutCubic),
    );
    _wordmark = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.92, curve: Curves.easeOutCubic),
    );
    _finalLogo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.94, 1, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _layer(String asset) => Image.asset(
    asset,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final logoSize = math.min(
      360.0,
      math.min(screen.width * 0.84, screen.height * 0.58),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox.square(
          dimension: logoSize,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _blueArc,
                child: _layer('assets/img/empwell_splash_blue.png'),
                builder: (context, child) => ClipPath(
                  clipper: _ArcRevealClipper(progress: _blueArc.value),
                  child: child,
                ),
              ),
              AnimatedBuilder(
                animation: _orangeFigure,
                child: _layer('assets/img/empwell_splash_orange.png'),
                builder: (context, child) => Opacity(
                  opacity: _orangeFigure.value,
                  child: Transform.scale(
                    scale: 0.82 + 0.18 * _orangeFigure.value,
                    alignment: const Alignment(0, -0.15),
                    child: child,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _greenLeaf,
                child: _layer('assets/img/empwell_splash_green.png'),
                builder: (context, child) => Opacity(
                  opacity: _greenLeaf.value,
                  child: Transform.translate(
                    offset: Offset(14 * (1 - _greenLeaf.value), 5),
                    child: child,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _wordmark,
                child: _layer('assets/img/empwell_splash_wordmark.png'),
                builder: (context, child) => ClipRect(
                  clipper: _BottomUpRevealClipper(progress: _wordmark.value),
                  child: child,
                ),
              ),
              FadeTransition(
                opacity: _finalLogo,
                child: _layer('assets/img/logoapk-employeewellness.jpeg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcRevealClipper extends CustomClipper<Path> {
  final double progress;

  const _ArcRevealClipper({required this.progress});

  @override
  Path getClip(Size size) {
    if (progress <= 0) return Path();

    final center = Offset(size.width * 0.5, size.height * 0.34);
    final radius = size.longestSide * 0.8;
    const startAngle = math.pi * 0.5;
    const sweepAngle = math.pi * 1.34;
    final circle = Rect.fromCircle(center: center, radius: radius);

    return Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * math.cos(startAngle),
        center.dy + radius * math.sin(startAngle),
      )
      ..arcTo(circle, startAngle, sweepAngle * progress, false)
      ..close();
  }

  @override
  bool shouldReclip(covariant _ArcRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}

class _BottomUpRevealClipper extends CustomClipper<Rect> {
  final double progress;

  const _BottomUpRevealClipper({required this.progress});

  @override
  Rect getClip(Size size) => Rect.fromLTWH(
    0,
    size.height * (1 - progress),
    size.width,
    size.height * progress,
  );

  @override
  bool shouldReclip(covariant _BottomUpRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}
