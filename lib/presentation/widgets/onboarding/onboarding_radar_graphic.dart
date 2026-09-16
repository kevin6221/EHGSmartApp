import 'package:ehgsmartapp/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_gradients.dart';

/// Animated radar graphic for Onboarding Screen 2 (Figma Node 14:2600).
/// Isolated repaint boundary with centralized rotation duration.
class OnboardingRadarGraphic extends StatefulWidget {
  final double dimension;

  const OnboardingRadarGraphic({super.key, this.dimension = 272.0});

  @override
  State<OnboardingRadarGraphic> createState() => _OnboardingRadarGraphicState();
}

class _OnboardingRadarGraphicState extends State<OnboardingRadarGraphic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _clockwiseTurns;
  late final Animation<double> _oppositeTurns;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: AppDurations.radarRotation,
    )..repeat();
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
  void dispose() {
    _rotationController.dispose();
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
            // 1. Static concentric radar dial rings (stationary in background)
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

            // 3. Static central EHG clover/cross brand logo (stationary)
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
