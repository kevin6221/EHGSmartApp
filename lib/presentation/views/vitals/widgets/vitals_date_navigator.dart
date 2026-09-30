import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_history_calculator.dart';

/// Interactive date navigation bar with back/forward paging matching QWatch Pro and Whoop.
class VitalsDateNavigator extends StatelessWidget {
  final ValueNotifier<DateTime> dateNotifier;
  final ValueNotifier<VitalsTimePeriod> periodNotifier;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const VitalsDateNavigator({
    super.key,
    required this.dateNotifier,
    required this.periodNotifier,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ValueListenableBuilder<VitalsTimePeriod>(
      valueListenable: periodNotifier,
      builder: (context, period, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: dateNotifier,
          builder: (context, date, _) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final target = DateTime(date.year, date.month, date.day);
            final bool canGoNext = target.isBefore(today);
            final bool canGoPrevious = target.isAfter(today.subtract(const Duration(days: 30)));

            final label = VitalsPeriodStats.computeDateLabel(period, target, today);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Previous Date Arrow Button (<)
                _buildArrowButton(
                  context,
                  icon: Icons.chevron_left_rounded,
                  isEnabled: canGoPrevious,
                  onTap: onPrevious,
                  r: r,
                ),

                // Selected Date / Period Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: (r.width * 0.038).clamp(14.0, 16.0),
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),

                // Next Date Arrow Button (>)
                _buildArrowButton(
                  context,
                  icon: Icons.chevron_right_rounded,
                  isEnabled: canGoNext,
                  onTap: onNext,
                  r: r,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildArrowButton(
    BuildContext context, {
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required Responsive r,
  }) {
    final dim = (r.width * 0.088).clamp(32.0, 38.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: dim,
          height: dim,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.white.withValues(alpha: 0.18)
                : AppColors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withValues(alpha: isEnabled ? 0.28 : 0.12),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20.0,
            color: isEnabled
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
