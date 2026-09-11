import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import '../../../widgets/common/app_card.dart';

/// Row containing the twin trend cards: Blood Pressure Trend and Skin Temperature.
class VitalsTwinTrendCards extends StatelessWidget {
  final String bloodPressure;
  final double skinTempDiff;
  final VoidCallback? onBloodPressureTap;
  final VoidCallback? onSkinTempTap;

  const VitalsTwinTrendCards({
    super.key,
    required this.bloodPressure,
    required this.skinTempDiff,
    this.onBloodPressureTap,
    this.onSkinTempTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final spacing = (r.width * 0.035).clamp(8.0, 16.0);

    return Row(
      children: [
        Expanded(
          child: _buildTrendCard(
            title: 'Blood pressure trend',
            value: bloodPressure,
            icon: Icons.arrow_upward_rounded,
            iconColor: AppColors.primary,
            waveColor: AppColors.primary,
            onTap: onBloodPressureTap,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildTrendCard(
            title: 'Skin temperature',
            value: '$skinTempDiff°C',
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.energy,
            waveColor: AppColors.energy,
            onTap: onSkinTempTap,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color waveColor,
    VoidCallback? onTap,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SparklineChart(
            values: const [10, 14, 11, 16, 12, 18, 15],
            lineColor: waveColor,
            height: 28,
            width: double.infinity,
            showFill: false,
          ),
        ],
      ),
    );
  }
}
