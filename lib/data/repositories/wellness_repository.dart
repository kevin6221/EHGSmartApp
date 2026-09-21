import '../models/band_device_model.dart';
import '../models/user_profile_model.dart';
import '../models/vitals_model.dart';
import '../models/wellness_data_model.dart';
import '../models/workout_model.dart';

class WellnessRepository {
  WellnessDataModel _wellnessData = const WellnessDataModel(
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
    moveScore: 36,
    recoverScore: 73,
    mindScore: 30,
    fuelScore: 31,
  );

  VitalsModel _vitalsData = const VitalsModel(
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

  final WorkoutModel _workoutData = const WorkoutModel(
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

  final UserProfileModel _userProfile = const UserProfileModel(
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

  WellnessDataModel getWellnessData() => _wellnessData;
  VitalsModel getVitalsData() => _vitalsData;
  WorkoutModel getWorkoutData() => _workoutData;
  UserProfileModel getUserProfile() => _userProfile;

  void updateFromBandVitals(BandSyncedVitals vitals, {int? heartRate}) {
    final double hours = vitals.sleepMinutes > 0
        ? (vitals.sleepMinutes / 60.0)
        : _wellnessData.sleepHours;
    final int energy = vitals.calories > 0
        ? vitals.calories
        : _wellnessData.energyBurned;

    _wellnessData = _wellnessData.copyWith(
      currentHeartRate: heartRate ?? _wellnessData.currentHeartRate,
      sleepHours: double.parse(hours.toStringAsFixed(1)),
      energyBurned: energy,
      hrvMs: vitals.hrvMs > 0 ? vitals.hrvMs : _wellnessData.hrvMs,
      restHr: vitals.restingHeartRate > 0
          ? vitals.restingHeartRate
          : _wellnessData.restHr,
      stressScore: vitals.stressLevel > 0
          ? vitals.stressLevel
          : _wellnessData.stressScore,
    );

    // Build sleep window and total sleep string from phases
    String totalSleep = _vitalsData.totalSleep;
    String sleepWindow = _vitalsData.sleepWindow;
    if (vitals.sleepMinutes > 0) {
      final h = vitals.sleepMinutes ~/ 60;
      final m = vitals.sleepMinutes % 60;
      totalSleep = '$h hrs. $m mins.';
    }
    if (vitals.sleepPhases.isNotEmpty) {
      final first = vitals.sleepPhases.first.startTime;
      final last = vitals.sleepPhases.last.endTime;
      if (first.isNotEmpty && last.isNotEmpty) {
        sleepWindow = '$first - $last';
      }
    }

    _vitalsData = _vitalsData.copyWith(
      currentHeartRate: heartRate ?? _vitalsData.currentHeartRate,
      bloodOxygen: vitals.bloodOxygen > 0
          ? vitals.bloodOxygen.round()
          : _vitalsData.bloodOxygen,
      bloodPressure: vitals.bloodPressureFormatted.isNotEmpty
          ? vitals.bloodPressureFormatted
          : _vitalsData.bloodPressure,
      isBloodPressureUp: vitals.systolicBP > 120,
      skinTempDiff: vitals.skinTemperature > 0
          ? vitals.skinTemperature - 36.5
          : _vitalsData.skinTempDiff,
      isSkinTempDown: vitals.skinTemperature > 0
          ? vitals.skinTemperature < 36.5
          : _vitalsData.isSkinTempDown,
      stressScore: vitals.stressLevel > 0
          ? vitals.stressLevel
          : _vitalsData.stressScore,
      stressStatus: vitals.stressLevel > 0
          ? _stressStatusLabel(vitals.stressLevel)
          : _vitalsData.stressStatus,
      hrvMs: vitals.hrvMs > 0 ? vitals.hrvMs : _vitalsData.hrvMs,
      restingHr: vitals.restingHeartRate > 0
          ? vitals.restingHeartRate
          : _vitalsData.restingHr,
      totalSleep: totalSleep,
      sleepWindow: sleepWindow,
    );
  }

  String _stressStatusLabel(int score) {
    if (score <= 25) return 'RELAXED';
    if (score <= 50) return 'NORMAL';
    if (score <= 75) return 'ELEVATED';
    return 'HIGH';
  }

  void updateHeartRate(int bpm) {
    if (bpm > 0) {
      _wellnessData = _wellnessData.copyWith(currentHeartRate: bpm);
      _vitalsData = _vitalsData.copyWith(currentHeartRate: bpm);
    }
  }

  void resetData() {
    // Reset back to baseline values
    _wellnessData = _wellnessData.copyWith(
      currentHeartRate: 72,
      sleepHours: 7.5,
      energyBurned: 1500,
    );
  }
}
