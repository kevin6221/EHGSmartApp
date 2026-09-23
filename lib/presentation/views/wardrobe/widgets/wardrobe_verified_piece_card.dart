import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_button.dart';

/// Detailed verified piece card (High Rise Flared Yoga Pants) on the Wardrobe screen.
class WardrobeVerifiedPieceCard extends StatelessWidget {
  final VoidCallback? onUnlock;

  const WardrobeVerifiedPieceCard({
    super.key,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: context.isDark
              ? AppColors.midnightBorder
              : AppColors.primarySky.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge icon container
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.isDark
                      ? AppColors.midnightBackground
                      : AppColors.wardrobePieceIconBg,
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
                      'High Rise Flared Yoga Pants',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14),
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'EHG Performance · Move system',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.recoverPillar,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      '72% nylon · 28% elastane',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(10.0),
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Care icons row
          Row(
            children: [
              _buildCareIcon(AppIcons.careWash, context),
              const SizedBox(width: 10.0),
              _buildCareIcon(AppIcons.careBleach, context),
              const SizedBox(width: 10.0),
              _buildCareIcon(AppIcons.careDry, context),
              const SizedBox(width: 10.0),
              _buildCareIcon(AppIcons.careIron, context),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              color: context.dividerColor,
              height: 1.0,
              thickness: 0.8,
            ),
          ),

          // Status subtitle
          Text(
            'Unlocked · 47 wears · Bronze',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 10.0),

          // 4 Programme bullet points with blue star
          _buildProgrammeItem('30-day Pilates programme', r, context),
          _buildProgrammeItem('Lower body challenge', r, context),
          _buildProgrammeItem('Stretch library', r, context),
          _buildProgrammeItem('Mobility tracker', r, context),
          const SizedBox(height: 14.0),

          // Full-width button: Unlock 90 days Free
          AppButton(
            text: 'Unlock 90 days Free',
            showArrow: false,
            useGradient: true,
            hasShadow: false,
            height: (screenHeight * 0.050).clamp(40.0, 44.0),
            borderRadius: BorderRadius.circular(10.0),
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            onPressed: onUnlock ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('90 days free membership unlocked!'),
                    ),
                  );
                },
          ),
        ],
      ),
    );
  }

  Widget _buildCareIcon(String svgPath, BuildContext context) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.isDark ? AppColors.midnightBackground : AppColors.transparent,
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(svgPath, size: 16.0, color: context.textSecondary),
    );
  }

  Widget _buildProgrammeItem(String title, Responsive r, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppSvgIcon(
            AppIcons.blueStar,
            size: 14.0,
            color: AppColors.primarySky,
          ),
          const SizedBox(width: 10.0),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
