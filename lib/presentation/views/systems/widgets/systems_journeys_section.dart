import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section showing user journeys in progress on the Systems screen.
class SystemsJourneysSection extends StatelessWidget {
  final Responsive r;
  final double screenHeight;

  const SystemsJourneysSection({
    super.key,
    required this.r,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journeys in progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 14.0),
        _buildJourneyCard(
          title: 'Morning Energy',
          progressText: '9/21 days',
          progressFraction: 9.0 / 21.0,
          gearText: 'Tank Top · Resistance Band · Smart Band',
          r: r,
        ),
        SizedBox(height: (screenHeight * 0.012).clamp(10.0, 14.0)),
        _buildJourneyCard(
          title: 'Better Sleep',
          progressText: '3/14 days',
          progressFraction: 3.0 / 14.0,
          gearText: 'Boxy Piping Tee · Eye Mask · Smart Band',
          r: r,
        ),
      ],
    );
  }

  Widget _buildJourneyCard({
    required String title,
    required String progressText,
    required double progressFraction,
    required String gearText,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                progressText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progressFraction,
            minHeight: 2.0,
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.cyanLight,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            gearText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
