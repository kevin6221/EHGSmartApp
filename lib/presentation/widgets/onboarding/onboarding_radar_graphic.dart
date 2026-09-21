import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

/// Animated radar graphic for Onboarding Screen 2 (Figma Node 14:2600).
/// Isolated repaint boundary with centralized rotation duration and active scanning wave ripples.
class OnboardingRadarGraphic extends StatefulWidget {
  final double dimension;
  final bool isScanning;

  const OnboardingRadarGraphic({
    super.key,
    this.dimension = 272.0,
    this.isScanning = false,
  });

  @override
  State<OnboardingRadarGraphic> createState() => _OnboardingRadarGraphicState();
}

class _OnboardingRadarGraphicState extends State<OnboardingRadarGraphic>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _waveController;
  late final Animation<double> _clockwiseTurns;
  late final Animation<double> _oppositeTurns;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: AppDurations.radarRotation,
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isScanning) {
      _waveController.repeat();
    }

    _clockwiseTurns = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _oppositeTurns = Tween<double>(
      begin: 0.0,
      end: -1.0,
    ).animate(_rotationController);
  }

  @override
  void didUpdateWidget(covariant OnboardingRadarGraphic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _waveController.repeat();
      } else {
        _waveController.stop();
        _waveController.reset();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = widget.dimension;
    final logoDim = dim * 0.11; // ~35px for 272px radar

    return RepaintBoundary(
      child: SizedBox(
        width: dim,
        height: dim,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Concentric pulsing radar waves when actively searching for band
            if (widget.isScanning)
              CustomPaint(
                size: Size(dim, dim),
                painter: _RadarWavePainter(animation: _waveController),
              ),

            // 2. Rotating concentric radar dial rings
            RotationTransition(
              turns: _clockwiseTurns,
              child: Image.asset(
                AppConstants.onboardingRadarRings,
                width: dim,
                height: dim,
                fit: BoxFit.contain,
                cacheWidth: (dim * 2).toInt(),
              ),
            ),

            // 3. Rotating radar shadow/glow in opposite direction
            RotationTransition(
              turns: _oppositeTurns,
              child: Image.asset(
                AppConstants.onboardingRadarShadow,
                width: dim,
                height: dim,
                fit: BoxFit.contain,
                cacheWidth: (dim * 2).toInt(),
              ),
            ),

            // 4. Central stationary glow halo when scanning
            if (widget.isScanning)
              Container(
                width: logoDim * 2.2,
                height: logoDim * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

            // 5. Static central EHG clover/cross brand logo (stationary)
            ShaderMask(
              shaderCallback: (Rect bounds) =>
                  AppGradients.primaryLogo.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: SvgPicture.asset(
                AppIcons.ehgLogo,
                height: logoDim,
                width: logoDim,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// High-performance custom painter for expanding concentric radar waves.
/// Repaints on the canvas using the animation ticker without widget rebuilds.
class _RadarWavePainter extends CustomPainter {
  final Animation<double> animation;

  _RadarWavePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final minRadius = size.width * 0.12;

    const waveCount = 3;
    final t = animation.value;

    for (int i = 0; i < waveCount; i++) {
      final waveProgress = (t + (i / waveCount)) % 1.0;
      final radius = minRadius + (maxRadius - minRadius) * waveProgress;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0) * 0.35;

      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);

      // Subtle filled gradient pulse behind the first wave
      if (waveProgress < 0.6) {
        final fillPaint = Paint()
          ..color = AppColors.cyanActive.withValues(alpha: opacity * 0.15)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radius, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarWavePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
