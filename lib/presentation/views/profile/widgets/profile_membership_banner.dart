import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Gradient banner promoting Health Tracking Membership (Figma Node 82:3028).
class ProfileMembershipBanner extends StatelessWidget {
  final VoidCallback? onSeeMembership;

  const ProfileMembershipBanner({super.key, this.onSeeMembership});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySky.withValues(alpha: 0.20),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Tracking',
            style: GoogleFonts.montserrat(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Free forever. Membership adds programmes, the outfit engine and double points.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 12.0),
          Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              onTap: onSeeMembership ?? () {},
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                alignment: Alignment.center,
                child: Text(
                  'See Membership',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(16.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
