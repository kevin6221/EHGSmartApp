import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/vitals_model.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/vitals/vitals_bloc.dart';
import '../../blocs/vitals/vitals_state.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_state.dart';
import '../../widgets/charts/hypnogram_chart.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/detail_screen_app_bar.dart';
import '../../widgets/common/screen_header.dart';

/// Full-screen Sleep Detail screen adhering to the EHG design system.
///
/// Features sleep architecture hypnogram, deep/REM/light/awake phase metrics,
/// personal sleep need fulfillment, and clinical restorative insights.
class SleepDetailScreen extends StatelessWidget {
  const SleepDetailScreen({super.key});

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSpacing = (r.height * 0.016).clamp(12.0, 18.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SkyHeaderBackground(height: r.hp(0.30), stops: const [0.0, 0.85]),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Navigation Bar
                const DetailScreenAppBar(
                  statusText: 'Last Night',
                  statusColor: AppColors.readinessSleep,
                ),

                // Main Scrollable Body
                Expanded(
                  child: BlocBuilder<WellnessBloc, WellnessState>(
                    builder: (context, wellnessState) {
                      return BlocBuilder<VitalsBloc, VitalsState>(
                        builder: (context, vitalsState) {
                          return BlocBuilder<BandBloc, BandState>(
                            builder: (context, bandState) {
                              final bandVitals = bandState.lastSyncedVitals;
                              final vitalsData = vitalsState.data;
                              final wellness = wellnessState.data;

                              final int totalMinutes = (bandVitals?.sleepMinutes ?? 0) > 0
                                  ? bandVitals!.sleepMinutes
                                  : ((wellness?.sleepHours ?? 0) > 0
                                      ? (wellness!.sleepHours * 60).round()
                                      : 487);

                              final int deepMinutes = (bandVitals?.deepSleepMinutes ?? 0) > 0
                                  ? bandVitals!.deepSleepMinutes
                                  : (totalMinutes * 0.21).round();

                              final int remMinutes = (totalMinutes * 0.23).round();
                              final int awakeMinutes = 36;
                              final int lightMinutes = (totalMinutes - deepMinutes - remMinutes).clamp(120, 360);

                              final String sleepWindow = vitalsData?.sleepWindow ?? '10:45 PM – 6:52 AM';
                              final double sleepHours = totalMinutes / 60.0;
                              final double efficiency = ((totalMinutes / (totalMinutes + awakeMinutes)) * 100).clamp(70.0, 98.0);

                              final List<double> weeklySleep = (wellness?.weeklySleep.length == 7)
                                  ? wellness!.weeklySleep
                                  : const [7.2, 6.8, 7.5, 8.0, 6.5, 8.1, 7.4];

                              final List<SleepInterval> intervals = vitalsData?.sleepIntervals ?? const [
                                SleepInterval(startOffset: 0.00, widthFraction: 0.12, phase: SleepPhase.light),
                                SleepInterval(startOffset: 0.12, widthFraction: 0.20, phase: SleepPhase.deep),
                                SleepInterval(startOffset: 0.32, widthFraction: 0.12, phase: SleepPhase.light),
                                SleepInterval(startOffset: 0.44, widthFraction: 0.18, phase: SleepPhase.rem),
                                SleepInterval(startOffset: 0.62, widthFraction: 0.20, phase: SleepPhase.deep),
                                SleepInterval(startOffset: 0.82, widthFraction: 0.12, phase: SleepPhase.light),
                                SleepInterval(startOffset: 0.94, widthFraction: 0.06, phase: SleepPhase.awake),
                              ];

                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  r.horizontalPadding,
                                  8.0,
                                  r.horizontalPadding,
                                  r.hp(0.10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title Header
                                    Text(
                                      'Sleep Performance',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: r.font(26.0),
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Sleep stages, autonomic recovery, and restorative efficiency',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: r.font(13.0),
                                        fontWeight: FontWeight.w400,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // Hero Sleep Summary Card
                                    _buildHeroCard(
                                      context: context,
                                      r: r,
                                      sleepHours: sleepHours,
                                      totalMinutes: totalMinutes,
                                      efficiency: efficiency,
                                      sleepWindow: sleepWindow,
                                      deepMinutes: deepMinutes,
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // Hypnogram Stage Intervals Chart
                                    _buildHypnogramCard(
                                      context: context,
                                      r: r,
                                      intervals: intervals,
                                      totalMinutes: totalMinutes,
                                      deepMinutes: deepMinutes,
                                      remMinutes: remMinutes,
                                      lightMinutes: lightMinutes,
                                      awakeMinutes: awakeMinutes,
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // Weekly Sleep Consistency Card
                                    _buildWeeklySleepConsistencyCard(
                                      context: context,
                                      r: r,
                                      weeklySleep: weeklySleep,
                                    ),
                                    SizedBox(height: itemSpacing),

                                    // Sleep Coaching Insights Card
                                    _buildSleepInsightsCard(
                                      context: context,
                                      r: r,
                                      deepMinutes: deepMinutes,
                                      totalMinutes: totalMinutes,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required BuildContext context,
    required Responsive r,
    required double sleepHours,
    required int totalMinutes,
    required double efficiency,
    required String sleepWindow,
    required int deepMinutes,
  }) {
    final int hours = totalMinutes ~/ 60;
    final int mins = totalMinutes % 60;

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 16.0 : 20.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.04),
          blurRadius: 14.0,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.vitalsSleepIcon,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.readinessSleep.withValues(alpha: 0.35),
                          blurRadius: 10.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const AppSvgIcon(
                      AppIcons.sleepZ,
                      color: AppColors.white,
                      size: 18.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Total Sleep',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(15.0),
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.readinessSleep.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  sleepHours >= 7.5 ? 'Restorative' : 'Good',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(11.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.readinessSleep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${hours}h ${mins}m',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(40.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.readinessSleep,
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '(${sleepHours.toStringAsFixed(1)} hrs)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(14.0),
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: 14.0),

          // 3 Sub-Metric Capsules
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniPill(
                  label: 'Efficiency',
                  value: '${efficiency.round()}%',
                  accentColor: AppColors.greenMetric,
                  r: r,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildMetricMiniPill(
                  label: 'Deep Sleep',
                  value: '${deepMinutes}m',
                  accentColor: AppColors.primary,
                  r: r,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildMetricMiniPill(
                  label: 'Bedtime',
                  value: sleepWindow.split('–').first.trim(),
                  accentColor: AppColors.purpleMetric,
                  r: r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricMiniPill({
    required String label,
    required String value,
    required Color accentColor,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHypnogramCard({
    required BuildContext context,
    required Responsive r,
    required List<SleepInterval> intervals,
    required int totalMinutes,
    required int deepMinutes,
    required int remMinutes,
    required int lightMinutes,
    required int awakeMinutes,
  }) {
    final stages = [
      {'name': 'Deep Sleep', 'time': '${deepMinutes}m', 'pct': (deepMinutes / totalMinutes * 100).round(), 'color': AppColors.primary, 'desc': 'Physical recovery & tissue repair'},
      {'name': 'REM Sleep', 'time': '${remMinutes}m', 'pct': (remMinutes / totalMinutes * 100).round(), 'color': AppColors.readinessSleep, 'desc': 'Memory consolidation & mental focus'},
      {'name': 'Light Sleep', 'time': '${lightMinutes}m', 'pct': (lightMinutes / totalMinutes * 100).round(), 'color': AppColors.cyanAccent, 'desc': 'Foundational restorative state'},
      {'name': 'Awake', 'time': '${awakeMinutes}m', 'pct': (awakeMinutes / totalMinutes * 100).round(), 'color': AppColors.textSecondary, 'desc': 'Normal nighttime micro-arousals'},
    ];

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Architecture & Stages',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(15.0),
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Overnight hypnogram transitions and restorative depth',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          // Hypnogram Timeline Chart
          HypnogramChart(intervals: intervals),
          const SizedBox(height: 18.0),

          // Stage Details Rows
          ...stages.map((st) {
            final color = st['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              st['name'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(13.0),
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              '${st['time']} (${st['pct']}%)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(13.0),
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          st['desc'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklySleepConsistencyCard({
    required BuildContext context,
    required Responsive r,
    required List<double> weeklySleep,
  }) {
    final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Sleep Consistency',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              Text(
                'Goal: 8.0h',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.readinessSleep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // 7-day capsule bars
          SizedBox(
            height: 114.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final double hrs = (i < weeklySleep.length) ? weeklySleep[i] : 0.0;
                final double ratio = (hrs / 8.5).clamp(0.08, 1.0);
                final bool isToday = i == todayIdx;
                final bool isFuture = i > todayIdx;

                final Color barColor = isToday
                    ? AppColors.readinessSleep
                    : (isFuture ? AppColors.readinessSleep.withValues(alpha: 0.12) : AppColors.readinessSleep.withValues(alpha: 0.55));

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isFuture && hrs > 0)
                      Text(
                        hrs.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(9.0),
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? AppColors.readinessSleep : context.textSecondary,
                        ),
                      )
                    else
                      const SizedBox(height: 13.0),
                    const SizedBox(height: 4.0),
                    Container(
                      width: 14.0,
                      height: 56.0 * ratio,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      _weekdays[i],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday ? AppColors.readinessSleep : context.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepInsightsCard({
    required BuildContext context,
    required Responsive r,
    required int deepMinutes,
    required int totalMinutes,
  }) {
    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.readinessSleep.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const AppSvgIcon(
                  AppIcons.sleepZ,
                  color: AppColors.readinessSleep,
                  size: 16.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Recovery Lever: Deep Sleep',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(14.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            deepMinutes >= 90
                ? 'Your deep sleep accounted for ${(deepMinutes / totalMinutes * 100).round()}% of your night ($deepMinutes minutes). This prolonged slow-wave sleep maximized cellular repair, human growth hormone secretion, and autonomic replenishment.'
                : 'Prioritizing a cool bedroom (18–20°C) and winding down screens 45 minutes prior to sleep can lengthen your deep restorative sleep cycle.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
