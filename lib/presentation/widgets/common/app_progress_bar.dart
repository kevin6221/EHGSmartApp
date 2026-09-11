import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 3 Progress Bar Variants defined in Figma Brand Guide (Node 2:575).
enum AppProgressBarVariant {
  /// Primary brand blue #3E83C8
  primary,

  /// Secondary dark slate #1F2937
  secondary,

  /// Tertiary mid slate #4B5563
  tertiary,
}

/// Brand progress bar matching Figma Brand Guide (Node 2:575).
class AppProgressBar extends StatelessWidget {
  /// Progress fraction between 0.0 and 1.0.
  final double value;

  /// Brand color variant.
  final AppProgressBarVariant variant;

  /// Custom fill color override.
  final Color? fillColor;

  /// Track background color (defaults to pure white / subtle track).
  final Color? trackColor;

  /// Bar height (defaults to 6.0).
  final double height;

  /// Corner radius (defaults to full capsule 100.0).
  final double borderRadius;

  /// Duration of progress transition animation.
  final Duration animationDuration;

  const AppProgressBar({
    super.key,
    required this.value,
    this.variant = AppProgressBarVariant.primary,
    this.fillColor,
    this.trackColor,
    this.height = 6.0,
    this.borderRadius = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Factory constructor for Primary variant (#3E83C8).
  const AppProgressBar.primary({
    super.key,
    required this.value,
    this.fillColor,
    this.trackColor,
    this.height = 6.0,
    this.borderRadius = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : variant = AppProgressBarVariant.primary;

  /// Factory constructor for Secondary variant (#1F2937).
  const AppProgressBar.secondary({
    super.key,
    required this.value,
    this.fillColor,
    this.trackColor,
    this.height = 6.0,
    this.borderRadius = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : variant = AppProgressBarVariant.secondary;

  /// Factory constructor for Tertiary variant (#4B5563).
  const AppProgressBar.tertiary({
    super.key,
    required this.value,
    this.fillColor,
    this.trackColor,
    this.height = 6.0,
    this.borderRadius = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : variant = AppProgressBarVariant.tertiary;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final effectiveRadius = BorderRadius.circular(borderRadius);

    Color resolvedFill;
    switch (variant) {
      case AppProgressBarVariant.primary:
        resolvedFill = fillColor ?? AppColors.primary;
        break;
      case AppProgressBarVariant.secondary:
        resolvedFill = fillColor ?? AppColors.secondary;
        break;
      case AppProgressBarVariant.tertiary:
        resolvedFill = fillColor ?? AppColors.tertiary;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final fillWidth = totalWidth * clampedValue;

        return Container(
          width: totalWidth,
          height: height,
          decoration: BoxDecoration(
            color: trackColor ?? AppColors.surface,
            borderRadius: effectiveRadius,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              width: fillWidth,
              height: height,
              decoration: BoxDecoration(
                color: resolvedFill,
                borderRadius: effectiveRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}
