import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/engine/heart_rate_zone_calculator.dart';
import '../../../data/models/band_device_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../../data/models/workout_model.dart';
import 'training_event.dart';
import 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final WellnessRepository repository;
  final BandRepository? bandRepository;
  final HeartRateZoneCalculator _zoneCalculator;

  StreamSubscription<int>? _hrSubscription;
  StreamSubscription<BandSyncedVitals>? _vitalsSubscription;
  StreamSubscription<BandPedometerInfo>? _pedometerSubscription;

  /// Calculates physiologically accurate energy expenditure (kcal/min)
  /// combining standard Compendium of Physical Activities METs with Keytel HR expenditure equations.
  static int calculateEstimatedKcalPerMin({
    required WorkoutType category,
    required int weightKg,
    int? liveHeartRate,
    int age = 30,
  }) {
    int targetMidHr;
    double sportMet;
    switch (category) {
      case WorkoutType.run:
        targetMidHr = 148; // Zone 2–4 (130–165 bpm)
        sportMet = 9.8;
        break;
      case WorkoutType.strength:
        targetMidHr = 135; // Zone 3–4 (125–160 bpm)
        sportMet = 5.0;
        break;
      case WorkoutType.walk:
        targetMidHr = 108; // Zone 1–2 (95–120 bpm)
        sportMet = 3.8;
        break;
      case WorkoutType.cycling:
        targetMidHr = 135; // Zone 2–3 (120–150 bpm)
        sportMet = 7.5;
        break;
      case WorkoutType.hit:
        targetMidHr = 168; // Zone 4–5 (150–185 bpm)
        sportMet = 11.0;
        break;
    }

    final effectiveHr = (liveHeartRate != null && liveHeartRate > 60)
        ? liveHeartRate
        : targetMidHr;

    // Keytel heart rate expenditure equation (Journal of Sports Sciences)
    // Men/General: (-55.0969 + (0.6309 * HR) + (0.1988 * weight) + (0.2017 * age)) / 4.184
    final keytelKcal = ((-55.0969 + (0.6309 * effectiveHr) + (0.1988 * weightKg) + (0.2017 * age)) / 4.184);

    // Sport-specific MET formula: kcal/min = (MET * 3.5 * weightKg) / 200
    final metKcal = (sportMet * 3.5 * weightKg) / 200.0;

    final double blendedRate;
    if (liveHeartRate != null && liveHeartRate > 60) {
      // Live streaming HR from band: 85% physiological HR, 15% sport MET
      blendedRate = (keytelKcal * 0.85) + (metKcal * 0.15);
    } else {
      // Target HR zone baseline: 70% sport MET, 30% Keytel zone target
      blendedRate = (metKcal * 0.70) + (keytelKcal * 0.30);
    }

    return blendedRate.round().clamp(2, 30);
  }

  TrainingBloc({
    required this.repository,
    this.bandRepository,
    HeartRateZoneCalculator? zoneCalculator,
  })  : _zoneCalculator = zoneCalculator ?? HeartRateZoneCalculator(),
        super(const TrainingState()) {

    on<LoadTrainingDataEvent>((event, emit) async {
      emit(state.copyWith(status: TrainingStatus.loading));
      try {
        final data = repository.getWorkoutData();
        final calculatedRate = calculateEstimatedKcalPerMin(
          category: data.selectedCategory,
          weightKg: data.selectedWeightKg,
          liveHeartRate: state.liveHeartRate > 0 ? state.liveHeartRate : null,
        );
        final syncedData = data.copyWith(estimatedKcalPerMin: calculatedRate);
        repository.updateWorkoutData(syncedData);

        // Load SQLite backed recent workout sessions history
        final recent = await repository.getRecentWorkoutSessions(limit: 10);
        var displayData = syncedData;
        if (recent.isNotEmpty) {
          final latest = recent.first;
          final h = latest.durationSeconds ~/ 3600;
          final m = (latest.durationSeconds % 3600) ~/ 60;
          final s = latest.durationSeconds % 60;
          final durStr = '${h.toString().padLeft(2, '0')}hr ${m.toString().padLeft(2, '0')}min ${s.toString().padLeft(2, '0')}sec';
          displayData = syncedData.copyWith(
            recentSessionTitle: latest.title,
            recentSessionDuration: durStr,
            recentPeakHr: latest.peakHeartRate,
            recentAvgHr: latest.avgHeartRate,
          );
          repository.updateWorkoutData(displayData);
        }

        emit(state.copyWith(
          status: TrainingStatus.loaded,
          data: displayData,
          recentSessions: recent,
        ));
      } catch (e) {
        emit(
          state.copyWith(
            status: TrainingStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<SelectWorkoutCategoryEvent>((event, emit) {
      if (state.data != null) {
        String title = 'Outdoor run';
        String zoneInfo = 'Zone 2–4 · 130–165 bpm';
        String metrics = 'Pace, cadence, HR zones, route, recovery HR';
        String outfit = 'Breathable Running Tee · Lightweight Split Shorts';

        switch (event.category) {
          case WorkoutType.run:
            title = 'Outdoor run';
            zoneInfo = 'Zone 2–4 · 130–165 bpm';
            metrics = 'Pace, cadence, HR zones, route, recovery HR';
            outfit = 'Breathable Running Tee · Lightweight Split Shorts';
            break;
          case WorkoutType.walk:
            title = 'Outdoor walking';
            zoneInfo = 'Zone 1–2 · 95–120 bpm';
            metrics = 'Steps, cadence, elevation gain, recovery HR';
            outfit = 'Comfort Fit T-Shirt · Flexible Walking Pants';
            break;
          case WorkoutType.cycling:
            title = 'Outdoor biking';
            zoneInfo = 'Zone 2–3 · 120–150 bpm';
            metrics = 'Speed, distance, elevation, power zones';
            outfit = 'Aerodynamic Cycling Jersey · Padded Bib Shorts';
            break;
          case WorkoutType.strength:
            title = 'Full body strength';
            zoneInfo = 'Zone 3–4 · 125–160 bpm';
            metrics = 'Reps, sets, volume, heart rate peak';
            outfit = 'Moisture-Wicking Athletic Shirt · Gym Training Shorts';
            break;
          case WorkoutType.hit:
            title = 'HIIT intervals';
            zoneInfo = 'Zone 4–5 · 150–185 bpm';
            metrics = 'Interval splits, max HR, EPOC burn';
            outfit = 'High-Ventilation Performance Tee · Compression Shorts';
            break;
        }

        final calculatedRate = calculateEstimatedKcalPerMin(
          category: event.category,
          weightKg: state.data!.selectedWeightKg,
          liveHeartRate: state.liveHeartRate > 0 ? state.liveHeartRate : null,
        );
        final updated = state.data!.copyWith(
          selectedCategory: event.category,
          title: title,
          zoneInfo: zoneInfo,
          metricsSummary: metrics,
          outfitRecommendation: outfit,
          estimatedKcalPerMin: calculatedRate,
        );
        repository.updateWorkoutData(updated);
        emit(state.copyWith(data: updated));
      }
    });

    on<SelectWeightEvent>((event, emit) {
      if (state.data != null) {
        final calculatedRate = calculateEstimatedKcalPerMin(
          category: state.data!.selectedCategory,
          weightKg: event.weightKg,
          liveHeartRate: state.liveHeartRate > 0 ? state.liveHeartRate : null,
        );
        final updated = state.data!.copyWith(
          selectedWeightKg: event.weightKg,
          estimatedKcalPerMin: calculatedRate,
        );
        repository.updateWorkoutData(updated);
        emit(state.copyWith(data: updated));
      }
    });

    on<SelectTargetZoneEvent>((event, emit) {
      // User tapped a specific zone card manually: honor selection without snapping back
      emit(state.copyWith(
        currentZone: event.zone.clamp(1, 5),
        isManualZone: true,
      ));
    });

    on<StartWorkoutEvent>((event, emit) async {
      // 1. Activate hardware optical PPG on band
      try {
        await bandRepository?.startRealtimeHeartRate();
      } catch (e) {
        debugPrint('⚠️ [TRAINING BLOC] startRealtimeHeartRate: $e');
      }

      // 2. Read baseline pedometer counters from band to calculate session deltas
      final currentVitals = bandRepository?.lastSyncedVitals;
      final startSteps = currentVitals?.steps ?? 0;
      final startDist = currentVitals?.distance ?? 0;
      final initialHr = currentVitals?.latestHeartRate ?? 0;
      final initialZone = initialHr > 0 ? _zoneCalculator.calculateZone(initialHr) : 1;

      emit(
        state.copyWith(
          sessionStatus: TrainingSessionStatus.running,
          elapsedSeconds: 0,
          burnedCalories: 0,
          peakHeartRate: initialHr,
          avgHeartRate: initialHr,
          heartRateSum: initialHr > 0 ? initialHr : 0,
          heartRateCount: initialHr > 0 ? 1 : 0,
          liveHeartRate: initialHr,
          currentZone: initialZone,
          isManualZone: false,
          distanceMeters: 0.0,
          currentSpeedKmh: 0.0,
          currentPaceSec: 0,
          sessionSteps: 0,
          initialSteps: startSteps,
          initialDistance: startDist,
          zone1Seconds: 0,
          zone2Seconds: 0,
          zone3Seconds: 0,
          zone4Seconds: 0,
          zone5Seconds: 0,
        ),
      );
    });

    on<ToggleWorkoutPauseEvent>((event, emit) {
      if (state.sessionStatus == TrainingSessionStatus.running) {
        emit(state.copyWith(sessionStatus: TrainingSessionStatus.paused));
      } else if (state.sessionStatus == TrainingSessionStatus.paused) {
        emit(state.copyWith(sessionStatus: TrainingSessionStatus.running));
      }
    });

    on<TickWorkoutEvent>((event, emit) {
      if (state.sessionStatus == TrainingSessionStatus.running) {
        final newSec = state.elapsedSeconds + 1;
        final weightKg = state.data?.selectedWeightKg ?? 70;
        final category = state.data?.selectedCategory ?? WorkoutType.run;
        final effectiveHr = state.liveHeartRate > 0 ? state.liveHeartRate : state.avgHeartRate;

        // 1. Time in Zone accumulation
        int z1 = state.zone1Seconds;
        int z2 = state.zone2Seconds;
        int z3 = state.zone3Seconds;
        int z4 = state.zone4Seconds;
        int z5 = state.zone5Seconds;

        switch (state.currentZone) {
          case 1:
            z1++;
            break;
          case 2:
            z2++;
            break;
          case 3:
            z3++;
            break;
          case 4:
            z4++;
            break;
          case 5:
          default:
            z5++;
            break;
        }

        // 2. High-precision metabolic calorie calculation
        double kcalPerMin;
        if (effectiveHr > 60) {
          final keytelKcal = ((-55.0969 + (0.6309 * effectiveHr) + (0.1988 * weightKg) + (0.2017 * 30)) / 4.184);

          double sportFactor = 1.0;
          if (category == WorkoutType.run) sportFactor = 1.05;
          if (category == WorkoutType.hit) sportFactor = 1.10;
          if (category == WorkoutType.strength) sportFactor = 0.85;
          if (category == WorkoutType.walk) sportFactor = 0.80;
          if (category == WorkoutType.cycling) sportFactor = 0.95;

          kcalPerMin = (keytelKcal * sportFactor).clamp(2.5, 25.0);
        } else {
          final baseKcal = (state.data?.estimatedKcalPerMin ?? 10).toDouble();
          double hrMultiplier = 1.0;
          if (state.currentZone == 2) hrMultiplier = 1.1;
          if (state.currentZone == 3) hrMultiplier = 1.25;
          if (state.currentZone == 4) hrMultiplier = 1.5;
          if (state.currentZone >= 5) hrMultiplier = 1.8;
          kcalPerMin = baseKcal * hrMultiplier;
        }

        // Smooth energy accumulation: registers calories accurately from the start
        final dynamicCalories = ((newSec / 60.0) * kcalPerMin).ceil();
        final calories = dynamicCalories > state.burnedCalories ? dynamicCalories : state.burnedCalories;

        // 3. Speed & Pace calculation for distance activities
        double currentSpeed = state.currentSpeedKmh;
        int currentPace = state.currentPaceSec;
        if (state.distanceMeters >= 5.0 && newSec >= 3) {
          final km = state.distanceMeters / 1000.0;
          final hours = newSec / 3600.0;
          currentSpeed = (km / hours).clamp(0.0, 70.0);
          final secPerKm = (newSec / km).round();
          currentPace = secPerKm.clamp(120, 1800); // 2:00/km to 30:00/km realistic bounds
        }

        emit(
          state.copyWith(
            elapsedSeconds: newSec,
            burnedCalories: calories,
            currentSpeedKmh: currentSpeed,
            currentPaceSec: currentPace,
            zone1Seconds: z1,
            zone2Seconds: z2,
            zone3Seconds: z3,
            zone4Seconds: z4,
            zone5Seconds: z5,
          ),
        );
      }
    });

    on<UpdateLiveTrainingCaloriesEvent>((event, emit) {
      if (state.sessionStatus == TrainingSessionStatus.idle) {
        emit(state.copyWith(burnedCalories: event.calories));
      }
    });

    on<UpdateLivePedometerEvent>((event, emit) {
      if (state.sessionStatus == TrainingSessionStatus.running) {
        final currentSteps = event.steps;
        int initialSteps = state.initialSteps;
        int initialDist = state.initialDistance;

        // Auto-anchor on first positive hardware reading if initial was uninitialized (0)
        if (initialSteps <= 0 && currentSteps > 0 && state.sessionSteps == 0) {
          initialSteps = currentSteps;
          initialDist = event.distanceMeters;
        }

        final diffSteps = (currentSteps - initialSteps).clamp(0, 150000);
        final currentDist = event.distanceMeters;
        final diffDist = (currentDist - initialDist).clamp(0, 1000000).toDouble();

        // Stride estimation fallback if hardware distance is not advancing:
        final effectiveDist = diffDist > 5.0 ? diffDist : (diffSteps * 0.76);

        // Instantly recalculate pace & speed when new band steps arrive
        double currentSpeed = state.currentSpeedKmh;
        int currentPace = state.currentPaceSec;
        if (effectiveDist >= 5.0 && state.elapsedSeconds >= 3) {
          final km = effectiveDist / 1000.0;
          final hours = state.elapsedSeconds / 3600.0;
          currentSpeed = (km / hours).clamp(0.0, 70.0);
          final secPerKm = (state.elapsedSeconds / km).round();
          currentPace = secPerKm.clamp(120, 1800);
        }

        emit(state.copyWith(
          initialSteps: initialSteps,
          initialDistance: initialDist,
          sessionSteps: diffSteps,
          distanceMeters: effectiveDist,
          currentSpeedKmh: currentSpeed,
          currentPaceSec: currentPace,
        ));
      }
    });

    on<UpdateLiveTrainingHeartRateEvent>((event, emit) {
      if (event.bpm > 0) {
        // Compute heart rate zone deterministically via domain calculator
        final calculatedZone = _zoneCalculator.calculateZone(event.bpm);

        final newPeak = event.bpm > state.peakHeartRate ? event.bpm : state.peakHeartRate;
        final newSum = state.heartRateSum + event.bpm;
        final newCount = state.heartRateCount + 1;
        final newAvg = (newSum / newCount).round();

        // Update the calorie estimate baseline with the latest live HR reading
        WorkoutModel? updatedData = state.data;
        if (updatedData != null) {
          final liveRate = calculateEstimatedKcalPerMin(
            category: updatedData.selectedCategory,
            weightKg: updatedData.selectedWeightKg,
            liveHeartRate: event.bpm,
          );
          if (liveRate != updatedData.estimatedKcalPerMin) {
            updatedData = updatedData.copyWith(estimatedKcalPerMin: liveRate);
            repository.updateWorkoutData(updatedData);
          }
        }

        // Only update currentZone automatically from HR if user hasn't explicitly locked a target zone,
        // or if live heart rate is actively moving through elevated zones
        final int activeZone = (state.isManualZone && event.bpm < 100)
            ? state.currentZone
            : calculatedZone;

        emit(state.copyWith(
          data: updatedData,
          liveHeartRate: event.bpm,
          currentZone: activeZone,
          peakHeartRate: newPeak,
          avgHeartRate: newAvg,
          heartRateSum: newSum,
          heartRateCount: newCount,
        ));
      }
    });

    on<FinishWorkoutEvent>((event, emit) async {
      // Prevent duplicate saves if triggered multiple times
      if (state.sessionStatus != TrainingSessionStatus.running &&
          state.sessionStatus != TrainingSessionStatus.paused) {
        return;
      }

      try {
        await bandRepository?.stopRealtimeHeartRate();
      } catch (_) {}

      final duration = state.elapsedSeconds;
      final peakHr = state.peakHeartRate;
      final avgHr = state.avgHeartRate;
      final calories = state.burnedCalories;
      final baseTitle = state.data?.title ?? 'Outdoor run';
      final category = state.data?.selectedCategory ?? WorkoutType.run;

      // Include tracked distance in session title when applicable
      String finalTitle = baseTitle;
      if (state.distanceMeters > 50) {
        final distKm = (state.distanceMeters / 1000.0).toStringAsFixed(2);
        finalTitle = '$baseTitle · $distKm km';
      }

      // Persist completed workout to SQLite
      if (duration >= 5 && (calories > 0 || avgHr > 0 || duration >= 15)) {
        final now = DateTime.now();
        final startTime = now.subtract(Duration(seconds: duration));

        await repository.saveWorkoutSession(
          title: finalTitle,
          category: category,
          durationSeconds: duration,
          burnedCalories: calories,
          avgHeartRate: avgHr,
          peakHeartRate: peakHr,
          startTime: startTime,
          endTime: now,
        );
      }

      // Reload fresh SQLite history
      final recent = await repository.getRecentWorkoutSessions(limit: 10);
      var updatedData = repository.getWorkoutData();
      if (recent.isNotEmpty) {
        final latest = recent.first;
        final h = latest.durationSeconds ~/ 3600;
        final m = (latest.durationSeconds % 3600) ~/ 60;
        final s = latest.durationSeconds % 60;
        final durStr = '${h.toString().padLeft(2, '0')}hr ${m.toString().padLeft(2, '0')}min ${s.toString().padLeft(2, '0')}sec';
        updatedData = updatedData.copyWith(
          recentSessionTitle: latest.title,
          recentSessionDuration: durStr,
          recentPeakHr: latest.peakHeartRate,
          recentAvgHr: latest.avgHeartRate,
        );
        repository.updateWorkoutData(updatedData);
      }

      emit(state.copyWith(
        sessionStatus: TrainingSessionStatus.completed,
        data: updatedData,
        recentSessions: recent,
      ));
    });

    on<DeleteWorkoutSessionEvent>((event, emit) async {
      await repository.deleteWorkoutSession(event.sessionId);
      final recent = await repository.getRecentWorkoutSessions(limit: 10);
      var updatedData = repository.getWorkoutData();
      if (recent.isNotEmpty) {
        final latest = recent.first;
        final h = latest.durationSeconds ~/ 3600;
        final m = (latest.durationSeconds % 3600) ~/ 60;
        final s = latest.durationSeconds % 60;
        final durStr = '${h.toString().padLeft(2, '0')}hr ${m.toString().padLeft(2, '0')}min ${s.toString().padLeft(2, '0')}sec';
        updatedData = updatedData.copyWith(
          recentSessionTitle: latest.title,
          recentSessionDuration: durStr,
          recentPeakHr: latest.peakHeartRate,
          recentAvgHr: latest.avgHeartRate,
        );
      } else {
        updatedData = updatedData.copyWith(
          recentSessionTitle: 'Outdoor run',
          recentSessionDuration: '--',
          recentPeakHr: 0,
          recentAvgHr: 0,
        );
      }
      repository.updateWorkoutData(updatedData);
      emit(state.copyWith(
        data: updatedData,
        recentSessions: recent,
      ));
    });

    // ── Streams Subscription from Wearable Repository ─────────────
    if (bandRepository != null) {
      final initialHr = bandRepository!.lastSyncedVitals.latestHeartRate;
      if (initialHr > 0) {
        add(UpdateLiveTrainingHeartRateEvent(initialHr));
      }

      _hrSubscription = bandRepository!.liveHeartRateStream.listen((bpm) {
        add(UpdateLiveTrainingHeartRateEvent(bpm));
      });

      _vitalsSubscription = bandRepository!.syncedVitalsStream.listen((vitals) {
        add(UpdateLiveTrainingCaloriesEvent(vitals.calories));
      });

      _pedometerSubscription = bandRepository!.pedometerStream.listen((pedometer) {
        add(UpdateLivePedometerEvent(
          steps: pedometer.steps,
          distanceMeters: pedometer.distance,
        ));
      });
    }
  }

  @override
  Future<void> close() {
    _hrSubscription?.cancel();
    _vitalsSubscription?.cancel();
    _pedometerSubscription?.cancel();
    return super.close();
  }
}
