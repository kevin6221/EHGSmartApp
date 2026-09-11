import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/vitals_model.dart';
import '../painters/hypnogram_painter.dart';

/// Clean UI widget displaying the sleep hypnogram stages and timeline.
class HypnogramChart extends StatelessWidget {
  final List<SleepInterval> intervals;

  const HypnogramChart({super.key, required this.intervals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legend row
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendItem(color: Color(0xFF1E60C8), label: 'Deep'),
            _LegendItem(color: Color(0xFF38BDF8), label: 'Light'),
            _LegendItem(color: Color(0xFF4ADE80), label: 'REM'),
            _LegendItem(color: Color(0xFFF43F5E), label: 'Awake'),
          ],
        ),
        const SizedBox(height: 18),

        // Hypnogram display with Y-axis labels and tooltip
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  // Y-axis Phase labels
                  SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deep',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'REM',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Light',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Awake',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chart Area
                  Expanded(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(double.infinity, 140),
                        painter: HypnogramPainter(intervals: intervals),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tooltip Popup overlay: "01:05 pm → 03:33 pm \n 2h 28m"
            Positioned(
              top: 0,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '01:05 pm → 03:33 pm',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2h 28m',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
