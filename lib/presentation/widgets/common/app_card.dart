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
    this.backgroundColor = AppColors.surface,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.midnightSurface : AppColors.surface;
    final defaultBorderColor =
        isDark ? AppColors.midnightBorder : AppColors.border;
    final effectiveBg =
        (backgroundColor == AppColors.surface || backgroundColor == null)
            ? defaultBg
            : backgroundColor;

    final effectiveRadius = borderRadius ?? BorderRadius.circular(16.0);
    final effectiveBorder =
        border ?? Border.all(color: defaultBorderColor, width: 1.0);
    final effectiveShadow =
        boxShadow ??
        [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBg : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      clipBehavior: clipBehavior,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: isDark ? AppColors.midnightTextPrimary : AppColors.secondary,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: isDark ? AppColors.midnightTextPrimary : AppColors.secondary,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: AppColors.transparent,
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
