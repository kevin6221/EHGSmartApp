import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section allowing users to redeem available points for discounts.
class RewardsSpendSection extends StatelessWidget {
  final Responsive r;

  const RewardsSpendSection({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spend your points',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Earning and spending are free for everyone. Members earn at double rate and reach the two reserved rewards.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12.0),
          // 800 - Activewear piece
          Container(
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: context.isDark ? context.cardBorder : AppColors.primary,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  '800',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '10% off any Activewear piece',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w400,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'REDEEM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(12.0),
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // 1200 - Free UK delivery (Redeemed)
          Container(
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: context.isDark ? context.cardBorder : AppColors.rewardsRedeemedBorder,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Text(
                  '1200',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Free UK delivery, next order',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w400,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                Text(
                  'REDEEMED',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.rewardsRedeemedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
