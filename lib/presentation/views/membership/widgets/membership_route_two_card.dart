import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_button.dart';

/// "Route two: £4.99 / month or £39 a year" card on the Membership screen.
class MembershipRouteTwoCard extends StatelessWidget {
  final VoidCallback? onStartTrial;

  const MembershipRouteTwoCard({
    super.key,
    this.onStartTrial,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route two tag
          Text(
            'Route two',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w700,
              color: AppColors.primarySky,
            ),
          ),
          const SizedBox(height: 6.0),

          // Price row
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '£4.99 ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(16.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                TextSpan(
                  text: '/ month · or £39 a year',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(13.5),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Description
          Text(
            'No clothes needed. Cancel in one tap, whenever. Band owners get the first three months free.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16.0),

          // Full-width button: Start 3 months free
          AppButton.outlined(
            text: 'Start 3 months free',
            showArrow: false,
            height: (screenHeight * 0.050).clamp(40.0, 44.0),
            borderRadius: BorderRadius.circular(10.0),
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            textColor: AppColors.primarySky,
            border: Border.all(color: AppColors.primarySky, width: 1.0),
            onPressed: onStartTrial ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting your 3-month free trial...'),
                    ),
                  );
                },
          ),
        ],
      ),
    );
  }
}
