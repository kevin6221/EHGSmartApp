import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/metric_card_calculator.dart';
import '../../../widgets/charts/capsule_bar_chart.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Card showing daily hydration progress and weekly capsule bar chart.
/// Fully dynamic layout using responsive proportions.
class HomeHydrationCard extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final List<double> weeklyHydration;
  final VoidCallback? onAddMl;
  final VoidCallback? onTap;

  const HomeHydrationCard({
    super.key,
    required this.currentMl,
    required this.goalMl,
    required this.weeklyHydration,
    this.onAddMl,
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
      border: Border.all(color: AppColors.borderLight, width: 0.8),
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
            title: 'Hydration',
            iconSvg: AppIcons.waterGlass,
            iconColor: AppColors.primary,
            iconSize: 18.0,
            titleFontSize: r.font(15.0),
            actionText: 'Today',
            actionFontSize: r.font(12.0),
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
                          '$currentMl',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(22.0),
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          ' / $goalMl ml',
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
                      'On Track',
                      style: GoogleFonts.plusJakartaSans(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: r.font(14.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 5,
                child: CapsuleBarChart(
                  values: weeklyHydration,
                  activeColor: AppColors.primary,
                  middleColor: AppColors.hydrationMiddle,
                  lightColor: AppColors.hydrationLight,
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
