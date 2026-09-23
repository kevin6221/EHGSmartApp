// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_dao.dart';

// ignore_for_file: type=lint
mixin _$HealthDataDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyHealthSummariesTableTable get dailyHealthSummariesTable =>
      attachedDatabase.dailyHealthSummariesTable;
  $HeartRateSamplesTableTable get heartRateSamplesTable =>
      attachedDatabase.heartRateSamplesTable;
  $SleepSessionsTableTable get sleepSessionsTable =>
      attachedDatabase.sleepSessionsTable;
  $SleepPhasesTableTable get sleepPhasesTable =>
      attachedDatabase.sleepPhasesTable;
  $VitalsRecordsTableTable get vitalsRecordsTable =>
      attachedDatabase.vitalsRecordsTable;
  HealthDataDaoManager get managers => HealthDataDaoManager(this);
}

class HealthDataDaoManager {
  final _$HealthDataDaoMixin _db;
  HealthDataDaoManager(this._db);
  $$DailyHealthSummariesTableTableTableManager get dailyHealthSummariesTable =>
      $$DailyHealthSummariesTableTableTableManager(
        _db.attachedDatabase,
        _db.dailyHealthSummariesTable,
      );
  $$HeartRateSamplesTableTableTableManager get heartRateSamplesTable =>
      $$HeartRateSamplesTableTableTableManager(
        _db.attachedDatabase,
        _db.heartRateSamplesTable,
      );
  $$SleepSessionsTableTableTableManager get sleepSessionsTable =>
      $$SleepSessionsTableTableTableManager(
        _db.attachedDatabase,
        _db.sleepSessionsTable,
      );
  $$SleepPhasesTableTableTableManager get sleepPhasesTable =>
      $$SleepPhasesTableTableTableManager(
        _db.attachedDatabase,
        _db.sleepPhasesTable,
      );
  $$VitalsRecordsTableTableTableManager get vitalsRecordsTable =>
      $$VitalsRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.vitalsRecordsTable,
      );
}
