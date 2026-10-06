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
  final WellnessMode recommendedMode;
  final String? recommendationExplanation;
  final ValueChanged<WellnessMode> onModeChanged;

  const HomeModeSelector({
    super.key,
    required this.currentMode,
    this.recommendedMode = WellnessMode.steady,
    this.recommendationExplanation,
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
                onTap: () {
                  if (mode != currentMode) {
                    onModeChanged(mode);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: (r.height * 0.045).clamp(36.0, 44.0),
                  alignment: Alignment.center,
                  child: Text(
                    label,
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
        if (recommendationExplanation != null && recommendationExplanation!.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
            decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.midnightSurface
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 11.0,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'RECOMMENDED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(9.5),
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${recommendedMode.name[0].toUpperCase()}${recommendedMode.name.substring(1)} Guidance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.5),
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7.0),
                Text(
                  recommendationExplanation!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
