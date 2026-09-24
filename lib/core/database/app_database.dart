import 'package:drift/drift.dart';
import 'tables/health_tables.dart';
import 'daos/health_dao.dart';
import 'daos/device_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'connection/native.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    DailyHealthSummariesTable,
    HeartRateSamplesTable,
    SleepSessionsTable,
    SleepPhasesTable,
    VitalsRecordsTable,
    BandDevicesTable,
    SyncQueueTable,
    WorkoutSessionsTable,
    UserRoutinesTable,
  ],
  daos: [
    HealthDataDao,
    DeviceDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Non-destructive progressive migrations preserving user health data
      for (final table in allTables) {
        try {
          await m.createTable(table);
        } catch (_) {
          // Table already exists, preserve existing schema and data
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_vitals_dev_type_time ON vitals_records_table (device_id, vital_type, timestamp DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_hr_dev_time ON heart_rate_samples_table (device_id, timestamp DESC);',
      );
    },
  );
}
