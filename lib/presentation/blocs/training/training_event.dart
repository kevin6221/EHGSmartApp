import 'package:equatable/equatable.dart';

import '../../../data/models/workout_model.dart';

abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainingDataEvent extends TrainingEvent {
  const LoadTrainingDataEvent();
}

class SelectWorkoutCategoryEvent extends TrainingEvent {
  final WorkoutType category;
  final String? customTitle;

  const SelectWorkoutCategoryEvent(this.category, {this.customTitle});

  @override
  List<Object?> get props => [category, customTitle];
}

class SelectWeightEvent extends TrainingEvent {
  final int weightKg;

  const SelectWeightEvent(this.weightKg);

  @override
  List<Object?> get props => [weightKg];
}

class StartWorkoutEvent extends TrainingEvent {
  const StartWorkoutEvent();
}

class ToggleWorkoutPauseEvent extends TrainingEvent {
  const ToggleWorkoutPauseEvent();
}

class TickWorkoutEvent extends TrainingEvent {
  const TickWorkoutEvent();
}

class FinishWorkoutEvent extends TrainingEvent {
  const FinishWorkoutEvent();
}

class SelectTargetZoneEvent extends TrainingEvent {
  final int zone;
  const SelectTargetZoneEvent(this.zone);

  @override
  List<Object?> get props => [zone];
}

class UpdateLiveTrainingHeartRateEvent extends TrainingEvent {
  final int bpm;
  const UpdateLiveTrainingHeartRateEvent(this.bpm);

  @override
  List<Object?> get props => [bpm];
}

class UpdateLiveTrainingCaloriesEvent extends TrainingEvent {
  final int calories;
  const UpdateLiveTrainingCaloriesEvent(this.calories);

  @override
  List<Object?> get props => [calories];
}

class UpdateLivePedometerEvent extends TrainingEvent {
  final int steps;
  final int distanceMeters;
  const UpdateLivePedometerEvent({required this.steps, required this.distanceMeters});

  @override
  List<Object?> get props => [steps, distanceMeters];
}

class DeleteWorkoutSessionEvent extends TrainingEvent {
  final int sessionId;
  const DeleteWorkoutSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
