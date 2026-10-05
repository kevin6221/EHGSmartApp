import 'package:equatable/equatable.dart';

import '../../../core/database/app_database.dart';
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
  final bool isManualZone;
  final int peakHeartRate;
  final int avgHeartRate;
  final int heartRateSum;
  final int heartRateCount;

  // Real-time activity-specific metrics
  final double distanceMeters;
  final double currentSpeedKmh;
  final int currentPaceSec;
  final int sessionSteps;
  final int initialSteps;
  final int initialDistance;

  // Time in Zone tracking (WHOOP / Garmin standard)
  final int zone1Seconds;
  final int zone2Seconds;
  final int zone3Seconds;
  final int zone4Seconds;
  final int zone5Seconds;

  // Local SQLite backed recent sessions history
  final List<WorkoutSession> recentSessions;

  const TrainingState({
    this.status = TrainingStatus.initial,
    this.data,
    this.errorMessage,
    this.sessionStatus = TrainingSessionStatus.idle,
    this.elapsedSeconds = 0,
    this.liveHeartRate = 0,
    this.burnedCalories = 0,
    this.currentZone = 1,
    this.isManualZone = false,
    this.peakHeartRate = 0,
    this.avgHeartRate = 0,
    this.heartRateSum = 0,
    this.heartRateCount = 0,
    this.distanceMeters = 0.0,
    this.currentSpeedKmh = 0.0,
    this.currentPaceSec = 0,
    this.sessionSteps = 0,
    this.initialSteps = 0,
    this.initialDistance = 0,
    this.zone1Seconds = 0,
    this.zone2Seconds = 0,
    this.zone3Seconds = 0,
    this.zone4Seconds = 0,
    this.zone5Seconds = 0,
    this.recentSessions = const [],
  });

  String get formattedDistance {
    final km = distanceMeters / 1000.0;
    return km.toStringAsFixed(2);
  }

  String get formattedSpeed {
    return currentSpeedKmh.toStringAsFixed(1);
  }

  String get formattedPace {
    if (currentPaceSec <= 0 || currentPaceSec > 3600) return '--:--';
    final m = currentPaceSec ~/ 60;
    final s = currentPaceSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  TrainingState copyWith({
    TrainingStatus? status,
    WorkoutModel? data,
    String? errorMessage,
    TrainingSessionStatus? sessionStatus,
    int? elapsedSeconds,
    int? liveHeartRate,
    int? burnedCalories,
    int? currentZone,
    bool? isManualZone,
    int? peakHeartRate,
    int? avgHeartRate,
    int? heartRateSum,
    int? heartRateCount,
    double? distanceMeters,
    double? currentSpeedKmh,
    int? currentPaceSec,
    int? sessionSteps,
    int? initialSteps,
    int? initialDistance,
    int? zone1Seconds,
    int? zone2Seconds,
    int? zone3Seconds,
    int? zone4Seconds,
    int? zone5Seconds,
    List<WorkoutSession>? recentSessions,
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
      isManualZone: isManualZone ?? this.isManualZone,
      peakHeartRate: peakHeartRate ?? this.peakHeartRate,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      heartRateSum: heartRateSum ?? this.heartRateSum,
      heartRateCount: heartRateCount ?? this.heartRateCount,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      currentPaceSec: currentPaceSec ?? this.currentPaceSec,
      sessionSteps: sessionSteps ?? this.sessionSteps,
      initialSteps: initialSteps ?? this.initialSteps,
      initialDistance: initialDistance ?? this.initialDistance,
      zone1Seconds: zone1Seconds ?? this.zone1Seconds,
      zone2Seconds: zone2Seconds ?? this.zone2Seconds,
      zone3Seconds: zone3Seconds ?? this.zone3Seconds,
      zone4Seconds: zone4Seconds ?? this.zone4Seconds,
      zone5Seconds: zone5Seconds ?? this.zone5Seconds,
      recentSessions: recentSessions ?? this.recentSessions,
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
    isManualZone,
    peakHeartRate,
    avgHeartRate,
    heartRateSum,
    heartRateCount,
    distanceMeters,
    currentSpeedKmh,
    currentPaceSec,
    sessionSteps,
    initialSteps,
    initialDistance,
    zone1Seconds,
    zone2Seconds,
    zone3Seconds,
    zone4Seconds,
    zone5Seconds,
    recentSessions,
  ];
}
