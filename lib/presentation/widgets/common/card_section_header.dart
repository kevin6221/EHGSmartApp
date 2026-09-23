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
    final svg = iconSvg;
    final action = actionText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading Icon + Title
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (svg != null) ...[
                AppSvgIcon(
                  svg,
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
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Trailing Action (e.g. "Today >", "Start a session >")
        if (action != null)
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  action,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: actionFontSize,
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: 4.0),
                AppSvgIcon(
                  AppIcons.rightArrowChevron,
                  size: actionFontSize + 2.0,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
