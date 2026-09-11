import 'package:equatable/equatable.dart';

enum SleepPhase { deep, light, rem, awake }

class SleepInterval extends Equatable {
  final double startOffset; // 0.0 to 1.0 representing timeline fraction
  final double widthFraction;
  final SleepPhase phase;

  const SleepInterval({
    required this.startOffset,
    required this.widthFraction,
    required this.phase,
  });

  @override
  List<Object?> get props => [startOffset, widthFraction, phase];
}

class VitalsModel extends Equatable {
  final String totalSleep;
  final String sleepWindow;
  final List<SleepInterval> sleepIntervals;
  final int currentHeartRate;
  final List<double> weeklyHeartRate;
  final int stressScore;
  final String stressStatus;
  final List<double> stressTimeline;
  final int hrvMs;
  final List<double> weeklyHrv;
  final int restingHr;
  final List<double> weeklyRestingHr;
  final int bloodOxygen;
  final List<double> weeklyOxygen;
  final double breathingRate;
  final List<double> weeklyBreathing;
  final String bloodPressure;
  final bool isBloodPressureUp;
  final double skinTempDiff;
  final bool isSkinTempDown;

  const VitalsModel({
    required this.totalSleep,
    required this.sleepWindow,
    required this.sleepIntervals,
    required this.currentHeartRate,
    required this.weeklyHeartRate,
    required this.stressScore,
    required this.stressStatus,
    required this.stressTimeline,
    required this.hrvMs,
    required this.weeklyHrv,
    required this.restingHr,
    required this.weeklyRestingHr,
    required this.bloodOxygen,
    required this.weeklyOxygen,
    required this.breathingRate,
    required this.weeklyBreathing,
    required this.bloodPressure,
    required this.isBloodPressureUp,
    required this.skinTempDiff,
    required this.isSkinTempDown,
  });

  @override
  List<Object?> get props => [
    totalSleep,
    sleepWindow,
    sleepIntervals,
    currentHeartRate,
    weeklyHeartRate,
    stressScore,
    stressStatus,
    stressTimeline,
    hrvMs,
    weeklyHrv,
    restingHr,
    weeklyRestingHr,
    bloodOxygen,
    weeklyOxygen,
    breathingRate,
    weeklyBreathing,
    bloodPressure,
    isBloodPressureUp,
    skinTempDiff,
    isSkinTempDown,
  ];
}
