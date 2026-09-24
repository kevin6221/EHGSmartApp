import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/sync/health_sync_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/repositories/band_repository.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../../blocs/vitals/vitals_bloc.dart';
import '../../blocs/vitals/vitals_event.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_event.dart';
import '../../blocs/wellness/wellness_state.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/home_day_wave_section.dart';
import 'widgets/home_energy_card.dart';
import 'widgets/home_header_greeting.dart';
import 'widgets/home_hydration_card.dart';
import 'widgets/home_mode_selector.dart';
import 'widgets/home_readiness_card.dart';
import 'widgets/home_vitals_summary_row.dart';
import 'widgets/home_wellness_score_card.dart';

/// Main Dashboard Home Screen displaying wellness score, daily waves, vitals, readiness, and habits.
/// Fully dynamic responsive layout adhering to senior developer architecture and zero setState.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chartAnimController;
  late final Animation<double> _chartAnim;
  Timer? _heartRatePeriodicTimer;

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.chartDraw,
    );
    _chartAnim = CurvedAnimation(
      parent: _chartAnimController,
      curve: AppCurves.chartEase,
    );
    _chartAnimController.forward();

    // Check HR immediately if due
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkHeartRateIfDue();
    });

    // Schedule 5-minute periodic check while on dashboard
    _heartRatePeriodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted) return;
      _checkHeartRateIfDue();
    });
  }

  void _checkHeartRateIfDue() {
    try {
      final syncMgr = context.read<HealthSyncManager>();
      final bandRepo = context.read<BandRepository>();
      final wellnessRepo = context.read<WellnessRepository>();
      syncMgr.syncHeartRateIfDue(bandRepo: bandRepo, wellnessRepo: wellnessRepo).then((_) {
        if (mounted) {
          context.read<WellnessBloc>().add(const LoadWellnessDataEvent());
          context.read<VitalsBloc>().add(LoadVitalsEvent());
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _heartRatePeriodicTimer?.cancel();
    _chartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSpacing = (r.height * 0.018).clamp(12.0, 20.0);

    return BlocBuilder<WellnessBloc, WellnessState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              SkyHeaderBackground(height: r.hp(0.36)),

              // 2. Main Scrollable Dashboard Content
              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    final syncMgr = context.read<HealthSyncManager>();
                    final bandRepo = context.read<BandRepository>();
                    final wellnessRepo = context.read<WellnessRepository>();
                    final bandBloc = context.read<BandBloc>();
                    final wellnessBloc = context.read<WellnessBloc>();
                    final vitalsBloc = context.read<VitalsBloc>();

                    try {
                      await syncMgr.performManualSync(
                        bandRepo: bandRepo,
                        wellnessRepo: wellnessRepo,
                      );
                    } catch (_) {
                      bandBloc.add(SyncVitalsEvent());
                    }
                    if (mounted) {
                      wellnessBloc.add(const LoadWellnessDataEvent());
                      vitalsBloc.add(LoadVitalsEvent());
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      r.horizontalPadding,
                      r.verticalPadding,
                      r.horizontalPadding,
                      r.hp(0.12),
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          final userName = profileState.data?.username;
                          return HomeHeaderGreeting(
                            userName: (userName != null && userName.isNotEmpty)
                                ? userName
                                : 'there',
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // Wellness Score Banner Card
                      HomeWellnessScoreCard(
                        score: data.wellnessScore,
                        moveScore: data.moveScore,
                        recoverScore: data.recoverScore,
                        mindScore: data.mindScore,
                        fuelScore: data.fuelScore,
                        scoreChange: '${data.scoreDiff.abs()}',
                        isNegativeChange: data.scoreDiff < 0,
                      ),
                      SizedBox(height: itemSpacing),

                      // Mode Selector Tabs (Recover / Steady / Push)
                      HomeModeSelector(
                        currentMode: data.activeMode,
                        onModeChanged: (mode) {
                          context.read<WellnessBloc>().add(
                            ChangeWellnessModeEvent(mode),
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // "Your day so far" Chart Section (No Card Wrapper)
                      HomeDayWaveSection(
                        points: data.dayChartPoints,
                        animation: _chartAnim,
                      ),
                      // SizedBox(height: itemSpacing),

                      // Quick-Glance Vitals Carousel (Heart Rate & Sleep)
                      HomeVitalsSummaryRow(
                        heartRate: data.currentHeartRate,
                        weeklyHeartRate: data.weeklyHeartRate,
                        sleepHours: data.sleepHours,
                      ),
                      SizedBox(height: itemSpacing),

                      // Readiness Detail Section Card
                      HomeReadinessCard(data: data),
                      SizedBox(height: itemSpacing),

                      // Hydration Card
                      HomeHydrationCard(
                        currentMl: data.hydrationCurrent,
                        goalMl: data.hydrationGoal,
                        weeklyHydration: data.weeklyHydration,
                        onAddMl: () {
                          context.read<WellnessBloc>().add(
                            const AddHydrationEvent(250),
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // Energy Burned Card
                      BlocBuilder<BandBloc, BandState>(
                        buildWhen: (prev, curr) =>
                            prev.lastSyncedVitals?.calories != curr.lastSyncedVitals?.calories ||
                            prev.lastSyncedVitals?.steps != curr.lastSyncedVitals?.steps,
                        builder: (context, bandState) {
                          final steps = (bandState.lastSyncedVitals?.steps ?? 0) > 0
                              ? bandState.lastSyncedVitals!.steps
                              : data.steps;
                          final energy = (bandState.lastSyncedVitals?.calories ?? 0) > 0
                              ? bandState.lastSyncedVitals!.calories
                              : data.energyBurned;

                          final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
                          List<double> chartValues = List<double>.from(
                            data.weeklyEnergy.length == 7
                                ? data.weeklyEnergy
                                : const [0.45, 0.62, 0.55, 0.70, 0.80, 0.60, 0.50],
                          );
                          if (energy > 0 && chartValues.length == 7) {
                            chartValues[todayIdx] = (energy / 600.0).clamp(0.05, 1.0);
                          }

                          return HomeEnergyCard(
                            energyBurned: energy,
                            steps: steps,
                            activeMins: data.activeMins,
                            goalMins: data.goalMins,
                            weeklyEnergy: chartValues,
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),
                    ],
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
}
