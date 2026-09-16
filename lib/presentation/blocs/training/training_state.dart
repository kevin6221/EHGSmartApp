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

  const TrainingState({
    this.status = TrainingStatus.initial,
    this.data,
    this.errorMessage,
    this.sessionStatus = TrainingSessionStatus.idle,
    this.elapsedSeconds = 0,
  });

  TrainingState copyWith({
    TrainingStatus? status,
    WorkoutModel? data,
    String? errorMessage,
    TrainingSessionStatus? sessionStatus,
    int? elapsedSeconds,
  }) {
    return TrainingState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    errorMessage,
    sessionStatus,
    elapsedSeconds,
  ];
}
