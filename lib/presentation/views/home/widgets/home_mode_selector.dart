import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/wellness_data_model.dart';

/// Precomputed geometry for HomeModeSelector sliding indicator.
class ModeSelectorGeometry {
  final double tabWidth;
  final double indicatorWidth;
  final double indicatorLeft;
  final double inset;

  const ModeSelectorGeometry({
    required this.tabWidth,
    required this.indicatorWidth,
    required this.indicatorLeft,
    required this.inset,
  });

  factory ModeSelectorGeometry.compute({
    required double totalWidth,
    required int tabCount,
    required int activeIndex,
  }) {
    final double tabWidth = tabCount > 0 ? totalWidth / tabCount : totalWidth;
    final double indicatorWidth = tabWidth * 0.98;
    final double inset = (tabWidth - indicatorWidth) / 2.0;
    final double indicatorLeft = (activeIndex * tabWidth) + inset;

    return ModeSelectorGeometry(
      tabWidth: tabWidth,
      indicatorWidth: indicatorWidth,
      indicatorLeft: indicatorLeft,
      inset: inset,
    );
  }
}

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
    final r = context.responsive;
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
                child: Container(
                  height: (r.height * 0.045).clamp(36.0, 44.0),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: r.font(14.0),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4.0),
        LayoutBuilder(
          builder: (context, constraints) {
            final geo = ModeSelectorGeometry.compute(
              totalWidth: constraints.maxWidth,
              tabCount: _modes.length,
              activeIndex: effectiveIndex,
            );

            return SizedBox(
              height: 2.0,
              child: Stack(
                children: [
                  // Full background track divider
                  Positioned(
                    left: geo.inset,
                    right: geo.inset,
                    top: 0,
                    child: Container(
                      height: 2.0,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),

                  // Blue active indicator
                  AnimatedPositioned(
                    duration: AppDurations.medium,
                    curve: AppCurves.standard,
                    left: geo.indicatorLeft,
                    width: geo.indicatorWidth,
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
            );
          },
        ),
      ],
    );
  }
}
