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

  const SelectWorkoutCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
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

