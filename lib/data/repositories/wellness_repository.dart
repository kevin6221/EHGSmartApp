import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart' hide SleepPhase;
import '../../core/security/secure_storage_service.dart';
import '../models/band_device_model.dart';
import '../models/user_profile_model.dart';
import '../models/vitals_model.dart';
import '../models/wellness_data_model.dart';
import '../models/workout_model.dart';

class WellnessRepository {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final Completer<void> _initCompleter = Completer<void>();
  int _yesterdayWellnessScore = 0;

  WellnessRepository({
    AppDatabase? database,
    SecureStorageService? secureStorage,
  })  : _db = database ?? AppDatabase(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _initData();
  }

  /// Awaiting this ensures SQLite cached health records and user profile are loaded.
  Future<void> ensureInitialized() => _initCompleter.future;

  /// Reloads cached health records from Drift SQLite and SecureStorage without triggering BLE communication.
  Future<void> refreshFromDatabase() async {
    await _loadCachedVitals();
  }

  int get _todayIndex => (DateTime.now().weekday - 1).clamp(0, 6);

  Future<void> _initData() async {
    try {
      await Future.wait([
        _loadCachedVitals(),
        loadUserProfile(),
      ]);
    } catch (e) {
      debugPrint('⚠️ [WELLNESS REPO] _initData error: $e');
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<void> _loadCachedVitals() async {
    try {
      // 0. Instant hydration from secure storage snapshot
      final cachedWellnessJson = await _secureStorage.read('cached_wellness_data_v1');
      if (cachedWellnessJson != null && cachedWellnessJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedWellnessJson) as Map<String, dynamic>;
          _wellnessData = WellnessDataModel.fromJson(decoded);
        } catch (_) {}
      }

      final cachedVitalsJson = await _secureStorage.read('cached_vitals_data_v1');
      if (cachedVitalsJson != null && cachedVitalsJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedVitalsJson) as Map<String, dynamic>;
          _vitalsData = VitalsModel.fromJson(decoded);
        } catch (_) {}
      }

      final today = DateTime.now().toIso8601String().substring(0, 10);
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

      final yesterdaySummary = await _db.healthDataDao.getDailySummary('default_user', yesterday);
      if (yesterdaySummary?.wellnessScore != null && yesterdaySummary!.wellnessScore! > 0) {
        _yesterdayWellnessScore = yesterdaySummary.wellnessScore!;
      }

      final summary = await _db.healthDataDao.getDailySummary('default_user', today);
      const devId = 'default_band';
      final latestStress = await _db.healthDataDao.getLatestVital(devId, 'stress');
      final latestHrv = await _db.healthDataDao.getLatestVital(devId, 'hrv');
      final latestBp = await _db.healthDataDao.getLatestVital(devId, 'blood_pressure');
      final latestTemp = await _db.healthDataDao.getLatestVital(devId, 'temperature');

      if (summary != null || latestStress != null || latestHrv != null) {
        final vitals = BandSyncedVitals(
          steps: summary?.steps ?? 0,
          calories: summary?.caloriesBurned.round() ?? 0,
          distance: summary?.distanceMeters.round() ?? 0,
          sleepMinutes: summary?.sleepDurationMinutes ?? 0,
          deepSleepMinutes: summary?.deepSleepMinutes ?? 0,
          bloodOxygen: summary?.avgSpo2 ?? 0.0,
          restingHeartRate: summary?.restingHeartRate ?? 0,
          stressLevel: latestStress?.valueNumeric?.round() ?? 0,
          hrvMs: latestHrv?.valueNumeric?.round() ?? 0,
          systolicBP: latestBp?.valueNumeric?.round() ?? 0,
          diastolicBP: latestBp?.secondaryNumeric?.round() ?? 0,
          skinTemperature: latestTemp?.valueNumeric ?? 0.0,
        );
        updateFromBandVitals(
          vitals,
          savedWellnessScore: summary?.wellnessScore,
          savedReadinessScore: summary?.readinessScore,
          savedMoveScore: summary?.moveScore,
          savedRecoverScore: summary?.recoverScore,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [WELLNESS REPO] _loadCachedVitals error: $e');
    }
  }

