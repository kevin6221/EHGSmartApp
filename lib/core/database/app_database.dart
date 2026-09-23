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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
        await m.createTable(table);
      }
    },
  );
}
