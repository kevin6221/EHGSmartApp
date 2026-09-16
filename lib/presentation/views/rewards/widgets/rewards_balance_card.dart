import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Balance card displaying total points and current streak badge.
class RewardsBalanceCard extends StatelessWidget {
  final Responsive r;

  const RewardsBalanceCard({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.rewardsBalanceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.rewardsTierCardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '2,350',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(30.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'BALANCE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.cyanLight,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '11–day streak',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
