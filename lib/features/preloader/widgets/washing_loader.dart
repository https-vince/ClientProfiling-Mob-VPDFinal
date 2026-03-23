import 'dart:math';
import 'package:flutter/material.dart';

/// Two-pair rotating-ball loader animation.
///
/// Recreates the CSS rotate + ball1 + ball2 keyframe animation in native Flutter.
///
/// Usage:
///   WashingLoader()            // default 50 × 50 base size
///   WashingLoader(scale: 1.5)  // 75 × 75 (50 % larger)
class WashingLoader extends StatefulWidget {
  /// Scale factor applied uniformly to every measurement.
  /// 1.0 = original CSS size (50 × 50 container, 20 × 20 balls).
  final double scale;

  const WashingLoader({Key? key, this.scale = 1.0}) : super(key: key);

  @override
  State<WashingLoader> createState() => _WashingLoaderState();
}

class _WashingLoaderState extends State<WashingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1-second cycle matches the CSS animation-duration: 1s.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    // ── Dimensions (all scaled) ──────────────────────────────────────────
    final base = 50.0 * s;   // total widget bounding box
    final bs = 20.0 * s;     // ball diameter  (CSS: 20px)
    final gap = 30.0 * s;    // left-edge spacing between paired balls (CSS: box-shadow 30px)
    // Position that centres a ball inside [base × base]
    final center = (base - bs) / 2; // = 15 * s

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value; // 0.0 → 1.0 per cycle

        // ── @keyframes rotate ────────────────────────────────────────────
        // 0% → rotate(0deg)  scale(0.8)
        // 50% → rotate(360deg) scale(1.2)
        // 100% → rotate(720deg) scale(0.8)
        final rotateAngle = t * 4 * pi; // 0 → 4π  (= 720°), linear

        final scaleVal = t < 0.5
            ? 0.8 + (t / 0.5) * 0.4         // 0.8 → 1.2
            : 1.2 - ((t - 0.5) / 0.5) * 0.4; // 1.2 → 0.8

        // ── Ball merge factor (ball1 + ball2 keyframes) ──────────────────
        // At t=0.0 / 1.0: balls spread at four corners of a square.
        // At t=0.5: balls converge to the widget centre.
        final rawMerge = t < 0.5 ? t * 2.0 : (1.0 - t) * 2.0;
        final merge = Curves.easeInOut.transform(rawMerge);

        // Lerp helpers: interpolate from spread position → centre
        double bx(double startX) => startX + (center - startX) * merge;
        double by(double startY) => startY + (center - startY) * merge;

        return Transform.rotate(
          angle: rotateAngle,
          child: Transform.scale(
            scale: scaleVal,
            child: SizedBox(
              width: base,
              height: base,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Ball A – white     (top-left,  CSS: .loader:before)
                  Positioned(
                    left: bx(0),
                    top: by(0),
                    child: _ball(bs, Colors.white),
                  ),
                  // Ball B – orange    (top-right,  CSS: box-shadow of ball1)
                  Positioned(
                    left: bx(gap),
                    top: by(0),
                    child: _ball(bs, const Color(0xFFFF3D00)),
                  ),
                  // Ball C – orange    (bottom-left, CSS: .loader:after)
                  Positioned(
                    left: bx(0),
                    top: by(gap),
                    child: _ball(bs, const Color(0xFFFF3D00)),
                  ),
                  // Ball D – white     (bottom-right, CSS: box-shadow of ball2)
                  Positioned(
                    left: bx(gap),
                    top: by(gap),
                    child: _ball(bs, Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ball(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

