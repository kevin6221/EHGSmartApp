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
