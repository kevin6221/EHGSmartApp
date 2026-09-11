import 'package:equatable/equatable.dart';

import '../../../data/models/workout_model.dart';

enum TrainingStatus { initial, loading, loaded, error }

class TrainingState extends Equatable {
  final TrainingStatus status;
  final WorkoutModel? data;
  final String? errorMessage;

  const TrainingState({
    this.status = TrainingStatus.initial,
    this.data,
    this.errorMessage,
  });

  TrainingState copyWith({
    TrainingStatus? status,
    WorkoutModel? data,
    String? errorMessage,
  }) {
    return TrainingState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
