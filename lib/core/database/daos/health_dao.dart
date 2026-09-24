import 'package:drift/drift.dart';
import '../tables/health_tables.dart';
import '../app_database.dart';

part 'health_dao.g.dart';

@DriftAccessor(tables: [
  DailyHealthSummariesTable,
  HeartRateSamplesTable,
  SleepSessionsTable,
  SleepPhasesTable,
  VitalsRecordsTable,
  WorkoutSessionsTable,
  UserRoutinesTable,
])
class HealthDataDao extends DatabaseAccessor<AppDatabase> with _$HealthDataDaoMixin {
  HealthDataDao(super.db);

  // Daily Summaries
  Future<int> upsertDailySummary(DailyHealthSummariesTableCompanion summary) async {
    final userId = summary.userId.value;
    final date = summary.date.value;
    final existing = await getDailySummary(userId, date);

    if (existing == null) {
      return into(dailyHealthSummariesTable).insert(summary, mode: InsertMode.insertOrReplace);
    }

    final merged = existing.toCompanion(true).copyWith(
      deviceId: summary.deviceId.present ? summary.deviceId : Value(existing.deviceId),
      steps: summary.steps.present ? summary.steps : Value(existing.steps),
      caloriesBurned: summary.caloriesBurned.present ? summary.caloriesBurned : Value(existing.caloriesBurned),
      distanceMeters: summary.distanceMeters.present ? summary.distanceMeters : Value(existing.distanceMeters),
      activeMinutes: summary.activeMinutes.present ? summary.activeMinutes : Value(existing.activeMinutes),
      restingHeartRate: summary.restingHeartRate.present ? summary.restingHeartRate : Value(existing.restingHeartRate),
      avgHeartRate: summary.avgHeartRate.present ? summary.avgHeartRate : Value(existing.avgHeartRate),
      maxHeartRate: summary.maxHeartRate.present ? summary.maxHeartRate : Value(existing.maxHeartRate),
      minHeartRate: summary.minHeartRate.present ? summary.minHeartRate : Value(existing.minHeartRate),
      avgSpo2: summary.avgSpo2.present ? summary.avgSpo2 : Value(existing.avgSpo2),
      sleepDurationMinutes: summary.sleepDurationMinutes.present ? summary.sleepDurationMinutes : Value(existing.sleepDurationMinutes),
      deepSleepMinutes: summary.deepSleepMinutes.present ? summary.deepSleepMinutes : Value(existing.deepSleepMinutes),
      lightSleepMinutes: summary.lightSleepMinutes.present ? summary.lightSleepMinutes : Value(existing.lightSleepMinutes),
      remSleepMinutes: summary.remSleepMinutes.present ? summary.remSleepMinutes : Value(existing.remSleepMinutes),
      awakeMinutes: summary.awakeMinutes.present ? summary.awakeMinutes : Value(existing.awakeMinutes),
      sleepScore: summary.sleepScore.present ? summary.sleepScore : Value(existing.sleepScore),
      wellnessScore: summary.wellnessScore.present ? summary.wellnessScore : Value(existing.wellnessScore),
      moveScore: summary.moveScore.present ? summary.moveScore : Value(existing.moveScore),
      recoverScore: summary.recoverScore.present ? summary.recoverScore : Value(existing.recoverScore),
      readinessScore: summary.readinessScore.present ? summary.readinessScore : Value(existing.readinessScore),
      lastSyncTimestamp: summary.lastSyncTimestamp.present ? summary.lastSyncTimestamp : Value(existing.lastSyncTimestamp),
    );

    return (update(dailyHealthSummariesTable)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.date.equals(date)))
        .write(merged);
  }

  Future<DailyHealthSummary?> getDailySummary(String userId, String date) {
    return (select(dailyHealthSummariesTable)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.date.equals(date)))
        .getSingleOrNull();
  }

  Stream<DailyHealthSummary?> watchDailySummary(String userId, String date) {
    return (select(dailyHealthSummariesTable)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.date.equals(date)))
        .watchSingleOrNull();
  }

  Stream<DailyHealthSummary?> watchLatestDailySummary(String userId) {
    return (select(dailyHealthSummariesTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<DailyHealthSummary>> getWeeklySummaries(String userId, String startDate, String endDate) {
    return (select(dailyHealthSummariesTable)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.date.isBiggerOrEqualValue(startDate) &
              tbl.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<DailyHealthSummary?> getPreviousDailySummary(String userId, String beforeDate) {
    return (select(dailyHealthSummariesTable)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.date.isSmallerThanValue(beforeDate) &
              tbl.wellnessScore.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  // Heart Rate Samples
  Future<void> insertHeartRateSamples(List<HeartRateSamplesTableCompanion> samples) async {
    await batch((batch) {
      batch.insertAll(heartRateSamplesTable, samples, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<HeartRateSample>> getHeartRateSamples(String deviceId, DateTime start, DateTime end) {
    return (select(heartRateSamplesTable)
          ..where((tbl) =>
              tbl.deviceId.equals(deviceId) &
              tbl.timestamp.isBiggerOrEqualValue(start) &
              tbl.timestamp.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Stream<List<HeartRateSample>> watchHeartRateSamples(String deviceId, DateTime start, DateTime end) {
    return (select(heartRateSamplesTable)
          ..where((tbl) =>
              tbl.deviceId.equals(deviceId) &
              tbl.timestamp.isBiggerOrEqualValue(start) &
              tbl.timestamp.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .watch();
  }

  // Sleep
  Future<int> insertSleepSessionWithPhases(
    SleepSessionsTableCompanion session,
    List<SleepPhasesTableCompanion> phases,
  ) {
    return transaction(() async {
      final sessionId = await into(sleepSessionsTable).insert(session);
      for (final phase in phases) {
        await into(sleepPhasesTable).insert(
          phase.copyWith(sessionId: Value(sessionId)),
        );
      }
      return sessionId;
    });
  }

  Future<SleepSession?> getLatestSleepSession(String deviceId, String date) {
    return (select(sleepSessionsTable)
          ..where((tbl) => tbl.deviceId.equals(deviceId) & tbl.date.equals(date))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<SleepPhase>> getPhasesForSession(int sessionId) {
    return (select(sleepPhasesTable)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  // Vitals Records
  Future<int> insertVital(VitalsRecordsTableCompanion vital) {
    return into(vitalsRecordsTable).insert(vital);
  }

  Future<void> insertVitalsBatch(List<VitalsRecordsTableCompanion> vitals) async {
    await batch((batch) {
      batch.insertAll(vitalsRecordsTable, vitals);
    });
  }

  Future<VitalsRecord?> getLatestVital(String? deviceId, String vitalType) {
    var query = select(vitalsRecordsTable);
    if (deviceId != null && deviceId.isNotEmpty && deviceId != 'default_band') {
      query.where((tbl) => tbl.deviceId.equals(deviceId) & tbl.vitalType.equals(vitalType));
    } else {
      query.where((tbl) => tbl.vitalType.equals(vitalType));
    }
    return (query
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<VitalsRecord?> watchLatestVital(String deviceId, String vitalType) {
    return (select(vitalsRecordsTable)
          ..where((tbl) => tbl.deviceId.equals(deviceId) & tbl.vitalType.equals(vitalType))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<VitalsRecord>> getVitalsHistory(
    String deviceId,
    String vitalType,
    DateTime start,
    DateTime end,
  ) {
    return (select(vitalsRecordsTable)
          ..where((tbl) =>
              tbl.deviceId.equals(deviceId) &
              tbl.vitalType.equals(vitalType) &
              tbl.timestamp.isBiggerOrEqualValue(start) &
              tbl.timestamp.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  /// Atomically deletes all local health records across all health entities.
  Future<void> deleteAllHealthData() {
    return transaction(() async {
      await delete(dailyHealthSummariesTable).go();
      await delete(heartRateSamplesTable).go();
      await delete(sleepPhasesTable).go();
      await delete(sleepSessionsTable).go();
      await delete(vitalsRecordsTable).go();
      await delete(workoutSessionsTable).go();
      await delete(userRoutinesTable).go();
    });
  }

  /// Retrieves all historical daily summaries for data export.
  Future<List<DailyHealthSummary>> getAllDailySummaries([String? userId]) {
    var query = select(dailyHealthSummariesTable);
    if (userId != null && userId.isNotEmpty) {
      query.where((tbl) => tbl.userId.equals(userId));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  }

  // Workout Sessions
  Future<int> insertWorkoutSession(WorkoutSessionsTableCompanion session) {
    return into(workoutSessionsTable).insert(session);
  }

  Future<WorkoutSession?> getLatestWorkoutSession([String? userId]) {
    var query = select(workoutSessionsTable);
    if (userId != null && userId.isNotEmpty) {
      query.where((tbl) => tbl.userId.equals(userId));
    }
    return (query
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<WorkoutSession>> getRecentWorkoutSessions({String? userId, int limit = 10}) {
    var query = select(workoutSessionsTable);
    if (userId != null && userId.isNotEmpty) {
      query.where((tbl) => tbl.userId.equals(userId));
    }
    return (query
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .get();
  }

  Stream<List<WorkoutSession>> watchRecentWorkoutSessions({String? userId, int limit = 10}) {
    var query = select(workoutSessionsTable);
    if (userId != null && userId.isNotEmpty) {
      query.where((tbl) => tbl.userId.equals(userId));
    }
    return (query
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .watch();
  }

  // User Routines
  Future<int> insertUserRoutine(UserRoutinesTableCompanion routine) {
    return into(userRoutinesTable).insert(routine);
  }

  Future<List<UserRoutine>> getUserRoutines({String? userId}) {
    var query = select(userRoutinesTable)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    if (userId != null && userId.isNotEmpty) {
      query.where((tbl) => tbl.userId.equals(userId));
    }
    return query.get();
  }

  Future<UserRoutine?> getLatestActiveUserRoutine({String? userId}) {
    var query = select(userRoutinesTable)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(1);
    if (userId != null && userId.isNotEmpty) {
      query.where((tbl) => tbl.userId.equals(userId));
    }
    return query.getSingleOrNull();
  }

  Future<int> deleteUserRoutine(int id) {
    return (delete(userRoutinesTable)..where((tbl) => tbl.id.equals(id))).go();
  }
}

