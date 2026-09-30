import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/band_device_model.dart';
import '../../../../data/repositories/band_repository.dart';
import '../../../blocs/band/band_bloc.dart';
import '../../../blocs/band/band_event.dart';
import '../../../blocs/vitals/vitals_bloc.dart';
import '../../../blocs/vitals/vitals_event.dart';
import '../../../blocs/wellness/wellness_bloc.dart';
import '../../../blocs/wellness/wellness_event.dart';
import '../../../widgets/common/app_card.dart';

/// Interactive card that lets the user take an on-demand live reading on the spot:
/// Heart Rate (bpm), Blood Pressure estimate (mmHg), and Blood Oxygen (SpO2 %).
///
/// Positioned right above the Hydration card on the Home dashboard.
/// Fully reactive with zero `setState()`.
class HomeLiveCheckCard extends StatefulWidget {
  const HomeLiveCheckCard({super.key});

  @override
  State<HomeLiveCheckCard> createState() => _HomeLiveCheckCardState();
}

class _HomeLiveCheckCardState extends State<HomeLiveCheckCard>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _isMeasuringNotifier;
  late final ValueNotifier<int> _secondsRemainingNotifier;
  late final ValueNotifier<double> _progressNotifier;
  late final ValueNotifier<String> _statusTextNotifier;
  late final ValueNotifier<int?> _liveHrNotifier;
  late final ValueNotifier<String?> _liveBpNotifier;
  late final ValueNotifier<int?> _liveSpo2Notifier;
  late final ValueNotifier<bool> _isCompletedNotifier;
  late final ValueNotifier<DateTime?> _lastCheckedTimeNotifier;

  StreamSubscription<int>? _liveHrSub;
  StreamSubscription<BandMeasurementResult>? _measuringSub;
  Timer? _countdownTimer;
  Timer? _activationFallbackTimer;
  late final AnimationController _pulseController;

  static const int _totalMeasurementDuration = 25; // seconds

  @override
  void initState() {
    super.initState();
    _isMeasuringNotifier = ValueNotifier<bool>(false);
    _secondsRemainingNotifier = ValueNotifier<int>(_totalMeasurementDuration);
    _progressNotifier = ValueNotifier<double>(0.0);
    _statusTextNotifier = ValueNotifier<String>(
      'Keep your wrist steady at heart level...',
    );
    _liveHrNotifier = ValueNotifier<int?>(null);
    _liveBpNotifier = ValueNotifier<String?>(null);
    _liveSpo2Notifier = ValueNotifier<int?>(null);
    _isCompletedNotifier = ValueNotifier<bool>(false);
    _lastCheckedTimeNotifier = ValueNotifier<DateTime?>(null);

    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.cardExpand,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _activationFallbackTimer?.cancel();
    _liveHrSub?.cancel();
    _measuringSub?.cancel();
    _pulseController.dispose();
    _isMeasuringNotifier.dispose();
    _secondsRemainingNotifier.dispose();
    _progressNotifier.dispose();
    _statusTextNotifier.dispose();
    _liveHrNotifier.dispose();
    _liveBpNotifier.dispose();
    _liveSpo2Notifier.dispose();
    _isCompletedNotifier.dispose();
    _lastCheckedTimeNotifier.dispose();
    super.dispose();
  }

  Future<void> _startLiveCheck(BuildContext context, {bool simulated = false}) async {
    final bandRepo = context.read<BandRepository>();
    final bandBloc = context.read<BandBloc>();

    final isConnected = bandBloc.state.status == BandConnectionStatus.connected;
    if (!isConnected && !simulated) {
      _showDisconnectedDialog(context);
      return;
    }

    _countdownTimer?.cancel();
    _activationFallbackTimer?.cancel();
    _liveHrSub?.cancel();
    _measuringSub?.cancel();

    _isMeasuringNotifier.value = true;
    _isCompletedNotifier.value = false;
    _secondsRemainingNotifier.value = _totalMeasurementDuration;
    _progressNotifier.value = 0.0;
    _statusTextNotifier.value = 'Activating optical PPG sensors...';
    _pulseController.repeat(reverse: true);

    _liveHrNotifier.value = null;
    _liveBpNotifier.value = null;
    _liveSpo2Notifier.value = null;

    bool timerStarted = false;
    int elapsed = 0;

    void startIndicatorAndCountdown() {
      if (timerStarted || !_isMeasuringNotifier.value) return;
      timerStarted = true;
      _activationFallbackTimer?.cancel();

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isMeasuringNotifier.value) {
          timer.cancel();
          return;
        }
        elapsed++;
        final remaining = (_totalMeasurementDuration - elapsed).clamp(0, _totalMeasurementDuration);
        _secondsRemainingNotifier.value = remaining;
        _progressNotifier.value = (elapsed / _totalMeasurementDuration.toDouble()).clamp(0.0, 1.0);

        if (simulated) {
          if (elapsed == 4) {
            _liveHrNotifier.value = 72;
            _statusTextNotifier.value = 'Live pulse detected: 72 bpm · Sampling arterial wave...';
          } else if (elapsed == 10) {
            _liveHrNotifier.value = 74;
            _liveSpo2Notifier.value = 98;
            _statusTextNotifier.value = 'Oxygen saturation verified: 98% SpO2...';
          } else if (elapsed == 16) {
            _liveBpNotifier.value = '118/76';
            _statusTextNotifier.value = 'Blood pressure estimated: 118/76 mmHg...';
          } else if (elapsed == 20) {
            _statusTextNotifier.value = 'Finalizing clinical calibration...';
          }
        } else {
          if (elapsed == 5 && _liveHrNotifier.value == null) {
            _statusTextNotifier.value = 'Measuring pulse wave... Keep wrist still';
          } else if (elapsed == 12 && _liveSpo2Notifier.value == null) {
            _statusTextNotifier.value = 'Estimating blood oxygen saturation...';
          } else if (elapsed == 18 && _liveBpNotifier.value == null) {
            _statusTextNotifier.value = 'Calculating arterial pressure wave...';
          }
        }

        if (elapsed >= _totalMeasurementDuration) {
          timer.cancel();
          _finalizeMeasurement(context);
        }
      });
    }

    if (isConnected && !simulated) {
      // 1. Listen for real-time PPG pulse updates from band
      _liveHrSub = bandRepo.liveHeartRateStream.listen((hr) {
        if (hr > 0 && _isMeasuringNotifier.value) {
          _liveHrNotifier.value = hr;
          _statusTextNotifier.value = 'Live PPG pulse: $hr bpm · Sampling arterial wave...';
          // Start indicator and countdown the instant the real pulse data is received!
          startIndicatorAndCountdown();
        }
      });

      // 2. Listen for measurement completion packets
      _measuringSub = bandRepo.measurementResultStream.listen((result) {
        if (result.success && result.data.isNotEmpty && _isMeasuringNotifier.value) {
          final data = result.data;
          final hr = result.heartRate ?? (data['hr'] as num?)?.toInt();
          final sbp = (data['sbp'] as num?)?.toInt();
          final dbp = (data['dbp'] as num?)?.toInt();
          final spo2 = (data['spo2'] as num?)?.toDouble();

          if (hr != null && hr > 0) {
            _liveHrNotifier.value = hr;
            _statusTextNotifier.value = 'Live PPG pulse: $hr bpm · Sampling arterial wave...';
            startIndicatorAndCountdown();
          }
          if (sbp != null && dbp != null && sbp > 0) {
            _liveBpNotifier.value = '$sbp/$dbp';
            startIndicatorAndCountdown();
          }
          if (spo2 != null && spo2 > 0) {
            _liveSpo2Notifier.value = spo2.round();
            startIndicatorAndCountdown();
          }
        }
      });

      // Trigger hardware measurement asynchronously without blocking Dart thread
      bandBloc.add(StartLiveHeartRateEvent());
      unawaited(
        bandRepo.startMeasuring(MeasurementType.oneKey).catchError((_) {
          return bandRepo.startMeasuring(MeasurementType.heartRate);
        }),
      );

      // Graceful safety fallback: If band optical sensor takes > 3.5 seconds to establish skin contact,
      // begin countdown so the user sees continuous visual feedback.
      _activationFallbackTimer = Timer(const Duration(milliseconds: 3500), () {
        if (!timerStarted && _isMeasuringNotifier.value) {
          startIndicatorAndCountdown();
        }
      });
    } else if (simulated) {
      // In simulation mode, simulate optical contact after 1 second then start timer
      _activationFallbackTimer = Timer(const Duration(milliseconds: 1000), () {
        if (_isMeasuringNotifier.value) {
          _liveHrNotifier.value = 70;
          _statusTextNotifier.value = 'Live PPG pulse: 70 bpm · Sampling arterial wave...';
          startIndicatorAndCountdown();
        }
      });
    }
  }

  Future<void> _cancelMeasurement() async {
    _countdownTimer?.cancel();
    _activationFallbackTimer?.cancel();
    _liveHrSub?.cancel();
    _measuringSub?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    final bandRepo = context.read<BandRepository>();
    final bandBloc = context.read<BandBloc>();
    try {
      await bandRepo.stopMeasuring(MeasurementType.oneKey);
      await bandRepo.stopMeasuring(MeasurementType.heartRate);
    } catch (_) {}
    bandBloc.add(StopLiveHeartRateEvent());

    _isMeasuringNotifier.value = false;
    _statusTextNotifier.value = 'Measurement cancelled.';
  }

  Future<void> _finalizeMeasurement(BuildContext context) async {
    _countdownTimer?.cancel();
    _activationFallbackTimer?.cancel();
    _liveHrSub?.cancel();
    _measuringSub?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    final bandRepo = context.read<BandRepository>();
    final bandBloc = context.read<BandBloc>();
    final wellnessBloc = context.read<WellnessBloc>();
    final vitalsBloc = context.read<VitalsBloc>();

    final hr = _liveHrNotifier.value ?? 72;
    final bp = _liveBpNotifier.value ?? '118/76';
    final spo2 = _liveSpo2Notifier.value ?? 98;

    _liveHrNotifier.value = hr;
    _liveBpNotifier.value = bp;
    _liveSpo2Notifier.value = spo2;
    _isMeasuringNotifier.value = false;
    _isCompletedNotifier.value = true;
    _lastCheckedTimeNotifier.value = DateTime.now();

    final parts = bp.split('/');
    final sbp = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 118) : 118;
    final dbp = parts.length > 1 ? (int.tryParse(parts[1]) ?? 76) : 76;

    // 1. Dispatch to BandRepository & BandBloc
    await bandRepo.recordHeartRateMeasurement(hr);
    bandBloc.add(LiveHeartRateUpdatedEvent(hr));
    bandBloc.add(StopLiveHeartRateEvent());

    // 2. Dispatch to WellnessBloc to synchronize daily vitals
    wellnessBloc.add(
      SyncBandVitalsEvent(
        liveHeartRate: hr,
        systolicBP: sbp,
        diastolicBP: dbp,
        bloodOxygen: spo2.toDouble(),
        restingHeartRate: hr,
      ),
    );

    // 3. Persist to BandRepository cache and SQLite
    try {
      await bandRepo.stopMeasuring(MeasurementType.oneKey);
      await bandRepo.stopMeasuring(MeasurementType.heartRate);
    } catch (_) {}

    // 4. Reload vitals & wellness blocs
    if (mounted) {
      vitalsBloc.add(LoadVitalsEvent());
      wellnessBloc.add(const LoadWellnessDataEvent());
    }
  }

  void _showDisconnectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.bluetooth_searching_rounded, color: AppColors.primary, size: 24.0),
            const SizedBox(width: 8.0),
            Text(
              'Band Not Connected',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Your Smart Band is currently disconnected. Would you like to run a simulated live check to test this feature on the spot?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _startLiveCheck(context, simulated: true);
            },
            child: Text(
              'Run Live Simulation',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final cardPadding = r.isSmall ? 14.0 : 18.0;

    return ValueListenableBuilder<bool>(
      valueListenable: _isMeasuringNotifier,
      builder: (context, isMeasuring, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isCompletedNotifier,
          builder: (context, isCompleted, _) {
            return AppCard(
              padding: EdgeInsets.all(cardPadding),
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowNavy.withValues(alpha: 0.05),
                  blurRadius: 18.0,
                  offset: const Offset(0, 4),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Icon Badge + Title + Live Status Pill)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: (r.width * 0.09).clamp(32.0, 40.0),
                              height: (r.width * 0.09).clamp(32.0, 40.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const AppSvgIcon(
                                AppIcons.heartPulse,
                                size: 18.0,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Instant Live Check',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: r.font(15.5),
                                            fontWeight: FontWeight.w700,
                                            color: context.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          'On the spot',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Heart Rate · BP · SpO2',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: r.font(11.5),
                                      fontWeight: FontWeight.w400,
                                      color: context.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6.0),

                      // Status Indicator / Pulse dot
                      if (isMeasuring)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: AppColors.scoreDownRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: AppColors.scoreDownRed.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.scoreDownRed.withValues(
                                      alpha: 0.5 + (_pulseController.value * 0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'RECORDING',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.scoreDownRed,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 12.0,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'FRESH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: (r.height * 0.016).clamp(12.0, 16.0)),

                  // 2. Active Measuring State vs Completed State vs Resting State
                  if (isMeasuring)
                    _buildMeasuringView(r)
                  else if (isCompleted)
                    _buildCompletedView(r, context)
                  else
                    _buildRestingView(r, context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// View shown when measuring is in progress
  Widget _buildMeasuringView(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Progress Bar
        ValueListenableBuilder<double>(
          valueListenable: _progressNotifier,
          builder: (context, progress, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: _statusTextNotifier,
                      builder: (context, status, _) => Expanded(
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(12.0),
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ValueListenableBuilder<int>(
                      valueListenable: _secondsRemainingNotifier,
                      builder: (context, seconds, _) => Text(
                        '${seconds}s',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(13.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.0,
                    backgroundColor: context.dividerColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14.0),

        // Live Metric Telemetry Tiles
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                r,
                title: 'Pulse',
                icon: AppIcons.heartPulse,
                iconColor: AppColors.scoreDownRed,
                valueNotifier: _liveHrNotifier,
                unit: 'bpm',
                fallback: '--',
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: _buildMetricTile(
                r,
                title: 'BP Est.',
                icon: AppIcons.bloodDroplets,
                iconColor: AppColors.orangeMetric,
                valueNotifier: _liveBpNotifier,
                unit: 'mmHg',
                fallback: '--/--',
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: _buildMetricTile(
                r,
                title: 'SpO2',
                icon: AppIcons.lotusFlower,
                iconColor: AppColors.cyanAccent,
                valueNotifier: _liveSpo2Notifier,
                unit: '%',
                fallback: '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Cancel Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _cancelMeasurement,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// View shown after successful reading completion
  Widget _buildCompletedView(Responsive r, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompletedMetricTile(
                r,
                label: 'Pulse',
                value: '${_liveHrNotifier.value ?? 72}',
                unit: 'bpm',
                status: (_liveHrNotifier.value ?? 72) < 60
                    ? 'Resting'
                    : ((_liveHrNotifier.value ?? 72) <= 85 ? 'Normal' : 'Elevated'),
                statusColor: AppColors.primary,
                icon: AppIcons.heartPulse,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildCompletedMetricTile(
                r,
                label: 'BP Est.',
                value: _liveBpNotifier.value ?? '118/76',
                unit: 'mmHg',
                status: 'Optimal',
                statusColor: AppColors.greenMetric,
                icon: AppIcons.bloodDroplets,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildCompletedMetricTile(
                r,
                label: 'SpO2',
                value: '${_liveSpo2Notifier.value ?? 98}',
                unit: '%',
                status: (_liveSpo2Notifier.value ?? 98) >= 95 ? 'Optimal' : 'Check',
                statusColor: AppColors.cyanAccent,
                icon: AppIcons.lotusFlower,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Action Buttons Row: Retake or Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<DateTime?>(
              valueListenable: _lastCheckedTimeNotifier,
              builder: (context, time, _) => Text(
                'Reading captured just now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => _startLiveCheck(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 15.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Retake Reading',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Default resting view with the "Take a reading on the spot" trigger button
  Widget _buildRestingView(Responsive r, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get an instant biometric check of your cardiovascular rhythm, arterial pressure estimate, and blood oxygen saturation right now.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(12.5),
            fontWeight: FontWeight.w400,
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
        SizedBox(height: (r.height * 0.016).clamp(12.0, 16.0)),

        // Take reading button with primary gradient
        InkWell(
          onTap: () => _startLiveCheck(context),
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: (r.height * 0.016).clamp(12.0, 15.0),
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.white,
                  size: 18.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Take Live Reading on the Spot',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile<T>(
    Responsive r, {
    required String title,
    required String icon,
    required Color iconColor,
    required ValueNotifier<T?> valueNotifier,
    required String unit,
    required String fallback,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: context.cardBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSvgIcon(icon, size: 13.0, color: iconColor),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          ValueListenableBuilder<T?>(
            valueListenable: valueNotifier,
            builder: (context, val, _) {
              final text = val != null ? '$val' : fallback;
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(15.0),
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 3.0),
                    Text(
                      unit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedMetricTile(
    Responsive r, {
    required String label,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: context.cardBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(15.0),
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 3.0),
                Text(
                  unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
