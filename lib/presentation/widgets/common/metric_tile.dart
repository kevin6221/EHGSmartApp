import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import 'app_card.dart';

/// Reusable metric tile displaying an icon, title, value/unit, and optional status badge or trailing widget.
class MetricTile extends StatelessWidget {
  final String iconPath;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String value;
  final String? unit;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MetricTile({
    super.key,
    required this.iconPath,
    required this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.value,
    this.unit,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      onTap: onTap,
      child: Row(
        children: [
          // Metric Icon in rounded container
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppSvgIcon(iconPath, size: 20.0, color: iconColor),
          ),
          const SizedBox(width: 14.0),

          // Title and Status Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(height: 3.0),
                  Text(
                    badgeText!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: badgeTextColor ?? AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Trailing: either custom widget (e.g. sparkline) or Value + Unit
          if (trailing != null)
            trailing!
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4.0),
                  Text(
                    unit!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
