import 'package:equatable/equatable.dart';

enum WorkoutType { run, walk, cycling, strength, hit }

class WorkoutModel extends Equatable {
  final WorkoutType selectedCategory;
  final String title;
  final String zoneInfo;
  final String metricsSummary;
  final String outfitRecommendation;
  final int selectedWeightKg;
  final int estimatedKcalPerMin;
  final String recentSessionTitle;
  final String recentSessionDuration;
  final int recentPeakHr;
  final int recentAvgHr;

  const WorkoutModel({
    required this.selectedCategory,
    required this.title,
    required this.zoneInfo,
    required this.metricsSummary,
    required this.outfitRecommendation,
    required this.selectedWeightKg,
    required this.estimatedKcalPerMin,
    required this.recentSessionTitle,
    required this.recentSessionDuration,
    required this.recentPeakHr,
    required this.recentAvgHr,
  });

  WorkoutModel copyWith({
    WorkoutType? selectedCategory,
    String? title,
    String? zoneInfo,
    String? metricsSummary,
    String? outfitRecommendation,
    int? selectedWeightKg,
    int? estimatedKcalPerMin,
    String? recentSessionTitle,
    String? recentSessionDuration,
    int? recentPeakHr,
    int? recentAvgHr,
  }) {
    return WorkoutModel(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      title: title ?? this.title,
      zoneInfo: zoneInfo ?? this.zoneInfo,
      metricsSummary: metricsSummary ?? this.metricsSummary,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      selectedWeightKg: selectedWeightKg ?? this.selectedWeightKg,
      estimatedKcalPerMin: estimatedKcalPerMin ?? this.estimatedKcalPerMin,
      recentSessionTitle: recentSessionTitle ?? this.recentSessionTitle,
      recentSessionDuration:
          recentSessionDuration ?? this.recentSessionDuration,
      recentPeakHr: recentPeakHr ?? this.recentPeakHr,
      recentAvgHr: recentAvgHr ?? this.recentAvgHr,
    );
  }

  @override
  List<Object?> get props => [
    selectedCategory,
    title,
    zoneInfo,
    metricsSummary,
    outfitRecommendation,
    selectedWeightKg,
    estimatedKcalPerMin,
    recentSessionTitle,
    recentSessionDuration,
    recentPeakHr,
    recentAvgHr,
  ];
}
