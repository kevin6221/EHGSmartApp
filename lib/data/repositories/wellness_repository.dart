import '../models/wellness_data_model.dart';
import '../models/vitals_model.dart';
import '../models/workout_model.dart';
import '../models/user_profile_model.dart';

class WellnessRepository {
  WellnessDataModel getWellnessData() {
    return const WellnessDataModel(
      wellnessScore: 84,
      scoreDiff: -3,
      activeMode: WellnessMode.recover,
      dayChartPoints: [
        DayChartPoint(timeLabel: '8 AM', score: 62),
        DayChartPoint(timeLabel: '9 AM', score: 68),
        DayChartPoint(timeLabel: '10 AM', score: 71),
        DayChartPoint(timeLabel: '11 AM', score: 76),
        DayChartPoint(timeLabel: '12 PM', score: 58),
        DayChartPoint(timeLabel: '1 PM', score: 60),
        DayChartPoint(timeLabel: '2 PM', score: 64),
        DayChartPoint(timeLabel: '3 PM', score: 61),
        DayChartPoint(timeLabel: '4 PM', score: 65, hasPin: true),
        DayChartPoint(timeLabel: '5 PM', score: 65, isProjected: true),
        DayChartPoint(timeLabel: '6 PM', score: 65, isProjected: true),
      ],
      currentHeartRate: 72,
      weeklyHeartRate: [74, 71, 75, 72, 73, 70, 72],
      sleepHours: 8.2,
      readinessScore: 62,
      readinessTag: 'Recover day',
      sleepDetail: '6hr 30 min',
      hrvMs: 44,
      restHr: 61,
      stressScore: 46,
      hydrationCurrent: 1650,
      hydrationGoal: 2400,
      weeklyHydration: [0.8, 0.6, 0.45, 0.7, 0.85, 0.95, 0.68],
      energyBurned: 1750,
      activeMins: 210,
      goalMins: 600,
      weeklyEnergy: [0.75, 0.55, 0.4, 0.65, 0.8, 0.9, 0.6],
    );
  }

  VitalsModel getVitalsData() {
    return const VitalsModel(
      totalSleep: '6 hrs. 12 mins.',
      sleepWindow: '9:30 PM - 6:40 AM',
      sleepIntervals: [
        SleepInterval(
          startOffset: 0.05,
          widthFraction: 0.12,
          phase: SleepPhase.deep,
        ),
        SleepInterval(
          startOffset: 0.17,
          widthFraction: 0.15,
          phase: SleepPhase.light,
        ),
        SleepInterval(
          startOffset: 0.32,
          widthFraction: 0.04,
          phase: SleepPhase.awake,
        ),
        SleepInterval(
          startOffset: 0.36,
          widthFraction: 0.22,
          phase: SleepPhase.deep,
        ),
        SleepInterval(
          startOffset: 0.58,
          widthFraction: 0.08,
          phase: SleepPhase.awake,
        ),
        SleepInterval(
          startOffset: 0.66,
          widthFraction: 0.14,
          phase: SleepPhase.deep,
        ),
        SleepInterval(
          startOffset: 0.80,
          widthFraction: 0.10,
          phase: SleepPhase.rem,
        ),
        SleepInterval(
          startOffset: 0.90,
          widthFraction: 0.06,
          phase: SleepPhase.light,
        ),
      ],
      currentHeartRate: 72,
      weeklyHeartRate: [72, 68, 76, 70, 74, 72, 67, 65, 69, 64, 60],
      stressScore: 46,
      stressStatus: 'ELEVATED',
      stressTimeline: [30, 32, 48, 35, 38, 37, 58, 54, 46],
      hrvMs: 44,
      weeklyHrv: [52, 46, 50, 48, 54, 49, 44, 42, 38],
      restingHr: 61,
      weeklyRestingHr: [58, 62, 59, 61, 60, 58, 57, 61],
      bloodOxygen: 96,
      weeklyOxygen: [0.96, 0.94, 0.93, 0.97, 0.98, 0.99, 0.95],
      breathingRate: 15.8,
      weeklyBreathing: [15.2, 14.8, 15.6, 15.0, 15.4, 15.8, 14.9],
      bloodPressure: '121/79',
      isBloodPressureUp: true,
      skinTempDiff: -0.3,
      isSkinTempDown: true,
    );
  }

  WorkoutModel getWorkoutData() {
    return const WorkoutModel(
      selectedCategory: WorkoutType.run,
      title: 'Outdoor run',
      zoneInfo: 'Zone 2–4 · 130–165 bpm',
      metricsSummary: 'Pace, cadence, HR zones, route, recovery HR',
      outfitRecommendation:
          'Cotton Earth Tone T-Shirt · High Rise Flared Yoga Pants',
      selectedWeightKg: 60,
      estimatedKcalPerMin: 15,
      recentSessionTitle: 'Outdoor run',
      recentSessionDuration: '02hr 08min 56sec',
      recentPeakHr: 23,
      recentAvgHr: 120,
    );
  }

  UserProfileModel getUserProfile() {
    return const UserProfileModel(
      email: 'You@lorem.com',
      username: 'John',
      age: 34,
      weight: 60,
      appearance: AppearanceTheme.midnight,
      unitSystem: UnitSystem.metric,
      dailyPlanReminder: true,
      hydrationNudges: false,
      journeyDays: false,
      sleepWindDown: false,
      bandModel: 'EHG Smart Band',
      bandId: 'EH-9F2C',
      bandBatteryDays: '4 days',
    );
  }
}
