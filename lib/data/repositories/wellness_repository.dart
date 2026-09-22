import 'package:shared_preferences/shared_preferences.dart';

import '../models/band_device_model.dart';
import '../models/user_profile_model.dart';
import '../models/vitals_model.dart';
import '../models/wellness_data_model.dart';
import '../models/workout_model.dart';

class WellnessRepository {
  static const String _prefUserName = 'ehg_user_name';
  static const String _prefUserAge = 'ehg_user_age';
  static const String _prefUserWeight = 'ehg_user_weight';
  static const String _prefUserEmail = 'ehg_user_email';

  WellnessDataModel _wellnessData = const WellnessDataModel(
    wellnessScore: 0,
    scoreDiff: 0,
    activeMode: WellnessMode.steady,
    dayChartPoints: [],
    currentHeartRate: 0,
    weeklyHeartRate: [],
    sleepHours: 0.0,
    readinessScore: 0,
    readinessTag: 'No data',
    sleepDetail: '--',
    hrvMs: 0,
    restHr: 0,
    stressScore: 0,
    hydrationCurrent: 0,
    hydrationGoal: 2000,
    weeklyHydration: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    energyBurned: 0,
    activeMins: 0,
    goalMins: 600,
    weeklyEnergy: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    moveScore: 0,
    recoverScore: 0,
    mindScore: 0,
    fuelScore: 0,
  );

  VitalsModel _vitalsData = const VitalsModel(
    totalSleep: '--',
    sleepWindow: 'No sleep recorded',
    sleepIntervals: [],
    currentHeartRate: 0,
    weeklyHeartRate: [],
    stressScore: 0,
    stressStatus: '--',
    stressTimeline: [],
    hrvMs: 0,
    weeklyHrv: [],
    restingHr: 0,
    weeklyRestingHr: [],
    bloodOxygen: 0,
    weeklyOxygen: [],
    breathingRate: 0.0,
    weeklyBreathing: [],
    bloodPressure: '--/--',
    isBloodPressureUp: false,
    skinTempDiff: 0.0,
    isSkinTempDown: false,
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
    recentSessionDuration: '00hr 00min 00sec',
    recentPeakHr: 0,
    recentAvgHr: 0,
  );

  UserProfileModel _userProfile = const UserProfileModel(
    email: 'You@lorem.com',
    username: 'John',
    age: 32,
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

  Future<void> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefUserName);
      final age = prefs.getInt(_prefUserAge);
      final weight = prefs.getInt(_prefUserWeight);
      final email = prefs.getString(_prefUserEmail);

