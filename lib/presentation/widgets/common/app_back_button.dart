import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';

/// Premium unified back button matching the EHG design system.
///
/// Features frosted glass styling, subtle border, smooth feedback,
/// and adaptive theming for both sky gradient headers and light/dark page surfaces.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showLabel;
  final String label;
  final bool isLightHeader;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppBackButton({
    super.key,
    this.onTap,
    this.showLabel = false,
    this.label = 'Back',
    this.isLightHeader = false,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color effectiveIconColor = iconColor ??
        (isLightHeader
            ? AppColors.white
            : (isDark ? AppColors.white : AppColors.textPrimary));

    final Color effectiveBg = backgroundColor ??
        (isLightHeader
            ? AppColors.white.withValues(alpha: 0.16)
            : (isDark
                ? AppColors.surface.withValues(alpha: 0.85)
                : AppColors.surface.withValues(alpha: 0.90)));

    final Color effectiveBorder = borderColor ??
        (isLightHeader
            ? AppColors.white.withValues(alpha: 0.28)
            : AppColors.borderLight);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 12.0 : 9.0,
          vertical: 7.5,
        ),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: effectiveBorder, width: 0.9),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15.0,
              color: effectiveIconColor,
            ),
            if (showLabel) ...[
              const SizedBox(width: 6.0),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.5),
                  fontWeight: FontWeight.w600,
                  color: effectiveIconColor,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