  WellnessDataModel _wellnessData = const WellnessDataModel(
    wellnessScore: 0,
    scoreDiff: 0,
    activeMode: WellnessMode.steady,
    dayChartPoints: [],
    currentHeartRate: 0,
    weeklyHeartRate: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
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
    weeklyHeartRate: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    stressScore: 0,
    stressStatus: '--',
    stressTimeline: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    hrvMs: 0,
    weeklyHrv: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    restingHr: 0,
    weeklyRestingHr: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    bloodOxygen: 0,
    weeklyOxygen: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    breathingRate: 0.0,
    weeklyBreathing: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    bloodPressure: '--',
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
    username: '',
    age: 32,
    weight: 60,
    appearance: AppearanceTheme.system,
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
      final name = await _secureStorage.getUserName();
      final age = await _secureStorage.getUserAge();
      final weight = await _secureStorage.getUserWeight();
      final email = await _secureStorage.getUserEmail();
      final appearanceStr = await _secureStorage.getAppearance();
      final unitStr = await _secureStorage.getUnitSystem();

      AppearanceTheme? appTheme;
      if (appearanceStr != null) {
        for (final t in AppearanceTheme.values) {
          if (t.name == appearanceStr) {
            appTheme = t;
            break;
          }
        }
      }

      UnitSystem? unitSys;
      if (unitStr != null) {
        for (final u in UnitSystem.values) {
          if (u.name == unitStr) {
            unitSys = u;
            break;
          }
        }
      }

      _userProfile = _userProfile.copyWith(
        username: (name != null && name.trim().isNotEmpty) ? name.trim() : _userProfile.username,
        age: (age != null && age > 0) ? age : _userProfile.age,
        weight: (weight != null && weight > 0) ? weight : _userProfile.weight,
        email: (email != null && email.trim().isNotEmpty) ? email.trim() : _userProfile.email,
        appearance: appTheme ?? _userProfile.appearance,
        unitSystem: unitSys ?? _userProfile.unitSystem,
      );
    } catch (_) {}
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    _userProfile = profile;
    try {
      if (profile.username.trim().isNotEmpty) {
        await _secureStorage.saveUserName(profile.username.trim());
      }
      if (profile.age > 0) {
        await _secureStorage.saveUserAge(profile.age);
      }
      if (profile.weight > 0) {
        await _secureStorage.saveUserWeight(profile.weight);
      }
      if (profile.email.trim().isNotEmpty) {
        await _secureStorage.saveUserEmail(profile.email.trim());
      }
      await _secureStorage.saveAppearance(profile.appearance.name);
      await _secureStorage.saveUnitSystem(profile.unitSystem.name);
    } catch (_) {}
  }

  void updateStepsAndCalories({required int steps, required int calories}) {
    List<double> updatedWeeklyEnergy = List<double>.from(
      _wellnessData.weeklyEnergy.length == 7
          ? _wellnessData.weeklyEnergy
          : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    );
    if (calories > 0 && updatedWeeklyEnergy.length == 7) {
      updatedWeeklyEnergy[_todayIndex] = (calories / 600.0).clamp(0.05, 1.0);
    }
    _wellnessData = _wellnessData.copyWith(
      steps: steps > 0 ? steps : _wellnessData.steps,
      energyBurned: calories > 0 ? calories : _wellnessData.energyBurned,
      weeklyEnergy: updatedWeeklyEnergy,
    );
    _secureStorage.write('cached_wellness_data_v1', jsonEncode(_wellnessData.toJson())).catchError((_) {});
  }

  void updateFromBandVitals(
    BandSyncedVitals vitals, {
    int? heartRate,
    int? savedWellnessScore,
    int? savedReadinessScore,
    int? savedMoveScore,
    int? savedRecoverScore,
  }) {
    final double hours = vitals.sleepMinutes > 0
        ? (vitals.sleepMinutes / 60.0)
        : _wellnessData.sleepHours;
    final int steps = vitals.steps > 0 ? vitals.steps : _wellnessData.steps;
    final int energy = vitals.calories > 0
        ? vitals.calories
        : _wellnessData.energyBurned;

    List<double> updatedWeeklyEnergy = List<double>.from(
      _wellnessData.weeklyEnergy.length == 7
          ? _wellnessData.weeklyEnergy
          : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    );
    if (energy > 0 && updatedWeeklyEnergy.length == 7) {
      updatedWeeklyEnergy[_todayIndex] = (energy / 600.0).clamp(0.05, 1.0);
    }

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
        final DateTime sleepStart = DateTime(2026, 1, 1, 23, 0); // 11:00 PM sleep start
        for (final phase in vitals.sleepPhases) {
          final dur = phase.durationMinutes > 0 ? phase.durationMinutes : 1;
          final offset = elapsed / totalPhaseMins;
          final width = dur / totalPhaseMins;
          final startT = sleepStart.add(Duration(minutes: elapsed));
          final endT = sleepStart.add(Duration(minutes: elapsed + dur));

          final startFormatted = '${(startT.hour % 12 == 0 ? 12 : startT.hour % 12).toString().padLeft(2, '0')}:${startT.minute.toString().padLeft(2, '0')} ${startT.hour >= 12 ? 'pm' : 'am'}';
          final endFormatted = '${(endT.hour % 12 == 0 ? 12 : endT.hour % 12).toString().padLeft(2, '0')}:${endT.minute.toString().padLeft(2, '0')} ${endT.hour >= 12 ? 'pm' : 'am'}';
          final durFormatted = '${dur ~/ 60}h ${dur % 60}m';
          final rangeText = '$startFormatted → $endFormatted ($durFormatted)';

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
            timeRangeText: rangeText,
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
    final int effectiveRestHr = vitals.restingHeartRate > 0
        ? vitals.restingHeartRate
        : _wellnessData.restHr;
    final int restHrScore = effectiveRestHr > 0
        ? (120 - effectiveRestHr).clamp(20, 100).round()
        : 0;

    final int effectiveHr = (heartRate != null && heartRate > 0)
        ? heartRate
        : (effectiveRestHr > 0
            ? effectiveRestHr
            : (vitals.heartRateHistory.isNotEmpty
                ? vitals.heartRateHistory.last.bpm
                : _wellnessData.currentHeartRate));

    final int effectiveStress = vitals.stressLevel > 0
        ? vitals.stressLevel
        : _wellnessData.stressScore;

    final int effectiveHrv = vitals.hrvMs > 0
        ? vitals.hrvMs
        : _wellnessData.hrvMs;

    final bool hasData = vitals.sleepMinutes > 0 ||
        energy > 0 ||
        steps > 0 ||
        effectiveHr > 0 ||
        effectiveStress > 0 ||
        effectiveHrv > 0 ||
        vitals.bloodOxygen > 0;

    final int computedMoveScore = hasData ? (energy / 600 * 100).clamp(15, 98).round() : 0;
    final int moveScore = (savedMoveScore != null && savedMoveScore > 0)
        ? savedMoveScore
        : computedMoveScore;

    final int computedRecoverScore = (vitals.sleepMinutes > 0
        ? (vitals.sleepMinutes / 480 * 100).clamp(15, 98).round()
        : (restHrScore > 0 ? restHrScore : (hasData ? _wellnessData.recoverScore : 0)));
    final int recoverScore = (savedRecoverScore != null && savedRecoverScore > 0)
        ? savedRecoverScore
        : computedRecoverScore;

    final int mindScore = effectiveStress > 0
        ? (100 - effectiveStress).clamp(15, 95)
        : (_wellnessData.mindScore > 0 ? _wellnessData.mindScore : (hasData ? 50 : 0));

    final int fuelScore = hasData
        ? (_wellnessData.hydrationCurrent / _wellnessData.hydrationGoal * 100).clamp(15, 95).round()
        : 0;

    final int calculatedWellnessScore = hasData
        ? ((moveScore + recoverScore + mindScore + fuelScore) / 4).round()
        : 0;
    final int newWellnessScore = (savedWellnessScore != null && savedWellnessScore > 0)
        ? savedWellnessScore
        : calculatedWellnessScore;

    final int scoreDiff = (newWellnessScore > 0 && _yesterdayWellnessScore > 0)
        ? (newWellnessScore - _yesterdayWellnessScore)
        : (_wellnessData.scoreDiff != 0 ? _wellnessData.scoreDiff : 0);

    // 4. Dynamic Readiness Score & Mode
    final int hrvScore = effectiveHrv > 0
        ? (effectiveHrv * 1.5).clamp(20, 100).round()
        : (_wellnessData.hrvMs > 0 ? (_wellnessData.hrvMs * 1.5).clamp(20, 100).round() : (hasData ? 50 : 0));

    final int calculatedReadinessScore = hasData
        ? (0.4 * (recoverScore > 0 ? recoverScore : 50) +
           0.3 * (hrvScore > 0 ? hrvScore : 50) +
           0.3 * (restHrScore > 0 ? restHrScore : 50))
            .clamp(20, 99)
            .round()
        : 0;
    final int readinessScore = (savedReadinessScore != null && savedReadinessScore > 0)
        ? savedReadinessScore
        : calculatedReadinessScore;

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
    final List<DayChartPoint> dayPoints = (hasData && baseScore > 0)
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
        : (_wellnessData.dayChartPoints.isNotEmpty ? _wellnessData.dayChartPoints : const []);

    // 6. Dynamic Weekly Heart Rate & Stress Timeline from Hardware Readings
    List<double> updatedWeeklyHr = List<double>.from(
      vitals.weeklyHeartRate.length == 7
          ? vitals.weeklyHeartRate
          : (_wellnessData.weeklyHeartRate.length == 7
              ? _wellnessData.weeklyHeartRate
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (effectiveHr > 0 && updatedWeeklyHr.length == 7) {
      updatedWeeklyHr[_todayIndex] = effectiveHr.toDouble();
    }

    List<double> updatedStressTimeline = List<double>.from(
      vitals.weeklyStress.length == 7
          ? vitals.weeklyStress
          : (_vitalsData.stressTimeline.length == 7
              ? _vitalsData.stressTimeline
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (vitals.stressLevel > 0 && updatedStressTimeline.length == 7) {
      updatedStressTimeline[_todayIndex] = vitals.stressLevel.toDouble();
    }

    List<double> updatedWeeklyHrv = List<double>.from(
      vitals.weeklyHrv.length == 7
          ? vitals.weeklyHrv
          : (_vitalsData.weeklyHrv.length == 7
              ? _vitalsData.weeklyHrv
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (vitals.hrvMs > 0 && updatedWeeklyHrv.length == 7) {
      updatedWeeklyHrv[_todayIndex] = vitals.hrvMs.toDouble();
    }

    List<double> updatedWeeklyRestingHr = List<double>.from(
      vitals.weeklyRestingHr.length == 7
          ? vitals.weeklyRestingHr
          : (_vitalsData.weeklyRestingHr.length == 7
              ? _vitalsData.weeklyRestingHr
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (vitals.restingHeartRate > 0 && updatedWeeklyRestingHr.length == 7) {
      updatedWeeklyRestingHr[_todayIndex] = vitals.restingHeartRate.toDouble();
    }

    List<double> updatedWeeklyOxygen = List<double>.from(
      vitals.weeklyOxygen.length == 7
          ? vitals.weeklyOxygen
          : (_vitalsData.weeklyOxygen.length == 7
              ? _vitalsData.weeklyOxygen
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (vitals.bloodOxygen > 0 && updatedWeeklyOxygen.length == 7) {
      updatedWeeklyOxygen[_todayIndex] = vitals.bloodOxygen.toDouble();
    }

    List<double> updatedWeeklyBreathing = List<double>.from(
      vitals.weeklyBreathing.length == 7
          ? vitals.weeklyBreathing
          : (_vitalsData.weeklyBreathing.length == 7
              ? _vitalsData.weeklyBreathing
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (vitals.breathingRate > 0 && updatedWeeklyBreathing.length == 7) {
      updatedWeeklyBreathing[_todayIndex] = vitals.breathingRate;
    }

    _wellnessData = _wellnessData.copyWith(
      wellnessScore: newWellnessScore,
      scoreDiff: scoreDiff != 0 ? scoreDiff : _wellnessData.scoreDiff,
      activeMode: activeMode,
      dayChartPoints: dayPoints,
      currentHeartRate: effectiveHr,
      weeklyHeartRate: updatedWeeklyHr,
      weeklyEnergy: updatedWeeklyEnergy,
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
      steps: steps,
      moveScore: moveScore,
      recoverScore: recoverScore,
      mindScore: mindScore,
      fuelScore: fuelScore,
    );

    final String bpDisplay = (vitals.systolicBP > 0 && vitals.diastolicBP > 0)
        ? '${vitals.systolicBP}/${vitals.diastolicBP}'
        : '--';

    _vitalsData = _vitalsData.copyWith(
      totalSleep: totalSleep,
      sleepWindow: sleepWindow,
      sleepIntervals: dynamicIntervals,
      currentHeartRate: effectiveHr,
      weeklyHeartRate: updatedWeeklyHr,
      stressScore: vitals.stressLevel > 0
          ? vitals.stressLevel
          : _vitalsData.stressScore,
      stressStatus: vitals.stressLevel > 0
          ? _stressStatusLabel(vitals.stressLevel)
          : _vitalsData.stressStatus,
      stressTimeline: updatedStressTimeline,
      hrvMs: vitals.hrvMs > 0 ? vitals.hrvMs : _vitalsData.hrvMs,
      weeklyHrv: updatedWeeklyHrv,
      restingHr: vitals.restingHeartRate > 0
          ? vitals.restingHeartRate
          : _vitalsData.restingHr,
      weeklyRestingHr: updatedWeeklyRestingHr,
      bloodOxygen: vitals.bloodOxygen > 0
          ? vitals.bloodOxygen.round()
          : _vitalsData.bloodOxygen,
      weeklyOxygen: updatedWeeklyOxygen,
      breathingRate: vitals.breathingRate > 0 ? vitals.breathingRate : _vitalsData.breathingRate,
      weeklyBreathing: updatedWeeklyBreathing,
      bloodPressure: bpDisplay,
      isBloodPressureUp: vitals.systolicBP > 120,
      skinTempDiff: vitals.skinTemperature > 0
          ? double.parse((vitals.skinTemperature - 36.5).toStringAsFixed(1))
          : _vitalsData.skinTempDiff,
      isSkinTempDown: vitals.skinTemperature > 0
          ? vitals.skinTemperature < 36.5
          : _vitalsData.isSkinTempDown,
    );

    // Persist snapshot to SecureStorage for immediate offline/restart hydration
    _secureStorage.write('cached_wellness_data_v1', jsonEncode(_wellnessData.toJson())).catchError((_) {});
    _secureStorage.write('cached_vitals_data_v1', jsonEncode(_vitalsData.toJson())).catchError((_) {});

    // Persist consolidated daily summary and computed scores to Drift SQLite DB
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _db.healthDataDao.upsertDailySummary(
      DailyHealthSummariesTableCompanion(
        userId: const drift.Value('default_user'),
        deviceId: const drift.Value('default_band'),
        date: drift.Value(today),
        steps: drift.Value(steps),
        caloriesBurned: drift.Value(energy.toDouble()),
        distanceMeters: drift.Value(vitals.distance.toDouble()),
        wellnessScore: drift.Value(newWellnessScore),
        moveScore: drift.Value(moveScore),
        recoverScore: drift.Value(recoverScore),
        readinessScore: drift.Value(readinessScore),
        restingHeartRate: drift.Value(vitals.restingHeartRate > 0 ? vitals.restingHeartRate : null),
        avgHeartRate: drift.Value(effectiveHr > 0 ? effectiveHr : null),
        avgSpo2: drift.Value(vitals.bloodOxygen > 0 ? vitals.bloodOxygen : null),
        sleepDurationMinutes: drift.Value(vitals.sleepMinutes),
        deepSleepMinutes: drift.Value(vitals.deepSleepMinutes),
        lastSyncTimestamp: drift.Value(DateTime.now()),
      ),
    ).catchError((e) {
      debugPrint('⚠️ [WELLNESS REPO] upsertDailySummary error: $e');
      return -1;
    });
  }

  String _stressStatusLabel(int score) {
    if (score <= 25) return 'RELAXED';
    if (score <= 50) return 'NORMAL';
    if (score <= 75) return 'ELEVATED';
    return 'HIGH';
  }

  void updateHeartRate(int bpm) {
    if (bpm > 0) {
      List<double> updatedWeeklyHr = List<double>.from(
        _wellnessData.weeklyHeartRate.length == 7
            ? _wellnessData.weeklyHeartRate
            : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      );
      if (updatedWeeklyHr.length == 7) {
        updatedWeeklyHr[_todayIndex] = bpm.toDouble();
      }

      _wellnessData = _wellnessData.copyWith(
        currentHeartRate: bpm,
        weeklyHeartRate: updatedWeeklyHr,
      );

      List<double> updatedVitalsWeeklyHr = List<double>.from(
        _vitalsData.weeklyHeartRate.length == 7
            ? _vitalsData.weeklyHeartRate
            : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      );
      if (updatedVitalsWeeklyHr.length == 7) {
        updatedVitalsWeeklyHr[_todayIndex] = bpm.toDouble();
      }

      _vitalsData = _vitalsData.copyWith(
        currentHeartRate: bpm,
        weeklyHeartRate: updatedVitalsWeeklyHr,
      );
      _secureStorage.write('cached_wellness_data_v1', jsonEncode(_wellnessData.toJson())).catchError((_) {});
      _secureStorage.write('cached_vitals_data_v1', jsonEncode(_vitalsData.toJson())).catchError((_) {});
    }
  }

  void resetData() {
    _wellnessData = _wellnessData.copyWith(
      currentHeartRate: 0,
      sleepHours: 0.0,
      energyBurned: 0,
      steps: 0,
      wellnessScore: 0,
      moveScore: 0,
      recoverScore: 0,
      readinessScore: 0,
    );
    _vitalsData = _vitalsData.copyWith(
      currentHeartRate: 0,
      totalSleep: '--',
      bloodPressure: '--',
      bloodOxygen: 0,
      restingHr: 0,
      stressScore: 0,
      hrvMs: 0,
    );
  }
}
