import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable section header for cards across the dashboard (Heart Rate, Sleep, Hydration, Energy Burned).
/// Displays an icon and title on the left, and an optional clickable action with chevron on the right.
class CardSectionHeader extends StatelessWidget {
  final String title;
  final String? iconSvg;
  final Color? iconColor;
  final double iconSize;
  final String? actionText;
  final VoidCallback? onActionTap;
  final double titleFontSize;
  final double actionFontSize;

  const CardSectionHeader({
    super.key,
    required this.title,
    this.iconSvg,
    this.iconColor,
    this.iconSize = 18.0,
    this.actionText,
    this.onActionTap,
    this.titleFontSize = 15.0,
    this.actionFontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading Icon + Title
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconSvg != null) ...[
                AppSvgIcon(
                  iconSvg!,
                  size: iconSize,
                  color: iconColor,
                ),
                const SizedBox(width: 8.0),
              ],
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Trailing Action (e.g. "Today >", "Start a session >")
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: actionFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 2.0),
                Icon(
                  Icons.chevron_right_rounded,
                  size: actionFontSize + 4.0,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
