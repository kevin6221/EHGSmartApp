import 'package:equatable/equatable.dart';

import '../../../data/models/workout_model.dart';

enum TrainingStatus { initial, loading, loaded, error }

enum TrainingSessionStatus { idle, running, paused, completed }

class TrainingState extends Equatable {
  final TrainingStatus status;
  final WorkoutModel? data;
  final String? errorMessage;
  final TrainingSessionStatus sessionStatus;
  final int elapsedSeconds;
  final int liveHeartRate;
  final int burnedCalories;
  final int currentZone;

  const TrainingState({
    this.status = TrainingStatus.initial,
    this.data,
    this.errorMessage,
    this.sessionStatus = TrainingSessionStatus.idle,
    this.elapsedSeconds = 0,
    this.liveHeartRate = 0,
    this.burnedCalories = 0,
    this.currentZone = 1,
  });

  TrainingState copyWith({
    TrainingStatus? status,
    WorkoutModel? data,
    String? errorMessage,
    TrainingSessionStatus? sessionStatus,
    int? elapsedSeconds,
    int? liveHeartRate,
    int? burnedCalories,
    int? currentZone,
  }) {
    return TrainingState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      liveHeartRate: liveHeartRate ?? this.liveHeartRate,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      currentZone: currentZone ?? this.currentZone,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    errorMessage,
    sessionStatus,
    elapsedSeconds,
    liveHeartRate,
    burnedCalories,
    currentZone,
  ];
}
