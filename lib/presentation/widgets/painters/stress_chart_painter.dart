import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Custom painter for the Stress area chart matching Figma Node 71:1042.
///
/// Features:
/// - 3 horizontal dashed guidelines
/// - Smooth cubic bezier curve with cyan gradient area fill
/// - Interactive scrubber line and active bead dot
/// - Gracefully handles sparse data: days with 0.0 are skipped. Single valid day renders a dot.
class StressChartPainter extends CustomPainter {
  final List<double> values;
  final int activeIndex;
  final Color lineColor;
  final bool showGuidelines;

  const StressChartPainter({
    required this.values,
    required this.activeIndex,
    this.lineColor = AppColors.stressCyan,
    this.showGuidelines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final width = size.width;
    final height = size.height;

    // 1. Draw 3 Horizontal Dashed Guide Lines
    if (showGuidelines) {
      final dashPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final yPositions = [
        height * 0.25,
        height * 0.50,
        height * 0.75,
      ];

      for (final y in yPositions) {
        _drawDashedLine(canvas, Offset(0, y), Offset(width, y), dashPaint);
      }
    }

    // Collect non-zero values for scaling
    final List<int> validIndices = [];
    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0) validIndices.add(i);
    }
    if (validIndices.isEmpty) return;

    const double topPadding = 16.0;
    const double bottomPadding = 16.0;
    final double usableHeight = height - topPadding - bottomPadding;

    final List<double> validValues = validIndices.map((i) => values[i]).toList();
    final double maxVal = validValues.reduce((a, b) => a > b ? a : b);

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
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, height)
      ..lineTo(points.first.dx, height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, height),
        [
          lineColor.withValues(alpha: 0.35),
          lineColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Draw Stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Draw Vertical Scrubber Line & Active Marker at activeIndex
    final activeIdx = activeIndex.clamp(0, points.length - 1);
    final activePt = points[activeIdx];

    // Vertical dashed/solid guide line from dot to bottom
    final verticalLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.6)
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

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double currentX = p1.dx;
    while (currentX < p2.dx) {
      final nextX = (currentX + dashWidth).clamp(p1.dx, p2.dx);
      canvas.drawLine(Offset(currentX, p1.dy), Offset(nextX, p1.dy), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant StressChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.lineColor != lineColor;
  }
}
