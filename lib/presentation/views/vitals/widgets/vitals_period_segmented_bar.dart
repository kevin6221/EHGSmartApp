import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_history_calculator.dart';

/// Segmented tab bar for Day / Week / Month historical browsing matching QWatch Pro & Garmin.
class VitalsPeriodSegmentedBar extends StatelessWidget {
  final ValueNotifier<VitalsTimePeriod> periodNotifier;
  final ValueChanged<VitalsTimePeriod>? onPeriodChanged;

  const VitalsPeriodSegmentedBar({
    super.key,
    required this.periodNotifier,
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ValueListenableBuilder<VitalsTimePeriod>(
      valueListenable: periodNotifier,
      builder: (context, currentPeriod, _) {
        return Container(
          height: (r.height * 0.046).clamp(36.0, 42.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.midnightSurface
                : AppColors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              _buildSegment(
                context,
                period: VitalsTimePeriod.day,
                label: 'Day',
                isSelected: currentPeriod == VitalsTimePeriod.day,
                r: r,
              ),
              _buildSegment(
                context,
                period: VitalsTimePeriod.week,
                label: 'Week',
                isSelected: currentPeriod == VitalsTimePeriod.week,
                r: r,
              ),
              _buildSegment(
                context,
                period: VitalsTimePeriod.month,
                label: 'Month',
                isSelected: currentPeriod == VitalsTimePeriod.month,
                r: r,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required VitalsTimePeriod period,
    required String label,
    required bool isSelected,
    required Responsive r,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (periodNotifier.value != period) {
            periodNotifier.value = period;
            onPeriodChanged?.call(period);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (context.isDark ? AppColors.primary : AppColors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.shadowNavy.withValues(alpha: 0.12),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (context.isDark ? AppColors.white : AppColors.primary)
                  : (context.isDark
                      ? context.textSecondary
                      : AppColors.white.withValues(alpha: 0.85)),
            ),
          ),
        ),
      ),
    );
  }
}
