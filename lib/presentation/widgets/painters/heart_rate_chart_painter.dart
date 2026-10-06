import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Professional wearable-grade custom painter for the Heart Rate rhythm chart.
///
/// Follows industry standards (Whoop, Garmin Connect, Qwatch Pro):
/// - Physiological Y-axis scaling (never plunges to 0 bpm or flatlines).
/// - Curve and gradient area fill span only recorded days.
/// - Unrecorded / future days are rendered with subtle slot indicators without artificial drops.
/// - Interactive scrubber indicator aligns with active day datum with glowing bead.
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

    final int totalSlots = values.length >= 7 ? 7 : values.length;
    if (totalSlots <= 0) return;

    // 1. Gather all days with recorded positive bpm
    final List<int> recordedIndices = [];
    for (int i = 0; i < totalSlots; i++) {
      if (values[i] > 0) {
        recordedIndices.add(i);
      }
    }

    const double topPadding = 10.0;
    const double bottomPadding = 10.0;
    final double usableHeight = height - topPadding - bottomPadding;

    // Draw faint horizontal baseline guide across the canvas
    final baselinePaint = Paint()
      ..color = AppColors.borderLight.withValues(alpha: 0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, height - bottomPadding),
      Offset(width, height - bottomPadding),
      baselinePaint,
    );

    // If completely empty of readings, draw placeholder indicators and return
    if (recordedIndices.isEmpty) {
      for (int i = 0; i < totalSlots; i++) {
        final double x = totalSlots > 1 ? (i / (totalSlots - 1)) * width : width * 0.5;
        canvas.drawCircle(
          Offset(x, height - bottomPadding),
          2.0,
          Paint()..color = AppColors.borderLight,
        );
      }
      return;
    }

    // 2. Compute physiological heart rate scaling (Whoop / Garmin standard)
    final recordedValues = recordedIndices.map((i) => values[i]).toList();
    final double minRecorded = recordedValues.reduce((a, b) => a < b ? a : b);
    final double maxRecorded = recordedValues.reduce((a, b) => a > b ? a : b);

    double plotMin = (minRecorded - 12.0).clamp(38.0, 180.0);
    double plotMax = (maxRecorded + 14.0).clamp(65.0, 220.0);
    if ((plotMax - plotMin) < 24.0) {
      final mid = (plotMin + plotMax) / 2;
      plotMin = (mid - 14.0).clamp(38.0, 180.0);
      plotMax = (mid + 14.0).clamp(65.0, 220.0);
    }
    final double range = plotMax - plotMin;

    // 3. Calculate canvas coordinates for recorded days
    final Map<int, Offset> pointsMap = {};
    for (final i in recordedIndices) {
      final double x = totalSlots > 1 ? (i / (totalSlots - 1)) * width : width * 0.5;
      final double normalized = ((values[i] - plotMin) / range).clamp(0.0, 1.0);
      final double y = height - bottomPadding - (normalized * usableHeight);
      pointsMap[i] = Offset(x, y);
    }

    // 4. Render subtle slot markers for unrecorded / future days
    final unrecordedPaint = Paint()
      ..color = AppColors.borderLight.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < totalSlots; i++) {
      if (!pointsMap.containsKey(i)) {
        final double x = totalSlots > 1 ? (i / (totalSlots - 1)) * width : width * 0.5;
        canvas.drawCircle(Offset(x, height - bottomPadding), 2.2, unrecordedPaint);
      }
    }

    // 5. Partition recorded days into contiguous series for spline rendering
    final List<List<Offset>> segments = [];
    List<Offset> currentSegment = [];
    int? prevIndex;

    for (final i in recordedIndices) {
      if (prevIndex == null || i == prevIndex + 1) {
        currentSegment.add(pointsMap[i]!);
      } else {
        if (currentSegment.isNotEmpty) {
          segments.add(List.from(currentSegment));
          currentSegment.clear();
        }
        currentSegment.add(pointsMap[i]!);
      }
      prevIndex = i;
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    // 6. Draw smooth spline and area fill for each contiguous segment
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final seg in segments) {
      if (seg.length == 1) {
        // Single isolated day: render prominent dot and subtle horizontal beacon
        final p = seg.first;
        final beaconPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.25)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset((p.dx - 14.0).clamp(0.0, width), p.dy),
          Offset((p.dx + 14.0).clamp(0.0, width), p.dy),
          beaconPaint,
        );
        canvas.drawCircle(p, 4.0, Paint()..color = lineColor);
      } else {
        // Smooth cubic bezier spline through recorded days
        final path = Path();
        path.moveTo(seg.first.dx, seg.first.dy);

        for (int k = 0; k < seg.length - 1; k++) {
          final p0 = seg[k];
          final p1 = seg[k + 1];
          final cx = (p0.dx + p1.dx) / 2;
          path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
        }

        // Draw area gradient fill under recorded range
        if (showFill) {
          final fillPath = Path.from(path)
            ..lineTo(seg.last.dx, height - bottomPadding)
            ..lineTo(seg.first.dx, height - bottomPadding)
            ..close();

          final fillPaint = Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, topPadding),
              Offset(0, height - bottomPadding),
              [
                lineColor.withValues(alpha: 0.24),
                lineColor.withValues(alpha: 0.01),
              ],
            );
          canvas.drawPath(fillPath, fillPaint);
        }

        // Draw continuous line stroke
        canvas.drawPath(path, strokePaint);

        // Draw discrete datum node points
        for (final pt in seg) {
          canvas.drawCircle(
            pt,
            2.8,
            Paint()..color = lineColor.withValues(alpha: 0.65),
          );
        }
      }
    }

    // 7. Draw interactive scrubber line & glowing bead at activeIndex
    final todayIdx = (DateTime.now().weekday - 1).clamp(0, totalSlots - 1);
    final targetActiveIdx = (activeIndex ?? todayIdx).clamp(0, totalSlots - 1);
    final double activeX = totalSlots > 1 ? (targetActiveIdx / (totalSlots - 1)) * width : width * 0.5;

    if (pointsMap.containsKey(targetActiveIdx)) {
      final activePt = pointsMap[targetActiveIdx]!;

      // Vertical guide line from top to bottom
      final verticalLinePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(activePt.dx, topPadding),
        Offset(activePt.dx, height - bottomPadding),
        verticalLinePaint,
      );

      // Outer soft glowing halo
      final haloPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePt, 8.5, haloPaint);

      // White perimeter ring
      final whiteRingPaint = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(activePt, 5.0, whiteRingPaint);

      // Solid primary core bead
      final beadPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePt, 4.0, beadPaint);
    } else {
      // Scrubber hovered on an unrecorded day: render faint vertical marker & muted indicator
      final ghostLinePaint = Paint()
        ..color = AppColors.borderLight.withValues(alpha: 0.45)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(activeX, topPadding),
        Offset(activeX, height - bottomPadding),
        ghostLinePaint,
      );
      canvas.drawCircle(
        Offset(activeX, height - bottomPadding),
        4.0,
        Paint()
          ..color = AppColors.borderLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
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
