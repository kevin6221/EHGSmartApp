import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/metric_card_calculator.dart';
import '../../../widgets/charts/capsule_bar_chart.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Card showing energy burned, active minutes, and weekly capsule bar chart.
/// Fully dynamic layout using responsive proportions.
class HomeEnergyCard extends StatelessWidget {
  final int energyBurned;
  final int steps;
  final int activeMins;
  final int goalMins;
  final List<double> weeklyEnergy;
  final VoidCallback? onStartSession;
  final VoidCallback? onTap;

  const HomeEnergyCard({
    super.key,
    required this.energyBurned,
    this.steps = 0,
    required this.activeMins,
    required this.goalMins,
    required this.weeklyEnergy,
    this.onStartSession,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = MetricCardDimensions.compute(
      screenWidth: r.width,
      screenHeight: r.height,
    );

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 12.0 : 16.0),
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
            title: 'Energy burned',
            iconSvg: AppIcons.energyBurn,
            iconColor: AppColors.cyanAccent,
            iconSize: 18.0,
            titleFontSize: r.font(15.0),
            actionText: 'Start a session',
            actionFontSize: r.font(12.0),
            onActionTap: onStartSession,
          ),
          SizedBox(height: dims.verticalSpacing),

          // Body: Metric on left, 7-day capsule bar chart on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$energyBurned',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(22.0),
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          ' kcal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(12.0),
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      steps > 0
                          ? '$steps steps · Active $activeMins / $goalMins'
                          : 'Active $activeMins / $goalMins',
                      style: GoogleFonts.plusJakartaSans(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: r.font(12.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 5,
                child: CapsuleBarChart(
                  values: weeklyEnergy,
                  activeColor: AppColors.cyanAccent,
                  middleColor: AppColors.energyMiddle,
                  lightColor: AppColors.energyLight,
                  height: dims.chartHeight,
                  barWidth: dims.barWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
