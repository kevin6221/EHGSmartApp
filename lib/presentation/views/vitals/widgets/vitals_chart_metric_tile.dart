import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../widgets/common/app_card.dart';

/// Reusable metric tile for Vitals screen showing an icon, value, unit, status, and side chart.
class VitalsChartMetricTile extends StatelessWidget {
  final String? svgIcon;
  final IconData? iconData;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final String status;
  final Widget chart;
  final bool showWeekdays;
  final VoidCallback? onTap;

  const VitalsChartMetricTile({
    super.key,
    this.svgIcon,
    this.iconData,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.chart,
    this.showWeekdays = true,
    this.onTap,
  }) : assert(
         svgIcon != null || iconData != null,
         'Either svgIcon or iconData must be provided',
       );

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (svgIcon != null)
                      AppSvgIcon(svgIcon!, size: 16, color: iconColor)
                    else
                      Icon(iconData, size: 16, color: iconColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: AppTypography.metricValue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(unit, style: AppTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                chart,
                if (showWeekdays) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekdays
                        .map(
                          (d) => Text(
                            d,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 8,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
