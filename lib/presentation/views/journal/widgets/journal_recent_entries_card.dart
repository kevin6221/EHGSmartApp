import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Recent entries list card for the Journal screen.
class JournalRecentEntriesCard extends StatelessWidget {
  final String dateText;
  final String energyText;
  final String noteText;

  const JournalRecentEntriesCard({
    super.key,
    this.dateText = "23 Jul · Calm",
    this.energyText = "8.0h · energy 4/5",
    this.noteText = "Long stretch session, slept deep.",
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
              Text(
                energyText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            noteText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
