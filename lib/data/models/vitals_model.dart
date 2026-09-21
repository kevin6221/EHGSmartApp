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

  VitalsModel copyWith({
    String? totalSleep,
    String? sleepWindow,
    List<SleepInterval>? sleepIntervals,
    int? currentHeartRate,
    List<double>? weeklyHeartRate,
    int? stressScore,
    String? stressStatus,
    List<double>? stressTimeline,
    int? hrvMs,
    List<double>? weeklyHrv,
    int? restingHr,
    List<double>? weeklyRestingHr,
    int? bloodOxygen,
    List<double>? weeklyOxygen,
    double? breathingRate,
    List<double>? weeklyBreathing,
    String? bloodPressure,
    bool? isBloodPressureUp,
    double? skinTempDiff,
    bool? isSkinTempDown,
  }) {
    return VitalsModel(
      totalSleep: totalSleep ?? this.totalSleep,
      sleepWindow: sleepWindow ?? this.sleepWindow,
      sleepIntervals: sleepIntervals ?? this.sleepIntervals,
      currentHeartRate: currentHeartRate ?? this.currentHeartRate,
      weeklyHeartRate: weeklyHeartRate ?? this.weeklyHeartRate,
      stressScore: stressScore ?? this.stressScore,
      stressStatus: stressStatus ?? this.stressStatus,
      stressTimeline: stressTimeline ?? this.stressTimeline,
      hrvMs: hrvMs ?? this.hrvMs,
      weeklyHrv: weeklyHrv ?? this.weeklyHrv,
      restingHr: restingHr ?? this.restingHr,
      weeklyRestingHr: weeklyRestingHr ?? this.weeklyRestingHr,
      bloodOxygen: bloodOxygen ?? this.bloodOxygen,
      weeklyOxygen: weeklyOxygen ?? this.weeklyOxygen,
      breathingRate: breathingRate ?? this.breathingRate,
      weeklyBreathing: weeklyBreathing ?? this.weeklyBreathing,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      isBloodPressureUp: isBloodPressureUp ?? this.isBloodPressureUp,
      skinTempDiff: skinTempDiff ?? this.skinTempDiff,
      isSkinTempDown: isSkinTempDown ?? this.isSkinTempDown,
    );
  }

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
