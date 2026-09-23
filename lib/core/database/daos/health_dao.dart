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
}
