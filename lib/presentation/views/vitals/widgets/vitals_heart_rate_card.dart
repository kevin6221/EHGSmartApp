import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing current heart rate and a 7-day sparkline trend chart.
class VitalsHeartRateCard extends StatelessWidget {
  final int currentHeartRate;
  final List<double> weeklyHeartRate;
  final VoidCallback? onTap;

  const VitalsHeartRateCard({
    super.key,
    required this.currentHeartRate,
    required this.weeklyHeartRate,
    this.onTap,
  });

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 12.0 : 18.0),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const AppSvgIcon(
                      AppIcons.vitals,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Heart Rate',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: r.font(15),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$currentHeartRate',
                    style: AppTypography.metricValue.copyWith(
                      color: AppColors.primary,
                      fontSize: r.font(24),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'bpm',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SparklineChart(
            values: weeklyHeartRate,
            lineColor: AppColors.primary,
            height: 70,
            width: double.infinity,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekdays
                .map(
                  (d) => Text(
                    d,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
