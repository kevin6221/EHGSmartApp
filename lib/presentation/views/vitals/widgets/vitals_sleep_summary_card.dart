import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/vitals_model.dart';
import '../../../widgets/charts/hypnogram_chart.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing the user's previous night sleep summary and hypnogram chart.
class VitalsSleepSummaryCard extends StatelessWidget {
  final String totalSleep;
  final String sleepWindow;
  final List<SleepInterval> sleepIntervals;
  final VoidCallback? onTap;

  const VitalsSleepSummaryCard({
    super.key,
    required this.totalSleep,
    required this.sleepWindow,
    required this.sleepIntervals,
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
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppSvgIcon(
                    AppIcons.sleep,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Last night Sleep Summary',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: r.font(14),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  totalSleep,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: r.font(18),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  sleepWindow,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: r.font(11),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HypnogramChart(intervals: sleepIntervals),
        ],
      ),
    );
  }
}
