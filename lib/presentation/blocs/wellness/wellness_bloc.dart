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
        emit(state.copyWith(
          status: WellnessStatus.loaded,
          data: data,
          baseline: repository.baselineData,
        ));
      } catch (e) {
        emit(
          state.copyWith(
            status: WellnessStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<ChangeWellnessModeEvent>((event, emit) async {
      await repository.changeWellnessMode(event.mode);
      final data = repository.getWellnessData();
      emit(state.copyWith(
        data: data,
        baseline: repository.baselineData,
      ));
    });

    on<AddHydrationEvent>((event, emit) async {
      await repository.addHydration(event.amountMl);
      final data = repository.getWellnessData();
      emit(state.copyWith(
        data: data,
        baseline: repository.baselineData,
      ));
    });

    on<RemoveHydrationEvent>((event, emit) async {
      await repository.removeHydration(event.amountMl);
      final data = repository.getWellnessData();
      emit(state.copyWith(
        data: data,
        baseline: repository.baselineData,
      ));
    });

    on<RemoveHydrationEntryEvent>((event, emit) async {
      await repository.removeHydrationEntryById(event.entryId, date: event.date);
      final data = repository.getWellnessData();
      emit(state.copyWith(
        data: data,
        baseline: repository.baselineData,
      ));
    });

    on<SetHydrationEvent>((event, emit) async {
      await repository.setHydration(event.totalMl);
      final data = repository.getWellnessData();
      emit(state.copyWith(
        data: data,
        baseline: repository.baselineData,
      ));
    });

    on<CompleteMindSessionEvent>((event, emit) async {
      await repository.completeMindSession(points: event.points);
      final data = repository.getWellnessData();
      emit(state.copyWith(
        status: WellnessStatus.loaded,
        data: data,
        baseline: repository.baselineData,
      ));
    });

    on<SyncBandVitalsEvent>((event, emit) {
      if (state.data != null) {
        final int hr = (event.liveHeartRate != null && event.liveHeartRate! > 0)
            ? event.liveHeartRate!
            : state.data!.currentHeartRate;
        if (hr > 0) {
          repository.updateHeartRate(hr);
        }
        repository.updateStepsAndCalories(
          steps: event.steps,
          calories: event.calories,
        );
        final data = repository.getWellnessData();
        emit(state.copyWith(
          data: data,
          baseline: repository.baselineData,
        ));
      }
    });

    on<CheckMidnightRolloverEvent>((event, emit) {
      final rolledOver = repository.checkMidnightRollover();
      if (rolledOver) {
        final data = repository.getWellnessData();
        emit(state.copyWith(
          status: WellnessStatus.loaded,
          data: data,
          baseline: repository.baselineData,
        ));
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
          repository.updateFromBandVitals(
            event.vitals,
            updateMode: event.isManualRefresh,
          );
        }
        final data = repository.getWellnessData();
        emit(state.copyWith(
          status: WellnessStatus.loaded,
          data: data,
          baseline: repository.baselineData,
        ));
      }
    });
  }
}

