import 'package:equatable/equatable.dart';

import '../../../data/models/wellness_data_model.dart';

abstract class WellnessEvent extends Equatable {
  const WellnessEvent();

  @override
  List<Object?> get props => [];
}

class LoadWellnessDataEvent extends WellnessEvent {
  const LoadWellnessDataEvent();
}

class ChangeWellnessModeEvent extends WellnessEvent {
  final WellnessMode mode;

  const ChangeWellnessModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class AddHydrationEvent extends WellnessEvent {
  final int amountMl;

  const AddHydrationEvent(this.amountMl);

  @override
  List<Object?> get props => [amountMl];
}

class SyncBandVitalsEvent extends WellnessEvent {
  final int steps;
  final int calories;
  final int distance;
  final int sleepMinutes;
  final int deepSleepMinutes;
  final int? liveHeartRate;
  final double bloodOxygen;
  final int systolicBP;
  final int diastolicBP;
  final double skinTemperature;
  final int stressLevel;
  final int hrvMs;
  final int restingHeartRate;

  const SyncBandVitalsEvent({
    required this.steps,
    required this.calories,
    required this.distance,
    required this.sleepMinutes,
    required this.deepSleepMinutes,
    this.liveHeartRate,
    this.bloodOxygen = 0,
    this.systolicBP = 0,
    this.diastolicBP = 0,
    this.skinTemperature = 0,
    this.stressLevel = 0,
    this.hrvMs = 0,
    this.restingHeartRate = 0,
  });

  @override
  List<Object?> get props => [
        steps,
        calories,
        distance,
        sleepMinutes,
        deepSleepMinutes,
        liveHeartRate,
        bloodOxygen,
        systolicBP,
        diastolicBP,
        skinTemperature,
        stressLevel,
        hrvMs,
        restingHeartRate,
      ];
}

class SyncBandFullVitalsEvent extends WellnessEvent {
  final dynamic vitals; // BandSyncedVitals
  const SyncBandFullVitalsEvent(this.vitals);

  @override
  List<Object?> get props => [vitals];
}

