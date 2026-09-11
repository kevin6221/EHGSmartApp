import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Reusable surface card container aligned with Figma design specifications.
/// Provides consistent elevation, corner radius, borders, and optional interaction.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius,
    this.backgroundColor = Colors.white,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16.0);
    final effectiveBorder =
        border ?? Border.all(color: AppColors.border, width: 1.0);
    final effectiveShadow =
        boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      clipBehavior: clipBehavior,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius is BorderRadius
              ? effectiveRadius
              : BorderRadius.circular(16.0),
          child: content,
        ),
      );
    }

    return content;
  }
}
