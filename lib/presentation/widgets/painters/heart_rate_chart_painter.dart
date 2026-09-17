import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Custom painter for the Heart Rate area chart with interactive scrubber indicator.
///
/// Features:
/// - Smooth cubic bezier curve with primary blue gradient area fill
/// - Interactive scrubber line and active bead dot with outer halo when activeIndex is non-null
/// - Matches the Stress card indicator style exactly for high visual fidelity
class HeartRateChartPainter extends CustomPainter {
  final List<double> values;
  final int? activeIndex;
  final Color lineColor;
  final double strokeWidth;
  final bool showFill;

  const HeartRateChartPainter({
    required this.values,
    this.activeIndex,
    this.lineColor = AppColors.primary,
    this.strokeWidth = 2.5,
    this.showFill = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final width = size.width;
    final height = size.height;

    // 1. Compute normalized points matching Figma proportions
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    const double topPadding = 6.0;
    const double bottomPadding = 6.0;
    final double usableHeight = height - topPadding - bottomPadding;

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = (i / (values.length - 1)) * width;
      final double normalized = (values[i] - minVal) / range;
      // Invert Y so high values are at top
      final double y = height - bottomPadding - (normalized * usableHeight);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // 2. Build smooth cubic path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // 3. Draw Area Gradient Fill
    if (showFill) {
      final fillPath = Path.from(path)
        ..lineTo(width, height)
        ..lineTo(0, height)
        ..close();

      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          [
            lineColor.withValues(alpha: 0.20),
            lineColor.withValues(alpha: 0.0),
          ],
        );
      canvas.drawPath(fillPath, fillPaint);
    }

    // 4. Draw Stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // 5. Draw Vertical Scrubber Line & Active Marker at activeIndex
    if (activeIndex != null) {
      final safeIndex = activeIndex!.clamp(0, points.length - 1);
      final activePt = points[safeIndex];

      // Vertical guide line from dot to bottom
      final verticalLinePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(activePt.dx, activePt.dy + 6.0),
        Offset(activePt.dx, height),
        verticalLinePaint,
      );

      // Outer glow / halo
      final haloPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePt, 8.0, haloPaint);

      // Solid inner bead
      final beadPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePt, 5.0, beadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartRateChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showFill != showFill;
  }
}
