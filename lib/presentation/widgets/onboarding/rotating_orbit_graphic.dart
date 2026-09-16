import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_gradients.dart';

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
    final logoWidth = widget.dimension * (57.0 / 393.0);
    final logoHeight = widget.dimension * (58.0 / 393.0);

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
          ShaderMask(
            shaderCallback: (Rect bounds) =>
                AppGradients.primaryLogo.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(
              AppIcons.ehgLogo,
              height: logoHeight,
              width: logoWidth,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
