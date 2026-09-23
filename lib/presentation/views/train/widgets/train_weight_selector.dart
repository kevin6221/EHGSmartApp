import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/user_profile_model.dart';

/// Weight selector row for calorie calculations (60kg, 70kg, 80kg, 90kg or lb equivalents).
/// Exact match to Figma Node 75:2658.
class TrainWeightSelector extends StatelessWidget {
  final int currentWeight;
  final UnitSystem unitSystem;
  final ValueChanged<int> onWeightSelected;

  const TrainWeightSelector({
    super.key,
    required this.currentWeight,
    this.unitSystem = UnitSystem.metric,
    required this.onWeightSelected,
  });

  static const List<int> _weights = [60, 70, 80, 90];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final pillHeight = (r.height * 0.048).clamp(36.0, 42.0);
    final isImperial = unitSystem == UnitSystem.imperial;

    return Row(
      children: _weights.map((w) {
        final isSelected = w == currentWeight;
        final label = isImperial ? '${(w * 2.20462).round()}lb' : '${w}kg';

        return Expanded(
          child: GestureDetector(
            onTap: () => onWeightSelected(w),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: pillHeight,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.trainWeightSelectedBg
                    : AppColors.trainWeightUnselectedBg,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: r.font(14.0),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
