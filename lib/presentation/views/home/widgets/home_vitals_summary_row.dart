import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Horizontal carousel displaying Heart Rate and Sleep quick-glance metric cards.
/// Fixed dimensions (width: 258.75, height: 105) matching Figma node 118:917 specs.
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
    const double cardWidth = 258.75;
    const double cardHeight = 105.0;

    return SizedBox(
      height: cardHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            // 1. Heart Rate Card
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildHeartRateCard(),
            ),
            const SizedBox(width: 12.0),

            // 2. Sleep Card
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildSleepCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      borderRadius: BorderRadius.circular(18.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
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
          const CardSectionHeader(
            title: 'Heart Rate',
            iconSvg: AppIcons.vitals,
            iconColor: AppColors.primary,
            iconSize: 15.0,
            titleFontSize: 12.0,
            actionText: 'Today',
            actionFontSize: 10.0,
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
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          'bpm',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.0,
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
                        fontSize: 11.0,
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
                width: 95.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SparklineChart(
                      values: weeklyHeartRate,
                      lineColor: AppColors.primary,
                      height: 24.0,
                      width: 95.0,
                      strokeWidth: 1.5,
                      showFill: false,
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekdays
                          .map(
                            (d) => Text(
                              d,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.0,
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

  Widget _buildSleepCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      borderRadius: BorderRadius.circular(18.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
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
          const CardSectionHeader(
            title: 'Sleep',
            iconSvg: AppIcons.sleep,
            iconColor: AppColors.purpleMetric,
            iconSize: 15.0,
            titleFontSize: 12.0,
            actionText: 'Today',
            actionFontSize: 10.0,
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
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          'hr',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.0,
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
                        fontSize: 11.0,
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
                width: 95.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final heights = [18.0, 22.0, 16.0, 24.0, 20.0, 26.0, 22.0];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.0,
                          height: heights[i % heights.length],
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
                            fontSize: 9.0,
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
