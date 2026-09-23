import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/dashed_container.dart';

/// Section presenting user's active discount codes with dashed borders.
class RewardsCodesSection extends StatelessWidget {
  final Responsive r;

  const RewardsCodesSection({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your codes',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12.0),
          // Code 1: Free UK delivery
          DashedContainer(
            color: context.isDark ? context.cardBorder : AppColors.rewardsCodeBorder,
            borderRadius: BorderRadius.circular(12.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Free UK delivery, next order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'EHG-LSRZ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Use at checkout on ehgsmartwellness.com',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // Code 2: 10% off any Activewear piece
          DashedContainer(
            color: context.isDark ? context.cardBorder : AppColors.rewardsCodeBorder,
            borderRadius: BorderRadius.circular(12.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '10% off any Activewear piece',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'EHG-DUV5',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.rewardsCodeOrange,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Use at checkout on ehgsmartwellness.com',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
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
