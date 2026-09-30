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
  final bool isLive;
  final int restingRate;
  final List<double> weeklyHeartRate;
  final double sleepHours;
  final List<double> weeklySleep;
  final VoidCallback? onHeartRateTap;
  final VoidCallback? onSleepTap;

  const HomeVitalsSummaryRow({
    super.key,
    required this.heartRate,
    this.isLive = false,
    this.restingRate = 0,
    required this.weeklyHeartRate,
    required this.sleepHours,
    this.weeklySleep = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
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
              context,
              r,
              dims.chartWidth,
              dims.cardWidth,
              dims.cardHeight,
            ),
            SizedBox(width: dims.cardGap),

            // 2. Sleep Card
            _buildSleepCard(
              context,
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
    BuildContext context,
    Responsive r,
    double chartWidth,
    double cardWidth,
    double cardHeight,
  ) {
    final sparklineHeight = (cardHeight * 0.22).clamp(20.0, 28.0);
    final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);

    final String statusText;
    final Color statusColor;
    final bool showLiveDot;

    if (isLive && heartRate > 0) {
      statusText = 'Live';
      statusColor = AppColors.qwatchNormalGreen;
      showLiveDot = true;
    } else if (heartRate > 0) {
      if (heartRate > 100) {
        statusText = 'Elevated';
        statusColor = AppColors.orangeMetric;
      } else if (heartRate < 55) {
        statusText = 'Low';
        statusColor = AppColors.primary;
      } else {
        statusText = 'Normal';
        statusColor = AppColors.qwatchNormalGreen;
      }
      showLiveDot = false;
    } else if (restingRate > 0) {
      statusText = 'Resting Rate';
      statusColor = context.textSecondary;
      showLiveDot = false;
    } else {
      statusText = 'No reading';
      statusColor = context.textSecondary;
      showLiveDot = false;
    }

    final int displayBpm = heartRate > 0
        ? heartRate
        : (restingRate > 0 ? restingRate : 0);

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
                          displayBpm > 0 ? '$displayBpm' : '--',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(20.0),
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          'bpm',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w500,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showLiveDot) ...[
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.qwatchNormalGreen,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                        ],
                        Flexible(
                          child: Text(
                            statusText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(11.0),
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                      children: _weekdays.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        final isToday = i == todayIdx;
                        return Text(
                          d,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(9.0),
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? context.textPrimary : AppColors.textMuted,
                          ),
                        );
                      }).toList(),
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
    BuildContext context,
    Responsive r,
    double chartWidth,
    double sleepBarWidth,
    double cardWidth,
    double cardHeight,
  ) {
    final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
    final scaleFactor = cardHeight / 112.0;
    final maxChartHeight = (28.0 * scaleFactor).clamp(20.0, 32.0);

    final String sleepQuality;
    if (sleepHours >= 7.5) {
      sleepQuality = 'Well-rested';
    } else if (sleepHours >= 6.0) {
      sleepQuality = 'Normal sleep';
    } else if (sleepHours > 0) {
      sleepQuality = 'Short sleep';
    } else {
      sleepQuality = 'No sleep recorded';
    }

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
                          sleepHours > 0 ? '$sleepHours' : '--',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(20.0),
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          'hr',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w500,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      sleepQuality,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Right: 7-day mini bars matching hardware data dynamically
              SizedBox(
                width: chartWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final bool isToday = i == todayIdx;
                    final bool isPast = i < todayIdx;
                    final bool isFuture = i > todayIdx;

                    final double dayHours;
                    if (isToday) {
                      dayHours = sleepHours > 0
                          ? sleepHours
                          : (i < weeklySleep.length ? weeklySleep[i] : 0.0);
                    } else if (i < weeklySleep.length && weeklySleep[i] > 0) {
                      dayHours = weeklySleep[i];
                    } else {
                      dayHours = 0.0;
                    }

                    final double barHeight;
                    if (dayHours > 0) {
                      final double ratio = (dayHours / 8.0).clamp(0.20, 1.25);
                      barHeight = (ratio * maxChartHeight).clamp(8.0, maxChartHeight);
                    } else if (isToday) {
                      barHeight = sleepHours > 0
                          ? ((sleepHours / 8.0).clamp(0.20, 1.25) * maxChartHeight).clamp(8.0, maxChartHeight)
                          : 10.0;
                    } else if (isPast) {
                      barHeight = 10.0;
                    } else {
                      barHeight = 6.0;
                    }

                    final Color barColor;
                    if (isToday) {
                      barColor = AppColors.purpleMetric;
                    } else if (isPast) {
                      barColor = dayHours > 0
                          ? AppColors.purpleMetric.withValues(alpha: 0.55)
                          : AppColors.purpleMetric.withValues(alpha: 0.22);
                    } else {
                      barColor = AppColors.purpleMetric.withValues(alpha: 0.12);
                    }

                    final Color textColor = isToday
                        ? context.textPrimary
                        : (isFuture
                            ? AppColors.textMuted.withValues(alpha: 0.4)
                            : AppColors.textMuted);
                    final FontWeight textWeight =
                        isToday ? FontWeight.w700 : FontWeight.w500;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: sleepBarWidth,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          _weekdays[i],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(9.0),
                            fontWeight: textWeight,
                            color: textColor,
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
