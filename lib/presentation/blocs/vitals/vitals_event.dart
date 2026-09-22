import 'package:equatable/equatable.dart';

abstract class VitalsEvent extends Equatable {
  const VitalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVitalsEvent extends VitalsEvent {}

class UpdateVitalsFromBandEvent extends VitalsEvent {
  final dynamic vitals; // BandSyncedVitals
  const UpdateVitalsFromBandEvent(this.vitals);

  @override
  List<Object?> get props => [vitals];
}

class UpdateLiveHeartRateEvent extends VitalsEvent {
  final int bpm;
  const UpdateLiveHeartRateEvent(this.bpm);

  @override
  List<Object?> get props => [bpm];
}
