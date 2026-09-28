import 'package:equatable/equatable.dart';

import '../../../core/engine/personalized_baseline_engine.dart';
import '../../../data/models/wellness_data_model.dart';

enum WellnessStatus { initial, loading, loaded, error }

class WellnessState extends Equatable {
  final WellnessStatus status;
  final WellnessDataModel? data;
  final PersonalizedBaselineData? baseline;
  final String? errorMessage;

  const WellnessState({
    this.status = WellnessStatus.initial,
    this.data,
    this.baseline,
    this.errorMessage,
  });

  WellnessState copyWith({
    WellnessStatus? status,
    WellnessDataModel? data,
    PersonalizedBaselineData? baseline,
    String? errorMessage,
  }) {
    return WellnessState(
      status: status ?? this.status,
      data: data ?? this.data,
      baseline: baseline ?? this.baseline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, baseline, errorMessage];
}
