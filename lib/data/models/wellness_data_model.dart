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
  final int activeMins;
  final int goalMins;
  final List<double> weeklyEnergy;

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
    required this.activeMins,
    required this.goalMins,
    required this.weeklyEnergy,
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
    int? activeMins,
    int? goalMins,
    List<double>? weeklyEnergy,
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
      activeMins: activeMins ?? this.activeMins,
      goalMins: goalMins ?? this.goalMins,
      weeklyEnergy: weeklyEnergy ?? this.weeklyEnergy,
    );
  }

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
    activeMins,
    goalMins,
    weeklyEnergy,
  ];
}
