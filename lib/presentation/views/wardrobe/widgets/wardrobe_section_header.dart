import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section header with a title and count/status badge for the Wardrobe screen.
class WardrobeSectionHeader extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;

  const WardrobeSectionHeader({
    super.key,
    required this.title,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        Text(
          badgeText,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(10.0),
            fontWeight: FontWeight.w600,
            color: badgeColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
