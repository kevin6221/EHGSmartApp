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
  final ValueChanged<DateTime>? onDateSelected;

  const VitalsDateNavigator({
    super.key,
    required this.dateNotifier,
    required this.periodNotifier,
    required this.onPrevious,
    required this.onNext,
    this.onDateSelected,
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

            final bool canGoNext;
            final bool canGoPrevious;

            if (period == VitalsTimePeriod.week) {
              final currentMonday = today.subtract(Duration(days: today.weekday - 1));
              final targetMonday = target.subtract(Duration(days: target.weekday - 1));
              canGoNext = targetMonday.isBefore(currentMonday);
              canGoPrevious = targetMonday.isAfter(today.subtract(const Duration(days: 90)));
            } else if (period == VitalsTimePeriod.month) {
              final currentMonth = DateTime(today.year, today.month, 1);
              final targetMonth = DateTime(target.year, target.month, 1);
              canGoNext = targetMonth.isBefore(currentMonth);
              canGoPrevious = targetMonth.isAfter(today.subtract(const Duration(days: 180)));
            } else {
              canGoNext = target.isBefore(today);
              canGoPrevious = target.isAfter(today.subtract(const Duration(days: 30)));
            }

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

                // Selected Date / Period Title (Clickable Date Picker)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: target.isAfter(today) ? today : target,
                        firstDate: today.subtract(const Duration(days: 90)),
                        lastDate: today,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: AppColors.white,
                                surface: AppColors.cardBackground,
                                onSurface: AppColors.textPrimary,
                              ),
                              dialogTheme: const DialogThemeData(
                                backgroundColor: AppColors.cardBackground,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        final pickedDate = DateTime(picked.year, picked.month, picked.day);
                        dateNotifier.value = pickedDate;
                        onDateSelected?.call(pickedDate);
                      }
                    },
                    borderRadius: BorderRadius.circular(10.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: (r.width * 0.038).clamp(14.0, 16.0),
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(14.5),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: isEnabled ? 0.22 : 0.08),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20.0,
            color: isEnabled
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
