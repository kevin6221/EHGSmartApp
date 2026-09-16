import 'package:flutter/material.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

/// Animated pulsing circle animation for the "Scan the tag" card.
/// Generates smooth, radiating concentric ripple waves inspired by Lottie pulsing circle
/// animations, while keeping the central tag scanner logo sticky (stationary and fixed).
class AnimatedTagScannerRings extends StatefulWidget {
  final double ringOuter;
  final double ringMid;
  final double ringInner;

  const AnimatedTagScannerRings({
    super.key,
    required this.ringOuter,
    required this.ringMid,
    required this.ringInner,
  });

  @override
  State<AnimatedTagScannerRings> createState() => _AnimatedTagScannerRingsState();
}

class _AnimatedTagScannerRingsState extends State<AnimatedTagScannerRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.scanPulse,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Outer boundary accommodating the radiating ripple expansion
    final maxBounds = widget.ringOuter * 1.25;

    return RepaintBoundary(
      child: SizedBox(
        width: maxBounds,
        height: maxBounds,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Static base outer circle (Figma #EFF9FD)
            Container(
              width: widget.ringOuter,
              height: widget.ringOuter,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.scanTagRingOuter,
              ),
            ),

            // 2. Static base middle circle (Figma #CEF0FA)
            Container(
              width: widget.ringMid,
              height: widget.ringMid,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.scanTagRingMid,
              ),
            ),

            // 3. Dynamic pulsing ripple waves expanding outward from the center
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(maxBounds, maxBounds),
                  painter: _PulsingCirclesPainter(
                    progress: _pulseController.value,
                    innerRadius: widget.ringInner / 2,
                    maxRadius: maxBounds / 2,
                    pulseColor: AppColors.scanTagRingInner,
                  ),
                );
              },
            ),

            // 4. Sticky central tag scanner badge (stationary, pinned at center)
            Container(
              width: widget.ringInner,
              height: widget.ringInner,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.scanTagRingInner,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.scanTagPulse.withValues(alpha: 0.30),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const AppSvgIcon(
                AppIcons.tagScanner,
                size: 26.0,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for radiating concentric pulsing circles with smooth ease-out curves.
class _PulsingCirclesPainter extends CustomPainter {
  final double progress;
  final double innerRadius;
  final double maxRadius;
  final Color pulseColor;

  _PulsingCirclesPainter({
    required this.progress,
    required this.innerRadius,
    required this.maxRadius,
    required this.pulseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const waveCount = 3;

    for (int i = 0; i < waveCount; i++) {
      final waveProgress = (progress + (i / waveCount)) % 1.0;
      // Natural ease-out deceleration curve matching Lottie animation
      final curved = Curves.easeOutCubic.transform(waveProgress);
      final radius = innerRadius + (maxRadius - innerRadius) * curved;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0);

      // Soft filled translucent ripple wave
      final fillPaint = Paint()
        ..color = pulseColor.withValues(alpha: 0.18 * opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);

      // Subtle crisp rim edge for defined beacon wave
      final strokePaint = Paint()
        ..color = pulseColor.withValues(alpha: 0.40 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsingCirclesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
