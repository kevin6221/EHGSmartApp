import 'package:equatable/equatable.dart';

import '../../../data/models/vitals_model.dart';

enum VitalsStatus { initial, loading, loaded, error }

class VitalsState extends Equatable {
  final VitalsStatus status;
  final VitalsModel? data;
  final String? errorMessage;

  const VitalsState({
    this.status = VitalsStatus.initial,
    this.data,
    this.errorMessage,
  });

  VitalsState copyWith({
    VitalsStatus? status,
    VitalsModel? data,
    String? errorMessage,
  }) {
    return VitalsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
