import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

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
      duration: const Duration(seconds: 12),
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
    final logoDim = dim * 0.13; // ~35px for 272px radar

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
            Image.asset(
              AppConstants.onboardingRadarLogo,
              width: logoDim,
              height: logoDim,
              fit: BoxFit.contain,
              cacheWidth: (logoDim * 2).toInt(),
            ),
          ],
        ),
      ),
    );
  }
}
