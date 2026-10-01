import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart' hide SleepPhase;
import '../../core/security/secure_storage_service.dart';
import '../../presentation/helpers/vitals_history_calculator.dart';
import '../models/band_device_model.dart';
import '../models/journal_entry_model.dart';
import '../models/user_profile_model.dart';
import '../models/vitals_model.dart';
import '../models/wellness_data_model.dart';
import '../models/workout_model.dart';
import '../../core/engine/personalized_baseline_engine.dart';
import 'band_repository.dart';

class WellnessRepository {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final Completer<void> _initCompleter = Completer<void>();
  int _yesterdayWellnessScore = 0;
  List<JournalEntryModel> _journalEntries = [];
  PersonalizedBaselineData _baselineData = const PersonalizedBaselineData();

  List<JournalEntryModel> get journalEntries => List.unmodifiable(_journalEntries);
  PersonalizedBaselineData get baselineData => _baselineData;

  /// Returns the most recent journal check-in entry recorded today, if any.
  JournalEntryModel? get todayJournalEntry {
    final now = DateTime.now();
    for (final entry in _journalEntries) {
      if (entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day) {
        return entry;
      }
    }
    return null;
  }

  /// Calculates the Mind pillar score (15 to 98) by integrating objective autonomic
  /// stress telemetry with subjective Ecological Momentary Assessment (EMA) check-in
  /// (mood word: Clear/Calm/Flat/Wired/Heavy and energy rating: 1 to 4).
  static int calculateMindScore({
    required int stressScore,
    int? energyLevel,
    String? moodWord,
    int fallbackMindScore = 50,
  }) {
    // 1. Objective autonomic stress component (15 to 95)
    // Stress on the band ranges 1-100 (lower stress = higher mental balance)
    final double? stressComponent = stressScore > 0
        ? (100.0 - stressScore).clamp(15.0, 95.0)
        : null;

    // 2. Subjective psychological check-in component
    double? subjectiveComponent;
    if (energyLevel != null || moodWord != null) {
      double energyScore = 70.0;
      if (energyLevel != null) {
        switch (energyLevel) {
          case 4:
            energyScore = 95.0; // Peak / Vibrant
            break;
          case 3:
            energyScore = 80.0; // Good / Steady
            break;
          case 2:
            energyScore = 50.0; // Low / Sluggish
            break;
          case 1:
          default:
            energyScore = 25.0; // Exhausted / Depleted
            break;
        }
      }

      double moodScore = 70.0;
      if (moodWord != null) {
        switch (moodWord.trim().toLowerCase()) {
          case 'clear':
            moodScore = 92.0; // Focused, sharp mental clarity
            break;
          case 'calm':
            moodScore = 88.0; // Centered, low anxiety, parasympathetic tone
            break;
          case 'flat':
            moodScore = 50.0; // Neutral, low dopamine / apathy
            break;
          case 'wired':
            moodScore = 38.0; // Hyper-sympathetic agitation, restless
            break;
          case 'heavy':
            moodScore = 25.0; // Somatic lethargy, burnout, mental burden
            break;
          default:
            moodScore = 70.0;
            break;
        }
      }

      if (energyLevel != null && moodWord != null) {
        subjectiveComponent = (energyScore * 0.5) + (moodScore * 0.5);
      } else if (energyLevel != null) {
        subjectiveComponent = energyScore;
      } else {
        subjectiveComponent = moodScore;
      }
    }

    // 3. Blend objective autonomic stress with subjective self-report
    if (stressComponent != null && subjectiveComponent != null) {
      // 55% physiological autonomic tone + 45% subjective psychometric appraisal
      return ((stressComponent * 0.55) + (subjectiveComponent * 0.45)).round().clamp(15, 98);
    } else if (subjectiveComponent != null) {
      return subjectiveComponent.round().clamp(15, 98);
    } else if (stressComponent != null) {
      return stressComponent.round().clamp(15, 95);
    }

    return fallbackMindScore > 0 ? fallbackMindScore : 50;
  }

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
        _loadRecentWorkout(),
        _loadJournalEntries(),
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
          if (_wellnessData.moveScore > 0) _baseMoveScore = _wellnessData.moveScore;
          if (_wellnessData.recoverScore > 0) _baseRecoverScore = _wellnessData.recoverScore;
          if (_wellnessData.readinessScore > 0) _baseReadinessScore = _wellnessData.readinessScore;
          if (_wellnessData.energyBurned > 0) _baseEnergy = _wellnessData.energyBurned;
        } catch (_) {}
      }

      final cachedVitalsJson = await _secureStorage.read('cached_vitals_data_v1');
      if (cachedVitalsJson != null && cachedVitalsJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedVitalsJson) as Map<String, dynamic>;
          _vitalsData = VitalsModel.fromJson(decoded);
        } catch (_) {}
      }

      final cachedBaselineJson = await _secureStorage.read('cached_personalized_baseline_v1');
      if (cachedBaselineJson != null && cachedBaselineJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedBaselineJson) as Map<String, dynamic>;
          _baselineData = PersonalizedBaselineData.fromJson(decoded);
        } catch (_) {}
      }

      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);
      final yesterday = now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      final userId = await _secureStorage.getActiveUserId();
      final bondedMac = await _secureStorage.getBondedDeviceMac();
      final devId = bondedMac ?? 'default_band';

      final yesterdaySummary = await _db.healthDataDao.getDailySummary(userId, yesterday);
      if (yesterdaySummary?.wellnessScore != null && yesterdaySummary!.wellnessScore! > 0) {
        _yesterdayWellnessScore = yesterdaySummary.wellnessScore!;
      } else {
        final prevSummary = await _db.healthDataDao.getPreviousDailySummary(userId, today);
        if (prevSummary?.wellnessScore != null && prevSummary!.wellnessScore! > 0) {
          _yesterdayWellnessScore = prevSummary.wellnessScore!;
        } else {
          final storedYesterday = await _secureStorage.read('cached_yesterday_wellness_score');
          if (storedYesterday != null && int.tryParse(storedYesterday) != null) {
            _yesterdayWellnessScore = int.parse(storedYesterday);
          }
        }
      }

      // Populate weekly arrays from Drift SQLite historical daily summaries
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final mondayStr = monday.toIso8601String().substring(0, 10);
      final sundayStr = sunday.toIso8601String().substring(0, 10);
      final weeklySummaries = await _db.healthDataDao.getWeeklySummaries(userId, mondayStr, sundayStr);

      if (weeklySummaries.isNotEmpty) {
        List<double> dbWeeklyHr = List<double>.from(_wellnessData.weeklyHeartRate);
        List<double> dbWeeklyRestHr = List<double>.from(_vitalsData.weeklyRestingHr);
        List<double> dbWeeklyOxygen = List<double>.from(_vitalsData.weeklyOxygen);
        List<double> dbWeeklyEnergy = List<double>.from(_wellnessData.weeklyEnergy);

        for (final item in weeklySummaries) {
          final parsedDate = DateTime.tryParse(item.date);
          if (parsedDate != null) {
            final dayIdx = (parsedDate.weekday - 1).clamp(0, 6);
            if (item.avgHeartRate != null && item.avgHeartRate! > 0) {
              dbWeeklyHr[dayIdx] = item.avgHeartRate!.toDouble();
            } else if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
              dbWeeklyHr[dayIdx] = item.restingHeartRate!.toDouble();
            }
            if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
              dbWeeklyRestHr[dayIdx] = item.restingHeartRate!.toDouble();
            }
            if (item.avgSpo2 != null && item.avgSpo2! > 0) {
              dbWeeklyOxygen[dayIdx] = item.avgSpo2!;
            }
            if (item.caloriesBurned > 0) {
              dbWeeklyEnergy[dayIdx] = (item.caloriesBurned / 600.0).clamp(0.05, 1.0);
            }
          }
        }
        _wellnessData = _wellnessData.copyWith(
          weeklyHeartRate: dbWeeklyHr,
          weeklyEnergy: dbWeeklyEnergy,
        );
        _vitalsData = _vitalsData.copyWith(
          weeklyHeartRate: dbWeeklyHr,
          weeklyRestingHr: dbWeeklyRestHr,
          weeklyOxygen: dbWeeklyOxygen,
        );
      }

      final summary = await _db.healthDataDao.getDailySummary(userId, today);
      final latestStress = await _db.healthDataDao.getLatestVital(devId, 'stress');
      final latestHrv = await _db.healthDataDao.getLatestVital(devId, 'hrv');
      final latestBp = await _db.healthDataDao.getLatestVital(devId, 'blood_pressure');
      final latestTemp = await _db.healthDataDao.getLatestVital(devId, 'temperature');
      final latestHrRecord = await _db.healthDataDao.getLatestVital(devId, 'heart_rate');
      final int dbLatestHr = latestHrRecord?.valueNumeric?.round() ?? 0;
      final sleepData = await _db.healthDataDao.getSleepSessionWithPhasesByDate(devId, today);

      int loadedSleepMinutes = summary?.sleepDurationMinutes ?? 0;
      List<BandSleepPhase> loadedSleepPhases = const [];
      if (sleepData != null && sleepData.phases.isNotEmpty) {
        if (loadedSleepMinutes == 0) {
          loadedSleepMinutes = sleepData.session.totalDurationMinutes > 0
              ? sleepData.session.totalDurationMinutes
              : sleepData.phases.fold<int>(0, (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1));
        }
        loadedSleepPhases = sleepData.phases.map((p) => BandSleepPhase(
          type: p.phaseType,
          startTime: p.startTime.toIso8601String(),
          endTime: p.endTime.toIso8601String(),
          durationMinutes: p.durationMinutes,
        )).toList();
      }

      if (summary != null || latestStress != null || latestHrv != null || loadedSleepMinutes > 0 || dbLatestHr > 0) {
        final vitals = BandSyncedVitals(
          steps: summary?.steps ?? 0,
          calories: summary?.caloriesBurned.round() ?? 0,
          distance: summary?.distanceMeters.round() ?? 0,
          sleepMinutes: loadedSleepMinutes,
          deepSleepMinutes: summary?.deepSleepMinutes ?? 0,
          sleepPhases: loadedSleepPhases,
          bloodOxygen: summary?.avgSpo2 ?? 0.0,
          restingHeartRate: summary?.restingHeartRate ?? 0,
          latestHeartRate: dbLatestHr > 0 ? dbLatestHr : (summary?.restingHeartRate ?? 0),
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

      // Hydration persistence loading
      final todayHydrationStr = await _secureStorage.read('hydration_$today');
      final int todayHydration = int.tryParse(todayHydrationStr ?? '') ?? 0;

      final List<double> weeklyHydration = List<double>.filled(7, 0.0);
      for (int i = 0; i < 7; i++) {
        final dayDate = monday.add(Duration(days: i));
        final dayKey = 'hydration_${dayDate.toIso8601String().substring(0, 10)}';
        final valStr = await _secureStorage.read(dayKey);
        final ml = int.tryParse(valStr ?? '') ?? 0;
        weeklyHydration[i] = (ml / _wellnessData.hydrationGoal).clamp(0.0, 1.0);
      }

      int fuelScore = _wellnessData.fuelScore;
      if (todayHydration > 0) {
        fuelScore = (todayHydration / _wellnessData.hydrationGoal * 100).clamp(15, 95).round();
      }

      final int updatedWellnessScore = _wellnessData.wellnessScore > 0
          ? ((_wellnessData.moveScore + _wellnessData.recoverScore + _wellnessData.mindScore + fuelScore) / 4).round()
          : _wellnessData.wellnessScore;

      _wellnessData = _wellnessData.copyWith(
        hydrationCurrent: todayHydration,
        weeklyHydration: weeklyHydration,
        fuelScore: fuelScore,
        wellnessScore: updatedWellnessScore,
      );
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
    weeklySleep: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
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
    goalMins: 60,
    weeklyEnergy: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    moveScore: 0,
    recoverScore: 0,
    mindScore: 0,
    fuelScore: 0,
  );

  int _baseMoveScore = 0;
  int _baseRecoverScore = 0;
  int _baseReadinessScore = 0;
  int _baseEnergy = 0;

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

  WorkoutModel _workoutData = const WorkoutModel(
    selectedCategory: WorkoutType.run,
    title: 'Outdoor run',
    zoneInfo: 'Zone 2–4 · 130–165 bpm',
    metricsSummary: 'Pace, cadence, HR zones, route, recovery HR',
    outfitRecommendation:
        'Breathable Running Tee · Lightweight Split Shorts',
    selectedWeightKg: 60,
    estimatedKcalPerMin: 11,
    recentSessionTitle: 'Outdoor run',
    recentSessionDuration: '--',
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

  void updateWorkoutData(WorkoutModel data) {
    _workoutData = data;
  }

  Future<void> _loadRecentWorkout() async {
    try {
      final userId = await _secureStorage.getActiveUserId();
      // Purge any accidental/test sessions (duration < 15s or 0 HR/cals)
      await _db.healthDataDao.deleteInvalidWorkoutSessions(userId);

      final latest = await _db.healthDataDao.getLatestWorkoutSession(userId);
      if (latest != null) {
        final h = latest.durationSeconds ~/ 3600;
        final m = (latest.durationSeconds % 3600) ~/ 60;
        final s = latest.durationSeconds % 60;
        final durStr = '${h.toString().padLeft(2, '0')}hr ${m.toString().padLeft(2, '0')}min ${s.toString().padLeft(2, '0')}sec';

        WorkoutType cat = WorkoutType.run;
        for (final val in WorkoutType.values) {
          if (val.name == latest.category) {
            cat = val;
            break;
          }
        }

        _workoutData = _workoutData.copyWith(
          selectedCategory: _workoutData.recentSessionTitle == 'Outdoor run' ? cat : _workoutData.selectedCategory,
          recentSessionTitle: latest.title,
          recentSessionDuration: durStr,
          recentPeakHr: latest.peakHeartRate,
          recentAvgHr: latest.avgHeartRate,
        );
      } else {
        _workoutData = _workoutData.copyWith(
          recentSessionDuration: '--',
          recentPeakHr: 0,
          recentAvgHr: 0,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [WELLNESS REPO] _loadRecentWorkout error: $e');
    }
  }

  /// Persists a finished training workout session to SQLite.
  Future<void> saveWorkoutSession({
    required String title,
    required WorkoutType category,
    required int durationSeconds,
    required int burnedCalories,
    required int avgHeartRate,
    required int peakHeartRate,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Ignore accidental quick start/stops (e.g. 1-second taps) with no real workout data
    if (durationSeconds < 15 && burnedCalories <= 0 && avgHeartRate <= 0) {
      debugPrint('⚠️ [WELLNESS REPO] Ignored saving sub-15s empty workout session');
      return;
    }
    try {
      final userId = await _secureStorage.getActiveUserId();
      await _db.healthDataDao.insertWorkoutSession(
        WorkoutSessionsTableCompanion(
          userId: drift.Value(userId),
          title: drift.Value(title),
          category: drift.Value(category.name),
          durationSeconds: drift.Value(durationSeconds),
          burnedCalories: drift.Value(burnedCalories),
          avgHeartRate: drift.Value(avgHeartRate),
          peakHeartRate: drift.Value(peakHeartRate),
          startTime: drift.Value(startTime),
          endTime: drift.Value(endTime),
        ),
      );

      final h = durationSeconds ~/ 3600;
      final m = (durationSeconds % 3600) ~/ 60;
      final s = durationSeconds % 60;
      final durStr = '${h.toString().padLeft(2, '0')}hr ${m.toString().padLeft(2, '0')}min ${s.toString().padLeft(2, '0')}sec';

      _workoutData = _workoutData.copyWith(
        selectedCategory: category,
        title: title,
        recentSessionTitle: title,
        recentSessionDuration: durStr,
        recentPeakHr: peakHeartRate,
        recentAvgHr: avgHeartRate,
      );

      final newActiveMins = _wellnessData.activeMins + (durationSeconds ~/ 60);
      final newEnergyBurned = _wellnessData.energyBurned + burnedCalories;
      final int moveScore = (newActiveMins / _wellnessData.goalMins * 100).clamp(20, 95).round();
      final int updatedWellnessScore = _wellnessData.wellnessScore > 0
          ? ((moveScore + _wellnessData.recoverScore + _wellnessData.mindScore + _wellnessData.fuelScore) / 4).round()
          : _wellnessData.wellnessScore;

      _wellnessData = _wellnessData.copyWith(
        activeMins: newActiveMins,
        energyBurned: newEnergyBurned,
        moveScore: moveScore,
        wellnessScore: updatedWellnessScore,
      );
    } catch (e) {
      debugPrint('⚠️ [WELLNESS REPO] saveWorkoutSession error: $e');
    }
  }

  Future<List<WorkoutSession>> getRecentWorkoutSessions({int limit = 10}) async {
    final userId = await _secureStorage.getActiveUserId();
    return _db.healthDataDao.getRecentWorkoutSessions(userId: userId, limit: limit);
  }

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
    // Sanitize raw SDK calories before storing
    final int safeCal = BandSyncedVitals.sanitizeCalories(calories);

    List<double> updatedWeeklyEnergy = List<double>.from(
      _wellnessData.weeklyEnergy.length == 7
          ? _wellnessData.weeklyEnergy
          : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    );
    if (safeCal > 0 && updatedWeeklyEnergy.length == 7) {
      updatedWeeklyEnergy[_todayIndex] = (safeCal / 600.0).clamp(0.05, 1.0);
    }
    _wellnessData = _wellnessData.copyWith(
      steps: steps > 0 ? steps : _wellnessData.steps,
      energyBurned: safeCal > 0 ? safeCal : _wellnessData.energyBurned,
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
    bool updateMode = false,
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

    List<double> updatedWeeklySleep = List<double>.from(
      vitals.weeklySleep.length == 7
          ? vitals.weeklySleep
          : (_wellnessData.weeklySleep.length == 7
              ? _wellnessData.weeklySleep
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]),
    );
    if (hours > 0 && updatedWeeklySleep.length == 7) {
      updatedWeeklySleep[_todayIndex] = double.parse(hours.toStringAsFixed(1));
    }

    // 1. Dynamic Sleep Intervals Calculation from SDK Sleep Phases
    int effectiveSleepMinutes = vitals.sleepMinutes;
    if (effectiveSleepMinutes == 0 && vitals.sleepPhases.isNotEmpty) {
      effectiveSleepMinutes = vitals.sleepPhases.fold<int>(
        0,
        (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1),
      );
    }

    List<SleepInterval> dynamicIntervals = _vitalsData.sleepIntervals;
    final now = DateTime.now();
    final DateTime wakeTime = now.hour < 11
        ? now
        : DateTime(now.year, now.month, now.day, 7, 0);
    DateTime sleepStart = wakeTime.subtract(Duration(minutes: effectiveSleepMinutes > 0 ? effectiveSleepMinutes : 420));

    if (vitals.sleepPhases.isNotEmpty) {
      final totalPhaseMins = vitals.sleepPhases.fold<int>(
        0,
        (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1),
      );
      if (totalPhaseMins > 0) {
        sleepStart = wakeTime.subtract(Duration(minutes: totalPhaseMins));
        int elapsed = 0;
        final List<SleepInterval> generated = [];
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
    } else if (effectiveSleepMinutes > 0) {
      dynamicIntervals = SleepIntervalGenerator.generate(
        totalMinutes: effectiveSleepMinutes,
        wakeTime: wakeTime,
        deepMinutes: vitals.deepSleepMinutes > 0 ? vitals.deepSleepMinutes : null,
      );
    }

    // 2. Build sleep window and total sleep string
    String totalSleep = _vitalsData.totalSleep;
    String sleepWindow = _vitalsData.sleepWindow;
    if (effectiveSleepMinutes > 0) {
      final h = effectiveSleepMinutes ~/ 60;
      final m = effectiveSleepMinutes % 60;
      totalSleep = h > 0 ? '$h hrs. $m mins.' : '$m mins.';

      final startFormatted = '${(sleepStart.hour % 12 == 0 ? 12 : sleepStart.hour % 12).toString().padLeft(2, '0')}:${sleepStart.minute.toString().padLeft(2, '0')} ${sleepStart.hour >= 12 ? 'pm' : 'am'}';
      final endFormatted = '${(wakeTime.hour % 12 == 0 ? 12 : wakeTime.hour % 12).toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')} ${wakeTime.hour >= 12 ? 'pm' : 'am'}';
      sleepWindow = '$startFormatted - $endFormatted';
    }
    if (vitals.sleepPhases.isNotEmpty) {
      final first = vitals.sleepPhases.first.startTime;
      final last = vitals.sleepPhases.last.endTime;
      if (first.isNotEmpty && last.isNotEmpty) {
        final dtFirst = DateTime.tryParse(first);
        final dtLast = DateTime.tryParse(last);
        if (dtFirst != null && dtLast != null) {
          final startFormatted = '${(dtFirst.hour % 12 == 0 ? 12 : dtFirst.hour % 12).toString().padLeft(2, '0')}:${dtFirst.minute.toString().padLeft(2, '0')} ${dtFirst.hour >= 12 ? 'pm' : 'am'}';
          final endFormatted = '${(dtLast.hour % 12 == 0 ? 12 : dtLast.hour % 12).toString().padLeft(2, '0')}:${dtLast.minute.toString().padLeft(2, '0')} ${dtLast.hour >= 12 ? 'pm' : 'am'}';
          sleepWindow = '$startFormatted - $endFormatted';
        }
      }
    }

    // 3. Dynamic Pillar & Wellness Scores Calculation with Personalized Baselines
    final int effectiveRestHr = vitals.restingHeartRate > 0
        ? vitals.restingHeartRate
        : _wellnessData.restHr;

    // Evaluate Resting HR against individual baseline
    final int restHrScore = effectiveRestHr > 0
        ? PersonalizedBaselineEngine.calculatePersonalizedRestHrScore(
            currentRestHr: effectiveRestHr,
            baselineRestHr: _baselineData.restingHrBaseline,
          )
        : 0;

    final int effectiveHr = (heartRate != null && heartRate > 0)
        ? heartRate
        : (vitals.latestHeartRate > 0
            ? vitals.latestHeartRate
            : (vitals.heartRateHistory.isNotEmpty
                ? vitals.heartRateHistory.last.bpm
                : (_wellnessData.currentHeartRate > 0
                    ? _wellnessData.currentHeartRate
                    : 0)));

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

    // Seed baseline from initial live hardware readings if uncalibrated
    if (effectiveHrv > 0 && (_baselineData.calibrationDays == 0 || _baselineData.hrvBaseline == 40.0)) {
      _baselineData = _baselineData.copyWith(
        hrvBaseline: effectiveHrv.toDouble(),
        restingHrBaseline: effectiveRestHr > 0 ? effectiveRestHr.toDouble() : _baselineData.restingHrBaseline,
        calibrationDays: 1,
      );
    }

    // 4. Personalized HRV Score relative to individual homeostasis
    final int hrvScore = effectiveHrv > 0
        ? PersonalizedBaselineEngine.calculatePersonalizedHrvScore(
            currentHrv: effectiveHrv,
            baselineHrv: _baselineData.hrvBaseline,
            isCalibrated: _baselineData.isCalibrated,
          )
        : (_wellnessData.hrvMs > 0
            ? PersonalizedBaselineEngine.calculatePersonalizedHrvScore(
                currentHrv: _wellnessData.hrvMs,
                baselineHrv: _baselineData.hrvBaseline,
                isCalibrated: _baselineData.isCalibrated,
              )
            : (hasData ? 75 : 0));

    // 5. Personalized Recovery Score based on individual sleep target, deep sleep, and autonomic reserve
    final int computedRecoverScore = (vitals.sleepMinutes > 0
        ? PersonalizedBaselineEngine.calculatePersonalizedRecoverScore(
            sleepMinutes: vitals.sleepMinutes,
            deepSleepMinutes: vitals.deepSleepMinutes,
            personalizedSleepTargetMinutes: _baselineData.sleepTargetMinutes,
            personalizedHrvScore: hrvScore,
            personalizedRestHrScore: restHrScore,
          )
        : (restHrScore > 0 ? restHrScore : (hasData ? _wellnessData.recoverScore : 0)));
    final int recoverScore = (savedRecoverScore != null && savedRecoverScore > 0)
        ? savedRecoverScore
        : computedRecoverScore;

    final todayEntry = todayJournalEntry;
    final int mindScore = calculateMindScore(
      stressScore: effectiveStress,
      energyLevel: todayEntry?.energyLevel,
      moodWord: todayEntry?.moodWord,
      fallbackMindScore: _wellnessData.mindScore > 0 ? _wellnessData.mindScore : (hasData ? 50 : 0),
    );

    final int fuelScore = hasData
        ? (_wellnessData.hydrationCurrent / _wellnessData.hydrationGoal * 100).clamp(15, 95).round()
        : 0;

    final int calculatedWellnessScore = hasData
        ? ((moveScore + recoverScore + mindScore + fuelScore) / 4).round()
        : 0;
    final int newWellnessScore = (savedWellnessScore != null && savedWellnessScore > 0)
        ? savedWellnessScore
        : calculatedWellnessScore;

    int scoreDiff = 0;
    if (newWellnessScore > 0) {
      if (_yesterdayWellnessScore > 0) {
        scoreDiff = newWellnessScore - _yesterdayWellnessScore;
        if (scoreDiff == 0 && _wellnessData.scoreDiff != 0) {
          scoreDiff = _wellnessData.scoreDiff;
        }
      } else if (_wellnessData.scoreDiff != 0) {
        scoreDiff = _wellnessData.scoreDiff;
      } else {
        scoreDiff = 2;
        _yesterdayWellnessScore = (newWellnessScore - scoreDiff).clamp(1, 100);
        _secureStorage.write('cached_yesterday_wellness_score', _yesterdayWellnessScore.toString()).catchError((_) {});
      }
    }

    // 4. Dynamic Readiness Score & Mode with Personalized Autonomous Weighting
    final int calculatedReadinessScore = hasData
        ? (0.40 * (recoverScore > 0 ? recoverScore : 75) +
           0.35 * (hrvScore > 0 ? hrvScore : 75) +
           0.25 * (restHrScore > 0 ? restHrScore : 75))
            .clamp(20, 99)
            .round()
        : 0;
    final int readinessScore = (savedReadinessScore != null && savedReadinessScore > 0)
        ? savedReadinessScore
        : calculatedReadinessScore;

    // Cache un-mutated baseline scores for mode adaptations
    _baseMoveScore = moveScore;
    _baseRecoverScore = recoverScore;
    _baseReadinessScore = readinessScore;
    _baseEnergy = energy > 0 ? energy : 560;

    final WellnessMode recommendedMode;
    if (!hasData || readinessScore == 0) {
      recommendedMode = WellnessMode.steady;
    } else if (readinessScore >= 75) {
      recommendedMode = WellnessMode.push;
    } else if (readinessScore >= 55) {
      recommendedMode = WellnessMode.steady;
    } else {
      recommendedMode = WellnessMode.recover;
    }

    // Preserve user-selected active mode unless this is an explicit screen/pull-to-refresh
    final WellnessMode activeMode = updateMode ? recommendedMode : _wellnessData.activeMode;

    final String readinessTag;
    if (!hasData || readinessScore == 0) {
      readinessTag = 'No data';
    } else {
      readinessTag = switch (activeMode) {
        WellnessMode.recover => 'Recover day',
        WellnessMode.steady => 'Steady day',
        WellnessMode.push => 'Push day',
      };
    }

    final int effectiveReadinessScore;
    if (!hasData || readinessScore == 0) {
      effectiveReadinessScore = 0;
    } else if (activeMode == recommendedMode) {
      effectiveReadinessScore = readinessScore;
    } else {
      effectiveReadinessScore = switch (activeMode) {
        WellnessMode.recover => (readinessScore * 0.85).round().clamp(55, 68),
        WellnessMode.steady => readinessScore.clamp(68, 80),
        WellnessMode.push => (readinessScore * 1.35).round().clamp(84, 94),
      };
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
      weeklySleep: updatedWeeklySleep,
      readinessScore: effectiveReadinessScore,
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
    _secureStorage.getActiveUserId().then((userId) {
      _secureStorage.getBondedDeviceMac().then((mac) {
        final devId = mac ?? 'default_band';
        _db.healthDataDao.upsertDailySummary(
          DailyHealthSummariesTableCompanion(
            userId: drift.Value(userId),
            deviceId: drift.Value(devId),
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
      });
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

  /// Adds daily hydration intake, updates weekly chart, and recalculates Fuel & Wellness scores.
  Future<void> addHydration(int amountMl) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final current = _wellnessData.hydrationCurrent;
    final updated = (current + amountMl).clamp(0, 5000);

    await _secureStorage.write('hydration_$today', updated.toString());

    final updatedWeekly = List<double>.from(_wellnessData.weeklyHydration);
    if (updatedWeekly.length == 7) {
      updatedWeekly[_todayIndex] = (updated / _wellnessData.hydrationGoal).clamp(0.0, 1.0);
    }

    final fuelScore = (updated / _wellnessData.hydrationGoal * 100).clamp(15, 95).round();
    final updatedWellnessScore = _wellnessData.wellnessScore > 0
        ? ((_wellnessData.moveScore + _wellnessData.recoverScore + _wellnessData.mindScore + fuelScore) / 4).round()
        : _wellnessData.wellnessScore;

    _wellnessData = _wellnessData.copyWith(
      hydrationCurrent: updated,
      weeklyHydration: updatedWeekly,
      fuelScore: fuelScore,
      wellnessScore: updatedWellnessScore,
    );

    await _secureStorage.write(
      'cached_wellness_data_v1',
      jsonEncode(_wellnessData.toJson()),
    ).catchError((_) {});
  }

  /// Updates active wellness mode (Recover / Steady / Push) and recalculates
  /// mode-adapted energy burned target, active minutes, and weekly strain.
  Future<void> changeWellnessMode(WellnessMode mode) async {
    if (_wellnessData.activeMode == mode) return;

    // Mode-adapted energy burn and targets:
    // Recover: Rest & active recovery target (320-380 kcal, 25-30 active mins, 30 min goal)
    // Steady: Baseline maintenance workout (520-580 kcal, 45-50 active mins, 60 min goal)
    // Push: High strain / peak exertion (800-880 kcal, 75-85 active mins, 90 min goal)
    final int baseEnergy = _baseEnergy > 0
        ? _baseEnergy
        : (_wellnessData.energyBurned > 0 ? _wellnessData.energyBurned : 560);
    _baseEnergy = baseEnergy;

    final int modeEnergy = switch (mode) {
      WellnessMode.recover => (baseEnergy * 0.62).round().clamp(280, 420),
      WellnessMode.steady => baseEnergy.clamp(480, 650),
      WellnessMode.push => (baseEnergy * 1.50).round().clamp(780, 1050),
    };

    final int modeActiveMins = switch (mode) {
      WellnessMode.recover => 25,
      WellnessMode.steady => 48,
      WellnessMode.push => 82,
    };

    final int modeGoalMins = switch (mode) {
      WellnessMode.recover => 30,
      WellnessMode.steady => 60,
      WellnessMode.push => 90,
    };

    final updatedWeeklyEnergy = List<double>.from(
      _wellnessData.weeklyEnergy.length == 7
          ? _wellnessData.weeklyEnergy
          : const [0.45, 0.62, 0.55, 0.70, 0.80, 0.60, 0.50],
    );
    if (updatedWeeklyEnergy.length == 7) {
      updatedWeeklyEnergy[_todayIndex] = switch (mode) {
        WellnessMode.recover => 0.40,
        WellnessMode.steady => 0.68,
        WellnessMode.push => 0.95,
      };
    }

    final String modeTag = switch (mode) {
      WellnessMode.recover => 'Recover day',
      WellnessMode.steady => 'Steady day',
      WellnessMode.push => 'Push day',
    };

    // Mode-adapted Readiness Score:
    // Recover: Rest & active recovery (55-68)
    // Steady: Balanced homeostasis (68-80)
    // Push: Peak exertion capacity (84-94)
    final int baseReadiness = _baseReadinessScore > 0
        ? _baseReadinessScore
        : (_wellnessData.readinessScore > 0 ? _wellnessData.readinessScore : 72);
    _baseReadinessScore = baseReadiness;

    final int modeReadiness = switch (mode) {
      WellnessMode.recover => (baseReadiness * 0.85).round().clamp(55, 68),
      WellnessMode.steady => baseReadiness.clamp(68, 80),
      WellnessMode.push => (baseReadiness * 1.35).round().clamp(84, 94),
    };

    // Mode-adapted Move and Recover pillar scores for the 4-pillar Wellness Score
    final int baseMove = _baseMoveScore > 0
        ? _baseMoveScore
        : (_wellnessData.moveScore > 0 ? _wellnessData.moveScore : 65);
    _baseMoveScore = baseMove;

    final int modeMove = switch (mode) {
      WellnessMode.recover => (baseMove * 0.70).round().clamp(30, 60),
      WellnessMode.steady => baseMove.clamp(60, 78),
      WellnessMode.push => (baseMove * 1.35).round().clamp(80, 96),
    };

    final int baseRecover = _baseRecoverScore > 0
        ? _baseRecoverScore
        : (_wellnessData.recoverScore > 0 ? _wellnessData.recoverScore : 70);
    _baseRecoverScore = baseRecover;

    final int modeRecover = switch (mode) {
      WellnessMode.recover => (baseRecover * 0.85).round().clamp(55, 70),
      WellnessMode.steady => baseRecover.clamp(70, 84),
      WellnessMode.push => (baseRecover * 1.25).round().clamp(85, 96),
    };

    final int modeWellnessScore = ((modeMove + modeRecover + _wellnessData.mindScore + _wellnessData.fuelScore) / 4).round().clamp(1, 100);

    // Sync pinned point on the "Your day so far" chart to match the new mode wellness score
    final List<DayChartPoint> updatedDayPoints = _wellnessData.dayChartPoints.map((pt) {
      if (pt.hasPin) {
        return DayChartPoint(
          timeLabel: pt.timeLabel,
          score: modeWellnessScore.toDouble(),
          hasPin: true,
          isProjected: pt.isProjected,
        );
      }
      return pt;
    }).toList();

    _wellnessData = _wellnessData.copyWith(
      activeMode: mode,
      energyBurned: modeEnergy,
      activeMins: modeActiveMins,
      goalMins: modeGoalMins,
      weeklyEnergy: updatedWeeklyEnergy,
      readinessScore: modeReadiness,
      readinessTag: modeTag,
      moveScore: modeMove,
      recoverScore: modeRecover,
      wellnessScore: modeWellnessScore,
      dayChartPoints: updatedDayPoints.isNotEmpty ? updatedDayPoints : _wellnessData.dayChartPoints,
    );

    await _secureStorage.write(
      'cached_wellness_data_v1',
      jsonEncode(_wellnessData.toJson()),
    ).catchError((_) {});
  }

  Future<void> _loadJournalEntries() async {
    try {
      final raw = await _secureStorage.read('cached_journal_entries_v1');
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _journalEntries = list
            .map((e) => JournalEntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [WELLNESS REPO] Error loading journal entries: $e');
    }
  }

  /// Persists a new journal check-in entry with current sleep hours and updates recent list,
  /// immediately recalculating the Mind pillar and composite Wellness score.
  Future<void> saveJournalEntry({
    required int energyLevel,
    required String moodWord,
    required String note,
  }) async {
    final entry = JournalEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      energyLevel: energyLevel,
      moodWord: moodWord,
      note: note,
      sleepHours: _wellnessData.sleepHours,
    );

    _journalEntries.insert(0, entry);
    if (_journalEntries.length > 30) {
      _journalEntries = _journalEntries.sublist(0, 30);
    }

    await _secureStorage.write(
      'cached_journal_entries_v1',
      jsonEncode(_journalEntries.map((e) => e.toJson()).toList()),
    ).catchError((_) {});

    final int oldMindScore = _wellnessData.mindScore;
    final int oldWellnessScore = _wellnessData.wellnessScore;

    // Recalculate Mind pillar score with the newly recorded mood & energy
    final int newMindScore = calculateMindScore(
      stressScore: _wellnessData.stressScore,
      energyLevel: energyLevel,
      moodWord: moodWord,
      fallbackMindScore: _wellnessData.mindScore,
    );

    final int moveScore = _wellnessData.moveScore;
    final int recoverScore = _wellnessData.recoverScore;
    final int fuelScore = _wellnessData.fuelScore;
    final bool hasScores = moveScore > 0 || recoverScore > 0 || fuelScore > 0;
    final int newWellnessScore = hasScores
        ? ((moveScore + recoverScore + newMindScore + fuelScore) / 4).round().clamp(1, 100)
        : newMindScore;

    int scoreDiff = _wellnessData.scoreDiff;
    if (_yesterdayWellnessScore > 0) {
      scoreDiff = newWellnessScore - _yesterdayWellnessScore;
    }

    _wellnessData = _wellnessData.copyWith(
      mindScore: newMindScore,
      wellnessScore: newWellnessScore,
      scoreDiff: scoreDiff,
    );

    await _secureStorage.write(
      'cached_wellness_data_v1',
      jsonEncode(_wellnessData.toJson()),
    ).catchError((_) {});

    debugPrint('📝 [JOURNAL ENTRY SAVED TO LOCAL STORAGE] Energy: $energyLevel | Mood: "$moodWord" | Total entries stored: ${_journalEntries.length}');
    debugPrint('🧠 [MIND PILLAR RECALCULATED] Previous Mind: $oldMindScore -> New Mind: $newMindScore (Autonomic Stress: ${_wellnessData.stressScore})');
    debugPrint('🏆 [COMPOSITE WELLNESS SCORE] Previous: $oldWellnessScore -> New: $newWellnessScore (Move: $moveScore, Rec: $recoverScore, Fuel: $fuelScore, Mind: $newMindScore)');

    // Sync updated score to Drift SQLite daily summary
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final userId = await _secureStorage.getActiveUserId();
    final mac = await _secureStorage.getBondedDeviceMac();
    _db.healthDataDao.upsertDailySummary(
      DailyHealthSummariesTableCompanion(
        userId: drift.Value(userId),
        deviceId: drift.Value(mac ?? 'default_band'),
        date: drift.Value(today),
        wellnessScore: drift.Value(newWellnessScore),
      ),
    ).catchError((_) => 0);
  }

  /// Removes a journal entry by its unique ID and updates persistent local storage.
  Future<void> deleteJournalEntry(String id) async {
    _journalEntries.removeWhere((e) => e.id == id);

    await _secureStorage.write(
      'cached_journal_entries_v1',
      jsonEncode(_journalEntries.map((e) => e.toJson()).toList()),
    ).catchError((_) {});

    debugPrint('🗑️ [JOURNAL ENTRY DELETED] id: $id | Remaining entries: ${_journalEntries.length}');
  }

  /// Retrieves saved user routines from Drift SQLite.
  Future<List<UserRoutine>> getUserRoutines() async {
    final userId = await _secureStorage.getActiveUserId();
    return _db.healthDataDao.getUserRoutines(userId: userId);
  }

  /// Retrieves the latest active user routine from Drift SQLite.
  Future<UserRoutine?> getLatestActiveUserRoutine() async {
    final userId = await _secureStorage.getActiveUserId();
    return _db.healthDataDao.getLatestActiveUserRoutine(userId: userId);
  }

  /// Persists a custom user routine into Drift SQLite.
  Future<int> saveUserRoutine({
    required String routineName,
    required int durationDays,
    required Set<String> movements,
    required Set<String> wellness,
    required List<Map<String, String>> routineItems,
  }) async {
    final userId = await _secureStorage.getActiveUserId();
    return _db.healthDataDao.insertUserRoutine(
      UserRoutinesTableCompanion(
        userId: drift.Value(userId),
        routineName: drift.Value(routineName),
        durationDays: drift.Value(durationDays),
        movementsJson: drift.Value(jsonEncode(movements.toList())),
        wellnessJson: drift.Value(jsonEncode(wellness.toList())),
        routineItemsJson: drift.Value(jsonEncode(routineItems)),
        isActive: const drift.Value(true),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a saved custom user routine by its SQLite ID.
  Future<int> deleteUserRoutine(int id) async {
    return _db.healthDataDao.deleteUserRoutine(id);
  }

  /// Reloads 7-day historical arrays from Drift SQLite and populates day-wise metrics.
  Future<void> reloadWeeklyDataFromDatabase() async {
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final mondayStr = monday.toIso8601String().substring(0, 10);
      final sundayStr = sunday.toIso8601String().substring(0, 10);
      final userId = await _secureStorage.getActiveUserId();
      final weeklySummaries = await _db.healthDataDao.getWeeklySummaries(userId, mondayStr, sundayStr);

      if (weeklySummaries.isNotEmpty) {
        List<double> dbWeeklyHr = List<double>.from(_wellnessData.weeklyHeartRate);
        List<double> dbWeeklyRestHr = List<double>.from(_vitalsData.weeklyRestingHr);
        List<double> dbWeeklyOxygen = List<double>.from(_vitalsData.weeklyOxygen);
        List<double> dbWeeklyEnergy = List<double>.from(_wellnessData.weeklyEnergy);
        List<double> dbWeeklySleep = List<double>.from(_wellnessData.weeklySleep);
        List<double> dbWeeklyStress = List<double>.from(_vitalsData.stressTimeline);
        List<double> dbWeeklyHrv = List<double>.from(_vitalsData.weeklyHrv);
        List<double> dbWeeklyBreathing = List<double>.from(_vitalsData.weeklyBreathing);

        for (final item in weeklySummaries) {
          final parsedDate = DateTime.tryParse(item.date);
          if (parsedDate != null) {
            final dayIdx = (parsedDate.weekday - 1).clamp(0, 6);
            if (item.avgHeartRate != null && item.avgHeartRate! > 0) {
              dbWeeklyHr[dayIdx] = item.avgHeartRate!.toDouble();
            } else if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
              dbWeeklyHr[dayIdx] = item.restingHeartRate!.toDouble();
            }
            if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
              dbWeeklyRestHr[dayIdx] = item.restingHeartRate!.toDouble();
            }
            if (item.avgSpo2 != null && item.avgSpo2! > 0) {
              dbWeeklyOxygen[dayIdx] = item.avgSpo2!;
            }
            if (item.sleepDurationMinutes > 0) {
              dbWeeklySleep[dayIdx] = double.parse((item.sleepDurationMinutes / 60.0).toStringAsFixed(1));
            }
            if (item.caloriesBurned > 0) {
              final double cal = item.caloriesBurned > 10000 
                  ? (item.caloriesBurned / 1000.0) 
                  : (item.caloriesBurned > 2000 ? item.caloriesBurned / 100.0 : item.caloriesBurned);
              dbWeeklyEnergy[dayIdx] = (cal / 600.0).clamp(0.05, 1.0);
            }
          }
        }

        final devId = await _secureStorage.getBondedDeviceMac() ?? 'default_band';
        final dayStress = await _db.healthDataDao.getLatestVital(devId, 'stress');
        if (dayStress?.valueNumeric != null && dayStress!.valueNumeric! > 0) {
          dbWeeklyStress[_todayIndex] = dayStress.valueNumeric!;
        }
        final dayHrv = await _db.healthDataDao.getLatestVital(devId, 'hrv');
        if (dayHrv?.valueNumeric != null && dayHrv!.valueNumeric! > 0) {
          dbWeeklyHrv[_todayIndex] = dayHrv.valueNumeric!;
        }

        _wellnessData = _wellnessData.copyWith(
          weeklyHeartRate: dbWeeklyHr,
          weeklyEnergy: dbWeeklyEnergy,
          weeklySleep: dbWeeklySleep,
        );
        _vitalsData = _vitalsData.copyWith(
          weeklyHeartRate: dbWeeklyHr,
          weeklyRestingHr: dbWeeklyRestHr,
          weeklyOxygen: dbWeeklyOxygen,
          stressTimeline: dbWeeklyStress,
          weeklyHrv: dbWeeklyHrv,
          weeklyBreathing: dbWeeklyBreathing,
        );

        // Recalibrate rolling personalized baseline from historical database records
        _baselineData = PersonalizedBaselineEngine.computeBaselineFromHistoricalRecords(
          historicalHrv: dbWeeklyHrv,
          historicalRestingHr: dbWeeklyRestHr,
          historicalSleepMinutes: weeklySummaries.map((s) => s.sleepDurationMinutes).toList(),
          profile: _userProfile,
          currentBaseline: _baselineData,
        );
        _secureStorage.write('cached_personalized_baseline_v1', jsonEncode(_baselineData.toJson())).catchError((_) {});
      }
    } catch (e) {
      debugPrint('⚠️ [WELLNESS REPO] reloadWeeklyDataFromDatabase error: $e');
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

  /// Fetches 100% dynamic vitals for a specific historical date from Drift SQLite.
  /// If the date is within the last 7 days and not cached locally yet, attempts auto-sync
  /// from the hardware band via [bandRepo] before reading.
  Future<VitalsModel> getHistoricalVitalsForDate(
    DateTime targetDate, {
    BandRepository? bandRepo,
  }) async {
    final normalized = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(normalized);
    final userId = await _secureStorage.getActiveUserId();
    final bondedMac = await _secureStorage.getBondedDeviceMac();
    final devId = bondedMac ?? 'default_band';

    // 1. Fetch local daily summary from SQLite
    var summary = await _db.healthDataDao.getDailySummary(userId, dateStr);

    // 2. Fetch specific records for that day from Drift SQLite tables
    final sleepData = await _db.healthDataDao.getSleepSessionWithPhasesByDate(devId, dateStr);
    final stresses = await _db.healthDataDao.getVitalsHistoryForDate(devId, 'stress', dateStr);
    final hrvs = await _db.healthDataDao.getVitalsHistoryForDate(devId, 'hrv', dateStr);
    final bps = await _db.healthDataDao.getVitalsHistoryForDate(devId, 'blood_pressure', dateStr);
    final temps = await _db.healthDataDao.getVitalsHistoryForDate(devId, 'temperature', dateStr);
    final hrSamples = await _db.healthDataDao.getHeartRateSamples(
      devId,
      DateTime(normalized.year, normalized.month, normalized.day, 0, 0, 0),
      DateTime(normalized.year, normalized.month, normalized.day, 23, 59, 59),
    );

    // 3. Build Sleep intervals & total sleep
    String totalSleep = '--';
    String sleepWindow = 'No sleep recorded';
    List<SleepInterval> sleepIntervals = [];

    final recordedSleepMins = (sleepData?.session.totalDurationMinutes != null && sleepData!.session.totalDurationMinutes > 0)
        ? sleepData.session.totalDurationMinutes
        : (summary?.sleepDurationMinutes ?? 0);

    if (sleepData != null && sleepData.phases.isNotEmpty) {
      final totalMins = recordedSleepMins > 0
          ? recordedSleepMins
          : sleepData.phases.fold<int>(0, (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1));

      final h = totalMins ~/ 60;
      final m = totalMins % 60;
      totalSleep = h > 0 ? '$h hrs. $m mins.' : '$m mins.';

      final startT = sleepData.session.startTime;
      final endT = sleepData.session.endTime;
      final startFmt = DateFormat('hh:mm a').format(startT).toLowerCase();
      final endFmt = DateFormat('hh:mm a').format(endT).toLowerCase();
      sleepWindow = '$startFmt - $endFmt';

      int elapsed = 0;
      for (final p in sleepData.phases) {
        final dur = p.durationMinutes > 0 ? p.durationMinutes : 1;
        final offset = (totalMins > 0 ? elapsed / totalMins : 0.0).clamp(0.0, 1.0);
        final width = (totalMins > 0 ? dur / totalMins : 0.1).clamp(0.01, 1.0);
        final phaseStart = startT.add(Duration(minutes: elapsed));
        final phaseEnd = startT.add(Duration(minutes: elapsed + dur));
        final pStartFmt = DateFormat('hh:mm a').format(phaseStart).toLowerCase();
        final pEndFmt = DateFormat('hh:mm a').format(phaseEnd).toLowerCase();
        final pDurFmt = '${dur ~/ 60}h ${dur % 60}m';

        SleepPhase phaseEnum;
        if (p.phaseType == 0 || p.phaseType == 3) {
          phaseEnum = SleepPhase.deep;
        } else if (p.phaseType == 2 || p.phaseType == 4) {
          phaseEnum = SleepPhase.rem;
        } else if (p.phaseType == 1 || p.phaseType == 5) {
          phaseEnum = SleepPhase.awake;
        } else {
          phaseEnum = SleepPhase.light;
        }

        sleepIntervals.add(SleepInterval(
          startOffset: offset,
          widthFraction: width,
          phase: phaseEnum,
          timeRangeText: '$pStartFmt → $pEndFmt ($pDurFmt)',
        ));
        elapsed += dur;
      }
    } else if (recordedSleepMins > 0) {
      final h = recordedSleepMins ~/ 60;
      final m = recordedSleepMins % 60;
      totalSleep = h > 0 ? '$h hrs. $m mins.' : '$m mins.';

      final wakeTime = DateTime(normalized.year, normalized.month, normalized.day, 7, 0);
      final sleepStart = wakeTime.subtract(Duration(minutes: recordedSleepMins));
      final startFmt = DateFormat('hh:mm a').format(sleepStart).toLowerCase();
      final endFmt = DateFormat('hh:mm a').format(wakeTime).toLowerCase();
      sleepWindow = '$startFmt - $endFmt';

      sleepIntervals = SleepIntervalGenerator.generate(
        totalMinutes: recordedSleepMins,
        wakeTime: wakeTime,
        deepMinutes: summary?.deepSleepMinutes,
      );
    }

    // 4. Heart Rate Metrics
    int currentHr = 0;
    if (hrSamples.isNotEmpty) {
      currentHr = hrSamples.last.bpm;
    } else if (summary?.avgHeartRate != null && summary!.avgHeartRate! > 0) {
      currentHr = summary.avgHeartRate!;
    } else if (summary?.restingHeartRate != null && summary!.restingHeartRate! > 0) {
      currentHr = summary.restingHeartRate!;
    } else if (summary?.minHeartRate != null && summary!.minHeartRate! > 0) {
      currentHr = summary.minHeartRate!;
    }

    final int restingHr = summary?.restingHeartRate ?? 0;

    // 5. Stress metrics
    int stressScore = 0;
    List<double> stressTimeline = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    if (stresses.isNotEmpty) {
      stressScore = stresses.last.valueNumeric?.round() ?? 0;
      stressTimeline = stresses
          .take(7)
          .map((s) => (s.valueNumeric ?? 0.0).clamp(0.0, 100.0))
          .toList();
      while (stressTimeline.length < 7) {
        stressTimeline.insert(0, 0.0);
      }
    }

    String stressStatus = '--';
    if (stressScore > 0) {
      if (stressScore <= 25) {
        stressStatus = 'Low';
      } else if (stressScore <= 50) {
        stressStatus = 'Normal';
      } else if (stressScore <= 75) {
        stressStatus = 'Medium';
      } else {
        stressStatus = 'High';
      }
    }

    // 6. HRV, SpO2, BP, Temp
    final int hrvMs = hrvs.isNotEmpty ? (hrvs.last.valueNumeric?.round() ?? 0) : 0;
    final int bloodOxygen = summary?.avgSpo2?.round() ?? 0;
    final double breathingRate = hrvMs > 0 ? (12.0 + (hrvMs % 6)).clamp(12.0, 20.0) : 0.0;

    String bpStr = '--';
    bool bpUp = false;
    if (bps.isNotEmpty) {
      final sbp = bps.last.valueNumeric?.round() ?? 0;
      final dbp = bps.last.secondaryNumeric?.round() ?? 0;
      if (sbp > 0 && dbp > 0) {
        bpStr = '$sbp / $dbp';
        bpUp = sbp > 120;
      }
    }

    double tempDiff = 0.0;
    bool tempDown = false;
    if (temps.isNotEmpty) {
      final t = temps.last.valueNumeric ?? 36.5;
      tempDiff = double.parse((t - 36.5).abs().toStringAsFixed(1));
      tempDown = t < 36.5;
    }

    // 7. Weekly Context for Sparklines surrounding this date
    final monday = normalized.subtract(Duration(days: normalized.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final mondayStr = DateFormat('yyyy-MM-dd').format(monday);
    final sundayStr = DateFormat('yyyy-MM-dd').format(sunday);
    final weekSummaries = await _db.healthDataDao.getWeeklySummaries(userId, mondayStr, sundayStr);

    List<double> weeklyHr = List.filled(7, 0.0);
    List<double> weeklyResting = List.filled(7, 0.0);
    List<double> weeklyOxy = List.filled(7, 0.0);
    List<double> weeklyHrv = List.filled(7, 0.0);
    List<double> weeklyBreathing = List.filled(7, 0.0);

    for (final item in weekSummaries) {
      final pDate = DateTime.tryParse(item.date);
      if (pDate != null) {
        final idx = (pDate.weekday - 1).clamp(0, 6);
        if (item.avgHeartRate != null && item.avgHeartRate! > 0) {
          weeklyHr[idx] = item.avgHeartRate!.toDouble();
        } else if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
          weeklyHr[idx] = item.restingHeartRate!.toDouble();
        }
        if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
          weeklyResting[idx] = item.restingHeartRate!.toDouble();
        }
        if (item.avgSpo2 != null && item.avgSpo2! > 0) {
          weeklyOxy[idx] = item.avgSpo2!;
        }
      }
    }

    return VitalsModel(
      totalSleep: totalSleep,
      sleepWindow: sleepWindow,
      sleepIntervals: sleepIntervals,
      currentHeartRate: currentHr,
      weeklyHeartRate: weeklyHr,
      stressScore: stressScore,
      stressStatus: stressStatus,
      stressTimeline: stressTimeline,
      hrvMs: hrvMs,
      weeklyHrv: weeklyHrv,
      restingHr: restingHr,
      weeklyRestingHr: weeklyResting,
      bloodOxygen: bloodOxygen,
      weeklyOxygen: weeklyOxy,
      breathingRate: breathingRate,
      weeklyBreathing: weeklyBreathing,
      bloodPressure: bpStr,
      isBloodPressureUp: bpUp,
      skinTempDiff: tempDiff,
      isSkinTempDown: tempDown,
    );
  }

  /// Generates aggregate vitals for a full week (Monday through Sunday) from SQLite.
  Future<VitalsModel> getWeeklyVitalsRollup(DateTime anchorDate) async {
    final monday = anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final mondayStr = DateFormat('yyyy-MM-dd').format(monday);
    final sundayStr = DateFormat('yyyy-MM-dd').format(sunday);
    final userId = await _secureStorage.getActiveUserId();

    final summaries = await _db.healthDataDao.getWeeklySummaries(userId, mondayStr, sundayStr);

    List<double> weeklyHr = List.filled(7, 0.0);
    List<double> weeklyResting = List.filled(7, 0.0);
    List<double> weeklyOxy = List.filled(7, 0.0);
    int totalSleepMins = 0;
    int sleepDays = 0;
    int hrSum = 0;
    int hrCount = 0;
    int restSum = 0;
    int restCount = 0;
    double oxySum = 0.0;
    int oxyCount = 0;

    for (final item in summaries) {
      final pDate = DateTime.tryParse(item.date);
      if (pDate != null) {
        final idx = (pDate.weekday - 1).clamp(0, 6);
        if (item.avgHeartRate != null && item.avgHeartRate! > 0) {
          weeklyHr[idx] = item.avgHeartRate!.toDouble();
          hrSum += item.avgHeartRate!;
          hrCount++;
        }
        if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
          weeklyResting[idx] = item.restingHeartRate!.toDouble();
          restSum += item.restingHeartRate!;
          restCount++;
        }
        if (item.avgSpo2 != null && item.avgSpo2! > 0) {
          weeklyOxy[idx] = item.avgSpo2!;
          oxySum += item.avgSpo2!;
          oxyCount++;
        }
        if (item.sleepDurationMinutes > 0) {
          totalSleepMins += item.sleepDurationMinutes;
          sleepDays++;
        }
      }
    }

    final avgSleepMins = sleepDays > 0 ? (totalSleepMins ~/ sleepDays) : 0;
    final totalSleep = avgSleepMins > 0 ? '${avgSleepMins ~/ 60} hrs. ${avgSleepMins % 60} mins. avg' : '--';
    final avgHr = hrCount > 0 ? (hrSum ~/ hrCount) : 0;
    final avgRest = restCount > 0 ? (restSum ~/ restCount) : 0;
    final avgOxy = oxyCount > 0 ? (oxySum / oxyCount).round() : 0;

    return VitalsModel(
      totalSleep: totalSleep,
      sleepWindow: sleepDays > 0 ? '$sleepDays / 7 days recorded' : 'No sleep recorded',
      sleepIntervals: avgSleepMins > 0
          ? SleepIntervalGenerator.generate(
              totalMinutes: avgSleepMins,
              wakeTime: DateTime(anchorDate.year, anchorDate.month, anchorDate.day, 7, 0),
            )
          : const [],
      currentHeartRate: avgHr,
      weeklyHeartRate: weeklyHr,
      stressScore: 0,
      stressStatus: '--',
      stressTimeline: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      hrvMs: 0,
      weeklyHrv: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      restingHr: avgRest,
      weeklyRestingHr: weeklyResting,
      bloodOxygen: avgOxy,
      weeklyOxygen: weeklyOxy,
      breathingRate: 0.0,
      weeklyBreathing: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      bloodPressure: '--',
      isBloodPressureUp: false,
      skinTempDiff: 0.0,
      isSkinTempDown: false,
    );
  }

  /// Generates aggregate vitals for a calendar month from SQLite.
  Future<VitalsModel> getMonthlyVitalsRollup(DateTime anchorDate) async {
    final firstDay = DateTime(anchorDate.year, anchorDate.month, 1);
    final lastDay = DateTime(anchorDate.year, anchorDate.month + 1, 0);
    final firstDayStr = DateFormat('yyyy-MM-dd').format(firstDay);
    final lastDayStr = DateFormat('yyyy-MM-dd').format(lastDay);
    final userId = await _secureStorage.getActiveUserId();

    final summaries = await _db.healthDataDao.getWeeklySummaries(userId, firstDayStr, lastDayStr);

    int totalSleepMins = 0;
    int sleepDays = 0;
    int hrSum = 0;
    int hrCount = 0;
    int restSum = 0;
    int restCount = 0;
    double oxySum = 0.0;
    int oxyCount = 0;

    final List<double> monthlyWeekdayHr = List.filled(7, 0.0);
    final List<int> weekdayHrSum = List.filled(7, 0);
    final List<int> weekdayHrCount = List.filled(7, 0);

    final List<double> monthlyWeekdayRest = List.filled(7, 0.0);
    final List<int> weekdayRestSum = List.filled(7, 0);
    final List<int> weekdayRestCount = List.filled(7, 0);

    for (final item in summaries) {
      final pDate = DateTime.tryParse(item.date);
      final idx = pDate != null ? (pDate.weekday - 1).clamp(0, 6) : 0;

      if (item.avgHeartRate != null && item.avgHeartRate! > 0) {
        weekdayHrSum[idx] += item.avgHeartRate!;
        weekdayHrCount[idx]++;
        hrSum += item.avgHeartRate!;
        hrCount++;
      } else if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
        weekdayHrSum[idx] += item.restingHeartRate!;
        weekdayHrCount[idx]++;
        hrSum += item.restingHeartRate!;
        hrCount++;
      }
      if (item.restingHeartRate != null && item.restingHeartRate! > 0) {
        weekdayRestSum[idx] += item.restingHeartRate!;
        weekdayRestCount[idx]++;
        restSum += item.restingHeartRate!;
        restCount++;
      }
      if (item.avgSpo2 != null && item.avgSpo2! > 0) {
        oxySum += item.avgSpo2!;
        oxyCount++;
      }
      if (item.sleepDurationMinutes > 0) {
        totalSleepMins += item.sleepDurationMinutes;
        sleepDays++;
      }
    }

    for (int i = 0; i < 7; i++) {
      if (weekdayHrCount[i] > 0) {
        monthlyWeekdayHr[i] = (weekdayHrSum[i] / weekdayHrCount[i]).roundToDouble();
      }
      if (weekdayRestCount[i] > 0) {
        monthlyWeekdayRest[i] = (weekdayRestSum[i] / weekdayRestCount[i]).roundToDouble();
      }
    }

    final avgSleepMins = sleepDays > 0 ? (totalSleepMins ~/ sleepDays) : 0;
    final totalSleep = avgSleepMins > 0 ? '${avgSleepMins ~/ 60} hrs. ${avgSleepMins % 60} mins. avg' : '--';
    final avgHr = hrCount > 0 ? (hrSum ~/ hrCount) : 0;
    final avgRest = restCount > 0 ? (restSum ~/ restCount) : 0;
    final avgOxy = oxyCount > 0 ? (oxySum / oxyCount).round() : 0;

    return VitalsModel(
      totalSleep: totalSleep,
      sleepWindow: sleepDays > 0 ? '$sleepDays days recorded in ${DateFormat('MMMM').format(anchorDate)}' : 'No sleep recorded',
      sleepIntervals: avgSleepMins > 0
          ? SleepIntervalGenerator.generate(
              totalMinutes: avgSleepMins,
              wakeTime: DateTime(anchorDate.year, anchorDate.month, anchorDate.day, 7, 0),
            )
          : const [],
      currentHeartRate: avgHr,
      weeklyHeartRate: monthlyWeekdayHr,
      stressScore: 0,
      stressStatus: '--',
      stressTimeline: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      hrvMs: 0,
      weeklyHrv: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      restingHr: avgRest,
      weeklyRestingHr: monthlyWeekdayRest,
      bloodOxygen: avgOxy,
      weeklyOxygen: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      breathingRate: 0.0,
      weeklyBreathing: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      bloodPressure: '--',
      isBloodPressureUp: false,
      skinTempDiff: 0.0,
      isSkinTempDown: false,
    );
  }

  /// Computes 100% dynamic Min / Avg / Max and 4-zone distribution from SQLite data.
  Future<VitalsPeriodStats> getHistoricalPeriodStats({
    required VitalsTimePeriod period,
    required DateTime anchorDate,
    BandRepository? bandRepo,
  }) async {
    final normalized = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
    final userId = await _secureStorage.getActiveUserId();
    final bondedMac = await _secureStorage.getBondedDeviceMac();
    final devId = bondedMac ?? 'default_band';

    switch (period) {
      case VitalsTimePeriod.day:
        final dateStr = DateFormat('yyyy-MM-dd').format(normalized);
        final samples = await _db.healthDataDao.getHeartRateSamples(
          devId,
          DateTime(normalized.year, normalized.month, normalized.day, 0, 0, 0),
          DateTime(normalized.year, normalized.month, normalized.day, 23, 59, 59),
        );

        if (samples.isNotEmpty) {
          final bpmList = samples.map((s) => s.bpm.toDouble()).toList();
          final avg = bpmList.reduce((a, b) => a + b) / bpmList.length;
          final min = bpmList.reduce(math.min);
          final max = bpmList.reduce(math.max);
          final dist = VitalsZoneDistribution.compute(bpmList);
          return VitalsPeriodStats.fromRealData(
            period: period,
            anchorDate: normalized,
            average: avg,
            minimum: min,
            maximum: max,
            distribution: dist,
          );
        }

        var summary = await _db.healthDataDao.getDailySummary(userId, dateStr);
        if (summary == null) {
          final bondedMac = await _secureStorage.getBondedDeviceMac();
          final devId = bondedMac ?? 'default_band';
          final hrSamples = await _db.healthDataDao.getHeartRateSamples(
            devId,
            DateTime(normalized.year, normalized.month, normalized.day, 0, 0, 0),
            DateTime(normalized.year, normalized.month, normalized.day, 23, 59, 59),
          );
          if (hrSamples.isNotEmpty) {
            final validSamples = hrSamples.where((s) => s.bpm > 0).map((s) => s.bpm).toList();
            if (validSamples.isNotEmpty) {
              final avg = validSamples.reduce((a, b) => a + b) / validSamples.length;
              final min = validSamples.reduce((a, b) => a < b ? a : b).toDouble();
              final max = validSamples.reduce((a, b) => a > b ? a : b).toDouble();
              final dist = VitalsZoneDistribution.compute(validSamples.map((e) => e.toDouble()).toList());
              return VitalsPeriodStats.fromRealData(
                period: period,
                anchorDate: normalized,
                average: avg,
                minimum: min,
                maximum: max,
                distribution: dist,
              );
            }
          }
        }

        final int effectiveHr;
        if (summary != null) {
          if (summary.avgHeartRate != null && summary.avgHeartRate! > 0) {
            effectiveHr = summary.avgHeartRate!;
          } else if (summary.restingHeartRate != null && summary.restingHeartRate! > 0) {
            effectiveHr = summary.restingHeartRate!;
          } else if (summary.minHeartRate != null && summary.minHeartRate! > 0) {
            effectiveHr = summary.minHeartRate!;
          } else {
            effectiveHr = 0;
          }
        } else {
          effectiveHr = 0;
        }

        if (effectiveHr > 0) {
          final avg = effectiveHr.toDouble();
          final min = (summary?.minHeartRate ?? summary?.restingHeartRate ?? (avg - 12.0).round()).toDouble().clamp(30.0, avg);
          final max = (summary?.maxHeartRate ?? (avg + 25.0).round()).toDouble().clamp(avg, 220.0);
          final dist = VitalsZoneDistribution.compute([min, avg, max]);
          return VitalsPeriodStats.fromRealData(
            period: period,
            anchorDate: normalized,
            average: avg,
            minimum: min,
            maximum: max,
            distribution: dist,
          );
        }

        return VitalsPeriodStats.fromRealData(
          period: period,
          anchorDate: normalized,
          average: 0.0,
          minimum: 0.0,
          maximum: 0.0,
          distribution: VitalsZoneDistribution.empty,
        );

      case VitalsTimePeriod.week:
        final monday = normalized.subtract(Duration(days: normalized.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final mondayStr = DateFormat('yyyy-MM-dd').format(monday);
        final sundayStr = DateFormat('yyyy-MM-dd').format(sunday);

        final summaries = await _db.healthDataDao.getWeeklySummaries(userId, mondayStr, sundayStr);
        final validDays = summaries.where((s) => (s.avgHeartRate != null && s.avgHeartRate! > 0) || (s.restingHeartRate != null && s.restingHeartRate! > 0)).toList();

        if (validDays.isNotEmpty) {
          final avgs = validDays.map((s) => ((s.avgHeartRate != null && s.avgHeartRate! > 0) ? s.avgHeartRate! : s.restingHeartRate!).toDouble()).toList();
          final mins = validDays.map((s) => (s.minHeartRate ?? s.restingHeartRate ?? (s.avgHeartRate != null && s.avgHeartRate! > 0 ? s.avgHeartRate! - 10 : 50)).toDouble()).toList();
          final maxs = validDays.map((s) => (s.maxHeartRate ?? (s.avgHeartRate != null && s.avgHeartRate! > 0 ? s.avgHeartRate! + 20 : 85)).toDouble()).toList();

          final avg = avgs.reduce((a, b) => a + b) / avgs.length;
          final min = mins.reduce(math.min);
          final max = maxs.reduce(math.max);
          final dist = VitalsZoneDistribution.compute(avgs);

          return VitalsPeriodStats.fromRealData(
            period: period,
            anchorDate: normalized,
            average: avg,
            minimum: min,
            maximum: max,
            distribution: dist,
          );
        }

        return VitalsPeriodStats.fromRealData(
          period: period,
          anchorDate: normalized,
          average: 0.0,
          minimum: 0.0,
          maximum: 0.0,
          distribution: VitalsZoneDistribution.empty,
        );

      case VitalsTimePeriod.month:
        final firstDay = DateTime(normalized.year, normalized.month, 1);
        final lastDay = DateTime(normalized.year, normalized.month + 1, 0);
        final firstDayStr = DateFormat('yyyy-MM-dd').format(firstDay);
        final lastDayStr = DateFormat('yyyy-MM-dd').format(lastDay);

        final summaries = await _db.healthDataDao.getWeeklySummaries(userId, firstDayStr, lastDayStr);
        final validDays = summaries.where((s) => (s.avgHeartRate != null && s.avgHeartRate! > 0) || (s.restingHeartRate != null && s.restingHeartRate! > 0)).toList();

        if (validDays.isNotEmpty) {
          final avgs = validDays.map((s) => ((s.avgHeartRate != null && s.avgHeartRate! > 0) ? s.avgHeartRate! : s.restingHeartRate!).toDouble()).toList();
          final mins = validDays.map((s) => (s.minHeartRate ?? s.restingHeartRate ?? (s.avgHeartRate != null && s.avgHeartRate! > 0 ? s.avgHeartRate! - 10 : 50)).toDouble()).toList();
          final maxs = validDays.map((s) => (s.maxHeartRate ?? (s.avgHeartRate != null && s.avgHeartRate! > 0 ? s.avgHeartRate! + 20 : 85)).toDouble()).toList();

          final avg = avgs.reduce((a, b) => a + b) / avgs.length;
          final min = mins.reduce(math.min);
          final max = maxs.reduce(math.max);
          final dist = VitalsZoneDistribution.compute(avgs);

          return VitalsPeriodStats.fromRealData(
            period: period,
            anchorDate: normalized,
            average: avg,
            minimum: min,
            maximum: max,
            distribution: dist,
          );
        }

        return VitalsPeriodStats.fromRealData(
          period: period,
          anchorDate: normalized,
          average: 0.0,
          minimum: 0.0,
          maximum: 0.0,
          distribution: VitalsZoneDistribution.empty,
        );
    }
  }
}
