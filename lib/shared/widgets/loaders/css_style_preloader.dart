import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Recreates the CSS-based preloader design with shaking and spinning animations.
class CssStylePreloader extends StatefulWidget {
  final double size;
  final Color backgroundColor;

  const CssStylePreloader({
    super.key,
    this.size = 120,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  @override
  State<CssStylePreloader> createState() => _CssStylePreloaderState();
}

class _CssStylePreloaderState extends State<CssStylePreloader>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _spinController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();

    // Shake animation: 3 seconds ease-in-out, infinite
    _shakeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shakeAnimation = _buildShakeAnimation();

    // Spin animation: 3 seconds ease-in-out, infinite
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _spinAnimation = _buildSpinAnimation();
  }

  Animation<double> _buildShakeAnimation() {
    return TweenSequence<double>([
      // 0% - 50%: rotate 0
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 50,
      ),
      // 50% - 65%: rotate -0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -0.5),
        weight: 15,
      ),
      // 65% - 75%: rotate 0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.5, end: 0.5),
        weight: 10,
      ),
      // 75% - 80%: rotate -0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: -0.5),
        weight: 5,
      ),
      // 80% - 84%: rotate 0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.5, end: 0.5),
        weight: 4,
      ),
      // 84% - 88%: rotate -0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: -0.5),
        weight: 4,
      ),
      // 88% - 92%: rotate 0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.5, end: 0.5),
        weight: 4,
      ),
      // 92% - 96%: rotate -0.5deg
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: -0.5),
        weight: 4,
      ),
      // 96% - 100%: rotate 0
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.5, end: 0),
        weight: 4,
      ),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  Animation<double> _buildSpinAnimation() {
    return TweenSequence<double>([
      // 0% - 50%: rotate 0 to 360
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 360),
        weight: 50,
      ),
      // 50% - 75%: rotate 360 to 750 (fast spin of 390 degrees)
      TweenSequenceItem(
        tween: Tween<double>(begin: 360, end: 750),
        weight: 25,
      ),
      // 75% - 100%: rotate 750 to 1800 (slow final spin)
      TweenSequenceItem(
        tween: Tween<double>(begin: 750, end: 1800),
        weight: 25,
      ),
    ]).animate(
        CurvedAnimation(parent: _spinController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const height = 150.0;
    const width = 120.0;
    const spinnerSize = 95.0;
    const spinnerBottomOffset = 20.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _spinAnimation]),
      builder: (context, _) {
        return SizedBox(
          width: width,
          height: height + 60,
          child: Transform.rotate(
            angle: _degToRad(_shakeAnimation.value),
            transformHitTests: false,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Main white rectangular body with gradients
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildMainBody(width, height),
                ),

                // Bottom feet (::before pseudo-element)
                Positioned(
                  top: height - 2,
                  left: 5,
                  child: _buildLeftFoot(),
                ),

                Positioned(
                  top: height - 2,
                  right: 5,
                  child: _buildRightFoot(),
                ),

                // Large spinning circular part (::after pseudo-element) - centered in middle with bottom bias
                Positioned(
                  top: (height - spinnerSize) / 2 + 15,
                  child: Transform.rotate(
                    angle: _degToRad(_spinAnimation.value),
                    child: _buildSpinner(spinnerSize),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainBody(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(width * 0.06),
      ),
      child: CustomPaint(
        painter: _MainBodyPainter(width, height),
      ),
    );
  }

  Widget _buildLeftFoot() {
    return Container(
      width: 7,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFAAAAAA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
    );
  }

  Widget _buildRightFoot() {
    return Container(
      width: 7,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFAAAAAA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSpinner(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpinnerPainter(size),
      ),
    );
  }

  double _degToRad(double degrees) {
    return degrees * math.pi / 180;
  }
}

/// Paints the main body with all the gradient details.
class _MainBodyPainter extends CustomPainter {
  final double width;
  final double height;

  _MainBodyPainter(this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal line at 20px from top (linear-gradient #ddd 50%, #bbb 51%)
    _drawHorizontalLine(canvas);

    // Vertical line on left (linear-gradient)
    _drawLeftVerticalLine(canvas);

    // Diagonal line (linear-gradient at 8px 6px)
    _drawDiagonalLine(canvas);

    // Three circular details at top
    _drawCircularDetails(canvas);
  }

  void _drawHorizontalLine(Canvas canvas) {
    final y = height * (20 / 150);

    // Top half (#ddd)
    final paint1 = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = height * (2 / 150);

    // Bottom half (#bbb)
    final paint2 = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..strokeWidth = height * (2 / 150);

    canvas.drawLine(Offset(0, y), Offset(width, y), paint1);
    canvas.drawLine(
      Offset(0, y + height * (2 / 150)),
      Offset(width, y + height * (2 / 150)),
      paint2,
    );
  }

  void _drawLeftVerticalLine(Canvas canvas) {
    final x = width * (45 / 120);
    final paint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = width * (1 / 120);

    canvas.drawLine(Offset(x, 0), Offset(x, height * (23 / 150)), paint);
  }

  void _drawDiagonalLine(Canvas canvas) {
    final x = width * (8 / 120);
    final y = height * (6 / 150);
    final size = height * (8 / 150);

    final paint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = width * (1 / 120);

    canvas.drawLine(Offset(x, y), Offset(x + size, y + size), paint);
  }

  void _drawCircularDetails(Canvas canvas) {
    const positions = [
      (55.0, 3.0),
      (75.0, 3.0),
      (95.0, 3.0),
    ];

    for (final (xRatio, yRatio) in positions) {
      final x = width * (xRatio / 120);
      final y = height * (yRatio / 150);
      final radius = width * (15 / 240);

      _drawCircularGradient(canvas, x, y, radius);
    }
  }

  void _drawCircularGradient(Canvas canvas, double cx, double cy, double r) {
    // Inner circle (#aaa)
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.25,
      Paint()..color = const Color(0xFFAAAAAA),
    );

    // Middle ring (#eee)
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.5,
      Paint()
        ..color = const Color(0xFFEEEEEE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.25,
    );
  }

  @override
  bool shouldRepaint(_MainBodyPainter oldDelegate) {
    return oldDelegate.width != width || oldDelegate.height != height;
  }
}

/// Paints the large spinning circular part.
class _SpinnerPainter extends CustomPainter {
  final double size;

  _SpinnerPainter(this.size);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final centerX = size / 2;
    final centerY = size / 2;

    // Background color (#bbdefb)
    canvas.drawCircle(
      Offset(centerX, centerY),
      size / 2,
      Paint()..color = const Color(0xFFBBDEFB),
    );

    // Vertical stripes (linear-gradient to right, #0004 0%-49%, #0000 50%-100%)
    _drawVerticalStripes(canvas, centerX, centerY);

    // Diagonal gradient (#64b5f6 50%, #607d8b 51%)
    _drawDiagonalGradient(canvas, centerX, centerY);

    // Border (#DDD, 10px)
    canvas.drawCircle(
      Offset(centerX, centerY),
      size / 2,
      Paint()
        ..color = const Color(0xFFDDDDDD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (10 / 95) * size,
    );

    // Inset shadows
    _drawInsetShadow(canvas, centerX, centerY);
  }

  void _drawVerticalStripes(Canvas canvas, double cx, double cy) {
    final stripeWidth = (30 / 95) * size;
    final paint = Paint()..color = const Color(0x00000044);

    for (double x = 0; x < size; x += stripeWidth) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, stripeWidth / 2, size),
        paint,
      );
    }
  }

  void _drawDiagonalGradient(Canvas canvas, double cx, double cy) {
    final radius = size / 2;

    // Create a shader for diagonal gradient
    final startX = cx - radius;
    final startY = cy - radius;
    final endX = cx + radius;
    final endY = cy + radius;

    final colors = [
      const Color(0xFF64B5F6),
      const Color(0xFF607D8B),
    ];
    final stops = [0.5, 0.51];

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: stops,
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTRB(startX, startY, endX, endY));

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  void _drawInsetShadow(Canvas canvas, double cx, double cy) {
    // Inner shadow effect
    const shadowColor = Color(0x00000044);
    final paint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = (4 / 95) * size;

    canvas.drawCircle(
        Offset(cx, cy), (size / 2) - ((10 / 95) * size) / 2, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) {
    return oldDelegate.size != size;
  }
}
