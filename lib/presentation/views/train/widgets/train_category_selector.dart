import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/workout_model.dart';
import '../../../helpers/category_selector_calculator.dart';
import '../../../widgets/common/app_card.dart';

/// Horizontal pill category selector for workout types (Run, Walk, Cycling, Strength, Hit).
/// Exact match to Figma Node 75:2570 with continuous track line and sliding active indicator.
class TrainCategorySelector extends StatelessWidget {
  final WorkoutType currentCategory;
  final ValueChanged<WorkoutType> onCategorySelected;

  const TrainCategorySelector({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> _categories = [
    {'type': WorkoutType.run, 'name': 'Run'},
    {'type': WorkoutType.walk, 'name': 'Walk'},
    {'type': WorkoutType.cycling, 'name': 'Cycling'},
    {'type': WorkoutType.strength, 'name': 'Strength'},
    {'type': WorkoutType.hit, 'name': 'Hit'},
  ];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final activeIndex = _categories.indexWhere(
      (c) => c['type'] == currentCategory,
    ).clamp(0, _categories.length - 1);

    final textStyle = GoogleFonts.plusJakartaSans(
      fontSize: r.font(14.0),
      fontWeight: FontWeight.w600,
    );

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: (r.height * 0.016).clamp(13.0, 16.0),
      ),
      borderRadius: BorderRadius.circular(12.0),
      border: const Border.fromBorderSide(BorderSide.none),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final categoryNames = _categories.map((c) => c['name'] as String).toList();
          final layout = CategorySelectorCalculator.calculate(
            categories: categoryNames,
            selectedIndex: activeIndex,
            totalWidth: totalWidth,
            textStyle: textStyle,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Tab Labels & Interactive Tap Zones
              SizedBox(
                height: 32.0,
                child: Stack(
                  children: _categories.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final type = cat['type'] as WorkoutType;
                    final name = cat['name'] as String;
                    final isSelected = type == currentCategory;
                    final tabLayout = layout.tabs[i];

                    return Positioned(
                      left: tabLayout.tapLeft,
                      width: tabLayout.tapWidth,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => onCategorySelected(type),
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: tabLayout.textLeft - tabLayout.tapLeft,
                              width: tabLayout.textWidth,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: OverflowBox(
                                    minWidth: 0.0,
                                    maxWidth: double.infinity,
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      softWrap: false,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: isSelected
                                            ? AppColors.primary
                                            : context.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: r.font(14.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 2. Underline Track with Smooth Animated Active Bar (Figma Line 10 & Line 9)
              SizedBox(
                height: 2.0,
                width: totalWidth,
                child: Stack(
                  children: [
                    // Continuous subtle background track line
                    Container(
                      height: 2.0,
                      width: totalWidth,
                      color: AppColors.primary.withValues(alpha: 0.10),
                    ),

                    // Sliding active blue indicator (starts at 0.0 at start, reaches totalWidth at end)
                    AnimatedPositioned(
                      duration: AppDurations.tabSwitch,
                      curve: AppCurves.standard,
                      left: layout.activeIndicatorLeft,
                      top: 0,
                      width: layout.indicatorWidth,
                      height: 2.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
