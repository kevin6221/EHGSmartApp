import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Standalone custom painter for rendering smooth cubic bezier sparkline trends.
///
/// Gracefully handles sparse data: days with 0.0 are treated as "no data" and skipped.
/// If only one day has data, renders a single dot. If no data, renders nothing.
class SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final bool showFill;
  final double strokeWidth;
  final int? activeDayIndex;

  const SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.showFill,
    required this.strokeWidth,
    this.activeDayIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    // Collect non-zero valid indices
    final List<int> validIndices = [];
    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0) validIndices.add(i);
    }
    if (validIndices.isEmpty) return;

    final List<double> validValues = validIndices.map((i) => values[i]).toList();
    final double maxVal = validValues.reduce((a, b) => a > b ? a : b);

    final int totalSlots = values.length >= 7 ? 7 : values.length;
    final List<Offset> points = [];

    for (int i = 0; i < totalSlots; i++) {
      final double x = totalSlots > 1 ? (i / (totalSlots - 1)) * width : width * 0.5;
      final double v = values[i] > 0 ? values[i] : 0.0;
      final double normalized = maxVal > 0 ? (v / maxVal).clamp(0.0, 1.0) : 0.0;
      final double y = (height - 6.0) - (normalized * (height - 12.0));
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Draw smooth cubic bezier path through 7-day points
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    if (showFill) {
      final Path fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, height);
      fillPath.lineTo(points.first.dx, height);
      fillPath.close();

      final Paint fillPaint = Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 0), Offset(0, height), [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ]);
      canvas.drawPath(fillPath, fillPaint);
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw active indicator dot on the active day / today
    final int todayIdx = (DateTime.now().weekday - 1).clamp(0, points.length - 1);
    final int targetIdx = (activeDayIndex ?? todayIdx).clamp(0, points.length - 1);
    final activePt = points[targetIdx];

    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(activePt, 8.0, glowPaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(activePt, 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.showFill != showFill ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.activeDayIndex != activeDayIndex;
  }
}
