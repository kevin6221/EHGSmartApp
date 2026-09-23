import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../helpers/wellness_card_calculator.dart';

/// A lightweight, 60fps native Flutter CustomPainter doughnut chart matching
/// Figma node 60:289 without third-party chart dependencies.
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
    // Clockwise order starting at 12 o'clock matching Figma 60:289 & screenshot:
    // Fuel (Purple) -> Mind (Cyan) -> Recover (Blue) -> Move (Indigo)
    final segments = [
      PillarChartSegment(
        label: 'Fuel',
        value: fuelScore > 0 ? fuelScore.toDouble() : 1.0,
        color: AppColors.fuelPillar,
      ),
      PillarChartSegment(
        label: 'Mind',
        value: mindScore > 0 ? mindScore.toDouble() : 1.0,
        color: AppColors.mindPillar,
      ),
      PillarChartSegment(
        label: 'Recover',
        value: recoverScore > 0 ? recoverScore.toDouble() : 1.0,
        color: AppColors.recoverPillar,
      ),
      PillarChartSegment(
        label: 'Move',
        value: moveScore > 0 ? moveScore.toDouble() : 1.0,
        color: AppColors.movePillar,
      ),
    ];

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${recoverScore}_${fuelScore}_${mindScore}_$moveScore'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
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
    final strokeWidth = size.width * 0.135; // 13.5% thickness matching Figma
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track ring
    final bgPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Calculate total value across segments
    double totalValue = 0;
    for (final seg in segments) {
      totalValue += seg.value;
    }
    if (totalValue <= 0) return;

    double currentAngle = -math.pi / 2;
    const gapWidth = 15.0;

    final totalSweep = 2 * math.pi * progress;
    final gapAngle = gapWidth / radius;

    for (final seg in segments) {
      final sweepFraction = seg.value / totalValue;
      final fullSweepAngle = sweepFraction * totalSweep;
      final arcSweep = fullSweepAngle - (progress * gapAngle);

      if (arcSweep > 0.02) {
        final paint = Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle + (gapAngle / 2),
          arcSweep,
          false,
          paint,
        );
      }

      currentAngle += fullSweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DoughnutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.segments != segments;
  }
}


// class _DoughnutChartPainter extends CustomPainter {
//   final List<PillarChartSegment> segments;
//   final double progress;
//
//   _DoughnutChartPainter({
//     required this.segments,
//     required this.progress,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (size.width <= 0 || size.height <= 0) return;
//
//     final center = Offset(
//       size.width / 2,
//       size.height / 2,
//     );
//
//     // Ring thickness.
//     final strokeWidth = size.width * 0.135;
//
//     // Keep the complete ring inside the canvas.
//     final radius = (size.width - strokeWidth) / 2;
//
//     // ------------------------------------------------------------
//     // Background ring
//     // ------------------------------------------------------------
//
//     final backgroundPaint = Paint()
//       ..color = AppColors.secondary.withValues(alpha: 0.05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;
//
//     canvas.drawCircle(
//       center,
//       radius,
//       backgroundPaint,
//     );
//
//     // ------------------------------------------------------------
//     // Calculate total score
//     // ------------------------------------------------------------
//
//     final totalValue = segments.fold<double>(
//       0,
//           (sum, segment) => sum + segment.value,
//     );
//
//     if (totalValue <= 0) return;
//
//     // ------------------------------------------------------------
//     // Chart configuration
//     // ------------------------------------------------------------
//
//     // Desired physical spacing between segments.
//     const gapWidth = 25.0;
//
//     // Convert pixel gap to radians.
//     final gapAngle = gapWidth / radius;
//
//     // Start at 12 o'clock.
//     const startAngle = -math.pi / 2;
//
//     // Complete chart sweep.
//     final totalChartAngle = math.pi * 2;
//
//     // During animation, scale the actual segment lengths.
//     final animatedSweep = totalChartAngle * progress;
//
//     double currentAngle = startAngle;
//
//     // ------------------------------------------------------------
//     // Draw segments
//     // ------------------------------------------------------------
//
//     for (final segment in segments) {
//       final valueFraction = segment.value / totalValue;
//
//       final segmentSweep =
//           animatedSweep * valueFraction;
//
//       // Don't draw the gap outside the segment.
//       final actualGap = math.min(
//         gapAngle * progress,
//         segmentSweep * 0.5,
//       );
//
//       final drawSweep = segmentSweep - actualGap;
//
//       if (drawSweep > 0.01) {
//         final paint = Paint()
//           ..color = segment.color
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = strokeWidth
//           ..strokeCap = StrokeCap.round
//           ..isAntiAlias = true;
//
//         canvas.drawArc(
//           Rect.fromCircle(
//             center: center,
//             radius: radius,
//           ),
//           currentAngle + (actualGap / 2),
//           drawSweep,
//           false,
//           paint,
//         );
//       }
//
//       currentAngle += segmentSweep;
//     }
//   }
//
//   @override
//   bool shouldRepaint(
//       covariant _DoughnutChartPainter oldDelegate,
//       ) {
//     return oldDelegate.progress != progress ||
//         oldDelegate.segments != segments;
//   }
// }