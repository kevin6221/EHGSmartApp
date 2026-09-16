import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Standardized section title header with optional trailing action button.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? actionWidget;
  final double fontSize;
  final FontWeight fontWeight;
  final Color titleColor;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionWidget,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.w700,
    this.titleColor = AppColors.textPrimary,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    final actWidget = actionWidget;
    final actLabel = actionLabel;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: titleColor,
                    letterSpacing: -0.2,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    sub,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actWidget != null)
            actWidget
          else if (actLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
