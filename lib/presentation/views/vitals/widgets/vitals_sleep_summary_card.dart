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

    final iconBoxDim = (r.width * 0.082).clamp(28.0, 36.0);
    final iconSize = (iconBoxDim * 0.5).clamp(14.0, 18.0);

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 12.0 : 18.0),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.04),
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
                width: iconBoxDim,
                height: iconBoxDim,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.vitalsSleepIcon,
                ),
                child: AppSvgIcon(
                  AppIcons.sleepZ,
                  color: AppColors.white,
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Last night Sleep Summary',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: r.font(16),
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
                    fontSize: r.font(14),
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
