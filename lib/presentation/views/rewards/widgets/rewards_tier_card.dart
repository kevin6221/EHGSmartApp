import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/dotted_divider.dart';

/// Bronze Member Tier card with progress indicator and benefits summary.
class RewardsTierCard extends StatelessWidget {
  final Responsive r;

  const RewardsTierCard({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.rewardsTierCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.rewardsTierCardBorder, width: 1.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bronze member',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(14.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.all(7.0),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '2x',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(10.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Text(
                '2,150 to Silver',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          LinearProgressIndicator(
            value: 0.35,
            backgroundColor: AppColors.white,
            color: AppColors.primary,
            minHeight: 3.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Free UK delivery on every order',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 14.0),
          const DottedDivider(
            color: AppColors.secondary,
            dashWidth: 3.0,
            dashSpace: 3.0,
            thickness: 0.5,
          ),
          const SizedBox(height: 12.0),
          Text(
            'Next · Silver unlocks early access to every drop and first refusal on limited colourways',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: AppColors.tertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
