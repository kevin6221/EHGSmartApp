import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/workout_model.dart';
import '../../../widgets/common/app_card.dart';

/// Horizontal pill category selector for workout types (Run, Walk, Cycling, Strength, Hit).
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
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((cat) {
          final type = cat['type'] as WorkoutType;
          final name = cat['name'] as String;
          final isSelected = type == currentCategory;

          return Expanded(
            child: GestureDetector(
              onTap: () => onCategorySelected(type),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Text(
                    name,
                    style: AppTypography.titleMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.5,
                    width: isSelected ? 32 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
