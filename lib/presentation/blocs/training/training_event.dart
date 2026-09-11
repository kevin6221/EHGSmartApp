import 'package:equatable/equatable.dart';

import '../../../data/models/workout_model.dart';

abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainingDataEvent extends TrainingEvent {}

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
