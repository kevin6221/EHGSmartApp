import 'package:flutter/material.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

/// Animated concentric pulsing rings displaying on the splash screen background.
/// Isolated repaint boundary with centralized animation parameters.
class SplashPulsingRings extends StatefulWidget {
  final double? baseDimension;

  const SplashPulsingRings({super.key, this.baseDimension});

  @override
  State<SplashPulsingRings> createState() => _SplashPulsingRingsState();
}

class _SplashPulsingRingsState extends State<SplashPulsingRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.splashPulse,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: AppCurves.pulse),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseDim = widget.baseDimension ?? (screenWidth * 0.85);
    final logoSize = (screenWidth * 0.16).clamp(52.0, 72.0);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = _pulseAnimation.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring 4
              Container(
                width: baseDim * scale,
                height: baseDim * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
              // Ring 3
              Container(
                width: baseDim * 0.78 * scale,
                height: baseDim * 0.78 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.09),
                ),
              ),
              // Ring 2
              Container(
                width: baseDim * 0.56 * scale,
                height: baseDim * 0.56 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.14),
                ),
              ),
              // Ring 1
              Container(
                width: baseDim * 0.38 * scale,
                height: baseDim * 0.38 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.22),
                ),
              ),
              // Center EHG Emblem SVG
              AppSvgIcon(
                AppIcons.logo,
                size: logoSize,
                color: AppColors.white,
              ),
            ],
          );
        },
      ),
    );
  }
}
