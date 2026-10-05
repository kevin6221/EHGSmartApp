import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

import 'locked_item_explanation_sheet.dart';

/// Section displaying programmes on the Systems screen with locked status.
class SystemsProgrammesSection extends StatelessWidget {
  final Responsive r;

  const SystemsProgrammesSection({
    super.key,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your programmes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(14.0),
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => LockedItemExplanationSheet.show(
                context,
                title: 'Programmes Catalog',
                itemType: 'Programme',
                requiredCondition: 'Complete daily missions and connect your wearable garments to unlock specialized programmes.',
                rewardDescription: 'Access structured multi-week training regimens, form feedback, and exclusive rewards.',
              ),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSvgIcon(
                    AppIcons.lock,
                    size: 11.0,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'LOCKED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildLockedProgrammeCard(
          context: context,
          title: '30–Day Pilates',
          category: '',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '',
          requiredCondition: 'Pair your High Rise Flared Yoga Pants and complete 5 core sessions to unlock.',
          rewardDescription: 'Unlocks full 30-day progressive Pilates calendar, form analysis, and +300 Reward points.',
          r: r,
        ),
        const SizedBox(height: 16.0),
        _buildLockedProgrammeCard(
          context: context,
          title: 'Lower Body Challenge',
          category: '',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '',
          requiredCondition: 'Reach 8,000 steps on 3 consecutive days to unlock this strength programme.',
          rewardDescription: 'Unlocks progressive resistance sessions, muscular fatigue recovery guide, and +250 Reward points.',
          r: r,
        ),
      ],
    );
  }

  Widget _buildLockedProgrammeCard({
    required BuildContext context,
    required String title,
    required String category,
    required String sourcePiece,
    required String kcalRemaining,
    required String requiredCondition,
    required String rewardDescription,
    required Responsive r,
  }) {
    return GestureDetector(
      onTap: () => LockedItemExplanationSheet.show(
        context,
        title: title,
        itemType: 'Programme',
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
                child: Row(
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
                    // const SizedBox(width: 8.0),
                    AppSvgIcon(
                      AppIcons.lock,
                      size: 13.0,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
              // const SizedBox(width: 8.0),
              Text(
                category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _buildLockedProgressBar(context, r),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sourcePiece,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                kcalRemaining,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.calorieOrangeColor,
                ),
              ),
            ],
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
