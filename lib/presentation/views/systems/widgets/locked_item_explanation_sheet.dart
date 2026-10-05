import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Modal bottom sheet presenting clear explanation of locked Journeys/Programmes,
/// required unlock conditions, upcoming rewards, and direct navigation to Rewards.
class LockedItemExplanationSheet extends StatelessWidget {
  final String title;
  final String itemType; // 'Journey' or 'Programme'
  final String requiredCondition;
  final String rewardDescription;

  const LockedItemExplanationSheet({
    super.key,
    required this.title,
    this.itemType = 'Journey',
    this.requiredCondition = 'Complete 3 more daily system missions to unlock this journey.',
    this.rewardDescription = 'Unlocks guided progressive protocol, biometric movement tracking, and +150 Wardrobe Reward points.',
  });

  static void show(
    BuildContext context, {
    required String title,
    String itemType = 'Journey',
    String? requiredCondition,
    String? rewardDescription,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LockedItemExplanationSheet(
        title: title,
        itemType: itemType,
        requiredCondition: requiredCondition ??
            'Complete 3 more daily system missions to unlock this $itemType.',
        rewardDescription: rewardDescription ??
            'Unlocks structured training flows, biometric recovery tracking, and tier rewards.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = context.isDark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.0,
        14.0,
        20.0,
        MediaQuery.of(context).padding.bottom + 20.0,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border.all(
          color: isDark ? context.cardBorder : AppColors.systemCardBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: context.cardBorder,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // Header with Lock Icon & Status
          Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const AppSvgIcon(
                  AppIcons.lock,
                  size: 20.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemType Locked',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(18.0),
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Unlock Requirement Box
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightBackground : AppColors.surface,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: context.cardBorder,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 16.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'HOW TO UNLOCK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w700,
                        color: context.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  requiredCondition,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(13.0),
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Reward Preview Box
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightBackground : AppColors.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppSvgIcon(
                      AppIcons.rewards,
                      size: 16.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'REWARD UPON UNLOCK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  rewardDescription,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.5),
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22.0),

          // Primary Navigation: View Rewards ->
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.rewards);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Rewards',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(14.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  const Icon(Icons.arrow_forward_rounded, size: 16.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8.0),

          // Secondary: Dismiss
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Dismiss',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(13.0),
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
