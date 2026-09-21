import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/wellness_repository.dart';
import 'wellness_event.dart';
import 'wellness_state.dart';

class WellnessBloc extends Bloc<WellnessEvent, WellnessState> {
  final WellnessRepository repository;

  WellnessBloc({required this.repository}) : super(const WellnessState()) {
    on<LoadWellnessDataEvent>((event, emit) {
      emit(state.copyWith(status: WellnessStatus.loading));
      try {
        final data = repository.getWellnessData();
        emit(state.copyWith(status: WellnessStatus.loaded, data: data));
      } catch (e) {
        emit(
          state.copyWith(
            status: WellnessStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<ChangeWellnessModeEvent>((event, emit) {
      if (state.data != null) {
        final updated = state.data!.copyWith(activeMode: event.mode);
        emit(state.copyWith(data: updated));
      }
    });

    on<AddHydrationEvent>((event, emit) {
      if (state.data != null) {
        final newHydration = (state.data!.hydrationCurrent + event.amountMl)
            .clamp(0, 5000);
        final updated = state.data!.copyWith(hydrationCurrent: newHydration);
        emit(state.copyWith(data: updated));
      }
    });

    on<SyncBandVitalsEvent>((event, emit) {
      if (state.data != null) {
        final double sleepHours = event.sleepMinutes > 0
            ? double.parse((event.sleepMinutes / 60.0).toStringAsFixed(1))
            : state.data!.sleepHours;
        final int energy = event.calories > 0
            ? event.calories
            : state.data!.energyBurned;
        final int hr = (event.liveHeartRate != null && event.liveHeartRate! > 0)
            ? event.liveHeartRate!
            : state.data!.currentHeartRate;

        // Recalculate move and recover scores from actual band data
        final moveScore = (energy / 600.0 * 50.0).clamp(10.0, 100.0).round();
        final recoverScore = (sleepHours / 8.0 * 60.0 + (event.deepSleepMinutes / 90.0 * 40.0))
            .clamp(20.0, 100.0)
            .round();
        final wellnessScore = ((moveScore + recoverScore + state.data!.mindScore + state.data!.fuelScore) / 4)
            .round();

        final updated = state.data!.copyWith(
          currentHeartRate: hr,
          sleepHours: sleepHours,
          energyBurned: energy,
          moveScore: moveScore,
          recoverScore: recoverScore,
          wellnessScore: wellnessScore,
        );
        emit(state.copyWith(data: updated));
      }
    });
  }
}
