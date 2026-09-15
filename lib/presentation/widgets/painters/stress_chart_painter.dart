import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../helpers/vitals_card_calculator.dart';

/// Custom painter for the Stress area chart matching Figma Node 71:1042.
///
/// Features:
/// - 3 horizontal dashed guidelines
/// - Smooth cubic bezier curve with cyan gradient area fill
/// - Interactive scrubber line and active bead dot
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
    if (values.length < 2) return;

    final width = size.width;
    final height = size.height;

    // 1. Draw 3 Horizontal Dashed Guide Lines
    if (showGuidelines) {
      final dashPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final yPositions = [
        height * 0.15,
        height * 0.52,
        height * 0.88,
      ];

      for (final y in yPositions) {
        _drawDashedLine(canvas, Offset(0, y), Offset(width, y), dashPaint);
      }
    }

    // 2. Compute normalized points
    final points = VitalsCardCalculator.computeNormalizedPoints(
      values: values,
      size: size,
      topPadding: 16.0,
      bottomPadding: 16.0,
    );

    if (points.length < 2) return;

    // 3. Build smooth cubic path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // 4. Draw Area Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo(width, height)
      ..lineTo(0, height)
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

    // 5. Draw Stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // 6. Draw Vertical Scrubber Line & Active Marker at activeIndex
    final safeIndex = activeIndex.clamp(0, points.length - 1);
    final activePt = points[safeIndex];

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
    return oldDelegate.values != values ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.lineColor != lineColor;
  }
}
