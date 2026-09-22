import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/band_device_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../../../data/repositories/wellness_repository.dart';
import 'vitals_event.dart';
import 'vitals_state.dart';

class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  final WellnessRepository repository;
  final BandRepository? bandRepository;

  StreamSubscription<BandSyncedVitals>? _vitalsSubscription;
  StreamSubscription<int>? _hrSubscription;

  VitalsBloc({required this.repository, this.bandRepository}) : super(const VitalsState()) {
    if (bandRepository != null) {
      _vitalsSubscription = bandRepository!.syncedVitalsStream.listen((vitals) {
        add(UpdateVitalsFromBandEvent(vitals));
      });
      _hrSubscription = bandRepository!.liveHeartRateStream.listen((bpm) {
        add(UpdateLiveHeartRateEvent(bpm));
      });
    }

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

    on<UpdateVitalsFromBandEvent>((event, emit) {
      if (event.vitals is BandSyncedVitals) {
        repository.updateFromBandVitals(event.vitals as BandSyncedVitals);
        final data = repository.getVitalsData();
        emit(state.copyWith(status: VitalsStatus.loaded, data: data));
      }
    });

    on<UpdateLiveHeartRateEvent>((event, emit) {
      repository.updateHeartRate(event.bpm);
      final data = repository.getVitalsData();
      emit(state.copyWith(data: data));
    });
  }

  @override
  Future<void> close() {
    _vitalsSubscription?.cancel();
    _hrSubscription?.cancel();
    return super.close();
  }
}


