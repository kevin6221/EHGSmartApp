import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/wellness_repository.dart';
import 'wellness_event.dart';
import 'wellness_state.dart';

class WellnessBloc extends Bloc<WellnessEvent, WellnessState> {
  final WellnessRepository repository;

  WellnessBloc({required this.repository}) : super(const WellnessState()) {
    on<LoadWellnessDataEvent>((event, emit) async {
      emit(state.copyWith(status: WellnessStatus.loading));
      try {
        await repository.ensureInitialized();
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

    on<AddHydrationEvent>((event, emit) async {
      await repository.addHydration(event.amountMl);
      final data = repository.getWellnessData();
      emit(state.copyWith(data: data));
    });

    on<SyncBandVitalsEvent>((event, emit) {
      if (state.data != null) {
        final int hr = (event.liveHeartRate != null && event.liveHeartRate! > 0)
            ? event.liveHeartRate!
            : state.data!.currentHeartRate;
        if (hr > 0) {
          repository.updateHeartRate(hr);
        }
        if (event.steps > 0 || event.calories > 0) {
          repository.updateStepsAndCalories(
            steps: event.steps > 0 ? event.steps : state.data!.steps,
            calories: event.calories > 0 ? event.calories : state.data!.energyBurned,
          );
        }
        final data = repository.getWellnessData();
        emit(state.copyWith(data: data));
      }
    });

    on<SyncBandFullVitalsEvent>((event, emit) {
      if (event.vitals != null) {
        if (event.vitals.steps == 0 &&
            event.vitals.calories == 0 &&
            event.vitals.restingHeartRate == 0 &&
            event.vitals.sleepMinutes == 0) {
          repository.resetData();
        } else {
          repository.updateFromBandVitals(event.vitals);
        }
        final data = repository.getWellnessData();
        emit(state.copyWith(status: WellnessStatus.loaded, data: data));
      }
    });
  }
}

