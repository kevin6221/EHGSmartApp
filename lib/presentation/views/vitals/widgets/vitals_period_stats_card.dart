import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_history_calculator.dart';
import '../../../widgets/common/app_card.dart';

/// Card displaying Min / Avg / Max period statistics and the 4-zone
/// "Relax / Normal / Medium / High" percentage distribution from QWatch Pro / Garmin.
class VitalsPeriodStatsCard extends StatelessWidget {
  final VitalsPeriodStats stats;
  final bool isLoading;

  const VitalsPeriodStatsCard({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dist = stats.distribution;

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: (r.width * 0.042).clamp(14.0, 18.0),
        vertical: (r.height * 0.016).clamp(12.0, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Period Title & Granularity Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Period Overview',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  isLoading
                      ? 'Syncing...'
                      : (stats.period == VitalsTimePeriod.day
                          ? 'Hourly Granularity'
                          : stats.period == VitalsTimePeriod.week
                              ? 'Daily Rollup'
                              : 'Monthly Trend'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(11.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // 2. Average / Min / Max 3-Column Stat Badges
          Row(
            children: [
              _buildStatBadge(
                context,
                label: 'Average',
                value: isLoading ? '...' : (stats.average > 0 ? '${stats.average.round()}' : '--'),
                unit: (!isLoading && stats.average > 0) ? stats.unit : '',
                color: AppColors.primary,
                r: r,
              ),
              const SizedBox(width: 8.0),
              _buildStatBadge(
                context,
                label: 'Minimum',
                value: isLoading ? '...' : (stats.minimum > 0 ? '${stats.minimum.round()}' : '--'),
                unit: (!isLoading && stats.minimum > 0) ? stats.unit : '',
                color: AppColors.cyanAccent,
                r: r,
              ),
              const SizedBox(width: 8.0),
              _buildStatBadge(
                context,
                label: 'Maximum',
                value: isLoading ? '...' : (stats.maximum > 0 ? '${stats.maximum.round()}' : '--'),
                unit: (!isLoading && stats.maximum > 0) ? stats.unit : '',
                color: AppColors.orangeMetric,
                r: r,
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // 3. Section Title: Zone Distribution
          Text(
            'Zone Distribution',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),

          // 4. Multi-Segment Horizontal Stacked Bar (QWatch Pro Reference)
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: SizedBox(
              height: 12.0,
              child: Row(
                children: [
                  if (dist.relaxPct + dist.normalPct + dist.mediumPct + dist.highPct == 0)
                    Expanded(
                      child: Container(
                        color: context.cardBorder.withValues(alpha: 0.5),
                      ),
                    ),
                  if (dist.relaxPct > 0)
                    Expanded(
                      flex: (dist.relaxPct * 10).round().clamp(1, 1000),
                      child: Container(color: AppColors.qwatchStressRelax),
                    ),
                  if (dist.normalPct > 0)
                    Expanded(
                      flex: (dist.normalPct * 10).round().clamp(1, 1000),
                      child: Container(color: AppColors.qwatchStressNormal),
                    ),
                  if (dist.mediumPct > 0)
                    Expanded(
                      flex: (dist.mediumPct * 10).round().clamp(1, 1000),
                      child: Container(color: AppColors.qwatchStressMedium),
                    ),
                  if (dist.highPct > 0)
                    Expanded(
                      flex: (dist.highPct * 10).round().clamp(1, 1000),
                      child: Container(color: AppColors.qwatchStressHigh),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // 5. 4-Zone Legend matching QWatch Pro (Relax, Normal, Medium, High)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendDot(
                color: AppColors.qwatchStressRelax,
                label: 'Relax',
                percentage: '${dist.relaxPct.round()}%',
                context: context,
                r: r,
              ),
              _buildLegendDot(
                color: AppColors.qwatchStressNormal,
                label: 'Normal',
                percentage: '${dist.normalPct.round()}%',
                context: context,
                r: r,
              ),
              _buildLegendDot(
                color: AppColors.qwatchStressMedium,
                label: 'Medium',
                percentage: '${dist.mediumPct.round()}%',
                context: context,
                r: r,
              ),
              _buildLegendDot(
                color: AppColors.qwatchStressHigh,
                label: 'High',
                percentage: '${dist.highPct.round()}%',
                context: context,
                r: r,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Responsive r,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: context.isDark
              ? AppColors.midnightSurface
              : AppColors.systemCardBgLight,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: context.cardBorder,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(11.0),
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(17.0),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3.0),
                Text(
                  unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.5),
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot({
    required Color color,
    required String label,
    required String percentage,
    required BuildContext context,
    required Responsive r,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5.0),
        Text(
          '$label $percentage',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(11.0),
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
