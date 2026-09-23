import 'package:equatable/equatable.dart';

enum WellnessMode { recover, steady, push }

class DayChartPoint extends Equatable {
  final String timeLabel;
  final double score;
  final bool isProjected;
  final bool hasPin;

  const DayChartPoint({
    required this.timeLabel,
    required this.score,
    this.isProjected = false,
    this.hasPin = false,
  });

  Map<String, dynamic> toJson() => {
    'timeLabel': timeLabel,
    'score': score,
    'isProjected': isProjected,
    'hasPin': hasPin,
  };

  factory DayChartPoint.fromJson(Map<String, dynamic> json) => DayChartPoint(
    timeLabel: json['timeLabel'] as String? ?? '',
    score: (json['score'] as num?)?.toDouble() ?? 0.0,
    isProjected: json['isProjected'] as bool? ?? false,
    hasPin: json['hasPin'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [timeLabel, score, isProjected, hasPin];
}

class WellnessDataModel extends Equatable {
  final int wellnessScore;
  final int scoreDiff;
  final WellnessMode activeMode;
  final List<DayChartPoint> dayChartPoints;
  final int currentHeartRate;
  final List<double> weeklyHeartRate;
  final double sleepHours;
  final int readinessScore;
  final String readinessTag;
  final String sleepDetail;
  final int hrvMs;
  final int restHr;
  final int stressScore;
  final int hydrationCurrent;
  final int hydrationGoal;
  final List<double> weeklyHydration;
  final int energyBurned;
  final int steps;
  final int activeMins;
  final int goalMins;
  final List<double> weeklyEnergy;

  final int moveScore;
  final int recoverScore;
  final int mindScore;
  final int fuelScore;

  const WellnessDataModel({
    required this.wellnessScore,
    required this.scoreDiff,
    required this.activeMode,
    required this.dayChartPoints,
    required this.currentHeartRate,
    required this.weeklyHeartRate,
    required this.sleepHours,
    required this.readinessScore,
    required this.readinessTag,
    required this.sleepDetail,
    required this.hrvMs,
    required this.restHr,
    required this.stressScore,
    required this.hydrationCurrent,
    required this.hydrationGoal,
    required this.weeklyHydration,
    required this.energyBurned,
    this.steps = 0,
    required this.activeMins,
    required this.goalMins,
    required this.weeklyEnergy,
    required this.moveScore,
    required this.recoverScore,
    required this.mindScore,
    required this.fuelScore,
  });

  WellnessDataModel copyWith({
    int? wellnessScore,
    int? scoreDiff,
    WellnessMode? activeMode,
    List<DayChartPoint>? dayChartPoints,
    int? currentHeartRate,
    List<double>? weeklyHeartRate,
    double? sleepHours,
    int? readinessScore,
    String? readinessTag,
    String? sleepDetail,
    int? hrvMs,
    int? restHr,
    int? stressScore,
    int? hydrationCurrent,
    int? hydrationGoal,
    List<double>? weeklyHydration,
    int? energyBurned,
    int? steps,
    int? activeMins,
    int? goalMins,
    List<double>? weeklyEnergy,
    int? moveScore,
    int? recoverScore,
    int? mindScore,
    int? fuelScore,
  }) {
    return WellnessDataModel(
      wellnessScore: wellnessScore ?? this.wellnessScore,
      scoreDiff: scoreDiff ?? this.scoreDiff,
      activeMode: activeMode ?? this.activeMode,
      dayChartPoints: dayChartPoints ?? this.dayChartPoints,
      currentHeartRate: currentHeartRate ?? this.currentHeartRate,
      weeklyHeartRate: weeklyHeartRate ?? this.weeklyHeartRate,
      sleepHours: sleepHours ?? this.sleepHours,
      readinessScore: readinessScore ?? this.readinessScore,
      readinessTag: readinessTag ?? this.readinessTag,
      sleepDetail: sleepDetail ?? this.sleepDetail,
      hrvMs: hrvMs ?? this.hrvMs,
      restHr: restHr ?? this.restHr,
      stressScore: stressScore ?? this.stressScore,
      hydrationCurrent: hydrationCurrent ?? this.hydrationCurrent,
      hydrationGoal: hydrationGoal ?? this.hydrationGoal,
      weeklyHydration: weeklyHydration ?? this.weeklyHydration,
      energyBurned: energyBurned ?? this.energyBurned,
      steps: steps ?? this.steps,
      activeMins: activeMins ?? this.activeMins,
      goalMins: goalMins ?? this.goalMins,
      weeklyEnergy: weeklyEnergy ?? this.weeklyEnergy,
      moveScore: moveScore ?? this.moveScore,
      recoverScore: recoverScore ?? this.recoverScore,
      mindScore: mindScore ?? this.mindScore,
      fuelScore: fuelScore ?? this.fuelScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'wellnessScore': wellnessScore,
    'scoreDiff': scoreDiff,
    'activeMode': activeMode.name,
    'dayChartPoints': dayChartPoints.map((p) => p.toJson()).toList(),
    'currentHeartRate': currentHeartRate,
    'weeklyHeartRate': weeklyHeartRate,
    'sleepHours': sleepHours,
    'readinessScore': readinessScore,
    'readinessTag': readinessTag,
    'sleepDetail': sleepDetail,
    'hrvMs': hrvMs,
    'restHr': restHr,
    'stressScore': stressScore,
    'hydrationCurrent': hydrationCurrent,
    'hydrationGoal': hydrationGoal,
    'weeklyHydration': weeklyHydration,
    'energyBurned': energyBurned,
    'steps': steps,
    'activeMins': activeMins,
    'goalMins': goalMins,
    'weeklyEnergy': weeklyEnergy,
    'moveScore': moveScore,
    'recoverScore': recoverScore,
    'mindScore': mindScore,
    'fuelScore': fuelScore,
  };

  factory WellnessDataModel.fromJson(Map<String, dynamic> json) => WellnessDataModel(
    wellnessScore: (json['wellnessScore'] as num?)?.toInt() ?? 0,
    scoreDiff: (json['scoreDiff'] as num?)?.toInt() ?? 0,
    activeMode: WellnessMode.values.firstWhere(
      (m) => m.name == json['activeMode'],
      orElse: () => WellnessMode.steady,
    ),
    dayChartPoints: (json['dayChartPoints'] as List<dynamic>?)
            ?.map((p) => DayChartPoint.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const [],
    currentHeartRate: (json['currentHeartRate'] as num?)?.toInt() ?? 0,
    weeklyHeartRate: (json['weeklyHeartRate'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0.0,
    readinessScore: (json['readinessScore'] as num?)?.toInt() ?? 0,
    readinessTag: json['readinessTag'] as String? ?? 'Steady day',
    sleepDetail: json['sleepDetail'] as String? ?? '--',
    hrvMs: (json['hrvMs'] as num?)?.toInt() ?? 0,
    restHr: (json['restHr'] as num?)?.toInt() ?? 0,
    stressScore: (json['stressScore'] as num?)?.toInt() ?? 0,
    hydrationCurrent: (json['hydrationCurrent'] as num?)?.toInt() ?? 0,
    hydrationGoal: (json['hydrationGoal'] as num?)?.toInt() ?? 2000,
    weeklyHydration: (json['weeklyHydration'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    energyBurned: (json['energyBurned'] as num?)?.toInt() ?? 0,
    steps: (json['steps'] as num?)?.toInt() ?? 0,
    activeMins: (json['activeMins'] as num?)?.toInt() ?? 0,
    goalMins: (json['goalMins'] as num?)?.toInt() ?? 600,
    weeklyEnergy: (json['weeklyEnergy'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    moveScore: (json['moveScore'] as num?)?.toInt() ?? 0,
    recoverScore: (json['recoverScore'] as num?)?.toInt() ?? 0,
    mindScore: (json['mindScore'] as num?)?.toInt() ?? 0,
    fuelScore: (json['fuelScore'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [
    wellnessScore,
    scoreDiff,
    activeMode,
    dayChartPoints,
    currentHeartRate,
    weeklyHeartRate,
    sleepHours,
    readinessScore,
    readinessTag,
    sleepDetail,
    hrvMs,
    restHr,
    stressScore,
    hydrationCurrent,
    hydrationGoal,
    weeklyHydration,
    energyBurned,
    steps,
    activeMins,
    goalMins,
    weeklyEnergy,
    moveScore,
    recoverScore,
    mindScore,
    fuelScore,
  ];
}
