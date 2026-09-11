import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/wellness_repository.dart';
import 'vitals_event.dart';
import 'vitals_state.dart';

class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  final WellnessRepository repository;

  VitalsBloc({required this.repository}) : super(const VitalsState()) {
    on<LoadVitalsEvent>((event, emit) {
      emit(state.copyWith(status: VitalsStatus.loading));
      try {
        final data = repository.getVitalsData();
        emit(state.copyWith(status: VitalsStatus.loaded, data: data));
      } catch (e) {
        emit(
          state.copyWith(
            status: VitalsStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
