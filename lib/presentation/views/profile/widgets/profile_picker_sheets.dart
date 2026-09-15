import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/user_profile_model.dart';

/// Shows an interactive bottom sheet for selecting user age.
Future<void> showAgePickerSheet(
  BuildContext context, {
  required int initialAge,
  required ValueChanged<int> onConfirmed,
}) {
  const int minAge = 10;
  const int maxAge = 100;
  const double itemExtent = 44.0;

  final initialIndex = (initialAge - minAge).clamp(0, maxAge - minAge);
  final scrollController = FixedExtentScrollController(initialItem: initialIndex);
  final selectedNotifier = ValueNotifier<int>(initialAge);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Container(
          height: 310.0,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8.0),
              // Grab handle
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              // Navigation toolbar with Cancel, Title, Done
              SizedBox(
                height: 48.0,
                child: NavigationToolbar(
                  leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.tertiary,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  middle: Text(
                    'Select Age',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      onConfirmed(selectedNotifier.value);
                      Navigator.of(ctx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        'Done',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1.0, color: AppColors.border),

              // Wheel Scroll View
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center selection indicator
                    Container(
                      height: itemExtent,
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: AppColors.profileInputFill,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      controller: scrollController,
                      itemExtent: itemExtent,
                      perspective: 0.003,
                      diameterRatio: 2.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        final newAge = index + minAge;
                        selectedNotifier.value = newAge;
                        HapticFeedback.selectionClick();
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: maxAge - minAge + 1,
                        builder: (context, index) {
                          final age = index + minAge;
                          return ValueListenableBuilder<int>(
                            valueListenable: selectedNotifier,
                            builder: (context, current, _) {
                              final isSelected = age == current;
                              final distance = (age - current).abs();

                              double fontSize = 14.0;
                              FontWeight fontWeight = FontWeight.w400;
                              Color color = AppColors.tertiary;

                              if (isSelected) {
                                fontSize = 20.0;
                                fontWeight = FontWeight.w600;
                                color = AppColors.primary;
                              } else if (distance == 1) {
                                fontSize = 16.0;
                                fontWeight = FontWeight.w500;
                                color = AppColors.secondary;
                              }

                              return Center(
                                child: Text(
                                  '$age',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: fontSize,
                                    fontWeight: fontWeight,
                                    color: color,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows an interactive bottom sheet for selecting user weight.
Future<void> showWeightPickerSheet(
  BuildContext context, {
  required int initialWeight,
  required UnitSystem unitSystem,
  required ValueChanged<int> onConfirmed,
}) {
  final bool isMetric = unitSystem == UnitSystem.metric;
  final int minWeight = isMetric ? 30 : 66;
  final int maxWeight = isMetric ? 200 : 440;
  final String unitLabel = isMetric ? 'kg' : 'lbs';
  const double itemExtent = 44.0;

  final initialIndex = (initialWeight - minWeight).clamp(0, maxWeight - minWeight);
  final scrollController = FixedExtentScrollController(initialItem: initialIndex);
  final selectedNotifier = ValueNotifier<int>(initialWeight);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Container(
          height: 310.0,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8.0),
              // Grab handle
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              // Navigation toolbar with Cancel, Title, Done
              SizedBox(
                height: 48.0,
                child: NavigationToolbar(
                  leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.tertiary,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  middle: Text(
                    'Select Weight',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      onConfirmed(selectedNotifier.value);
                      Navigator.of(ctx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        'Done',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1.0, color: AppColors.border),

              // Wheel Scroll View
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center selection indicator
                    Container(
                      height: itemExtent,
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: AppColors.profileInputFill,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      controller: scrollController,
                      itemExtent: itemExtent,
                      perspective: 0.003,
                      diameterRatio: 2.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        final newWeight = index + minWeight;
                        selectedNotifier.value = newWeight;
                        HapticFeedback.selectionClick();
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: maxWeight - minWeight + 1,
                        builder: (context, index) {
                          final weight = index + minWeight;
                          return ValueListenableBuilder<int>(
                            valueListenable: selectedNotifier,
                            builder: (context, current, _) {
                              final isSelected = weight == current;
                              final distance = (weight - current).abs();

                              double fontSize = 14.0;
                              FontWeight fontWeight = FontWeight.w400;
                              Color color = AppColors.tertiary;

                              if (isSelected) {
                                fontSize = 20.0;
                                fontWeight = FontWeight.w600;
                                color = AppColors.primary;
                              } else if (distance == 1) {
                                fontSize = 16.0;
                                fontWeight = FontWeight.w500;
                                color = AppColors.secondary;
                              }

                              return Center(
                                child: Text(
                                  '$weight $unitLabel',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: fontSize,
                                    fontWeight: fontWeight,
                                    color: color,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      );
    },
  );
}
