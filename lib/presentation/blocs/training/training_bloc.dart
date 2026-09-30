import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/band_device_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../../data/models/workout_model.dart';
import 'training_event.dart';
import 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final WellnessRepository repository;
  final BandRepository? bandRepository;
  StreamSubscription<int>? _hrSubscription;
  StreamSubscription<BandSyncedVitals>? _vitalsSubscription;

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

  TrainingBloc({required this.repository, this.bandRepository}) : super(const TrainingState()) {
    on<LoadTrainingDataEvent>((event, emit) {
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
        emit(state.copyWith(status: TrainingStatus.loaded, data: syncedData));
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

    on<StartWorkoutEvent>((event, emit) {
      emit(
        state.copyWith(
          sessionStatus: TrainingSessionStatus.running,
          elapsedSeconds: 0,
          burnedCalories: 0,
          peakHeartRate: 0,
          avgHeartRate: 0,
          heartRateSum: 0,
          heartRateCount: 0,
          liveHeartRate: 0,
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
        int calories = state.burnedCalories;
        final weightKg = state.data?.selectedWeightKg ?? 70;
        final category = state.data?.selectedCategory ?? WorkoutType.run;
        final effectiveHr = state.liveHeartRate > 0 ? state.liveHeartRate : state.avgHeartRate;

        double kcalPerMin;
        if (effectiveHr > 60) {
          // Proven Keytel heart-rate based expenditure equation (Journal of Sports Sciences)
          // Men/General: (-55.0969 + (0.6309 * HR) + (0.1988 * weight) + (0.2017 * age=30)) / 4.184
          final keytelKcal = ((-55.0969 + (0.6309 * effectiveHr) + (0.1988 * weightKg) + (0.2017 * 30)) / 4.184);

          // Sport-specific factor for mechanical difference between modes
          double sportFactor = 1.0;
          if (category == WorkoutType.run) sportFactor = 1.05;
          if (category == WorkoutType.hit) sportFactor = 1.10;
          if (category == WorkoutType.strength) sportFactor = 0.85;
          if (category == WorkoutType.walk) sportFactor = 0.80;
          if (category == WorkoutType.cycling) sportFactor = 0.95;

          kcalPerMin = (keytelKcal * sportFactor).clamp(2.5, 25.0);
        } else {
          // Baseline workout category estimation with intensity zone multiplier
          final baseKcal = (state.data?.estimatedKcalPerMin ?? 10).toDouble();
          double hrMultiplier = 1.0;
          if (state.currentZone == 3) hrMultiplier = 1.2;
          if (state.currentZone == 4) hrMultiplier = 1.5;
          if (state.currentZone >= 5) hrMultiplier = 1.8;
          kcalPerMin = baseKcal * hrMultiplier;
        }

        final dynamicCalories = ((newSec / 60.0) * kcalPerMin).round();
        if (dynamicCalories > calories) {
          calories = dynamicCalories;
        }
        emit(
          state.copyWith(
            elapsedSeconds: newSec,
            burnedCalories: calories,
          ),
        );
      }
    });

    on<UpdateLiveTrainingCaloriesEvent>((event, emit) {
      // Only allow idle pedometer calibration, never overwrite an active or finished workout session
      if (state.sessionStatus == TrainingSessionStatus.idle) {
        emit(state.copyWith(burnedCalories: event.calories));
      }
    });

    on<UpdateLiveTrainingHeartRateEvent>((event, emit) {
      if (event.bpm > 0) {
        int zone = 1;
        if (event.bpm >= 170) {
          zone = 5;
        } else if (event.bpm >= 150) {
          zone = 4;
        } else if (event.bpm >= 130) {
          zone = 3;
        } else if (event.bpm >= 110) {
          zone = 2;
        } else {
          zone = 1;
        }

        final newPeak = event.bpm > state.peakHeartRate ? event.bpm : state.peakHeartRate;
        final newSum = state.heartRateSum + event.bpm;
        final newCount = state.heartRateCount + 1;
        final newAvg = (newSum / newCount).round();

        // Dynamically update the calorie estimate on the active training card with the live HR reading
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

        emit(state.copyWith(
          data: updatedData,
          liveHeartRate: event.bpm,
          currentZone: zone,
          peakHeartRate: newPeak,
          avgHeartRate: newAvg,
          heartRateSum: newSum,
          heartRateCount: newCount,
        ));
      }
    });

    on<FinishWorkoutEvent>((event, emit) async {
      final duration = state.elapsedSeconds;
      final peakHr = state.peakHeartRate;
      final avgHr = state.avgHeartRate;
      final calories = state.burnedCalories;
      final title = state.data?.title ?? 'Outdoor run';
      final category = state.data?.selectedCategory ?? WorkoutType.run;

      // Only persist genuine sessions (duration >= 15s with actual burn/HR or >= 60s)
      if (duration >= 15 && (calories > 0 || avgHr > 0 || duration >= 60)) {
        final now = DateTime.now();
        final startTime = now.subtract(Duration(seconds: duration));

        await repository.saveWorkoutSession(
          title: title,
          category: category,
          durationSeconds: duration,
          burnedCalories: calories,
          avgHeartRate: avgHr,
          peakHeartRate: peakHr,
          startTime: startTime,
          endTime: now,
        );
      }

      final updatedData = repository.getWorkoutData();
      emit(state.copyWith(
        sessionStatus: TrainingSessionStatus.completed,
        data: updatedData,
      ));
    });

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
    }
  }

  @override
  Future<void> close() {
    _hrSubscription?.cancel();
    _vitalsSubscription?.cancel();
    return super.close();
  }
}