      _userProfile = _userProfile.copyWith(
        username: (name != null && name.trim().isNotEmpty) ? name.trim() : _userProfile.username,
        age: (age != null && age > 0) ? age : _userProfile.age,
        weight: (weight != null && weight > 0) ? weight : _userProfile.weight,
        email: (email != null && email.trim().isNotEmpty) ? email.trim() : _userProfile.email,
      );
    } catch (_) {}
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    _userProfile = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (profile.username.trim().isNotEmpty) {
        await prefs.setString(_prefUserName, profile.username.trim());
      }
      if (profile.age > 0) {
        await prefs.setInt(_prefUserAge, profile.age);
      }
      if (profile.weight > 0) {
        await prefs.setInt(_prefUserWeight, profile.weight);
      }
      if (profile.email.trim().isNotEmpty) {
        await prefs.setString(_prefUserEmail, profile.email.trim());
      }
    } catch (_) {}
  }

  void updateFromBandVitals(BandSyncedVitals vitals, {int? heartRate}) {
    final double hours = vitals.sleepMinutes > 0
        ? (vitals.sleepMinutes / 60.0)
        : _wellnessData.sleepHours;
    final int energy = vitals.calories > 0
        ? vitals.calories
        : _wellnessData.energyBurned;

    // 1. Dynamic Sleep Intervals Calculation from SDK Sleep Phases
    List<SleepInterval> dynamicIntervals = _vitalsData.sleepIntervals;
    if (vitals.sleepPhases.isNotEmpty) {
      final totalPhaseMins = vitals.sleepPhases.fold<int>(
        0,
        (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1),
      );
      if (totalPhaseMins > 0) {
        int elapsed = 0;
        final List<SleepInterval> generated = [];
        for (final phase in vitals.sleepPhases) {
          final dur = phase.durationMinutes > 0 ? phase.durationMinutes : 1;
          final offset = elapsed / totalPhaseMins;
          final width = dur / totalPhaseMins;
          SleepPhase sp;
          switch (phase.type) {
            case 3:
              sp = SleepPhase.deep;
              break;
            case 4:
              sp = SleepPhase.rem;
              break;
            case 1:
              sp = SleepPhase.awake;
              break;
            case 2:
            default:
              sp = SleepPhase.light;
              break;
          }
          generated.add(SleepInterval(
            startOffset: offset.clamp(0.0, 1.0),
            widthFraction: width.clamp(0.01, 1.0),
            phase: sp,
          ));
          elapsed += dur;
        }
        dynamicIntervals = generated;
      }
    }

    // 2. Build sleep window and total sleep string
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

    // 3. Dynamic Pillar & Wellness Scores Calculation
    final bool hasData = vitals.sleepMinutes > 0 ||
        energy > 0 ||
        (heartRate != null && heartRate > 0) ||
        vitals.stressLevel > 0 ||
        vitals.bloodOxygen > 0;

    final int moveScore = hasData ? (energy / 600 * 100).clamp(15, 98).round() : 0;
    final int recoverScore = (vitals.sleepMinutes > 0 ? (vitals.sleepMinutes / 480 * 100).clamp(15, 98).round() : 0);
    final int mindScore = vitals.stressLevel > 0 ? (100 - vitals.stressLevel).clamp(15, 95) : (hasData ? _wellnessData.mindScore : 0);
    final int fuelScore = hasData ? (_wellnessData.hydrationCurrent / _wellnessData.hydrationGoal * 100).clamp(15, 95).round() : 0;
    final int newWellnessScore = hasData ? ((moveScore + recoverScore + mindScore + fuelScore) / 4).round() : 0;
    final int scoreDiff = hasData ? (newWellnessScore - _wellnessData.wellnessScore) : 0;

    // 4. Dynamic Readiness Score & Mode
    final int hrvScore = vitals.hrvMs > 0 ? (vitals.hrvMs * 1.5).clamp(20, 100).round() : 0;
    final int restHrScore = vitals.restingHeartRate > 0
        ? (120 - vitals.restingHeartRate).clamp(20, 100).round()
        : 0;
    final int readinessScore = hasData
        ? (0.4 * (recoverScore > 0 ? recoverScore : 50) + 0.3 * (hrvScore > 0 ? hrvScore : 50) + 0.3 * (restHrScore > 0 ? restHrScore : 50)).clamp(20, 99).round()
        : 0;

    final WellnessMode activeMode;
    final String readinessTag;
    if (!hasData || readinessScore == 0) {
      activeMode = WellnessMode.steady;
      readinessTag = 'No data';
    } else if (readinessScore >= 75) {
      activeMode = WellnessMode.push;
      readinessTag = 'Push day';
    } else if (readinessScore >= 55) {
      activeMode = WellnessMode.steady;
      readinessTag = 'Steady day';
    } else {
      activeMode = WellnessMode.recover;
      readinessTag = 'Recover day';
    }

    // 5. Dynamic 24h day chart points
    final baseScore = newWellnessScore.toDouble();
    final List<DayChartPoint> dayPoints = hasData
        ? [
            DayChartPoint(timeLabel: '8 AM', score: (baseScore - 12).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '9 AM', score: (baseScore - 8).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '10 AM', score: (baseScore - 4).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '11 AM', score: (baseScore + 2).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '12 PM', score: (baseScore - 10).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '1 PM', score: (baseScore - 6).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '2 PM', score: (baseScore - 2).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '3 PM', score: (baseScore - 5).clamp(30.0, 95.0)),
            DayChartPoint(timeLabel: '4 PM', score: baseScore, hasPin: true),
            DayChartPoint(timeLabel: '5 PM', score: baseScore, isProjected: true),
            DayChartPoint(timeLabel: '6 PM', score: baseScore, isProjected: true),
          ]
        : const [];

    _wellnessData = _wellnessData.copyWith(
      wellnessScore: newWellnessScore,
      scoreDiff: scoreDiff != 0 ? scoreDiff : _wellnessData.scoreDiff,
      activeMode: activeMode,
      dayChartPoints: dayPoints,
      currentHeartRate: heartRate ?? _wellnessData.currentHeartRate,
      weeklyHeartRate: vitals.weeklyHeartRate.isNotEmpty ? vitals.weeklyHeartRate : _wellnessData.weeklyHeartRate,
      sleepHours: double.parse(hours.toStringAsFixed(1)),
      readinessScore: readinessScore,
      readinessTag: readinessTag,
      sleepDetail: vitals.sleepMinutes > 0 ? '${vitals.sleepMinutes ~/ 60}hr ${vitals.sleepMinutes % 60} min' : '--',
      hrvMs: vitals.hrvMs > 0 ? vitals.hrvMs : _wellnessData.hrvMs,
      restHr: vitals.restingHeartRate > 0
          ? vitals.restingHeartRate
          : _wellnessData.restHr,
      stressScore: vitals.stressLevel > 0
          ? vitals.stressLevel
          : _wellnessData.stressScore,
      energyBurned: energy,
      moveScore: moveScore,
      recoverScore: recoverScore,
      mindScore: mindScore,
      fuelScore: fuelScore,
    );

    _vitalsData = _vitalsData.copyWith(
      totalSleep: totalSleep,
      sleepWindow: sleepWindow,
      sleepIntervals: dynamicIntervals,
      currentHeartRate: heartRate ?? _vitalsData.currentHeartRate,
      weeklyHeartRate: vitals.weeklyHeartRate.isNotEmpty ? vitals.weeklyHeartRate : _vitalsData.weeklyHeartRate,
      stressScore: vitals.stressLevel > 0
          ? vitals.stressLevel
          : _vitalsData.stressScore,
      stressStatus: vitals.stressLevel > 0
          ? _stressStatusLabel(vitals.stressLevel)
          : _vitalsData.stressStatus,
      stressTimeline: vitals.weeklyStress.isNotEmpty ? vitals.weeklyStress : _vitalsData.stressTimeline,
      hrvMs: vitals.hrvMs > 0 ? vitals.hrvMs : _vitalsData.hrvMs,
      weeklyHrv: vitals.weeklyHrv.isNotEmpty ? vitals.weeklyHrv : _vitalsData.weeklyHrv,
      restingHr: vitals.restingHeartRate > 0
          ? vitals.restingHeartRate
          : _vitalsData.restingHr,
      weeklyRestingHr: vitals.weeklyRestingHr.isNotEmpty ? vitals.weeklyRestingHr : _vitalsData.weeklyRestingHr,
      bloodOxygen: vitals.bloodOxygen > 0
          ? vitals.bloodOxygen.round()
          : _vitalsData.bloodOxygen,
      weeklyOxygen: vitals.weeklyOxygen.isNotEmpty ? vitals.weeklyOxygen : _vitalsData.weeklyOxygen,
      breathingRate: vitals.breathingRate > 0 ? vitals.breathingRate : _vitalsData.breathingRate,
      weeklyBreathing: vitals.weeklyBreathing.isNotEmpty ? vitals.weeklyBreathing : _vitalsData.weeklyBreathing,
      bloodPressure: vitals.bloodPressureFormatted.isNotEmpty
          ? vitals.bloodPressureFormatted
          : _vitalsData.bloodPressure,
      isBloodPressureUp: vitals.systolicBP > 120,
      skinTempDiff: vitals.skinTemperature > 0
          ? double.parse((vitals.skinTemperature - 36.5).toStringAsFixed(1))
          : _vitalsData.skinTempDiff,
      isSkinTempDown: vitals.skinTemperature > 0
          ? vitals.skinTemperature < 36.5
          : _vitalsData.isSkinTempDown,
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
