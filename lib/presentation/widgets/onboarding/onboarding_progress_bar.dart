import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';

/// Top horizontal capsule segmented progress indicator for onboarding screens.
///
/// Features dynamic step resolution:
/// 1. If [currentStep] is explicitly provided, it is used.
/// 2. If [OnboardingCubit] exists in the widget tree, it dynamically listens to its state.
/// 3. Otherwise, it automatically infers the current step from the active [ModalRoute].
///
/// Also provides smooth animated fill transitions as the user navigates between steps.
class OnboardingProgressBar extends StatefulWidget {
  /// Explicit step override (1-indexed, e.g. 1 to 6).
  /// If null, the step is dynamically resolved from [OnboardingCubit] or the active route.
  final int? currentStep;

  /// Total number of capsule segments (default is 6).
  final int totalSteps;

  /// Height of the capsule bars (default is 4.0).
  final double height;

  /// Padding around the progress bar row.
  final EdgeInsetsGeometry padding;

  /// Duration of the progress fill animation.
  final Duration animationDuration;

  /// Curve of the progress fill animation.
  final Curve animationCurve;

  const OnboardingProgressBar({
    super.key,
    this.currentStep,
    this.totalSteps = 5,
    this.height = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.animationDuration = AppDurations.pageTransition,
    this.animationCurve = AppCurves.slideIn,
  });

  @override
  State<OnboardingProgressBar> createState() => _OnboardingProgressBarState();
}

class _OnboardingProgressBarState extends State<OnboardingProgressBar> {
  double? _lastProgress;

  int _resolveStep(BuildContext context) {
    if (widget.currentStep != null) {
      return widget.currentStep!.clamp(1, widget.totalSteps);
    }

    // 1. Try inferring from active route name (e.g. /onboarding-1, /onboarding-2, /onboarding-3)
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null) {
      if (routeName == AppRoutes.onboarding1) return 1;
      if (routeName == AppRoutes.onboarding2) return 2;
      if (routeName == AppRoutes.onboarding3) return 3;
      if (routeName == AppRoutes.onboarding4) return 4;
      if (routeName == AppRoutes.onboarding5) return 5;

      final match = RegExp(r'onboarding-?(\d+)').firstMatch(routeName);
      if (match != null) {
        final parsed = int.tryParse(match.group(1)!);
        if (parsed != null) return parsed.clamp(1, widget.totalSteps);
      }
    }

    // 2. Try reading from OnboardingCubit if available in tree
    try {
      final cubit = BlocProvider.of<OnboardingCubit>(context, listen: true);
      return cubit.state.currentStep.clamp(1, widget.totalSteps);
    } catch (_) {}

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStep = _resolveStep(context);
    final targetProgress = effectiveStep.toDouble();
    final beginProgress =
        _lastProgress ??
        (effectiveStep > 1 ? (effectiveStep - 1).toDouble() : 0.0);
    _lastProgress = targetProgress;

    return Padding(
      padding: widget.padding,
      child: TweenAnimationBuilder<double>(
        key: ValueKey<int>(effectiveStep),
        tween: Tween<double>(begin: beginProgress, end: targetProgress),
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        builder: (context, animatedValue, _) {
          return Row(
            children: List.generate(widget.totalSteps, (index) {
              final segmentProgress = (animatedValue - index).clamp(0.0, 1.0);

              return Expanded(
                child: Container(
                  height: widget.height,
                  margin: EdgeInsets.only(
                    right: index < widget.totalSteps - 1 ? 4.0 : 0.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: segmentProgress,
                      child: Container(
                        height: widget.height,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            widget.height / 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
