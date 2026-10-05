import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Card displaying real-time step counting, daily progress toward step goal,
/// distance in kilometers, and estimated active calorie burn.
class HomeStepsCard extends StatelessWidget {
  final int steps;
  final int goalSteps;
  final double? distanceMeters;
  final int? calories;
  final VoidCallback? onTap;

  const HomeStepsCard({
    super.key,
    required this.steps,
    this.goalSteps = 10000,
    this.distanceMeters,
    this.calories,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final double progress = (steps / (goalSteps > 0 ? goalSteps : 10000)).clamp(0.0, 1.5);
    final int pct = (progress * 100).round();

    final double effectiveDistanceKm = (distanceMeters != null && distanceMeters! > 0)
        ? (distanceMeters! / 1000.0)
        : ((steps * 0.762) / 1000.0);

    final int effectiveCalories = (calories != null && calories! > 0)
        ? calories!
        : (steps * 0.04).round();

    final formattedSteps = _formatNumber(steps);
    final formattedGoal = _formatNumber(goalSteps);

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          CardSectionHeader(
            title: "Today's Activity",
            iconSvg: AppIcons.runningManIcon,
            iconColor: AppColors.primary,
            iconSize: 18.0,
            titleFontSize: r.font(15.0),
            actionText: pct >= 100 ? 'Goal Reached' : '$pct% of Goal',
            actionFontSize: r.font(12.0),
            onActionTap: onTap,
          ),
          const SizedBox(height: 10.0),
          Text(
            'Steps',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4.0),

          // Main Step Count Value and Goal
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formattedSteps,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(32.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'of $formattedGoal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Animated Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8.0,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14.0),

          // Secondary metrics row: Distance and Estimated Calories
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.midnightBackground
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: context.cardBorder, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const AppSvgIcon(
                        AppIcons.targetDart,
                        size: 14.0,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(10.0),
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                          ),
                          Text(
                            '${effectiveDistanceKm.toStringAsFixed(2)} km',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(13.0),
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.midnightBackground
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: context.cardBorder, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const AppSvgIcon(
                        AppIcons.energyBurn,
                        size: 14.0,
                        color: AppColors.cyanAccent,
                      ),
                      const SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Burn',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(10.0),
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                          ),
                          Text(
                            '$effectiveCalories kcal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(13.0),
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
