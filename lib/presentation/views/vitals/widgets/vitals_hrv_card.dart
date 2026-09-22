import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import 'vitals_expandable_metric_card.dart';

/// Expandable Heart Rate Variability card per Figma Node 71:886 and 119:1442.
///
/// Clean, effect-free butter-smooth accordion transition without background flash.
class VitalsHrvCard extends StatelessWidget {
  final int hrvMs;
  final String status;
  final List<double> weeklyHrv;
  final ValueNotifier<bool>? isExpandedNotifier;
  final VoidCallback? onExpandChanged;
  final VoidCallback? onTap;

  const VitalsHrvCard({
    super.key,
    required this.hrvMs,
    this.status = 'Below your usual',
    required this.weeklyHrv,
    this.isExpandedNotifier,
    this.onExpandChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VitalsExpandableMetricCard(
      svgIcon: AppIcons.heartPulse,
      iconColor: AppColors.primary,
      title: 'Heart Rate Variability',
      value: hrvMs > 0 ? '$hrvMs' : '--',
      unit: 'ms',
      status: hrvMs > 0 ? status : '--',
      isExpandedNotifier: isExpandedNotifier,
      onExpandChanged: onExpandChanged,
      onTap: onTap,
      chart: SparklineChart(
        values: weeklyHrv,
        lineColor: AppColors.primary,
        height: 40.0,
        width: double.infinity,
        showFill: true,
        strokeWidth: 2.0,
      ),
      showWeekdays: true,
      whatItIs:
          'The gap between heartbeats varies slightly. More variation means your nervous system is switching easily between effort and rest.',
      yourReading:
          "Below your 30-day average. Something is still costing you — short sleep, hard training, alcohol, or stress that hasn't cleared.",
      doThis: 'Keep today easy and aerobic. Push tomorrow instead.',
    );
  }
}
