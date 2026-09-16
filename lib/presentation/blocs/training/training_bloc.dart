import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/wellness_repository.dart';
import '../../../data/models/workout_model.dart';
import 'training_event.dart';
import 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final WellnessRepository repository;

  TrainingBloc({required this.repository}) : super(const TrainingState()) {
    on<LoadTrainingDataEvent>((event, emit) {
      emit(state.copyWith(status: TrainingStatus.loading));
      try {
        final data = repository.getWorkoutData();
        emit(state.copyWith(status: TrainingStatus.loaded, data: data));
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

        switch (event.category) {
          case WorkoutType.run:
            title = 'Outdoor run';
            zoneInfo = 'Zone 2–4 · 130–165 bpm';
            metrics = 'Pace, cadence, HR zones, route, recovery HR';
            break;
          case WorkoutType.walk:
            title = 'Brisk walk';
            zoneInfo = 'Zone 1–2 · 95–120 bpm';
            metrics = 'Steps, cadence, elevation gain, recovery HR';
            break;
          case WorkoutType.cycling:
            title = 'Outdoor cycling';
            zoneInfo = 'Zone 2–3 · 120–150 bpm';
            metrics = 'Speed, distance, elevation, power zones';
            break;
          case WorkoutType.strength:
            title = 'Full body strength';
            zoneInfo = 'Zone 3–4 · 125–160 bpm';
            metrics = 'Reps, sets, volume, heart rate peak';
            break;
          case WorkoutType.hit:
            title = 'HIIT intervals';
            zoneInfo = 'Zone 4–5 · 150–185 bpm';
            metrics = 'Interval splits, max HR, EPOC burn';
            break;
        }

        final updated = state.data!.copyWith(
          selectedCategory: event.category,
          title: title,
          zoneInfo: zoneInfo,
          metricsSummary: metrics,
        );
        emit(state.copyWith(data: updated));
      }
    });

    on<SelectWeightEvent>((event, emit) {
      if (state.data != null) {
        final calculatedRate = (event.weightKg * 0.167).round();
        final updated = state.data!.copyWith(
          selectedWeightKg: event.weightKg,
          estimatedKcalPerMin: calculatedRate,
        );
        emit(state.copyWith(data: updated));
      }
    });

    on<StartWorkoutEvent>((event, emit) {
      emit(
        state.copyWith(
          sessionStatus: TrainingSessionStatus.running,
          elapsedSeconds: 0,
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
        emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
      }
    });

    on<FinishWorkoutEvent>((event, emit) {
      emit(state.copyWith(sessionStatus: TrainingSessionStatus.completed));
    });
  }
}
