import 'package:flutter/material.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_constants.dart';

/// Rotating orbital graphic widget used on the onboarding screen.
class RotatingOrbitGraphic extends StatefulWidget {
  final double dimension;
  final Duration rotationDuration;

  const RotatingOrbitGraphic({
    super.key,
    required this.dimension,
    this.rotationDuration = AppDurations.orbitRotation,
  });

  @override
  State<RotatingOrbitGraphic> createState() => _RotatingOrbitGraphicState();
}

class _RotatingOrbitGraphicState extends State<RotatingOrbitGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidth = widget.dimension * (57.0 / 500.0);
    final logoHeight = widget.dimension * (58.0 / 396.0);

    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _orbitController,
            child: Image.asset(
              AppConstants.welcomeOrbit,
              width: widget.dimension,
              height: widget.dimension,
              fit: BoxFit.cover,
            ),
          ),

          // Static EHG brand logo centered inside the orbital graphic
          Image.asset(
            AppConstants.welcomeLogo,
            width: logoWidth,
            height: logoHeight,
            fit: BoxFit.contain,
            cacheWidth: (logoWidth * 3).toInt(),
          ),
        ],
      ),
    );
  }
}
