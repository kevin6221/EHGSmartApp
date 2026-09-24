import 'package:drift/drift.dart';

@DataClassName('DailyHealthSummary')
class DailyHealthSummariesTable extends Table {
  TextColumn get userId => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get deviceId => text()();
  IntColumn get steps => integer().withDefault(const Constant(0))();
  RealColumn get caloriesBurned => real().withDefault(const Constant(0.0))();
  RealColumn get distanceMeters => real().withDefault(const Constant(0.0))();
  IntColumn get activeMinutes => integer().withDefault(const Constant(0))();
  IntColumn get restingHeartRate => integer().nullable()();
  IntColumn get avgHeartRate => integer().nullable()();
  IntColumn get maxHeartRate => integer().nullable()();
  IntColumn get minHeartRate => integer().nullable()();
  RealColumn get avgSpo2 => real().nullable()();
  IntColumn get sleepDurationMinutes => integer().withDefault(const Constant(0))();
  IntColumn get deepSleepMinutes => integer().withDefault(const Constant(0))();
  IntColumn get lightSleepMinutes => integer().withDefault(const Constant(0))();
  IntColumn get remSleepMinutes => integer().withDefault(const Constant(0))();
  IntColumn get awakeMinutes => integer().withDefault(const Constant(0))();
  IntColumn get sleepScore => integer().nullable()();
  IntColumn get wellnessScore => integer().nullable()();
  IntColumn get moveScore => integer().nullable()();
  IntColumn get recoverScore => integer().nullable()();
  IntColumn get readinessScore => integer().nullable()();
  DateTimeColumn get lastSyncTimestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId, date};
}

@DataClassName('HeartRateSample')
class HeartRateSamplesTable extends Table {
  TextColumn get deviceId => text()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get bpm => integer()();
  BoolColumn get isResting => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {deviceId, timestamp};
}

@DataClassName('SleepSession')
class SleepSessionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get totalDurationMinutes => integer()();
  IntColumn get deepMinutes => integer().withDefault(const Constant(0))();
  IntColumn get lightMinutes => integer().withDefault(const Constant(0))();
  IntColumn get remMinutes => integer().withDefault(const Constant(0))();
  IntColumn get awakeMinutes => integer().withDefault(const Constant(0))();
  IntColumn get sleepScore => integer().nullable()();
  TextColumn get date => text()(); // YYYY-MM-DD
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deviceId, date},
  ];
}

@DataClassName('SleepPhase')
class SleepPhasesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(SleepSessionsTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get phaseType => integer()(); // 0: deep, 1: light, 2: rem, 3: awake
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get durationMinutes => integer()();
}

@DataClassName('VitalsRecord')
class VitalsRecordsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  TextColumn get vitalType => text()(); // 'spo2', 'blood_pressure', 'temperature', 'stress', 'hrv'
  RealColumn get valueNumeric => real().nullable()();
  RealColumn get secondaryNumeric => real().nullable()(); // diastolic for BP
  TextColumn get unit => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get rawPayload => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BandDeviceEntry')
class BandDevicesTable extends Table {
  TextColumn get macAddress => text()();
  TextColumn get deviceName => text()();
  TextColumn get modelNumber => text().nullable()();
  TextColumn get firmwareVersion => text().nullable()();
  IntColumn get batteryLevel => integer().withDefault(const Constant(0))();
  BoolColumn get isCharging => boolean().withDefault(const Constant(false))();
  BoolColumn get isBonded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {macAddress};
}

@DataClassName('SyncQueueItem')
class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endpoint => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, in_progress, completed, failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}

@DataClassName('WorkoutSession')
class WorkoutSessionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get title => text()();
  TextColumn get category => text()(); // run, walk, cycling, strength, hit
  IntColumn get durationSeconds => integer()();
  IntColumn get burnedCalories => integer().withDefault(const Constant(0))();
  IntColumn get avgHeartRate => integer().withDefault(const Constant(0))();
  IntColumn get peakHeartRate => integer().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserRoutine')
class UserRoutinesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get routineName => text()();
  IntColumn get durationDays => integer().withDefault(const Constant(14))();
  TextColumn get movementsJson => text().withDefault(const Constant('[]'))();
  TextColumn get wellnessJson => text().withDefault(const Constant('[]'))();
  TextColumn get routineItemsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

