import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

/// 4 Brand Emblem Color Variants defined in Figma Brand Guide (Node 2:575).
enum AppBrandLogoVariant {
  /// Primary blue container (#3E83C8) with white logo.
  primary,

  /// Secondary dark slate container (#1F2937) with white logo.
  secondary,

  /// Tertiary mid slate container (#4B5563) with white logo.
  white,
}

/// Reusable Brand Logo Emblem Tile matching Figma Brand Guide (Node 2:575).
class AppBrandLogo extends StatelessWidget {
  final AppBrandLogoVariant variant;
  final double size;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppBrandLogo({
    super.key,
    this.variant = AppBrandLogoVariant.primary,
    this.size = 36.0,
    this.borderRadius = 8.0,
    this.padding,
  });

  const AppBrandLogo.primary({
    super.key,
    this.size = 36.0,
    this.borderRadius = 8.0,
    this.padding,
  }) : variant = AppBrandLogoVariant.primary;

  const AppBrandLogo.secondary({
    super.key,
    this.size = 36.0,
    this.borderRadius = 8.0,
    this.padding,
  }) : variant = AppBrandLogoVariant.secondary;

  const AppBrandLogo.white({
    super.key,
    this.size = 36.0,
    this.borderRadius = 8.0,
    this.padding,
  }) : variant = AppBrandLogoVariant.white;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    BoxBorder? border;

    switch (variant) {
      case AppBrandLogoVariant.primary:
        bgColor = AppColors.primary;
        iconColor = AppColors.white;
        border = null;
        break;
      case AppBrandLogoVariant.secondary:
        bgColor = AppColors.secondary;
        iconColor = AppColors.white;
        border = null;
        break;
      case AppBrandLogoVariant.white:
        bgColor = AppColors.white;
        iconColor = AppColors.secondary;
        border = Border.all(color: AppColors.border, width: 1.0);
        break;
    }

    final effectivePadding = padding ?? EdgeInsets.all(size * 0.22);

    return Container(
      width: size,
      height: size,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: variant == AppBrandLogoVariant.white
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.ehgLogo,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// Brand Pill Badge (e.g. "Label") matching Figma Brand Guide (Node 2:575).
class AppBrandBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppBrandBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.white,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
