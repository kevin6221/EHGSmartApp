import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_row_calculator.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Horizontal carousel displaying Heart Rate and Sleep quick-glance metric cards.
/// Dynamically sized according to screen width and viewport constraints.
class HomeVitalsSummaryRow extends StatelessWidget {
  final int heartRate;
  final List<double> weeklyHeartRate;
  final double sleepHours;
  final VoidCallback? onHeartRateTap;
  final VoidCallback? onSleepTap;

  const HomeVitalsSummaryRow({
    super.key,
    required this.heartRate,
    required this.weeklyHeartRate,
    required this.sleepHours,
    this.onHeartRateTap,
    this.onSleepTap,
  });

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsRowDimensions.compute(
      screenWidth: r.width,
      screenHeight: r.height,
    );

    return SizedBox(
      height: dims.cardHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            // 1. Heart Rate Card
            _buildHeartRateCard(
              r,
              dims.chartWidth,
              dims.cardWidth,
              dims.cardHeight,
            ),
            SizedBox(width: dims.cardGap),

            // 2. Sleep Card
            _buildSleepCard(
              r,
              dims.chartWidth,
              dims.sleepBarWidth,
              dims.cardWidth,
              dims.cardHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard(
    Responsive r,
    double chartWidth,
    double cardWidth,
    double cardHeight,
  ) {
    final sparklineHeight = (cardHeight * 0.22).clamp(20.0, 28.0);

    return AppCard(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      borderRadius: BorderRadius.circular(18.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.04),
          blurRadius: 10.0,
          offset: const Offset(0, 3),
        ),
      ],
      onTap: onHeartRateTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          CardSectionHeader(
            title: 'Heart Rate',
            iconSvg: AppIcons.heartPulse,
            iconColor: AppColors.primary,
            iconSize: 15.0,
            titleFontSize: r.font(12.0),
            actionText: 'Today',
            actionFontSize: r.font(10.0),
          ),

          // Content Row: Value on left (Expanded), Sparkline on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Metric value + label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$heartRate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(20.0),
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          'bpm',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Resting Rate',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Right: Mini Sparkline + Weekday Row
              SizedBox(
                width: chartWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SparklineChart(
                      values: weeklyHeartRate,
                      lineColor: AppColors.primary,
                      height: sparklineHeight,
                      width: chartWidth,
                      strokeWidth: 1.5,
                      showFill: true,
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekdays
                          .map(
                            (d) => Text(
                              d,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(9.0),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(
    Responsive r,
    double chartWidth,
    double sleepBarWidth,
    double cardWidth,
    double cardHeight,
  ) {
    final baseHeights = [18.0, 22.0, 16.0, 24.0, 20.0, 26.0, 22.0];
    final scaleFactor = cardHeight / 112.0;

    return AppCard(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      borderRadius: BorderRadius.circular(18.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.04),
          blurRadius: 10.0,
          offset: const Offset(0, 3),
        ),
      ],
      onTap: onSleepTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          CardSectionHeader(
            title: 'Sleep',
            iconSvg: AppIcons.sleepZ,
            iconColor: AppColors.purpleMetric,
            iconSize: 15.0,
            titleFontSize: r.font(12.0),
            actionText: 'Today',
            actionFontSize: r.font(10.0),
          ),

          // Content Row: Value on left (Expanded), 7 mini-bars on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Metric value + label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$sleepHours',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(20.0),
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          'hr',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Well-rested',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Right: 7-day mini bars matching Figma
              SizedBox(
                width: chartWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final barHeight =
                        (baseHeights[i % baseHeights.length] * scaleFactor)
                            .clamp(12.0, 32.0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: sleepBarWidth,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: AppColors.purpleMetric.withValues(
                              alpha: i == 5 ? 0.9 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          _weekdays[i],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(9.0),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
