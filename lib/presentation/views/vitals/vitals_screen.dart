import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/vitals/vitals_bloc.dart';
import '../../blocs/vitals/vitals_state.dart';
import '../../widgets/charts/capsule_bar_chart.dart';
import '../../widgets/charts/sparkline_chart.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/vitals_expandable_metric_card.dart';
import 'widgets/vitals_heart_rate_card.dart';
import 'widgets/vitals_hrv_card.dart';
import 'widgets/vitals_sleep_summary_card.dart';
import 'widgets/vitals_stress_card.dart';
import 'widgets/vitals_twin_trend_cards.dart';

/// Vitals dashboard screen displaying sleep, heart metrics, stress, oxygen, and trend vitals.
///
/// Features expandable/collapsible metric cards for HRV, Resting HR, Blood Oxygen, and Breathing Rate
/// with butter-smooth transitions matching Figma Node 71:886 and 119:1442.
class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  late final List<ValueNotifier<bool>> _expandNotifiers;

  @override
  void initState() {
    super.initState();
    _expandNotifiers = List.generate(4, (_) => ValueNotifier<bool>(false));
  }

  @override
  void dispose() {
    for (final notifier in _expandNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _onToggleCard(int index) {
    final willExpand = !_expandNotifiers[index].value;
    for (int i = 0; i < _expandNotifiers.length; i++) {
      _expandNotifiers[i].value = (i == index) ? willExpand : false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSpacing = (r.height * 0.016).clamp(10.0, 16.0);
    final cardSpacing = (r.height * 0.019).clamp(12.0, 18.0);
    final breathingSparklineHeight = (r.height * 0.045).clamp(32.0, 44.0);

    return BlocBuilder<VitalsBloc, VitalsState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Top Sky Gradient
              SkyHeaderBackground(height: r.hp(0.32), stops: const [0.0, 0.85]),

              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    context.read<BandBloc>().add(SyncVitalsEvent());
                    context.read<BandBloc>().add(StartLiveHeartRateEvent());
                    await Future.delayed(const Duration(milliseconds: 1200));
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
                        const ScreenHeader(title: 'Vitals',showAvatar: true,showOnlineIndicator: true,),
                      SizedBox(height: cardSpacing),

                      // 1. Last night Sleep Summary Card (Figma Node 73:1319)
                      VitalsSleepSummaryCard(
                        totalSleep: data.totalSleep,
                        sleepWindow: data.sleepWindow,
                        sleepIntervals: data.sleepIntervals,
                      ),
                      SizedBox(height: cardSpacing),

                      // 2. Heart Rate Card (Figma Node 73:1418)
                      BlocBuilder<BandBloc, BandState>(
                        buildWhen: (prev, curr) => prev.liveHeartRate != curr.liveHeartRate,
                        builder: (context, bandState) {
                          final hr = bandState.liveHeartRate > 0
                              ? bandState.liveHeartRate
                              : data.currentHeartRate;
                          return VitalsHeartRateCard(
                            currentHeartRate: hr,
                            weeklyHeartRate: data.weeklyHeartRate,
                          );
                        },
                      ),
                      SizedBox(height: cardSpacing),

                      // 3. Stress Card with Interactive Scrubber (Figma Node 71:1042)
                      VitalsStressCard(
                        stressScore: data.stressScore,
                        stressStatus: data.stressStatus,
                        stressTimeline: data.stressTimeline,
                      ),
                      SizedBox(height: cardSpacing),

                      // 4. Expandable Heart Rate Variability Card (Figma Node 73:1530 & 119:1517)
                      VitalsHrvCard(
                        hrvMs: data.hrvMs,
                        status: 'Below your usual',
                        weeklyHrv: data.weeklyHrv,
                        isExpandedNotifier: _expandNotifiers[0],
                        onTap: () => _onToggleCard(0),
                      ),
                      SizedBox(height: itemSpacing),

                      // 5. Expandable Resting Heart Rate Card (Figma Node 73:1559)
                      VitalsExpandableMetricCard(
                        svgIcon: AppIcons.restingLounger,
                        iconColor: AppColors.orangeMetric,
                        title: 'Resting Heart Rate',
                        value: data.restingHr > 0 ? '${data.restingHr}' : '--',
                        unit: 'bpm',
                        status: data.restingHr > 0 ? 'In your range' : '--',
                        showWeekdays: true,
                        isExpandedNotifier: _expandNotifiers[1],
                        onTap: () => _onToggleCard(1),
                        chart: SparklineChart(
                          values: data.weeklyRestingHr,
                          lineColor: AppColors.orangeMetric,
                          showFill: true,
                        ),
                        whatItIs:
                            'Your heart rate when completely at rest, measured during deep sleep or quiet wakefulness. A lower resting heart rate indicates stronger cardiovascular efficiency.',
                        yourReading: data.restingHr > 0
                            ? 'In your optimal range. Your resting heart rate indicates healthy autonomic recovery.'
                            : 'No resting heart rate data recorded yet. Wear your band during sleep to track baseline readings.',
                        doThis:
                            'Prioritize an extra hour of sleep tonight and avoid heavy meals or alcohol before bed.',
                      ),
                      SizedBox(height: itemSpacing),

                      // 6. Expandable Blood Oxygen Card (Figma Node 73:1590) - Single Weekdays
                      VitalsExpandableMetricCard(
                        svgIcon: AppIcons.bloodDroplets,
                        iconColor: AppColors.greenMetric,
                        title: 'Blood oxygen',
                        value: data.bloodOxygen > 0 ? '${data.bloodOxygen}' : '--',
                        unit: '%',
                        status: data.bloodOxygen > 0 ? 'In your range' : '--',
                        showWeekdays: false, // CapsuleBarChart already renders weekdays
                        isExpandedNotifier: _expandNotifiers[2],
                        onTap: () => _onToggleCard(2),
                        chart: CapsuleBarChart(
                          values: data.weeklyOxygen,
                          activeColor: AppColors.greenMetric,
                        ),
                        whatItIs:
                            'The percentage of oxygen your red blood cells carry from your lungs to the rest of your body. Normal levels range from 95% to 100%.',
                        yourReading: data.bloodOxygen > 0
                            ? 'In your optimal range. Your blood oxygen saturation has remained healthy and stable.'
                            : 'No blood oxygen data recorded yet. Sync your band or trigger a measurement to view saturation levels.',
                        doThis:
                            'Maintain optimal hydration and practice deep diaphragmatic breathing throughout your day.',
                      ),
                      SizedBox(height: itemSpacing),

                      // 7. Expandable Breathing Rate Card (Figma Node 75:1727)
                      VitalsExpandableMetricCard(
                        svgIcon: AppIcons.lotusFlower,
                        iconColor: AppColors.cyanAccent,
                        title: 'Breathing rate',
                        value: data.breathingRate > 0 ? '${data.breathingRate}' : '--',
                        unit: '/min.',
                        status: data.breathingRate > 0 ? 'Normal' : '--',
                        showWeekdays: true,
                        isExpandedNotifier: _expandNotifiers[3],
                        onTap: () => _onToggleCard(3),
                        chart: SparklineChart(
                          values: data.weeklyBreathing,
                          lineColor: AppColors.cyanAccent,
                          height: breathingSparklineHeight,
                          showFill: true,
                        ),
                        whatItIs:
                            'The number of breaths you take per minute during sleep. A steady, baseline breathing rate indicates undisturbed sleep and good respiratory efficiency.',
                        yourReading:
                            'Slightly elevated at ${data.breathingRate} breaths/min. This can be caused by physical exertion earlier in the day, warmer bedroom temperatures, or mild nasal congestion.',
                        doThis:
                            'Wind down with 5 minutes of slow box breathing before sleep to calm your autonomic nervous system.',
                      ),
                      SizedBox(height: cardSpacing),

                      // 8. Unified Twin Trend Card (Figma Node 75:1819 / 119:1654)
                      VitalsTwinTrendCards(
                        bloodPressure: data.bloodPressure,
                        skinTempDiff: data.skinTempDiff,
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
  }
}
