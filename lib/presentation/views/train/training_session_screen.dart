import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/training/training_bloc.dart';
import '../../blocs/training/training_event.dart';
import '../../blocs/training/training_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
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
  late final ValueNotifier<int> _selectedZoneNotifier;

  int _calculateZone(int bpm) {
    if (bpm >= 170) return 5;
    if (bpm >= 150) return 4;
    if (bpm >= 130) return 3;
    if (bpm >= 110) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    final initialHr = context.read<BandBloc>().state.liveHeartRate;
    _selectedZoneNotifier = ValueNotifier<int>(
      initialHr > 0 ? _calculateZone(initialHr) : 1,
    );
    context.read<BandBloc>().add(StartLiveHeartRateEvent());
    context.read<BandBloc>().add(SyncVitalsEvent());
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        context.read<TrainingBloc>().add(const TickWorkoutEvent());
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _selectedZoneNotifier.dispose();
    try {
      context.read<BandBloc>().add(StopLiveHeartRateEvent());
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        if (state.data == null) return const SizedBox.shrink();

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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recording · ${state.data?.title ?? "Workout"}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white,
                            fontSize: r.font(24),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          r.horizontalPadding,
                          (screenHeight * 0.018).clamp(12.0, 16.0),
                          r.horizontalPadding,
                          (screenHeight * 0.04).clamp(24.0, 36.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrainingTimerCard(elapsedSeconds: state.elapsedSeconds),
                            SizedBox(
                              height: (screenHeight * 0.020).clamp(12.0, 16.0),
                            ),
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: BlocConsumer<BandBloc, BandState>(
                                      listenWhen: (prev, curr) => prev.liveHeartRate != curr.liveHeartRate,
                                      listener: (context, bandState) {
                                        if (bandState.liveHeartRate > 0) {
                                          _selectedZoneNotifier.value = _calculateZone(bandState.liveHeartRate);
                                        }
                                      },
                                      buildWhen: (prev, curr) => prev.liveHeartRate != curr.liveHeartRate,
                                      builder: (context, bandState) {
                                        final hrValue = bandState.liveHeartRate > 0
                                            ? '${bandState.liveHeartRate}'
                                            : '--';
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
                              height: (screenHeight * 0.028).clamp(18.0, 24.0),
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
                              selectedZoneNotifier: _selectedZoneNotifier,
                            ),
                            SizedBox(
                              height: (screenHeight * 0.018).clamp(10.0, 16.0),
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: _selectedZoneNotifier,
                              builder: (context, selectedZone, _) {
                                return Text(
                                  TrainingZoneCard.zoneDescription(selectedZone),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: context.textSecondary,
                                    fontSize: r.font(13.5),
                                    height: 1.45,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: (screenHeight * 0.032).clamp(20.0, 28.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: AppButton(
                                text: 'Finish session',
                                onPressed: () {
                                  context.read<BandBloc>().add(StopLiveHeartRateEvent());
                                  context.read<TrainingBloc>().add(
                                    const FinishWorkoutEvent(),
                                  );
                                  Navigator.of(context).pushReplacementNamed(
                                    AppRoutes.membership,
                                  );
                                },
                                useGradient: true,
                                borderRadius: BorderRadius.circular(12),
                                fontSize: r.font(16),
                                fontWeight: FontWeight.w700,
                                hasShadow: false,
                              ),
                            ),
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
