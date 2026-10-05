import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

import 'locked_item_explanation_sheet.dart';

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
    final itemSpacing = (screenHeight * 0.012).clamp(10.0, 14.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journeys in progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 14.0),
        _buildLockedJourneyCard(
          context: context,
          title: 'Morning Energy',
          gearText: 'Tank Top · Resistance Band · Smart Band',
          requiredCondition: 'Complete 3 more daily missions to unlock this morning activation journey.',
          rewardDescription: 'Unlocks morning protocol, daylight exposure sync, and +150 Wardrobe Reward points.',
          r: r,
        ),
        SizedBox(height: itemSpacing),
        _buildLockedJourneyCard(
          context: context,
          title: 'Better Sleep',
          gearText: 'Boxy Piping Tee · Eye Mask · Smart Band',
          requiredCondition: 'Complete 4 consecutive nights of sleep tracking to unlock this wind-down journey.',
          rewardDescription: 'Unlocks parasympathetic breathwork flow, circadian lighting guidance, and +200 Reward points.',
          r: r,
        ),
      ],
    );
  }

  Widget _buildLockedJourneyCard({
    required BuildContext context,
    required String title,
    required String gearText,
    required String requiredCondition,
    required String rewardDescription,
    required Responsive r,
  }) {
    return GestureDetector(
      onTap: () => LockedItemExplanationSheet.show(
        context,
        title: title,
        itemType: 'Journey',
        requiredCondition: requiredCondition,
        rewardDescription: rewardDescription,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.cardBorder, width: 1.0),
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
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8.0),
              AppSvgIcon(
                AppIcons.lock,
                size: 14.0,
                color: context.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _buildLockedProgressBar(context, r),
          const SizedBox(height: 10.0),
          Text(
            gearText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildLockedProgressBar(BuildContext context, Responsive r) {
    return Container(
      height: 14.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.midnightBackground
            : AppColors.background,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(
          color: context.isDark ? AppColors.midnightBorder : AppColors.divider,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSvgIcon(
            AppIcons.lock,
            size: 9.0,
            color: context.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5.0),
          Text(
            'LOCKED',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(8.0),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: context.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
