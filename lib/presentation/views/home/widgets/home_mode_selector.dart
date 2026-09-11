import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/wellness_data_model.dart';

/// Tab bar selector for wellness modes: Recover, Steady, Push.
/// Features a continuous baseline divider with a sliding active indicator bar matching Figma specs.
class HomeModeSelector extends StatelessWidget {
  final WellnessMode currentMode;
  final ValueChanged<WellnessMode> onModeChanged;

  const HomeModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  static const List<Map<String, dynamic>> _modes = [
    {'label': 'Recover', 'mode': WellnessMode.recover},
    {'label': 'Steady', 'mode': WellnessMode.steady},
    {'label': 'Push', 'mode': WellnessMode.push},
  ];

  @override
  Widget build(BuildContext context) {
    final int activeIndex = _modes.indexWhere((m) => m['mode'] == currentMode);
    final effectiveIndex = activeIndex >= 0 ? activeIndex : 0;

    return Column(
      children: [
        // Tab labels row
        Row(
          children: _modes.map((m) {
            final mode = m['mode'] as WellnessMode;
            final label = m['label'] as String;
            final isSelected = mode == currentMode;

            return Expanded(
              child: GestureDetector(
                onTap: () => onModeChanged(mode),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF4B5563),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4.0),

        // Baseline divider with sliding active indicator
        LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final double tabWidth = totalWidth / _modes.length;
            final double indicatorWidth = tabWidth * 0.85;

            return Stack(
              children: [
                // Full width baseline (Line 10 in Figma)
                Container(
                  width: totalWidth,
                  height: 2.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),

                // Animated Active Indicator (Line 9 in Figma)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: effectiveIndex * tabWidth +
                      ((tabWidth - indicatorWidth) / 2),
                  width: indicatorWidth,
                  height: 2.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
