import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Weight selector row for calorie calculations (60kg, 70kg, 80kg, 90kg).
class TrainWeightSelector extends StatelessWidget {
  final int currentWeight;
  final ValueChanged<int> onWeightSelected;

  const TrainWeightSelector({
    super.key,
    required this.currentWeight,
    required this.onWeightSelected,
  });

  static const List<int> _weights = [60, 70, 80, 90];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _weights.map((w) {
        final isSelected = w == currentWeight;
        return Expanded(
          child: GestureDetector(
            onTap: () => onWeightSelected(w),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F172A)
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${w}kg',
                style: AppTypography.titleMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
