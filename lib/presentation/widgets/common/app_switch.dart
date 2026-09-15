import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A pixel-perfect animated toggle switch replicating Figma Nodes 82:2985 - 82:3000.
///
/// States:
/// - Enabled (ON): Solid primary blue (#3E83C8) track with a pure white circular thumb on the right.
/// - Disabled (OFF): Pure white (#FFFFFF) track with a subtle outline border (#CBD5E1 / rgba(0.29, 0.33, 0.39, 0.3))
///   and a slate-grey (#B7BBC1) circular thumb on the left.
///
/// Features:
/// - Strictly stateless (no `setState()`), reactive with BLoC / parent state.
/// - Smooth animated transitions (`Duration(milliseconds: 200)`).
/// - Accessible tap target with padded gesture detection.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final double thumbSize;
  final Duration duration;
  final Curve curve;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 30.0,
    this.height = 16.0,
    this.thumbSize = 14.0,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onChanged != null;

    return Semantics(
      toggled: value,
      enabled: isInteractive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isInteractive ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(height),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.profileSwitchBorder,
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.2),
              child: AnimatedAlign(
                duration: duration,
                curve: curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value
                        ? AppColors.white
                        : AppColors.profileSwitchThumbInactive,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
