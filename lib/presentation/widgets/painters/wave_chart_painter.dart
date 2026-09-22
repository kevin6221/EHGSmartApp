import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/wellness_data_model.dart';

/// Standalone custom painter for rendering smooth cubic bezier wave charts,
/// gradient fills, grid lines, and interactive pins with dynamic tooltips.
class WaveChartPainter extends CustomPainter {
  final List<DayChartPoint> points;
  final double progress;
  final int? activePointIndex;

  const WaveChartPainter({
    required this.points,
    required this.progress,
    this.activePointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    const double bottomPadding = 24.0;
    const double topPadding = 30.0;
    final double chartHeight = height - bottomPadding - topPadding;

    // 1. Draw dashed vertical time gridlines and labels
    final List<String> timeLabels = [
      '8 AM',
      '10 AM',
      '12 PM',
      '2 PM',
      '4 PM',
      '6 PM',
    ];
    final double stepX = width / (timeLabels.length - 1);

    final Paint gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < timeLabels.length; i++) {
      final double x = i * stepX;
      _drawDashedVerticalLine(
        canvas,
        x,
        topPadding,
        height - bottomPadding,
        gridPaint,
      );

      // Label
      final textSpan = TextSpan(
        text: timeLabels[i],
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelX = (x - (textPainter.width / 2)).clamp(0.0, width - textPainter.width);
      textPainter.paint(canvas, Offset(labelX, 4));
    }

    if (points.isEmpty) return;

    // 2. Determine Pin Index
    int effectivePinIndex = -1;
    if (activePointIndex != null &&
        activePointIndex! >= 0 &&
        activePointIndex! < points.length) {
      effectivePinIndex = activePointIndex!;
    } else {
      effectivePinIndex = points.indexWhere((p) => p.hasPin);
      if (effectivePinIndex == -1) effectivePinIndex = (points.length * 0.75).round();
    }

    // Normalizing scores between 45 and 85
    const double minScore = 45.0;
    const double maxScore = 85.0;

    final List<Offset> solidOffsets = [];
    final List<Offset> dashedOffsets = [];
    Offset? pinOffset;
    DayChartPoint? activePoint;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final double x = (i / (points.length - 1)) * width;
      final double normalized =
          ((p.score - minScore) / (maxScore - minScore)).clamp(0.0, 1.0);
      final double y =
          (height - bottomPadding) - (normalized * chartHeight * progress);

      final offset = Offset(x, y);
      if (p.isProjected) {
        dashedOffsets.add(offset);
      } else {
        solidOffsets.add(offset);
      }

      if (i == effectivePinIndex) {
        pinOffset = offset;
        activePoint = p;
      }
    }

    if (solidOffsets.isEmpty) return;

    // 3. Build Smooth Solid Path
    final Path linePath = Path();
    linePath.moveTo(solidOffsets[0].dx, solidOffsets[0].dy);

    for (int i = 0; i < solidOffsets.length - 1; i++) {
      final p0 = solidOffsets[i];
      final p1 = solidOffsets[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;

      linePath.cubicTo(
        controlX1,
        controlY1,
        controlX2,
        controlY2,
        p1.dx,
        p1.dy,
      );
    }

    // 4. Fill Gradient Under the Solid Curve
    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(solidOffsets.last.dx, height - bottomPadding);
    fillPath.lineTo(solidOffsets.first.dx, height - bottomPadding);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, topPadding),
        Offset(0, height - bottomPadding),
        [
          AppColors.primary.withValues(alpha: 0.35 * progress),
          AppColors.primary.withValues(alpha: 0.02 * progress),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw Solid Curve
    final Paint linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // 6. Draw Projected Dashed Segment
    if (dashedOffsets.isNotEmpty) {
      // Build smooth bezier path through projected points
      final List<Offset> projPoints = [solidOffsets.last, ...dashedOffsets];
      final Path projPath = Path();
      projPath.moveTo(projPoints[0].dx, projPoints[0].dy);

      for (int i = 0; i < projPoints.length - 1; i++) {
        final p0 = projPoints[i];
        final p1 = projPoints[i + 1];
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;
        projPath.cubicTo(
            controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      }

      final Paint projPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Draw dashed path using PathMetrics
      const double dashWidth = 6.0;
      const double dashSpace = 4.0;
      for (final metric in projPath.computeMetrics()) {
        double distance = 0.0;
        while (distance < metric.length) {
          final double end = (distance + dashWidth).clamp(0.0, metric.length);
          final extractedPath = metric.extractPath(distance, end);
          canvas.drawPath(extractedPath, projPaint);
          distance += dashWidth + dashSpace;
        }
      }
    }

    // 7. Draw Pin Indicator & Tooltip at Selected Time
    if (pinOffset != null && activePoint != null) {
      // Vertical indicator guide
      final Paint pinGuidePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(pinOffset.dx, topPadding),
        Offset(pinOffset.dx, height - bottomPadding),
        pinGuidePaint,
      );

      // Pin circle
      final Paint circleOuter = Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill;
      final Paint circleInner = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(pinOffset.dx, topPadding + 4), 6, circleOuter);
      canvas.drawCircle(Offset(pinOffset.dx, topPadding + 4), 4, circleInner);

      // Score Tooltip Pill: "${score} Score"
      final currentScore = activePoint.score.round();
      final double pillWidth = 76.0;
      final double pillX = (pinOffset.dx).clamp(pillWidth / 2 + 4, width - pillWidth / 2 - 4);

      final RRect tooltipRRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(pillX, topPadding + 26),
          width: pillWidth,
          height: 26,
        ),
        const Radius.circular(8),
      );

      final Paint shadowPaint = Paint()
        ..color = AppColors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(tooltipRRect.shift(const Offset(0, 2)), shadowPaint);

      final Paint tooltipBg = Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill;
      final Paint tooltipBorder = Paint()
        ..color = AppColors.borderLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(tooltipRRect, tooltipBg);
      canvas.drawRRect(tooltipRRect, tooltipBorder);

      final textSpan = TextSpan(
        children: [
          TextSpan(
            text: '$currentScore ',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'Score',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pillX - (textPainter.width / 2), topPadding + 20),
      );
    }
  }

  void _drawDashedVerticalLine(
    Canvas canvas,
    double x,
    double startY,
    double endY,
    Paint paint,
  ) {
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;
    double currentY = startY;
    while (currentY < endY) {
      canvas.drawLine(
        Offset(x, currentY),
        Offset(x, (currentY + dashHeight).clamp(startY, endY)),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant WaveChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.points != points ||
        oldDelegate.activePointIndex != activePointIndex;
  }
}
