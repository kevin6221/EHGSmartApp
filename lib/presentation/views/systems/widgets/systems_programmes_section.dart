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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.midnightSurface
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: context.isDark ? AppColors.midnightBorder : AppColors.divider,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSvgIcon(
                      AppIcons.lock,
                      size: 10.0,
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
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildLockedProgrammeCard(
          context: context,
          title: '30–Day Pilates',
          sessionsCount: '0/4 sessions',
          category: 'Pilates',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '371 kcal to go',
          progressFraction: 0.0,
          requiredCondition: 'Pair your High Rise Flared Yoga Pants and complete 5 core sessions to unlock.',
          rewardDescription: 'Unlocks full 30-day progressive Pilates calendar, form analysis, and +300 Reward points.',
          r: r,
        ),
        const SizedBox(height: 16.0),
        _buildLockedProgrammeCard(
          context: context,
          title: 'Lower Body Challenge',
          sessionsCount: '0/4 sessions',
          category: 'Strength',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '1,055 kcal to go',
          progressFraction: 0.0,
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
    required String sessionsCount,
    required String category,
    required String sourcePiece,
    required String kcalRemaining,
    required double progressFraction,
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
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(12.5),
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(width: 6.0),
                        Text(
                          category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(10.5),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.midnightSurface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: context.isDark ? AppColors.midnightBorder : AppColors.divider,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(
                        AppIcons.lock,
                        size: 10.0,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        sessionsCount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.5),
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.0),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 3.0,
                backgroundColor: context.isDark ? AppColors.midnightBorder : AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressFraction > 0 ? AppColors.cyanLight : context.textSecondary.withValues(alpha: 0.25),
                ),
              ),
            ),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to unlock',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(10.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 14.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
