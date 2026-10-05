import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/wellness/wellness_bloc.dart';
import '../../../blocs/wellness/wellness_event.dart';
import '../../../blocs/wellness/wellness_state.dart';

/// Immersive, premium Guided Meditation & Breathwork session screen.
/// Features interactive countdown timer, breathing visualizer guide (Inhale / Hold / Exhale),
/// custom session controls, and immediate reward claiming directly boosting the Wellness Score.
/// Strictly ZERO setState - 100% reactive via ValueNotifiers.
class MindMeditationSessionSheet extends StatefulWidget {
  final String title;
  final int totalSeconds;
  final WellnessBloc wellnessBloc;

  const MindMeditationSessionSheet({
    super.key,
    required this.title,
    required this.totalSeconds,
    required this.wellnessBloc,
  });

  @override
  State<MindMeditationSessionSheet> createState() => _MindMeditationSessionSheetState();
}

class _MindMeditationSessionSheetState extends State<MindMeditationSessionSheet>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final ValueNotifier<int> _remainingNotifier;
  late final ValueNotifier<bool> _isPausedNotifier;
  late final ValueNotifier<String> _breathPhaseNotifier;
  late final ValueNotifier<bool> _isCompletedNotifier;

  Timer? _timer;
  DateTime? _sessionEndTime;
  int _pausedRemainingSeconds = 0;
  int? _scoreBeforeCompletion;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingNotifier = ValueNotifier<int>(widget.totalSeconds);
    _isPausedNotifier = ValueNotifier<bool>(false);
    _breathPhaseNotifier = ValueNotifier<String>('Inhale deeply...');
    _isCompletedNotifier = ValueNotifier<bool>(false);
    _sessionEndTime = DateTime.now().add(Duration(seconds: widget.totalSeconds));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.90, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-synchronize remaining timer with real-world elapsed time
      if (!_isPausedNotifier.value && !_isCompletedNotifier.value && _sessionEndTime != null) {
        final diff = _sessionEndTime!.difference(DateTime.now()).inSeconds;
        if (diff > 0) {
          _remainingNotifier.value = diff;
        } else {
          _remainingNotifier.value = 0;
          _onCompletePractice();
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    int cycleSecond = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPausedNotifier.value) return;

      if (_sessionEndTime != null) {
        final diff = _sessionEndTime!.difference(DateTime.now()).inSeconds;
        if (diff > 1) {
          _remainingNotifier.value = diff;
          cycleSecond = (cycleSecond + 1) % 12;

          // Box breathing rhythm guidance
          if (cycleSecond < 4) {
            _breathPhaseNotifier.value = 'Inhale slowly...';
          } else if (cycleSecond < 6) {
            _breathPhaseNotifier.value = 'Hold gently...';
          } else if (cycleSecond < 10) {
            _breathPhaseNotifier.value = 'Exhale completely...';
          } else {
            _breathPhaseNotifier.value = 'Rest & center...';
          }
        } else {
          _remainingNotifier.value = 0;
          _timer?.cancel();
          _onCompletePractice();
        }
      }
    });
  }

  void _onCompletePractice() {
    if (_isCompletedNotifier.value) return;
    _scoreBeforeCompletion = widget.wellnessBloc.state.data?.wellnessScore;
    _isCompletedNotifier.value = true;
    _sessionEndTime = null;
    _timer?.cancel();

    // Directly dispatch event to WellnessBloc to boost Mind & Wellness Score
    widget.wellnessBloc.add(const CompleteMindSessionEvent(points: 5));
  }

  void _togglePause() {
    final nextPaused = !_isPausedNotifier.value;
    _isPausedNotifier.value = nextPaused;
    if (nextPaused) {
      _pausedRemainingSeconds = _remainingNotifier.value;
      _sessionEndTime = null;
      _pulseController.stop();
    } else {
      _sessionEndTime = DateTime.now().add(Duration(seconds: _pausedRemainingSeconds));
      _pulseController.repeat(reverse: true);
    }
  }

  void _adjustTime(int deltaSeconds) {
    if (deltaSeconds > 0 && _remainingNotifier.value >= widget.totalSeconds) {
      return;
    }
    final newRemaining = (_remainingNotifier.value + deltaSeconds).clamp(30, widget.totalSeconds);
    _remainingNotifier.value = newRemaining;
    if (!_isPausedNotifier.value) {
      _sessionEndTime = DateTime.now().add(Duration(seconds: newRemaining));
    } else {
      _pausedRemainingSeconds = newRemaining;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    _remainingNotifier.dispose();
    _isPausedNotifier.dispose();
    _breathPhaseNotifier.dispose();
    _isCompletedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = context.isDark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: r.hp(0.85),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 20.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isCompletedNotifier,
          builder: (context, isCompleted, _) {
            if (isCompleted) {
              return _buildCompletionView(context, r, isDark);
            }
            return _buildActiveSessionView(context, r, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildActiveSessionView(BuildContext context, Responsive r, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44.0,
            height: 4.5,
            decoration: BoxDecoration(
              color: context.cardBorder,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          const SizedBox(height: 16.0),

          // Header with Category, Title, and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const AppSvgIcon(
                      AppIcons.mindBreath,
                      size: 20.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MIND PRACTICE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        widget.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(17.0),
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22.0),
                color: context.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Wellness Score Reward Pill Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 16.0,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    '+5 points added to Wellness Score on completion',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(11.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Central Breathing Visualizer & Circular Countdown Progress
          ValueListenableBuilder<int>(
            valueListenable: _remainingNotifier,
            builder: (context, remainingSeconds, _) {
              final progress = (remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0);
              final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
              final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ambient Pulsing Breathing Halo
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 220.0,
                          height: 220.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.06),
                          ),
                        ),
                      );
                    },
                  ),

                  // Middle Ring
                  Container(
                    width: 195.0,
                    height: 195.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.midnightBackground : AppColors.surface,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        width: 1.0,
                      ),
                    ),
                  ),

                  // Circular Progress Indicator
                  SizedBox(
                    width: 200.0,
                    height: 200.0,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6.0,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),

                  // Inner Content: Breathing Cue + Large MM:SS
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: _breathPhaseNotifier,
                        builder: (context, phase, _) {
                          return Text(
                            phase,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(12.0),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        '$minutes:$seconds',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(40.0),
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          letterSpacing: 1.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'REMAINING',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20.0),

          // Time Adjustments (+1m / -1m) capped at session duration
          ValueListenableBuilder<int>(
            valueListenable: _remainingNotifier,
            builder: (context, remainingSeconds, _) {
              final canAdd = remainingSeconds < widget.totalSeconds;
              final canSubtract = remainingSeconds > 60;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeAdjustChip(
                    label: '-1 Min',
                    r: r,
                    onTap: canSubtract ? () => _adjustTime(-60) : null,
                    isDark: isDark,
                    isEnabled: canSubtract,
                  ),
                  const SizedBox(width: 12.0),
                  _buildTimeAdjustChip(
                    label: '+1 Min',
                    r: r,
                    onTap: canAdd ? () => _adjustTime(60) : null,
                    isDark: isDark,
                    isEnabled: canAdd,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28.0),

          // Primary Actions: Pause/Resume and Complete Practice
          Row(
            children: [
              // Pause / Resume Button
              Expanded(
                flex: 4,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isPausedNotifier,
                  builder: (context, isPaused, _) {
                    return OutlinedButton.icon(
                      onPressed: _togglePause,
                      icon: Icon(
                        isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        size: 20.0,
                        color: context.textPrimary,
                      ),
                      label: Text(
                        isPaused ? 'Resume' : 'Pause',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(13.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.cardBorder, width: 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        backgroundColor: isDark ? AppColors.midnightBackground : AppColors.surface,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),

              // Complete Practice Button
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: _onCompletePractice,
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20.0,
                    color: AppColors.white,
                  ),
                  label: Text(
                    'Complete Practice',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(13.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, Responsive r, bool isDark) {
    return BlocBuilder<WellnessBloc, WellnessState>(
      bloc: widget.wellnessBloc,
      builder: (context, state) {
        final currentScore = state.data?.wellnessScore ?? 75;
        final int displayScore = (currentScore >= (_scoreBeforeCompletion ?? 0) + 5)
            ? currentScore
            : (((_scoreBeforeCompletion ?? currentScore) + 5).clamp(1, 100));

        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: context.cardBorder,
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
              const SizedBox(height: 28.0),

              // Glowing Success Check Icon
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  size: 44.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20.0),

              Text(
                'Practice Completed!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(22.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Your nervous system has settled into recovery state.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(13.0),
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Score Reward Confirmation Card
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellness Score Impact',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(12.0),
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Now at $displayScore pts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(18.0),
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        '+5 PTS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(13.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),

              // Return Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.title} completed · +5 added to Wellness Score!',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 0,
                  ),
                  child: Text(
                    'Return to Systems',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(14.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeAdjustChip({
    required String label,
    required Responsive r,
    required VoidCallback? onTap,
    required bool isDark,
    bool isEnabled = true,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.35,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.midnightBackground : AppColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: context.cardBorder,
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(11.0),
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
