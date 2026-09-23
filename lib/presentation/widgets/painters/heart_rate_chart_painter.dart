import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Custom painter for the Heart Rate area chart with interactive scrubber indicator.
///
/// Features:
/// - Smooth cubic bezier curve with primary blue gradient area fill
/// - Interactive scrubber line and active bead dot with outer halo when activeIndex is non-null
/// - Gracefully handles sparse data: days with 0.0 are treated as "no data" and skipped
/// - If only one day has data, renders a single prominent dot at that day's position
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
    if (values.isEmpty) return;

    final width = size.width;
    final height = size.height;

    // Collect non-zero values for scaling
    final List<int> validIndices = [];
    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0) validIndices.add(i);
    }
    if (validIndices.isEmpty) return;

    const double topPadding = 6.0;
    const double bottomPadding = 6.0;
    final double usableHeight = height - topPadding - bottomPadding;

    final List<double> validValues = validIndices.map((i) => values[i]).toList();
    final double maxVal = validValues.reduce((a, b) => a > b ? a : b);
    final int firstValid = validIndices.first;

    final int totalSlots = values.length >= 7 ? 7 : values.length;
    final List<Offset> points = [];

    for (int i = 0; i < totalSlots; i++) {
      final double x = totalSlots > 1 ? (i / (totalSlots - 1)) * width : width * 0.5;
      final double v = values[i] > 0 ? values[i] : 0.0;
      final double normalized = maxVal > 0 ? (v / maxVal).clamp(0.0, 1.0) : 0.0;
      final double y = height - bottomPadding - (normalized * usableHeight);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Build smooth cubic path through 7-day points
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Draw Area Gradient Fill
    if (showFill) {
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, height)
        ..lineTo(points.first.dx, height)
        ..close();

      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, height),
          [
            lineColor.withValues(alpha: 0.22),
            lineColor.withValues(alpha: 0.0),
          ],
        );
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw Stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Draw Vertical Scrubber Line & Active Marker at activeIndex
    final activeIdx = (activeIndex ?? firstValid).clamp(0, points.length - 1);
    final activePt = points[activeIdx];

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

  @override
  bool shouldRepaint(covariant HeartRateChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showFill != showFill;
  }
}
