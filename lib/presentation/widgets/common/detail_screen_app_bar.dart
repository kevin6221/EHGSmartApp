import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import 'app_back_button.dart';

/// Unified app bar for all detail/sub-screens (Heart Rate, Sleep, Hydration,
/// Training Session, etc.) matching the EHG design system.
///
/// Features a frosted [AppBackButton] on the left, an optional status pill in
/// the center-right, and consistent padding across all detail views.
class DetailScreenAppBar extends StatelessWidget {
  /// The title displayed next to the back button (optional).
  final String? title;

  /// If true, show the title label next to the back icon.
  final bool showLabel;

  /// Custom back-button callback; defaults to [Navigator.maybePop].
  final VoidCallback? onBackTap;

  /// Optional status pill text (e.g. "Live Telemetry", "Last Night", "Fuel System").
  final String? statusText;

  /// Color for the status pill dot and text.
  final Color? statusColor;

  /// Optional trailing widget after the status pill.
  final Widget? trailing;

  const DetailScreenAppBar({
    super.key,
    this.title,
    this.showLabel = true,
    this.onBackTap,
    this.statusText,
    this.statusColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final status = statusText;
    final color = statusColor ?? AppColors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.horizontalPadding,
        vertical: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading: Back button (optionally with label)
          AppBackButton(
            showLabel: showLabel,
            label: title ?? 'Back',
            onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
            isLightHeader: true,
          ),

          // Trailing: Status pill and/or custom trailing widget
          if (status != null || trailing != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w600,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (trailing != null) ...[
                  const SizedBox(width: 8.0),
                  trailing!,
                ],
              ],
            ),
        ],
      ),
    );
  }
}
