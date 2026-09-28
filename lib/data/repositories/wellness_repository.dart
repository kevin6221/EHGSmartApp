import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart' hide SleepPhase;
import '../../core/security/secure_storage_service.dart';
import '../models/band_device_model.dart';
import '../models/journal_entry_model.dart';
import '../models/user_profile_model.dart';
import '../models/vitals_model.dart';
import '../models/wellness_data_model.dart';
import '../models/workout_model.dart';
import '../../core/engine/personalized_baseline_engine.dart';

class WellnessRepository {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final Completer<void> _initCompleter = Completer<void>();
  int _yesterdayWellnessScore = 0;
  List<JournalEntryModel> _journalEntries = [];
  PersonalizedBaselineData _baselineData = const PersonalizedBaselineData();

  List<JournalEntryModel> get journalEntries => List.unmodifiable(_journalEntries);
  PersonalizedBaselineData get baselineData => _baselineData;

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

  Future<void> _loadRecentWorkout() async {
    try {
      final userId = await _secureStorage.getActiveUserId();
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
          selectedCategory: cat,
          title: latest.title,
          recentSessionTitle: latest.title,
          recentSessionDuration: durStr,
          recentPeakHr: latest.peakHeartRate,
          recentAvgHr: latest.avgHeartRate,
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
    List<SleepInterval> dynamicIntervals = _vitalsData.sleepIntervals;
    final now = DateTime.now();
    final DateTime wakeTime = now.hour < 11
        ? now
        : DateTime(now.year, now.month, now.day, 7, 0);
    DateTime sleepStart = wakeTime.subtract(Duration(minutes: vitals.sleepMinutes > 0 ? vitals.sleepMinutes : 420));

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
    }

    // 2. Build sleep window and total sleep string
    String totalSleep = _vitalsData.totalSleep;
    String sleepWindow = _vitalsData.sleepWindow;
    if (vitals.sleepMinutes > 0) {
      final h = vitals.sleepMinutes ~/ 60;
      final m = vitals.sleepMinutes % 60;
      totalSleep = '$h hrs. $m mins.';

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
    // Mode-adapted energy burn and targets:
    // Recover: Rest & active recovery target (320-380 kcal, 25-30 active mins, 30 min goal)
    // Steady: Baseline maintenance workout (520-580 kcal, 45-50 active mins, 60 min goal)
    // Push: High strain / peak exertion (800-880 kcal, 75-85 active mins, 90 min goal)
    final int baseEnergy = _wellnessData.energyBurned > 0
        ? _wellnessData.energyBurned
        : 560;

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
    final int baseReadiness = _wellnessData.readinessScore > 0
        ? _wellnessData.readinessScore
        : 72;

    final int modeReadiness = switch (mode) {
      WellnessMode.recover => (baseReadiness * 0.85).round().clamp(55, 68),
      WellnessMode.steady => baseReadiness.clamp(68, 80),
      WellnessMode.push => (baseReadiness * 1.35).round().clamp(84, 94),
    };

    // Mode-adapted Move and Recover pillar scores for the 4-pillar Wellness Score
    final int baseMove = _wellnessData.moveScore > 0 ? _wellnessData.moveScore : 65;
    final int modeMove = switch (mode) {
      WellnessMode.recover => (baseMove * 0.70).round().clamp(30, 60),
      WellnessMode.steady => baseMove.clamp(60, 78),
      WellnessMode.push => (baseMove * 1.35).round().clamp(80, 96),
    };

    final int baseRecover = _wellnessData.recoverScore > 0 ? _wellnessData.recoverScore : 70;
    final int modeRecover = switch (mode) {
      WellnessMode.recover => (baseRecover * 0.85).round().clamp(55, 70),
      WellnessMode.steady => baseRecover.clamp(70, 84),
      WellnessMode.push => (baseRecover * 1.25).round().clamp(85, 96),
    };

    final int modeWellnessScore = ((modeMove + modeRecover + _wellnessData.mindScore + _wellnessData.fuelScore) / 4).round().clamp(1, 100);

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

  /// Persists a new journal check-in entry with current sleep hours and updates recent list.
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
}
