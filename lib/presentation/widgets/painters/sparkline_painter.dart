import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Standalone custom painter for rendering smooth cubic bezier sparkline trends.
class SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final bool showFill;
  final double strokeWidth;

  const SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.showFill,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final double width = size.width;
    final double height = size.height;
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = (i / (values.length - 1)) * width;
      final double normalized = (values[i] - minVal) / range;
      // Invert Y so high values are at top
      final double y = height - (normalized * (height - 6)) - 3;
      points.add(Offset(x, y));
    }

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
      fillPath.lineTo(width, height);
      fillPath.lineTo(0, height);
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
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.showFill != showFill ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
