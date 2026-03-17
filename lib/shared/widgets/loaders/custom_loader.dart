import 'dart:math' as math;

import 'package:flutter/material.dart';

class DiamondPreloader extends StatefulWidget {
  final double size;
  final Color outerColor;
  final Color middleLayerColor;
  final Color movingLayerColor;
  final double? movingBorderWidth;
  final Duration duration;

  const DiamondPreloader({
    super.key,
    this.size = 64,
    this.outerColor = const Color(0x80000000),
    this.middleLayerColor = const Color(0xFF222B32),
    this.movingLayerColor = const Color(0xFFDE3500),
    this.movingBorderWidth,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<DiamondPreloader> createState() => _DiamondPreloaderState();
}

class _DiamondPreloaderState extends State<DiamondPreloader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _translation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _translation = _buildTranslationAnimation();
  }

  @override
  void didUpdateWidget(covariant DiamondPreloader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration ||
        oldWidget.size != widget.size) {
      _controller.duration = widget.duration;
      _translation = _buildTranslationAnimation();
      _controller
        ..reset()
        ..repeat();
    }
  }

  Animation<Offset> _buildTranslationAnimation() {
    final start = Offset(-widget.size, -widget.size);

    return TweenSequence<Offset>([
      TweenSequenceItem<Offset>(
        tween: ConstantTween<Offset>(start),
        weight: 10,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(begin: start, end: Offset.zero),
        weight: 80,
      ),
      TweenSequenceItem<Offset>(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 10,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final afterInset = widget.size * (8 / 64);
    final beforeInset = widget.size * (15 / 64);
    final borderWidth = widget.movingBorderWidth ?? (widget.size * (2 / 64));

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: ClipRect(
          child: DecoratedBox(
            decoration: BoxDecoration(color: widget.outerColor),
            child: Stack(
              children: [
                Positioned(
                  top: afterInset,
                  right: afterInset,
                  bottom: afterInset,
                  left: afterInset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: widget.middleLayerColor),
                  ),
                ),
                Positioned(
                  top: -beforeInset,
                  right: -beforeInset,
                  bottom: -beforeInset,
                  left: -beforeInset,
                  child: AnimatedBuilder(
                    animation: _translation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: _translation.value,
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: child,
                        ),
                      );
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: widget.movingLayerColor,
                          width: borderWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomLoader extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Duration duration;

  const CustomLoader({
    super.key,
    this.size = 64,
    this.primaryColor = const Color(0xFF222B32),
    this.secondaryColor = const Color(0xFFDE3500),
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  Widget build(BuildContext context) {
    return DiamondPreloader(
      size: size,
      middleLayerColor: primaryColor,
      movingLayerColor: secondaryColor,
      duration: duration,
    );
  }
}

class FullscreenLoaderOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color backgroundColor;
  final Widget? loader;

  const FullscreenLoaderOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.backgroundColor = const Color(0xFFF7F5F5),
    this.loader,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: backgroundColor,
              child: Center(child: loader ?? const DiamondPreloader()),
            ),
          ),
      ],
    );
  }
}

class DiamondPreloaderScreen extends StatelessWidget {
  const DiamondPreloaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F5F5),
      body: Center(
        child: DiamondPreloader(),
      ),
    );
  }
}
