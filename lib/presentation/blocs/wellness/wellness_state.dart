import 'package:equatable/equatable.dart';

import '../../../data/models/wellness_data_model.dart';

enum WellnessStatus { initial, loading, loaded, error }

class WellnessState extends Equatable {
  final WellnessStatus status;
  final WellnessDataModel? data;
  final String? errorMessage;

  const WellnessState({
    this.status = WellnessStatus.initial,
    this.data,
    this.errorMessage,
  });

  WellnessState copyWith({
    WellnessStatus? status,
    WellnessDataModel? data,
    String? errorMessage,
  }) {
    return WellnessState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
