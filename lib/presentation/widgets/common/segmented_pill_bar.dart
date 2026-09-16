import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

class SegmentedPillItem<T> {
  final T value;
  final String label;
  final String? iconPath;

  const SegmentedPillItem({
    required this.value,
    required this.label,
    this.iconPath,
  });
}

/// Generic, accessible horizontal segmented pill selector with smooth animated transitions.
class SegmentedPillBar<T> extends StatelessWidget {
  final List<SegmentedPillItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double height;
  final Color backgroundColor;
  final Gradient? activeGradient;
  final Color? activeColor;
  final Color inactiveTextColor;
  final Color activeTextColor;
  final EdgeInsetsGeometry padding;

  const SegmentedPillBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.height = 44.0,
    this.backgroundColor = AppColors.pillBarBg,
    this.activeGradient = AppGradients.primary,
    this.activeColor,
    this.inactiveTextColor = AppColors.textSecondary,
    this.activeTextColor = AppColors.white,
    this.padding = const EdgeInsets.all(4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.value),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                curve: AppCurves.standard,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((height - 8) / 2),
                  gradient: isSelected ? activeGradient : null,
                  color: isSelected && activeGradient == null
                      ? (activeColor ?? AppColors.primary)
                      : AppColors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (activeColor ?? AppColors.primary)
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.iconPath != null) ...[
                      AppSvgIcon(
                        item.iconPath!,
                        size: 16.0,
                        color: isSelected ? activeTextColor : inactiveTextColor,
                      ),
                      const SizedBox(width: 6.0),
                    ],
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.0,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? activeTextColor : inactiveTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
