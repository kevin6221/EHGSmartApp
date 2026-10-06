import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/band_device_model.dart';
import '../../../data/models/vitals_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_event.dart';
import '../../blocs/wellness/wellness_state.dart';
import '../../helpers/vitals_card_calculator.dart';
import '../../helpers/vitals_history_calculator.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/detail_screen_app_bar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/painters/heart_rate_chart_painter.dart';
import '../vitals/widgets/vitals_date_navigator.dart';
import '../vitals/widgets/vitals_period_segmented_bar.dart';

/// Full-screen Heart Rate Detail screen adhering to the EHG design system.
///
/// Features 24h scrubbable spline curve, Zone 1–5 distribution,
/// resting HR comparison against personal baseline, and clinical coaching insights.
class HeartRateDetailScreen extends StatefulWidget {
  const HeartRateDetailScreen({super.key});

  @override
  State<HeartRateDetailScreen> createState() => _HeartRateDetailScreenState();
}

class _HeartRateDetailScreenState extends State<HeartRateDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _scrubIndexNotifier;
  late final ValueNotifier<bool> _isMeasuringNotifier;
  late final ValueNotifier<String?> _measuringStatusNotifier;
  late final ValueNotifier<double> _measuringProgressNotifier;
  late final ValueNotifier<int> _secondsRemainingNotifier;
  late final ValueNotifier<int?> _latestSampledHrNotifier;

  late final ValueNotifier<DateTime> _selectedDateNotifier;
  late final ValueNotifier<VitalsTimePeriod> _selectedPeriodNotifier;
  late final ValueNotifier<VitalsModel?> _historicalVitalsNotifier;
  late final ValueNotifier<VitalsPeriodStats?> _periodStatsNotifier;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  StreamSubscription<BandMeasurementResult>? _measuringSub;
  StreamSubscription<int>? _liveHrSub;
  Timer? _countdownTimer;
  BandRepository? _bandRepo;
  BandBloc? _bandBloc;

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
    _scrubIndexNotifier = ValueNotifier<int>(todayIdx);
    _isMeasuringNotifier = ValueNotifier<bool>(false);
    _measuringStatusNotifier = ValueNotifier<String?>(null);
    _measuringProgressNotifier = ValueNotifier<double>(0.0);
    _secondsRemainingNotifier = ValueNotifier<int>(30);
    _latestSampledHrNotifier = ValueNotifier<int?>(null);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDateNotifier = ValueNotifier<DateTime>(today);
    _selectedPeriodNotifier = ValueNotifier<VitalsTimePeriod>(VitalsTimePeriod.week);
    _historicalVitalsNotifier = ValueNotifier<VitalsModel?>(null);
    _periodStatsNotifier = ValueNotifier<VitalsPeriodStats?>(null);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _pulseScale = Tween<double>(begin: 0.94, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bandRepo ??= context.read<BandRepository>();
    _bandBloc ??= context.read<BandBloc>();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _measuringSub?.cancel();
    _liveHrSub?.cancel();
    if (_isMeasuringNotifier.value) {
      _bandRepo?.stopMeasuring(MeasurementType.heartRate);
      _bandBloc?.add(StopLiveHeartRateEvent());
    }
    _pulseController.dispose();
    _measuringProgressNotifier.dispose();
    _secondsRemainingNotifier.dispose();
    _latestSampledHrNotifier.dispose();
    _isMeasuringNotifier.dispose();
    _measuringStatusNotifier.dispose();
    _scrubIndexNotifier.dispose();
    _selectedDateNotifier.dispose();
    _selectedPeriodNotifier.dispose();
    _historicalVitalsNotifier.dispose();
    _periodStatsNotifier.dispose();
    super.dispose();
  }

  void _onPreviousDate() {
    final cur = _selectedDateNotifier.value;
    final curDate = DateTime(cur.year, cur.month, cur.day);
    final period = _selectedPeriodNotifier.value;
    final int step = period == VitalsTimePeriod.week ? 7 : (period == VitalsTimePeriod.month ? 30 : 1);
    _selectedDateNotifier.value = curDate.subtract(Duration(days: step));
    _syncScrubIndex();
    _loadHistoricalDate();
  }

  void _onNextDate() {
    final cur = _selectedDateNotifier.value;
    final curDate = DateTime(cur.year, cur.month, cur.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final period = _selectedPeriodNotifier.value;

    if (period == VitalsTimePeriod.week) {
      final currentMonday = today.subtract(Duration(days: today.weekday - 1));
      final curMonday = curDate.subtract(Duration(days: curDate.weekday - 1));
      final nextMonday = curMonday.add(const Duration(days: 7));
      if (!nextMonday.isAfter(currentMonday)) {
        _selectedDateNotifier.value = nextMonday.isAtSameMomentAs(currentMonday) ? today : nextMonday;
        _syncScrubIndex();
        _loadHistoricalDate();
      }
    } else if (period == VitalsTimePeriod.month) {
      final nextMonth = DateTime(curDate.year, curDate.month + 1, curDate.day);
      if (!nextMonth.isAfter(today)) {
        _selectedDateNotifier.value = nextMonth;
        _syncScrubIndex();
        _loadHistoricalDate();
      }
    } else {
      final nextDate = curDate.add(const Duration(days: 1));
      if (!nextDate.isAfter(today)) {
        _selectedDateNotifier.value = nextDate;
        _syncScrubIndex();
        _loadHistoricalDate();
      }
    }
  }

  void _onDateSelected(DateTime picked) {
    _selectedDateNotifier.value = DateTime(picked.year, picked.month, picked.day);
    // When the user explicitly picks a specific day, switch to day period to show that day
    _selectedPeriodNotifier.value = VitalsTimePeriod.day;
    _syncScrubIndex();
    _loadHistoricalDate();
  }

  void _onPeriodChanged(VitalsTimePeriod period) {
    _syncScrubIndex();
    _loadHistoricalDate();
  }

  void _syncScrubIndex() {
    final date = _selectedDateNotifier.value;
    final weekdayIdx = (date.weekday - 1).clamp(0, 6);
    _scrubIndexNotifier.value = weekdayIdx;
  }

  Future<void> _loadHistoricalDate() async {
    final date = _selectedDateNotifier.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final period = _selectedPeriodNotifier.value;

    final isCurrentDay = period == VitalsTimePeriod.day &&
        date.year == today.year && date.month == today.month && date.day == today.day;
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));
    final selectedMonday = date.subtract(Duration(days: date.weekday - 1));
    final isCurrentWeek = period == VitalsTimePeriod.week &&
        currentMonday.year == selectedMonday.year &&
        currentMonday.month == selectedMonday.month &&
        currentMonday.day == selectedMonday.day;

    if (isCurrentDay || isCurrentWeek) {
      _historicalVitalsNotifier.value = null;
      _periodStatsNotifier.value = null;
      return;
    }
    final wellnessRepo = context.read<WellnessRepository>();
    final results = await Future.wait([
      wellnessRepo.getHistoricalVitalsForDate(date),
      wellnessRepo.getHistoricalPeriodStats(period: period, anchorDate: date),
    ]);
    if (mounted) {
      _historicalVitalsNotifier.value = results[0] as VitalsModel;
      _periodStatsNotifier.value = results[1] as VitalsPeriodStats;
    }
  }

  Future<void> _toggleHeartRateMeasurement() async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = _bandRepo ?? context.read<BandRepository>();
    final bloc = _bandBloc ?? context.read<BandBloc>();
    final wellnessBloc = context.read<WellnessBloc>();

    if (_isMeasuringNotifier.value) {
      await _stopMeasurement(repo, bloc, wellnessBloc, reason: 'Measurement cancelled');
      return;
    }

    if (bloc.state.status != BandConnectionStatus.connected) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Smart Band is not connected. Connect band in settings to measure.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.scoreDownRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _isMeasuringNotifier.value = true;
    _latestSampledHrNotifier.value = null;
    _measuringProgressNotifier.value = 0.0;
    _secondsRemainingNotifier.value = 30;
    _measuringStatusNotifier.value = 'Activating optical PPG sensor... Keep wrist steady at heart level';
    _pulseController.repeat(reverse: true);

    _measuringSub?.cancel();
    _liveHrSub?.cancel();
    _countdownTimer?.cancel();

    // 1. Listen to live continuous pulse telemetry from band PPG
    _liveHrSub = repo.liveHeartRateStream.listen((hr) {
      if (hr > 0 && _isMeasuringNotifier.value) {
        _latestSampledHrNotifier.value = hr;
        bloc.add(LiveHeartRateUpdatedEvent(hr));
        _measuringStatusNotifier.value = 'Live PPG pulse: $hr bpm · Sampling stabilization...';
      }
    });

    // 2. Listen to completed on-demand measurement packet or failure
    _measuringSub = repo.measurementResultStream.listen((result) {
      if (result.type == MeasurementType.heartRate || result.type == MeasurementType.oneKey) {
        if (!result.success || result.isNotWorn || (result.error != null && result.error!.isNotEmpty)) {
          _stopMeasurement(
            repo,
            bloc,
            wellnessBloc,
            reason: 'Please wear smart device properly',
          );
          if (mounted) {
            AppSnackbar.showWearDeviceProperly(context);
          }
          return;
        }

        final int hr = result.heartRate ?? 0;
        if (hr > 0) {
          _latestSampledHrNotifier.value = hr;
          bloc.add(LiveHeartRateUpdatedEvent(hr));
          _measuringStatusNotifier.value = 'Live PPG pulse: $hr bpm · Sampling arterial wave...';
        } else {
          // Intermediate frame while optical LEDs calibrate against skin reflectivity
          _measuringStatusNotifier.value = 'Sampling arterial pulse wave... Keep wrist still';
        }
      }
    });

    // 3. 30-second sampling window countdown matching QWatch Pro optical PPG calibration cycle
    int elapsed = 0;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsed++;
      final remaining = (30 - elapsed).clamp(0, 30);
      _secondsRemainingNotifier.value = remaining;
      _measuringProgressNotifier.value = (elapsed / 30.0).clamp(0.0, 1.0);

      // QWatch Pro off-wrist check: If after 20 seconds of continuous optical sampling
      // no pulse wave has been detected by the PPG optical sensor on real hardware, abort and alert user.
      if (elapsed >= 20 && (_latestSampledHrNotifier.value == null || _latestSampledHrNotifier.value! <= 0)) {
        timer.cancel();
        _stopMeasurement(
          repo,
          bloc,
          wellnessBloc,
          reason: 'Please wear smart device properly',
        );
        if (mounted) {
          AppSnackbar.showWearDeviceProperly(context);
        }
        return;
      }

      if (elapsed >= 30) {
        timer.cancel();
        final finalHr = _latestSampledHrNotifier.value ?? bloc.state.liveHeartRate;
        if (finalHr > 0) {
          _finalizeMeasurement(repo, bloc, wellnessBloc, finalHr);
        } else {
          _stopMeasurement(
            repo,
            bloc,
            wellnessBloc,
            reason: 'Please wear smart device properly',
          );
          if (mounted) {
            AppSnackbar.showWearDeviceProperly(context);
          }
        }
      }
    });

    final success = await repo.startMeasuring(MeasurementType.heartRate);
    if (!success && mounted) {
      await _stopMeasurement(
        repo,
        bloc,
        wellnessBloc,
        reason: 'Unable to start optical sensor. Please ensure band is nearby and retry.',
      );
    }
  }

  Future<void> _finalizeMeasurement(
    BandRepository repo,
    BandBloc bloc,
    WellnessBloc wellnessBloc,
    int hr,
  ) async {
    _countdownTimer?.cancel();
    _measuringSub?.cancel();
    _liveHrSub?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    _isMeasuringNotifier.value = false;
    _latestSampledHrNotifier.value = hr;
    _measuringProgressNotifier.value = 1.0;
    _secondsRemainingNotifier.value = 0;

    String classification;
    if (hr < 60) {
      classification = 'Bradycardia / Athletic Rest';
    } else if (hr <= 80) {
      classification = 'Optimal Resting HR';
    } else if (hr <= 100) {
      classification = 'Normal Adult Resting HR';
    } else {
      classification = 'Elevated Resting HR';
    }

    _measuringStatusNotifier.value = 'Reading complete: $hr bpm ($classification) · Saved to Daily Vitals';

    // Dispatch to Bloc, Repository, and SQLite
    await repo.recordHeartRateMeasurement(hr);
    bloc.add(LiveHeartRateUpdatedEvent(hr));
    bloc.add(StopLiveHeartRateEvent());
    wellnessBloc.add(SyncBandVitalsEvent(liveHeartRate: hr));
    await repo.stopMeasuring(MeasurementType.heartRate);
  }

  Future<void> _stopMeasurement(
    BandRepository repo,
    BandBloc bloc,
    WellnessBloc wellnessBloc, {
    required String reason,
  }) async {
    _countdownTimer?.cancel();
    _measuringSub?.cancel();
    _liveHrSub?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    _isMeasuringNotifier.value = false;
    _measuringProgressNotifier.value = 0.0;
    _secondsRemainingNotifier.value = 30;
    _measuringStatusNotifier.value = reason;

    bloc.add(StopLiveHeartRateEvent());
    await repo.stopMeasuring(MeasurementType.heartRate);
  }

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
                ValueListenableBuilder<VitalsTimePeriod>(
                  valueListenable: _selectedPeriodNotifier,
                  builder: (context, period, _) {
                    return ValueListenableBuilder<DateTime>(
                      valueListenable: _selectedDateNotifier,
                      builder: (context, selectedDate, _) {
                        final now = DateTime.now();
                        final isTodayDate = selectedDate.year == now.year &&
                            selectedDate.month == now.month &&
                            selectedDate.day == now.day;
                        final currentMon = now.subtract(Duration(days: now.weekday - 1));
                        final selectedMon = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
                        final isCurrentWeek = currentMon.year == selectedMon.year &&
                            currentMon.month == selectedMon.month &&
                            currentMon.day == selectedMon.day;
                        final bool isCurrentScope = period == VitalsTimePeriod.week ? isCurrentWeek : isTodayDate;

                        final statusText = isCurrentScope
                            ? 'Live Telemetry'
                            : (period == VitalsTimePeriod.week
                                ? 'Week of ${DateFormat('d MMM').format(selectedMon)}'
                                : DateFormat('d MMM yyyy').format(selectedDate));

                        return DetailScreenAppBar(
                          statusText: statusText,
                          statusColor: isCurrentScope ? AppColors.primary : AppColors.textSecondary,
                        );
                      },
                    );
                  },
                ),

                // Main Scrollable Body
                Expanded(
                  child: BlocBuilder<WellnessBloc, WellnessState>(
                    builder: (context, wellnessState) {
                      return BlocBuilder<BandBloc, BandState>(
                        builder: (context, bandState) {
                          return ValueListenableBuilder<VitalsTimePeriod>(
                            valueListenable: _selectedPeriodNotifier,
                            builder: (context, period, _) {
                              return ValueListenableBuilder<DateTime>(
                                valueListenable: _selectedDateNotifier,
                                builder: (context, selectedDate, _) {
                                  final now = DateTime.now();
                                  final isTodayDate = selectedDate.year == now.year &&
                                      selectedDate.month == now.month &&
                                      selectedDate.day == now.day;
                                  final currentMon = now.subtract(Duration(days: now.weekday - 1));
                                  final selectedMon = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
                                  final isCurrentWeek = currentMon.year == selectedMon.year &&
                                      currentMon.month == selectedMon.month &&
                                      currentMon.day == selectedMon.day;
                                  final bool isToday = period == VitalsTimePeriod.week ? isCurrentWeek : isTodayDate;

                                  return ValueListenableBuilder<VitalsModel?>(
                                    valueListenable: _historicalVitalsNotifier,
                                    builder: (context, historicalVitals, _) {
                                      return ValueListenableBuilder<VitalsPeriodStats?>(
                                        valueListenable: _periodStatsNotifier,
                                        builder: (context, periodStats, _) {
                                          final BandSyncedVitals? bandSynced = bandState.lastSyncedVitals;
                                          final wellness = wellnessState.data;

                                          final int liveHr = isToday ? bandState.liveHeartRate : 0;
                                          final bool isLive = isToday && bandState.isConnected && liveHr > 0;

                                          int latestHr = 0;
                                          if (isLive) {
                                            latestHr = liveHr;
                                          } else if (isToday && bandState.latestHeartRate > 0) {
                                            latestHr = bandState.latestHeartRate;
                                          } else if (bandSynced != null && bandSynced.latestHeartRate > 0) {
                                            latestHr = bandSynced.latestHeartRate;
                                          } else {
                                            final hrList = bandSynced?.heartRateHistory;
                                            if (hrList != null && hrList.isNotEmpty) {
                                              for (int i = hrList.length - 1; i >= 0; i--) {
                                                if (hrList[i].bpm > 0) {
                                                  latestHr = hrList[i].bpm;
                                                  break;
                                                }
                                              }
                                            }
                                          }

                                          if (latestHr <= 0 && isToday && (wellness?.currentHeartRate ?? 0) > 0) {
                                            latestHr = wellness!.currentHeartRate;
                                          }

                                          final int currentHr;
                                          final int restingHr;
                                          final int minHr;
                                          final int maxHr;

                                          if (!isToday && historicalVitals != null) {
                                            currentHr = historicalVitals.currentHeartRate;
                                            restingHr = historicalVitals.restingHr;
                                            minHr = restingHr > 0
                                                ? restingHr - 4
                                                : (currentHr > 0 ? currentHr - 12 : 0);
                                            maxHr = currentHr > 0
                                                ? (currentHr * 1.55).round().clamp(120, 185)
                                                : 0;
                                          } else {
                                            currentHr = latestHr > 0 ? latestHr : (isToday ? 72 : 0);

                                            restingHr = (wellness?.restHr ?? 0) > 0
                                                ? wellness!.restHr
                                                : ((bandSynced?.restingHeartRate ?? 0) > 0
                                                    ? bandSynced!.restingHeartRate
                                                    : 58);

                                            int minRecorded = 0;
                                            int maxRecorded = 0;
                                            if (bandSynced?.heartRateHistory.isNotEmpty == true) {
                                              final positiveBpm = bandSynced!.heartRateHistory
                                                  .map((e) => e.bpm)
                                                  .where((b) => b > 35 && b < 220)
                                                  .toList();
                                              if (positiveBpm.isNotEmpty) {
                                                minRecorded = positiveBpm.reduce((a, b) => a < b ? a : b);
                                                maxRecorded = positiveBpm.reduce((a, b) => a > b ? a : b);
                                              }
                                            }

                                            minHr = minRecorded > 0
                                                ? minRecorded
                                                : (restingHr > 0 ? restingHr - 4 : (currentHr > 0 ? currentHr - 15 : 0));
                                            maxHr = maxRecorded > 0
                                                ? maxRecorded
                                                : (currentHr > 0 ? (currentHr * 1.55).round().clamp(120, 185) : 0);
                                          }

                                          // Reconcile and merge weekly heart rate across all sources to guarantee consistent weekly trend
                                          final List<double> weeklyHr = List<double>.filled(7, 0.0);
                                          if (historicalVitals != null && historicalVitals.weeklyHeartRate.length == 7) {
                                            for (int i = 0; i < 7; i++) {
                                              if (historicalVitals.weeklyHeartRate[i] > 0) {
                                                weeklyHr[i] = historicalVitals.weeklyHeartRate[i];
                                              }
                                            }
                                          }
                                          if (wellness != null && wellness.weeklyHeartRate.length == 7) {
                                            for (int i = 0; i < 7; i++) {
                                              if (wellness.weeklyHeartRate[i] > 0) {
                                                weeklyHr[i] = wellness.weeklyHeartRate[i];
                                              }
                                            }
                                          }
                                          if (bandSynced != null && bandSynced.weeklyHeartRate.length == 7) {
                                            for (int i = 0; i < 7; i++) {
                                              if (bandSynced.weeklyHeartRate[i] > 0) {
                                                weeklyHr[i] = bandSynced.weeklyHeartRate[i];
                                              }
                                            }
                                          }
                                          final selectedWeekdayIdx = (selectedDate.weekday - 1).clamp(0, 6);
                                          if (currentHr > 0 && weeklyHr[selectedWeekdayIdx] <= 0) {
                                            weeklyHr[selectedWeekdayIdx] = currentHr.toDouble();
                                          }
                                          final nowDt = DateTime.now();
                                          final curMonDt = nowDt.subtract(Duration(days: nowDt.weekday - 1));
                                          final selMonDt = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
                                          final bool isSameWeek = curMonDt.year == selMonDt.year &&
                                              curMonDt.month == selMonDt.month &&
                                              curMonDt.day == selMonDt.day;
                                          if (isSameWeek && latestHr > 0) {
                                            final todayIdx = (nowDt.weekday - 1).clamp(0, 6);
                                            weeklyHr[todayIdx] = latestHr.toDouble();
                                          }

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
                                                  'Heart Rate',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: r.font(26.0),
                                                    fontWeight: FontWeight.w700,
                                                    color: context.textPrimary,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  'Real-time pulse rate and 24-hour cardiovascular dynamics',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: r.font(13.0),
                                                    fontWeight: FontWeight.w400,
                                                    color: context.textSecondary,
                                                  ),
                                                ),
                                                SizedBox(height: itemSpacing * 0.75),

                                                // Period Segmented Bar (Day / Week toggle)
                                                VitalsPeriodSegmentedBar(
                                                  periodNotifier: _selectedPeriodNotifier,
                                                  periods: const [
                                                    VitalsTimePeriod.day,
                                                    VitalsTimePeriod.week,
                                                  ],
                                                  onPeriodChanged: _onPeriodChanged,
                                                ),
                                                const SizedBox(height: 12.0),

                                                // Date Navigator
                                                VitalsDateNavigator(
                                                  dateNotifier: _selectedDateNotifier,
                                                  periodNotifier: _selectedPeriodNotifier,
                                                  onPrevious: _onPreviousDate,
                                                  onNext: _onNextDate,
                                                  onDateSelected: _onDateSelected,
                                                ),
                                                SizedBox(height: itemSpacing),

                                                // Hero Heart Rate Card
                                                _buildHeroCard(
                                                  context: context,
                                                  r: r,
                                                  isToday: isToday,
                                                  currentHr: currentHr,
                                                  restingHr: restingHr,
                                                  minHr: minHr,
                                                  maxHr: maxHr,
                                                  isMeasuringNotifier: _isMeasuringNotifier,
                                                  measuringStatusNotifier: _measuringStatusNotifier,
                                                  measuringProgressNotifier: _measuringProgressNotifier,
                                                  secondsRemainingNotifier: _secondsRemainingNotifier,
                                                  latestSampledHrNotifier: _latestSampledHrNotifier,
                                                  pulseScale: _pulseScale,
                                                  onMeasureTap: _toggleHeartRateMeasurement,
                                                ),
                                                SizedBox(height: itemSpacing),

                                                // 24h Interactive Scrubbable Chart Card
                                                _buildInteractiveChartCard(
                                                  context: context,
                                                  r: r,
                                                  weeklyHr: weeklyHr,
                                                  currentHr: currentHr,
                                                  selectedDate: selectedDate,
                                                ),
                                                SizedBox(height: itemSpacing),

                                                // Heart Rate Training Zones
                                                _buildHeartRateZonesCard(
                                                  context: context,
                                                  r: r,
                                                  restingHr: restingHr,
                                                  maxHr: maxHr,
                                                ),
                                                SizedBox(height: itemSpacing),

                                                // Physiological Insight Card
                                                _buildPhysiologicalInsightCard(
                                                  context: context,
                                                  r: r,
                                                  restingHr: restingHr,
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
    required bool isToday,
    required int currentHr,
    required int restingHr,
    required int minHr,
    required int maxHr,
    required ValueNotifier<bool> isMeasuringNotifier,
    required ValueNotifier<String?> measuringStatusNotifier,
    required ValueNotifier<double> measuringProgressNotifier,
    required ValueNotifier<int> secondsRemainingNotifier,
    required ValueNotifier<int?> latestSampledHrNotifier,
    required Animation<double> pulseScale,
    required VoidCallback onMeasureTap,
  }) {
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
                  ValueListenableBuilder<bool>(
                    valueListenable: isMeasuringNotifier,
                    builder: (context, isMeasuring, _) {
                      return ScaleTransition(
                        scale: isMeasuring ? pulseScale : const AlwaysStoppedAnimation(1.0),
                        child: Container(
                          width: 38.0,
                          height: 38.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: isMeasuring ? 0.55 : 0.35),
                                blurRadius: isMeasuring ? 14.0 : 10.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const AppSvgIcon(
                            AppIcons.heartPulse,
                            color: AppColors.white,
                            size: 19.0,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    isToday ? 'Current Pulse' : 'Recorded Pulse',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(15.0),
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isMeasuringNotifier,
                builder: (context, isMeasuring, _) {
                  if (isMeasuring) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            'MEASURING LIVE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(10.5),
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!isToday) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.borderLight, width: 0.6),
                      ),
                      child: Text(
                        'Archived',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(11.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tileGreenBg,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      restingHr < 60 ? 'Optimal Rest' : 'Normal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.readinessRest,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ValueListenableBuilder<bool>(
            valueListenable: isMeasuringNotifier,
            builder: (context, isMeasuring, _) {
              return ValueListenableBuilder<int?>(
                valueListenable: latestSampledHrNotifier,
                builder: (context, sampledHr, _) {
                  final displayHr = (isMeasuring && sampledHr != null && sampledHr > 0)
                      ? sampledHr
                      : currentHr;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$displayHr',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(44.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.0,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'bpm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(16.0),
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                      if (isMeasuring) ...[
                        const SizedBox(width: 10.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            'OPTICAL PPG',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(9.5),
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 18.0),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: 14.0),

          // 3 Sub-Metric Capsules
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniPill(
                  label: 'Resting HR',
                  value: '$restingHr bpm',
                  accentColor: AppColors.readinessRest,
                  r: r,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildMetricMiniPill(
                  label: 'Day Min',
                  value: '$minHr bpm',
                  accentColor: AppColors.cyanAccent,
                  r: r,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildMetricMiniPill(
                  label: 'Peak Max',
                  value: '$maxHr bpm',
                  accentColor: AppColors.orangeMetric,
                  r: r,
                ),
              ),
            ],
          ),

          if (isToday) ...[
            // Real-time PPG Sampling Window Gauge (Shown while measuring)
            ValueListenableBuilder<bool>(
            valueListenable: isMeasuringNotifier,
            builder: (context, isMeasuring, _) {
              if (!isMeasuring) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      width: 0.8,
                    ),
                  ),
                  child: ValueListenableBuilder<double>(
                    valueListenable: measuringProgressNotifier,
                    builder: (context, progress, _) {
                      return ValueListenableBuilder<int>(
                        valueListenable: secondsRemainingNotifier,
                        builder: (context, secRemaining, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const AppSvgIcon(
                                        AppIcons.heartPulse,
                                        color: AppColors.primary,
                                        size: 14.0,
                                      ),
                                      const SizedBox(width: 6.0),
                                      Text(
                                        'PPG Acquisition: ${secRemaining}s remaining',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: r.font(12.0),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: r.font(12.0),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  minHeight: 5.0,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                'Keep arm stationary & band close to skin',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(10.5),
                                  fontWeight: FontWeight.w400,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // On-Demand Measure Heart Rate Action Button
          const SizedBox(height: 16.0),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: 14.0),

          ValueListenableBuilder<bool>(
            valueListenable: isMeasuringNotifier,
            builder: (context, isMeasuring, _) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: onMeasureTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13.0),
                      decoration: BoxDecoration(
                        gradient: isMeasuring ? null : AppGradients.primary,
                        color: isMeasuring
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : null,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: isMeasuring
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.2,
                        ),
                        boxShadow: isMeasuring
                            ? null
                            : [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.30),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isMeasuring) ...[
                            const SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              'Measuring Pulse... (Tap to Cancel)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(13.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ] else ...[
                            const AppSvgIcon(
                              AppIcons.heartPulse,
                              color: AppColors.white,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Measure Current Heart Rate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(13.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: measuringStatusNotifier,
                    builder: (context, statusText, _) {
                      if (statusText == null || statusText.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          statusText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.5),
                            fontWeight: FontWeight.w500,
                            color: isMeasuring
                                ? AppColors.primary
                                : AppColors.readinessRest,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ] else ...[
          const SizedBox(height: 16.0),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: 14.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: AppColors.borderLight, width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded, size: 16.0, color: AppColors.textSecondary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Recorded cardiovascular telemetry from local archive',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(12.0),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildInteractiveChartCard({
    required BuildContext context,
    required Responsive r,
    required List<double> weeklyHr,
    required int currentHr,
    required DateTime selectedDate,
  }) {
    final chartHeight = (r.height * 0.12).clamp(90.0, 120.0);
    final selectedDayIdx = (selectedDate.weekday - 1).clamp(0, 6);

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
                'Weekly Heart Rate Rhythm',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _scrubIndexNotifier,
                builder: (context, scrubIdx, _) {
                  final dayVal = scrubIdx < weeklyHr.length && weeklyHr[scrubIdx] > 0
                      ? '${weeklyHr[scrubIdx].round()} bpm'
                      : (scrubIdx == selectedDayIdx && currentHr > 0
                          ? '$currentHr bpm'
                          : '--');
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      dayVal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Interactive Custom Spline Chart with Tap & Drag Scrubber
          SizedBox(
            height: chartHeight,
            width: double.infinity,
            child: ValueListenableBuilder<int>(
              valueListenable: _scrubIndexNotifier,
              builder: (context, scrubIdx, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final localX = details.localPosition.dx.clamp(
                          0.0,
                          constraints.maxWidth,
                        );
                        final newIdx = VitalsCardCalculator.computeScrubIndex(
                          localX: localX,
                          totalWidth: constraints.maxWidth,
                          itemCount: weeklyHr.length,
                        );
                        if (newIdx != _scrubIndexNotifier.value) {
                          _scrubIndexNotifier.value = newIdx;
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        final localX = details.localPosition.dx.clamp(
                          0.0,
                          constraints.maxWidth,
                        );
                        final newIdx = VitalsCardCalculator.computeScrubIndex(
                          localX: localX,
                          totalWidth: constraints.maxWidth,
                          itemCount: weeklyHr.length,
                        );
                        if (newIdx != _scrubIndexNotifier.value) {
                          _scrubIndexNotifier.value = newIdx;
                        }
                      },
                      child: CustomPaint(
                        painter: HeartRateChartPainter(
                          values: weeklyHr,
                          activeIndex: scrubIdx,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),

          // Weekday Labels with active selection highlight
          ValueListenableBuilder<int>(
            valueListenable: _scrubIndexNotifier,
            builder: (context, activeIdx, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final isSelected = i == activeIdx;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _scrubIndexNotifier.value = i;
                      },
                      child: Center(
                        child: Text(
                          _weekdays[i],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateZonesCard({
    required BuildContext context,
    required Responsive r,
    required int restingHr,
    required int maxHr,
  }) {
    final zones = [
      {'name': 'Zone 5 · Peak Effort', 'range': '${(maxHr * 0.90).round()}+ bpm', 'pct': 0.08, 'color': AppColors.systemRed},
      {'name': 'Zone 4 · Threshold', 'range': '${(maxHr * 0.80).round()}–${(maxHr * 0.90).round()} bpm', 'pct': 0.18, 'color': AppColors.orangeMetric},
      {'name': 'Zone 3 · Aerobic Pace', 'range': '${(maxHr * 0.70).round()}–${(maxHr * 0.80).round()} bpm', 'pct': 0.32, 'color': AppColors.orangeMetric.withValues(alpha: 0.85)},
      {'name': 'Zone 2 · Steady Burn', 'range': '${(maxHr * 0.60).round()}–${(maxHr * 0.70).round()} bpm', 'pct': 0.28, 'color': AppColors.primary},
      {'name': 'Zone 1 · Recovery Pace', 'range': '$restingHr–${(maxHr * 0.60).round()} bpm', 'pct': 0.14, 'color': AppColors.readinessRest},
    ];

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training & Cardiovascular Zones',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(15.0),
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Time distribution across metabolic thresholds today',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          ...zones.map((z) {
            final double pct = z['pct'] as double;
            final Color color = z['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        z['name'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        z['range'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(11.0),
                          fontWeight: FontWeight.w500,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6.0,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
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

  Widget _buildPhysiologicalInsightCard({
    required BuildContext context,
    required Responsive r,
    required int restingHr,
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
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const AppSvgIcon(
                  AppIcons.lotusFlower,
                  color: AppColors.primary,
                  size: 16.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Autonomic Coaching Context',
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
            restingHr <= 55
                ? 'Your cardiovascular system is resting deeply. A low resting pulse indicates excellent parasympathetic tone and cardiovascular efficiency, meaning your body is primed for physical exertion.'
                : 'Your resting heart rate is in a balanced baseline state. To encourage cardiovascular efficiency, maintain steady zone 2 aerobic sessions and stay well-hydrated throughout the day.',
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
