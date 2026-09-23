import 'package:equatable/equatable.dart';

enum SleepPhase { deep, light, rem, awake }

class SleepInterval extends Equatable {
  final double startOffset; // 0.0 to 1.0 representing timeline fraction
  final double widthFraction;
  final SleepPhase phase;
  final String? timeRangeText; // e.g. "01:05 pm → 03:33 pm (2h 28m)"

  const SleepInterval({
    required this.startOffset,
    required this.widthFraction,
    required this.phase,
    this.timeRangeText,
  });

  Map<String, dynamic> toJson() => {
    'startOffset': startOffset,
    'widthFraction': widthFraction,
    'phase': phase.name,
    'timeRangeText': timeRangeText,
  };

  factory SleepInterval.fromJson(Map<String, dynamic> json) => SleepInterval(
    startOffset: (json['startOffset'] as num?)?.toDouble() ?? 0.0,
    widthFraction: (json['widthFraction'] as num?)?.toDouble() ?? 0.0,
    phase: SleepPhase.values.firstWhere(
      (p) => p.name == json['phase'],
      orElse: () => SleepPhase.light,
    ),
    timeRangeText: json['timeRangeText'] as String?,
  );

  @override
  List<Object?> get props => [startOffset, widthFraction, phase, timeRangeText];
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

  Map<String, dynamic> toJson() => {
    'totalSleep': totalSleep,
    'sleepWindow': sleepWindow,
    'sleepIntervals': sleepIntervals.map((i) => i.toJson()).toList(),
    'currentHeartRate': currentHeartRate,
    'weeklyHeartRate': weeklyHeartRate,
    'stressScore': stressScore,
    'stressStatus': stressStatus,
    'stressTimeline': stressTimeline,
    'hrvMs': hrvMs,
    'weeklyHrv': weeklyHrv,
    'restingHr': restingHr,
    'weeklyRestingHr': weeklyRestingHr,
    'bloodOxygen': bloodOxygen,
    'weeklyOxygen': weeklyOxygen,
    'breathingRate': breathingRate,
    'weeklyBreathing': weeklyBreathing,
    'bloodPressure': bloodPressure,
    'isBloodPressureUp': isBloodPressureUp,
    'skinTempDiff': skinTempDiff,
    'isSkinTempDown': isSkinTempDown,
  };

  factory VitalsModel.fromJson(Map<String, dynamic> json) => VitalsModel(
    totalSleep: json['totalSleep'] as String? ?? '--',
    sleepWindow: json['sleepWindow'] as String? ?? 'No sleep recorded',
    sleepIntervals: (json['sleepIntervals'] as List<dynamic>?)
            ?.map((i) => SleepInterval.fromJson(i as Map<String, dynamic>))
            .toList() ??
        const [],
    currentHeartRate: (json['currentHeartRate'] as num?)?.toInt() ?? 0,
    weeklyHeartRate: (json['weeklyHeartRate'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    stressScore: (json['stressScore'] as num?)?.toInt() ?? 0,
    stressStatus: json['stressStatus'] as String? ?? '--',
    stressTimeline: (json['stressTimeline'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    hrvMs: (json['hrvMs'] as num?)?.toInt() ?? 0,
    weeklyHrv: (json['weeklyHrv'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    restingHr: (json['restingHr'] as num?)?.toInt() ?? 0,
    weeklyRestingHr: (json['weeklyRestingHr'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    bloodOxygen: (json['bloodOxygen'] as num?)?.toInt() ?? 0,
    weeklyOxygen: (json['weeklyOxygen'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    breathingRate: (json['breathingRate'] as num?)?.toDouble() ?? 0.0,
    weeklyBreathing: (json['weeklyBreathing'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    bloodPressure: json['bloodPressure'] as String? ?? '--',
    isBloodPressureUp: json['isBloodPressureUp'] as bool? ?? false,
    skinTempDiff: (json['skinTempDiff'] as num?)?.toDouble() ?? 0.0,
    isSkinTempDown: json['isSkinTempDown'] as bool? ?? false,
  );

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
