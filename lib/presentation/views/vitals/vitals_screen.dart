import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/engine/recommendation_engine.dart';
import '../../../core/sync/health_sync_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/vitals_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../blocs/vitals/vitals_bloc.dart';
import '../../blocs/vitals/vitals_event.dart';
import '../../blocs/vitals/vitals_state.dart';
import '../../helpers/vitals_history_calculator.dart';
import '../../widgets/charts/capsule_bar_chart.dart';
import '../../widgets/charts/sparkline_chart.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/vitals_date_navigator.dart';
import 'widgets/vitals_expandable_metric_card.dart';
import 'widgets/vitals_heart_rate_card.dart';
import 'widgets/vitals_hrv_card.dart';
import 'widgets/vitals_period_segmented_bar.dart';
import 'widgets/vitals_sleep_summary_card.dart';
import 'widgets/vitals_stress_card.dart';
import 'widgets/vitals_twin_trend_cards.dart';

/// Vitals dashboard screen displaying sleep, heart metrics, stress, oxygen, and trend vitals.
///
/// Features Day/Week/Month historical browsing with date navigation,
/// period stats, and expandable/collapsible metric cards matching Figma Nodes 71:886 & 119:1442.
class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  late final List<ValueNotifier<bool>> _expandNotifiers;
  late final ValueNotifier<VitalsTimePeriod> _selectedPeriodNotifier;
  late final ValueNotifier<DateTime> _selectedDateNotifier;
  late final ValueNotifier<VitalsModel?> _historicalVitalsNotifier;
  late final ValueNotifier<VitalsPeriodStats?> _periodStatsNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  int _loadGeneration = 0;
  Timer? _historicalSyncDebounce;

  @override
  void initState() {
    super.initState();
    _expandNotifiers = List.generate(9, (_) => ValueNotifier<bool>(false));
    _selectedPeriodNotifier = ValueNotifier<VitalsTimePeriod>(VitalsTimePeriod.day);
    final now = DateTime.now();
    _selectedDateNotifier = ValueNotifier<DateTime>(DateTime(now.year, now.month, now.day));
    _historicalVitalsNotifier = ValueNotifier<VitalsModel?>(null);
    _periodStatsNotifier = ValueNotifier<VitalsPeriodStats?>(null);
    _isLoadingNotifier = ValueNotifier<bool>(false);

    _selectedPeriodNotifier.addListener(_onPeriodOrDateChanged);
    _selectedDateNotifier.addListener(_onPeriodOrDateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshHistoricalData();
  }

  @override
  void dispose() {
    _historicalSyncDebounce?.cancel();
    _selectedPeriodNotifier.removeListener(_onPeriodOrDateChanged);
    _selectedDateNotifier.removeListener(_onPeriodOrDateChanged);
    for (final notifier in _expandNotifiers) {
      notifier.dispose();
    }
    _selectedPeriodNotifier.dispose();
    _selectedDateNotifier.dispose();
    _historicalVitalsNotifier.dispose();
    _periodStatsNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _onPeriodOrDateChanged() {
    _refreshHistoricalData();
  }

  Future<void> _refreshHistoricalData() async {
    final generation = ++_loadGeneration;
    final period = _selectedPeriodNotifier.value;
    final date = _selectedDateNotifier.value;
    final wellnessRepo = context.read<WellnessRepository>();
    final bandRepo = context.read<BandRepository>();

    // 0. If viewing today with Day period:
    if (period == VitalsTimePeriod.day && _isToday(date)) {
      _isLoadingNotifier.value = false;
      _historicalVitalsNotifier.value = null; // null triggers fallback to liveData
      final stats = await wellnessRepo.getHistoricalPeriodStats(period: period, anchorDate: date);
      if (generation == _loadGeneration && mounted) {
        _periodStatsNotifier.value = stats;
      }
      return;
    }

    final hasCachedStats = wellnessRepo.hasCachedPeriodStats(period, date);
    final hasCachedVitals = wellnessRepo.hasCachedHistoricalVitals(date);

    // If data is not yet in memory cache, mark loading
    if (!hasCachedStats && !hasCachedVitals) {
      _isLoadingNotifier.value = true;
    }

    // 1. Immediately fetch cached SQLite / in-memory data
    final statsFuture = wellnessRepo.getHistoricalPeriodStats(
      period: period,
      anchorDate: date,
    );

    final vitalsFuture = (period == VitalsTimePeriod.day)
        ? wellnessRepo.getHistoricalVitalsForDate(date)
        : (period == VitalsTimePeriod.week)
            ? wellnessRepo.getWeeklyVitalsRollup(date)
            : wellnessRepo.getMonthlyVitalsRollup(date);

    final results = await Future.wait([statsFuture, vitalsFuture]);
    if (generation != _loadGeneration || !mounted) return;

    final cachedStats = results[0] as VitalsPeriodStats;
    final cachedVitals = results[1] as VitalsModel?;

    // Present local database & in-memory data instantaneously (<16ms, 60fps)
    _periodStatsNotifier.value = cachedStats;
    _historicalVitalsNotifier.value = cachedVitals;
    _isLoadingNotifier.value = false;

    // 2. Non-blocking silent background sync from hardware band ONLY if not yet cached in DB
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    final dayDiff = today.difference(normalized).inDays;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final bool hasDbData = cachedVitals != null &&
        (cachedVitals.totalSleep != '--' || cachedVitals.currentHeartRate > 0 || cachedVitals.stressScore > 0);
    final bool alreadySynced = bandRepo.isHistoricalDateSynced(dateStr);

    if (period == VitalsTimePeriod.day &&
        dayDiff >= 1 &&
        dayDiff <= 6 &&
        bandRepo.isConnected &&
        !hasDbData &&
        !alreadySynced) {
      _historicalSyncDebounce?.cancel();
      _historicalSyncDebounce = Timer(const Duration(milliseconds: 350), () {
        if (generation != _loadGeneration || !mounted) return;
        bandRepo.syncHistoricalDay(dayDiff).then((_) async {
          if (generation != _loadGeneration || !mounted) return;
          wellnessRepo.invalidateDateCache(dateStr);
          final updated = await Future.wait([
            wellnessRepo.getHistoricalPeriodStats(period: period, anchorDate: date),
            wellnessRepo.getHistoricalVitalsForDate(date),
          ]);
          if (generation == _loadGeneration && mounted) {
            _periodStatsNotifier.value = updated[0] as VitalsPeriodStats;
            _historicalVitalsNotifier.value = updated[1] as VitalsModel?;
          }
        }).catchError((e) {
          debugPrint('⚠️ [VITALS] Non-blocking background past day sync error: $e');
        });
      });
    }
  }

  void _onToggleCard(int index) {
    final willExpand = !_expandNotifiers[index].value;
    for (int i = 0; i < _expandNotifiers.length; i++) {
      _expandNotifiers[i].value = (i == index) ? willExpand : false;
    }
  }

  void _onPreviousDate() {
    final cur = _selectedDateNotifier.value;
    final curDate = DateTime(cur.year, cur.month, cur.day);
    final period = _selectedPeriodNotifier.value;
    switch (period) {
      case VitalsTimePeriod.day:
        _selectedDateNotifier.value = curDate.subtract(const Duration(days: 1));
        break;
      case VitalsTimePeriod.week:
        _selectedDateNotifier.value = curDate.subtract(const Duration(days: 7));
        break;
      case VitalsTimePeriod.month:
        _selectedDateNotifier.value = DateTime(curDate.year, curDate.month - 1, curDate.day);
        break;
    }
  }

  void _onNextDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cur = _selectedDateNotifier.value;
    final curDate = DateTime(cur.year, cur.month, cur.day);
    final period = _selectedPeriodNotifier.value;
    DateTime next;
    switch (period) {
      case VitalsTimePeriod.day:
        next = curDate.add(const Duration(days: 1));
        break;
      case VitalsTimePeriod.week:
        next = curDate.add(const Duration(days: 7));
        break;
      case VitalsTimePeriod.month:
        next = DateTime(curDate.year, curDate.month + 1, curDate.day);
        break;
    }
    if (next.isAfter(today)) {
      next = today;
    }
    _selectedDateNotifier.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSpacing = (r.height * 0.016).clamp(10.0, 16.0);
    final cardSpacing = (r.height * 0.019).clamp(12.0, 18.0);
    final breathingSparklineHeight = (r.height * 0.045).clamp(32.0, 44.0);

    return BlocBuilder<VitalsBloc, VitalsState>(
      builder: (context, state) {
        final liveData = state.data;
        if (liveData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<VitalsModel?>(
          valueListenable: _historicalVitalsNotifier,
          builder: (context, historicalData, _) {
            final data = historicalData ?? liveData;

            final sleepRec = RecommendationEngine.getSleepRecommendation(
              data.totalSleep,
              data.sleepIntervals,
            );
            final hrRec = RecommendationEngine.getHeartRateRecommendation(
              data.currentHeartRate,
              data.weeklyHeartRate,
            );
            final stressRec = RecommendationEngine.getStressRecommendation(
              data.stressScore,
              data.stressTimeline,
            );
            final restingHrRec = RecommendationEngine.getRestingHrRecommendation(
              data.restingHr,
              data.weeklyRestingHr,
            );
            final oxygenRec = RecommendationEngine.getBloodOxygenRecommendation(
              data.bloodOxygen,
              data.weeklyOxygen,
            );
            final breathingRec = RecommendationEngine.getBreathingRateRecommendation(
              data.breathingRate,
              data.weeklyBreathing,
            );

            return ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, _) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Stack(
                    children: [
                      // Top Sky Gradient
                      SkyHeaderBackground(height: r.hp(0.42), stops: const [0.0, 0.85]),

                      SafeArea(
                        bottom: false,
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onRefresh: () async {
                            final syncMgr = context.read<HealthSyncManager>();
                            final bandRepo = context.read<BandRepository>();
                            final wellnessRepo = context.read<WellnessRepository>();
                            final vitalsBloc = context.read<VitalsBloc>();

                            await syncMgr.performManualSync(
                              bandRepo: bandRepo,
                              wellnessRepo: wellnessRepo,
                              force: true,
                            );
                            if (mounted) {
                              vitalsBloc.add(LoadVitalsEvent());
                              await _refreshHistoricalData();
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
                                // Header Row
                                const ScreenHeader(
                                  title: 'Vitals',
                                  showAvatar: true,
                                  showOnlineIndicator: false,
                                ),
                                SizedBox(height: itemSpacing * 0.7),

                                // 1. Day / Week / Month Segmented Control (QWatch Pro & Garmin)
                                VitalsPeriodSegmentedBar(
                                  periodNotifier: _selectedPeriodNotifier,
                                ),
                                const SizedBox(height: 12.0),

                                // 2. Date Navigation Bar with Back/Forward Arrows
                                VitalsDateNavigator(
                                  dateNotifier: _selectedDateNotifier,
                                  periodNotifier: _selectedPeriodNotifier,
                                  onPrevious: _onPreviousDate,
                                  onNext: _onNextDate,
                                ),
                                SizedBox(height: cardSpacing),

                                // 3. Period Overview Stats Card with Relax/Normal/Medium/High Distribution
                                // ValueListenableBuilder<VitalsPeriodStats?>(
                                //   valueListenable: _periodStatsNotifier,
                                //   builder: (context, dynamicStats, _) {
                                //     final periodStats = dynamicStats ??
                                //         VitalsPeriodStats.compute(
                                //           period: _selectedPeriodNotifier.value,
                                //           anchorDate: _selectedDateNotifier.value,
                                //           currentVitals: data,
                                //         );
                                //     return VitalsPeriodStatsCard(
                                //       stats: periodStats,
                                //       isLoading: isLoading,
                                //     );
                                //   },
                                // ),
                                // SizedBox(height: cardSpacing),

                                // 4. Last night / Weekly / Monthly Sleep Summary Card (Figma Node 73:1319)
                                ValueListenableBuilder<VitalsTimePeriod>(
                                  valueListenable: _selectedPeriodNotifier,
                                  builder: (context, period, _) {
                                    final sleepTitle = period == VitalsTimePeriod.day
                                        ? 'Last night Sleep Summary'
                                        : period == VitalsTimePeriod.week
                                            ? 'Weekly Sleep Summary'
                                            : 'Monthly Sleep Summary';
                                    return VitalsSleepSummaryCard(
                                      title: sleepTitle,
                                      totalSleep: data.totalSleep,
                                      sleepWindow: data.sleepWindow,
                                      sleepIntervals: data.sleepIntervals,
                                      isLoading: isLoading,
                                      isExpandedNotifier: _expandNotifiers[0],
                                      onTap: () => _onToggleCard(0),
                                      whatItIs: sleepRec.whatItIs,
                                      yourReading: sleepRec.yourReading,
                                      doThis: sleepRec.doThis,
                                    );
                                  },
                                ),
                                SizedBox(height: cardSpacing),

                                // 2. Heart Rate Card (Figma Node 73:1418)
                                ValueListenableBuilder<VitalsTimePeriod>(
                                  valueListenable: _selectedPeriodNotifier,
                                  builder: (context, period, _) {
                                    return VitalsHeartRateCard(
                                      currentHeartRate: data.currentHeartRate,
                                      weeklyHeartRate: data.weeklyHeartRate,
                                      period: period,
                                      isLoading: isLoading,
                                      isExpandedNotifier: _expandNotifiers[1],
                                      onTap: () => _onToggleCard(1),
                                      whatItIs: hrRec.whatItIs,
                                      yourReading: hrRec.yourReading,
                                      doThis: hrRec.doThis,
                                    );
                                  },
                                ),
                                SizedBox(height: cardSpacing),

                                // 3. Stress Card with Interactive Scrubber (Figma Node 71:1042)
                                VitalsStressCard(
                                  stressScore: data.stressScore,
                                  stressStatus: data.stressStatus,
                                  stressTimeline: data.stressTimeline,
                                  isExpandedNotifier: _expandNotifiers[2],
                                  onTap: () => _onToggleCard(2),
                                  whatItIs: stressRec.whatItIs,
                                  yourReading: stressRec.yourReading,
                                  doThis: stressRec.doThis,
                                ),
                                SizedBox(height: cardSpacing),

                                // 4. Expandable Heart Rate Variability Card (Figma Node 73:1530 & 119:1517)
                                VitalsHrvCard(
                                  hrvMs: data.hrvMs,
                                  weeklyHrv: data.weeklyHrv,
                                  isLoading: isLoading,
                                  isExpandedNotifier: _expandNotifiers[3],
                                  onTap: () => _onToggleCard(3),
                                ),
                                SizedBox(height: itemSpacing),

                                // 5. Expandable Resting Heart Rate Card (Figma Node 73:1559)
                                VitalsExpandableMetricCard(
                                  svgIcon: AppIcons.restingLounger,
                                  iconColor: AppColors.orangeMetric,
                                  title: 'Resting Heart Rate',
                                  value: data.restingHr > 0
                                      ? '${data.restingHr}'
                                      : (isLoading ? '...' : '--'),
                                  unit: 'bpm',
                                  status: data.restingHr > 0
                                      ? restingHrRec.status
                                      : (isLoading ? 'Syncing...' : '--'),
                                  showWeekdays: true,
                                  isExpandedNotifier: _expandNotifiers[4],
                                  onTap: () => _onToggleCard(4),
                                  chart: SparklineChart(
                                    values: data.weeklyRestingHr,
                                    lineColor: AppColors.orangeMetric,
                                    showFill: true,
                                    width: double.infinity,
                                  ),
                                  whatItIs: restingHrRec.whatItIs,
                                  yourReading: restingHrRec.yourReading,
                                  doThis: restingHrRec.doThis,
                                ),
                                SizedBox(height: itemSpacing),

                                // 6. Expandable Blood Oxygen Card (Figma Node 73:1590) - Single Weekdays
                                VitalsExpandableMetricCard(
                                  svgIcon: AppIcons.bloodDroplets,
                                  iconColor: AppColors.greenMetric,
                                  title: 'Blood oxygen',
                                  value: data.bloodOxygen > 0
                                      ? '${data.bloodOxygen}'
                                      : (isLoading ? '...' : '--'),
                                  unit: '%',
                                  status: data.bloodOxygen > 0
                                      ? oxygenRec.status
                                      : (isLoading ? 'Syncing...' : '--'),
                                  showWeekdays: false, // CapsuleBarChart already renders weekdays
                                  isExpandedNotifier: _expandNotifiers[5],
                                  onTap: () => _onToggleCard(5),
                                  chart: CapsuleBarChart(
                                    values: data.weeklyOxygen,
                                    activeColor: AppColors.greenMetric,
                                  ),
                                  whatItIs: oxygenRec.whatItIs,
                                  yourReading: oxygenRec.yourReading,
                                  doThis: oxygenRec.doThis,
                                ),
                                SizedBox(height: itemSpacing),

                                // 7. Expandable Breathing Rate Card (Figma Node 75:1727)
                                VitalsExpandableMetricCard(
                                  svgIcon: AppIcons.lotusFlower,
                                  iconColor: AppColors.cyanAccent,
                                  title: 'Breathing rate',
                                  value: data.breathingRate > 0
                                      ? '${data.breathingRate}'
                                      : (isLoading ? '...' : '--'),
                                  unit: '/min.',
                                  status: data.breathingRate > 0
                                      ? breathingRec.status
                                      : (isLoading ? 'Syncing...' : '--'),
                                  showWeekdays: true,
                                  isExpandedNotifier: _expandNotifiers[6],
                                  onTap: () => _onToggleCard(6),
                                  chart: SparklineChart(
                                    values: data.weeklyBreathing,
                                    lineColor: AppColors.cyanAccent,
                                    height: breathingSparklineHeight,
                                    showFill: true,
                                    width: double.infinity,
                                  ),
                                  whatItIs: breathingRec.whatItIs,
                                  yourReading: breathingRec.yourReading,
                                  doThis: breathingRec.doThis,
                                ),
                                SizedBox(height: cardSpacing),

                                // 8. Blood Pressure Trend Card (Skin temp commented out as hardware does not support it)
                                VitalsTwinTrendCards(
                                  bloodPressure: data.bloodPressure,
                                  // skinTempDiff: data.skinTempDiff,
                                  isBpExpandedNotifier: _expandNotifiers[7],
                                  // isSkinTempExpandedNotifier: _expandNotifiers[8],
                                  onBloodPressureTap: () => _onToggleCard(7),
                                  // onSkinTempTap: () => _onToggleCard(8),
                                ),
                                SizedBox(height: cardSpacing),
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
          },
        );
      },
    );
  }
}

