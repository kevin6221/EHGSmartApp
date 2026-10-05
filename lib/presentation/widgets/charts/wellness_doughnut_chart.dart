import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../helpers/wellness_card_calculator.dart';

/// A precision 60fps native Flutter CustomPainter doughnut chart matching
/// Figma node 60:289 (Home >> Expanded) with mathematically exact rounded caps,
/// uniform gap spacing, and smooth entry animation.
class WellnessDoughnutChart extends StatelessWidget {
  final int recoverScore;
  final int fuelScore;
  final int mindScore;
  final int moveScore;
  final double size;

  const WellnessDoughnutChart({
    super.key,
    required this.recoverScore,
    required this.fuelScore,
    required this.mindScore,
    required this.moveScore,
    this.size = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    // Clockwise order starting at 12 o'clock matching Figma 60:289 & screenshots:
    // Move (Indigo) -> Recover (Blue) -> Mind (Cyan) -> Fuel (Purple)
    final segments = [
      PillarChartSegment(
        label: 'Move',
        value: moveScore > 0 ? moveScore.toDouble() : 1.0,
        color: AppColors.movePillar,
      ),
      PillarChartSegment(
        label: 'Recover',
        value: recoverScore > 0 ? recoverScore.toDouble() : 1.0,
        color: AppColors.recoverPillar,
      ),
      PillarChartSegment(
        label: 'Mind',
        value: mindScore > 0 ? mindScore.toDouble() : 1.0,
        color: AppColors.mindPillar,
      ),
      PillarChartSegment(
        label: 'Fuel',
        value: fuelScore > 0 ? fuelScore.toDouble() : 1.0,
        color: AppColors.fuelPillar,
      ),
    ];

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${recoverScore}_${fuelScore}_${mindScore}_$moveScore'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) {
          return CustomPaint(
            size: Size(size, size),
            painter: _DoughnutChartPainter(
              segments: segments,
              progress: progress,
            ),
          );
        },
      ),
    );
  }
}

class _DoughnutChartPainter extends CustomPainter {
  final List<PillarChartSegment> segments;
  final double progress;

  _DoughnutChartPainter({
    required this.segments,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Stroke width around 9.5-10% of chart size (12-14 dp) matching Figma 60:289
    final strokeWidth = (size.width * 0.095).clamp(11.0, 14.0);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track ring
    final bgPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final double totalValue = segments.fold(0.0, (sum, s) => sum + s.value);
    if (totalValue <= 0) return;

    // StrokeCap.round adds half of the stroke width beyond the start and end angles.
    // In radians on a circle of radius R, that extension is capAngle = (strokeWidth / 2) / radius.
    final double capAngle = (strokeWidth / 2) / radius;

    // Desired visual physical gap in pixels between adjacent rounded caps
    const double desiredGapPixels = 8.0;
    final double gapAngle = desiredGapPixels / radius;

    // Start clockwise at 12 o'clock (-pi / 2)
    double currentAngle = -math.pi / 2;

    for (final seg in segments) {
      final double fraction = seg.value / totalValue;
      final double allocatedAngle = fraction * 2 * math.pi * progress;

      // The actual drawn arc sweep must subtract the gap and both rounded ends
      // to ensure caps NEVER overlap and leave exactly gapAngle of visual space.
      final double sweepArc = allocatedAngle - gapAngle - (2 * capAngle);

      if (sweepArc > 0.005) {
        final paint = Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        final double startArc = currentAngle + (gapAngle / 2) + capAngle;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startArc,
          sweepArc,
          false,
          paint,
        );
      } else if (allocatedAngle > 0.04) {
        // If the segment is too small for a stroked arc with round caps,
        // draw a solid circular dot at the segment center angle
        final double midAngle = currentAngle + (allocatedAngle / 2);
        final dotCenter = Offset(
          center.dx + radius * math.cos(midAngle),
          center.dy + radius * math.sin(midAngle),
        );
        final dotPaint = Paint()
          ..color = seg.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotCenter, strokeWidth / 2, dotPaint);
      }

      currentAngle += allocatedAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DoughnutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.segments != segments;
  }
}