import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/workout_model.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/training/training_bloc.dart';
import '../../blocs/training/training_event.dart';
import '../../blocs/training/training_state.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_event.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'models/zone_pacing_info.dart';
import 'widgets/training_metric_card.dart';
import 'widgets/training_recording_background.dart';
import 'widgets/training_timer_card.dart';
import 'widgets/training_zone_card.dart';

/// Pixel-perfect recording view matching Figma Node 128:554.
/// Modular architecture with strictly Zero setState.
class TrainingSessionScreen extends StatefulWidget {
  const TrainingSessionScreen({super.key});

  @override
  State<TrainingSessionScreen> createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    context.read<BandBloc>().add(StartLiveHeartRateEvent());
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        context.read<TrainingBloc>().add(const TickWorkoutEvent());
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    try {
      context.read<BandBloc>().add(StopLiveHeartRateEvent());
    } catch (_) {}
    super.dispose();
  }

  Future<void> _showFinishConfirmationDialog(
    BuildContext context,
    TrainingState state,
    Responsive r,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          decoration: BoxDecoration(
            color: sheetContext.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: sheetContext.cardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowNavy.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: sheetContext.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Finish Workout?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: sheetContext.textPrimary,
                  fontSize: r.font(20),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to finish this session? Your metrics and progress will be saved to your workout history.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: sheetContext.textSecondary,
                  fontSize: r.font(13.5),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: sheetContext.isDark
                      ? sheetContext.inputFill
                      : AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sheetContext.cardBorder, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModalStat(
                      label: 'Duration',
                      value: TrainingState.formatDuration(state.elapsedSeconds),
                      r: r,
                      context: sheetContext,
                    ),
                    _buildModalStat(
                      label: 'Calories',
                      value: '${state.burnedCalories} kcal',
                      r: r,
                      context: sheetContext,
                    ),
                    _buildModalStat(
                      label: 'Avg HR',
                      value: state.avgHeartRate > 0 ? '${state.avgHeartRate} bpm' : '--',
                      r: r,
                      context: sheetContext,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setButtonState) {
                  bool isFinishing = false;
                  return AppButton(
                    text: 'Finish & Save',
                    onPressed: () {
                      if (isFinishing) return;
                      isFinishing = true;
                      sheetContext.read<BandBloc>().add(StopLiveHeartRateEvent());
                      sheetContext.read<TrainingBloc>().add(const FinishWorkoutEvent());
                      sheetContext.read<WellnessBloc>().add(const LoadWellnessDataEvent());
                      Navigator.of(sheetContext).pop();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                      }
                    },
                    useGradient: true,
                    borderRadius: BorderRadius.circular(12),
                    fontSize: r.font(15),
                    fontWeight: FontWeight.w700,
                    hasShadow: false,
                  );
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.of(sheetContext).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sheetContext.cardBorder, width: 1),
                  ),
                  child: Text(
                    'Resume Workout',
                    style: GoogleFonts.plusJakartaSans(
                      color: sheetContext.textPrimary,
                      fontSize: r.font(14.5),
                      fontWeight: FontWeight.w600,
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

  Widget _buildModalStat({
    required String label,
    required String value,
    required Responsive r,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: context.textPrimary,
            fontSize: r.font(14),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: context.textSecondary,
            fontSize: r.font(11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildZonePill(
    String zone,
    String duration,
    bool isActive,
    BuildContext context,
    Responsive r,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          zone,
          style: GoogleFonts.plusJakartaSans(
            color: isActive ? AppColors.primary : context.textSecondary,
            fontSize: r.font(11),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          duration,
          style: GoogleFonts.plusJakartaSans(
            color: isActive ? AppColors.primary : context.textPrimary,
            fontSize: r.font(11.5),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneCoachingCard(
    BuildContext context,
    TrainingState state,
    WorkoutType category,
    Responsive r,
  ) {
    final zoneInfo = ZonePacingInfo.forZoneAndCategory(state.currentZone, category);
    final isRun = category == WorkoutType.run;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.cardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(
              alpha: context.isDark ? 0.2 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Zone Name and HR intensity tag
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  zoneInfo.icon,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zoneInfo.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: context.textPrimary,
                        fontSize: r.font(13.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${zoneInfo.intensityTag} · ${zoneInfo.hrRange}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: r.font(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Metric Pills: Target Time, Cadence, Breathing
          Row(
            children: [
              Expanded(
                child: _buildZoneDetailCapsule(
                  title: 'TIME GOAL',
                  value: zoneInfo.targetDuration,
                  icon: Icons.timer_outlined,
                  context: context,
                  r: r,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildZoneDetailCapsule(
                  title: isRun
                      ? 'CADENCE'
                      : (category == WorkoutType.cycling ? 'RPM' : 'TEMPO'),
                  value: zoneInfo.cadenceTarget,
                  icon: Icons.speed_rounded,
                  context: context,
                  r: r,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildZoneDetailCapsule(
            title: 'BREATHING RHYTHM',
            value: zoneInfo.breathingTechnique,
            icon: Icons.air_rounded,
            context: context,
            r: r,
            fullWidth: true,
          ),
          const SizedBox(height: 14),

          // Pacing & Form Guide ("kevi rite bhagvanu")
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.isDark
                  ? context.inputFill
                  : AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_run_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isRun
                          ? 'HOW TO RUN & PACING CUE'
                          : 'TECHNIQUE & EXECUTION',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: r.font(10.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  zoneInfo.executionGuide,
                  style: GoogleFonts.plusJakartaSans(
                    color: context.textPrimary,
                    fontSize: r.font(12),
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Physiological Benefit (Whoop / Garmin style)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(11.5),
                      height: 1.4,
                      color: context.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Physiological Adaptation: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      TextSpan(text: zoneInfo.physiologicalBenefit),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDetailCapsule({
    required String title,
    required String value,
    required IconData icon,
    required BuildContext context,
    required Responsive r,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.isDark
            ? context.inputFill
            : AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.cardBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(9),
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(11),
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  maxLines: fullWidth ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        if (state.data == null) return const SizedBox.shrink();

        final category = state.data?.selectedCategory ?? WorkoutType.run;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              const TrainingRecordingBackground(),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        r.horizontalPadding,
                        (screenHeight * 0.012).clamp(8.0, 12.0),
                        r.horizontalPadding,
                        0,
                      ),
                      child: Row(
                        children: [
                          AppBackButton(
                            onTap: () => Navigator.of(context).maybePop(),
                            isLightHeader: true,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              'Recording · ${state.data?.title ?? "Workout"}',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.white,
                                fontSize: r.font(22),
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          r.horizontalPadding,
                          (screenHeight * 0.018).clamp(12.0, 16.0),
                          r.horizontalPadding,
                          (screenHeight * 0.12).clamp(80.0, 120.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrainingTimerCard(elapsedSeconds: state.elapsedSeconds),
                            SizedBox(
                              height: (screenHeight * 0.020).clamp(12.0, 16.0),
                            ),

                            // Row 1: Primary Metrics (Heart Rate & Calories)
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: BlocBuilder<BandBloc, BandState>(
                                      buildWhen: (prev, curr) =>
                                          prev.liveHeartRate != curr.liveHeartRate ||
                                          prev.lastSyncedVitals?.restingHeartRate !=
                                              curr.lastSyncedVitals?.restingHeartRate,
                                      builder: (context, bandState) {
                                        final hr = state.liveHeartRate > 0
                                            ? state.liveHeartRate
                                            : (bandState.liveHeartRate > 0
                                                ? bandState.liveHeartRate
                                                : (bandState.lastSyncedVitals?.restingHeartRate ?? 0));
                                        final hrValue = hr > 0 ? '$hr' : '--';
                                        return TrainingMetricCard(
                                          icon: AppIcons.heartPulse,
                                          label: 'Heart Rate',
                                          color: AppColors.primary,
                                          value: hrValue,
                                          unit: 'bpm',
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TrainingMetricCard(
                                      icon: AppIcons.trainFlame,
                                      color: AppColors.mindPillar,
                                      label: 'Calories',
                                      value: '${state.burnedCalories}',
                                      unit: 'kcal',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: (screenHeight * 0.014).clamp(10.0, 14.0),
                            ),

                            // Row 2: Activity-Specific Real-Time Metrics
                            if (category == WorkoutType.run || category == WorkoutType.walk)
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TrainingMetricCard(
                                        iconData: Icons.straighten_rounded,
                                        label: 'Distance',
                                        color: AppColors.cyanAccent,
                                        value: state.formattedDistance,
                                        unit: 'km',
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: TrainingMetricCard(
                                        iconData: Icons.speed_rounded,
                                        label: 'Pace',
                                        color: AppColors.movePillar,
                                        value: state.formattedPace,
                                        unit: '/km',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (category == WorkoutType.cycling)
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TrainingMetricCard(
                                        iconData: Icons.straighten_rounded,
                                        label: 'Distance',
                                        color: AppColors.cyanAccent,
                                        value: state.formattedDistance,
                                        unit: 'km',
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: TrainingMetricCard(
                                        iconData: Icons.speed_rounded,
                                        label: 'Speed',
                                        color: AppColors.primary,
                                        value: state.formattedSpeed,
                                        unit: 'km/h',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TrainingMetricCard(
                                        iconData: Icons.trending_up_rounded,
                                        label: 'Peak HR',
                                        color: AppColors.mindPillar,
                                        value: state.peakHeartRate > 0
                                            ? '${state.peakHeartRate}'
                                            : '--',
                                        unit: 'bpm',
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: TrainingMetricCard(
                                        iconData: Icons.timeline_rounded,
                                        label: 'Avg HR',
                                        color: AppColors.primary,
                                        value: state.avgHeartRate > 0
                                            ? '${state.avgHeartRate}'
                                            : '--',
                                        unit: 'bpm',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(
                              height: (screenHeight * 0.024).clamp(16.0, 22.0),
                            ),
                            Text(
                              'Zone',
                              style: GoogleFonts.plusJakartaSans(
                                color: context.textPrimary,
                                fontSize: r.font(18),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: (screenHeight * 0.014).clamp(8.0, 12.0),
                            ),
                            TrainingZoneCard(
                              selectedZone: state.currentZone,
                              onZoneSelected: (zone) {
                                context.read<TrainingBloc>().add(
                                  SelectTargetZoneEvent(zone),
                                );
                              },
                            ),
                            SizedBox(
                              height: (screenHeight * 0.018).clamp(10.0, 16.0),
                            ),
                            Text(
                              TrainingZoneCard.zoneDescription(state.currentZone),
                              style: GoogleFonts.plusJakartaSans(
                                color: context.textSecondary,
                                fontSize: r.font(13.5),
                                height: 1.45,
                              ),
                            ),

                            // Time in Zones Breakdown Card
                            if (state.elapsedSeconds > 0)
                              Container(
                                margin: EdgeInsets.only(
                                  top: (screenHeight * 0.016).clamp(10.0, 14.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: context.cardBorder,
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time in Zones',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: context.textSecondary,
                                        fontSize: r.font(12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildZonePill(
                                          'Z1',
                                          TrainingState.formatDuration(
                                            state.zone1Seconds,
                                          ),
                                          state.currentZone == 1,
                                          context,
                                          r,
                                        ),
                                        _buildZonePill(
                                          'Z2',
                                          TrainingState.formatDuration(
                                            state.zone2Seconds,
                                          ),
                                          state.currentZone == 2,
                                          context,
                                          r,
                                        ),
                                        _buildZonePill(
                                          'Z3',
                                          TrainingState.formatDuration(
                                            state.zone3Seconds,
                                          ),
                                          state.currentZone == 3,
                                          context,
                                          r,
                                        ),
                                        _buildZonePill(
                                          'Z4',
                                          TrainingState.formatDuration(
                                            state.zone4Seconds,
                                          ),
                                          state.currentZone == 4,
                                          context,
                                          r,
                                        ),
                                        _buildZonePill(
                                          'Z5',
                                          TrainingState.formatDuration(
                                            state.zone5Seconds,
                                          ),
                                          state.currentZone == 5,
                                          context,
                                          r,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(
                              height: (screenHeight * 0.032).clamp(20.0, 28.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: AppButton(
                                text: 'Finish session',
                                onPressed: () => _showFinishConfirmationDialog(
                                  context,
                                  state,
                                  r,
                                ),
                                useGradient: true,
                                borderRadius: BorderRadius.circular(12),
                                fontSize: r.font(16),
                                fontWeight: FontWeight.w700,
                                hasShadow: false,
                              ),
                            ),
                            SizedBox(
                              height: (screenHeight * 0.024).clamp(16.0, 22.0),
                            ),
                            _buildZoneCoachingCard(context, state, category, r),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavBar(
                  activeIndex: 2,
                  onTabSelected: (_) => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
