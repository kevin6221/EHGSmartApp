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
  final int peakHeartRate;
  final int avgHeartRate;
  final int heartRateSum;
  final int heartRateCount;

  const TrainingState({
    this.status = TrainingStatus.initial,
    this.data,
    this.errorMessage,
    this.sessionStatus = TrainingSessionStatus.idle,
    this.elapsedSeconds = 0,
    this.liveHeartRate = 0,
    this.burnedCalories = 0,
    this.currentZone = 1,
    this.peakHeartRate = 0,
    this.avgHeartRate = 0,
    this.heartRateSum = 0,
    this.heartRateCount = 0,
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
    int? peakHeartRate,
    int? avgHeartRate,
    int? heartRateSum,
    int? heartRateCount,
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
      peakHeartRate: peakHeartRate ?? this.peakHeartRate,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      heartRateSum: heartRateSum ?? this.heartRateSum,
      heartRateCount: heartRateCount ?? this.heartRateCount,
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
    peakHeartRate,
    avgHeartRate,
    heartRateSum,
    heartRateCount,
  ];
}
