import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing current stress status, score indicator bubble, and timeline chart.
class VitalsStressCard extends StatelessWidget {
  final int stressScore;
  final String stressStatus;
  final List<double> stressTimeline;
  final VoidCallback? onTap;

  const VitalsStressCard({
    super.key,
    required this.stressScore,
    required this.stressStatus,
    required this.stressTimeline,
    this.onTap,
  });

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
                      AppIcons.stress,
                      size: 18,
                      color: AppColors.energy,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Stress',
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stressStatus,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              SparklineChart(
                values: stressTimeline,
                lineColor: AppColors.energy,
                height: 85,
                width: double.infinity,
              ),
              Positioned(
                right: 20,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.energy.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    '$stressScore',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.energy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
