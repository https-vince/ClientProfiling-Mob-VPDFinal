import 'package:flutter/material.dart';
import 'css_style_preloader.dart';

/// Demo screen showing the CSS-style preloader centered on a light gray background.
class CssPreloaderScreen extends StatelessWidget {
  const CssPreloaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        title: const Text('CSS Style Preloader'),
        centerTitle: true,
      ),
      body: const Center(
        child: CssStylePreloader(),
      ),
    );
  }
}
