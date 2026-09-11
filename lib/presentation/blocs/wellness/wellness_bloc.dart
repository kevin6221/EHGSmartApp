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
  }
}
