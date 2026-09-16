import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Pattern banner card found by the band for the Journal screen.
class JournalPatternBanner extends StatelessWidget {
  const JournalPatternBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pattern the band found",
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: AppGradients.journalPatternBanner,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  "Your energy averages 4.5 after 7h+ sleep, and 2.7 when you sleep less. Across 5 entries, sleep is your strongest lever.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
