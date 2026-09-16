import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Compact verified wardrobe piece tile (e.g. Cotton Earth Tone T-Shirt).
class WardrobeVerifiedTShirtCard extends StatelessWidget {
  const WardrobeVerifiedTShirtCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Badge
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.wardrobePieceIconBg,
              border: Border.all(
                color: AppColors.primarySky.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: const AppSvgIcon(
              AppIcons.wardrobePieceBadge,
              size: 22.0,
              color: AppColors.cyanAccent,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cotton Earth Tone T-Shirt',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  'EHG Core · Move system',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primarySky,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSvgIcon(
                AppIcons.check,
                size: 12.0,
                color: AppColors.greenMetric,
              ),
              const SizedBox(width: 4.0),
              Text(
                'VERIFIED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenMetric,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Locked piece card displaying piece title, programme count, and a padlock icon.
class WardrobeLockedPieceCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const WardrobeLockedPieceCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Muted Badge
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            alignment: Alignment.center,
            child: const AppSvgIcon(
              AppIcons.wardrobePieceBadge,
              size: 20.0,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSvgIcon(
                AppIcons.lock,
                size: 13.0,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 4.0),
              Text(
                'LOCKED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
