import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/vitals_model.dart';

/// Standalone custom painter for sleep phase intervals (Deep, Light, REM, Awake).
class HypnogramPainter extends CustomPainter {
  final List<SleepInterval> intervals;

  const HypnogramPainter({required this.intervals});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Background horizontal faint reference lines
    final Paint linePaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = (height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), linePaint);
    }

    // Interval bars
    for (final it in intervals) {
      final double x = it.startOffset * width;
      final double barWidth = it.widthFraction * width;

      Color color;
      double topY;
      double barHeight;

      switch (it.phase) {
        case SleepPhase.deep:
          color = const Color(0xFF1E60C8);
          topY = 0;
          barHeight = height;
          break;
        case SleepPhase.rem:
          color = const Color(0xFF4ADE80);
          topY = height * 0.33;
          barHeight = height * 0.67;
          break;
        case SleepPhase.light:
          color = const Color(0xFF38BDF8);
          topY = height * 0.66;
          barHeight = height * 0.34;
          break;
        case SleepPhase.awake:
          color = const Color(0xFFF43F5E);
          topY = 0;
          barHeight = height;
          break;
      }

      final Paint barPaint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(x, topY, barWidth.clamp(3.0, width), barHeight),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HypnogramPainter oldDelegate) {
    return oldDelegate.intervals != intervals;
  }
}
