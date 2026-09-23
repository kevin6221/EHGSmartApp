import 'package:drift/drift.dart';
import '../tables/health_tables.dart';
import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> enqueue(String endpoint, String payload) {
    return into(syncQueueTable).insert(
      SyncQueueTableCompanion(
        endpoint: Value(endpoint),
        payload: Value(payload),
        status: const Value('pending'),
      ),
    );
  }

  Future<List<SyncQueueItem>> getPendingItems({int limit = 50}) {
    return (select(syncQueueTable)
          ..where((tbl) => tbl.status.equals('pending') | tbl.status.equals('failed'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<int> markStatus(int id, String status) {
    return (update(syncQueueTable)..where((tbl) => tbl.id.equals(id))).write(
      SyncQueueTableCompanion(
        status: Value(status),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> incrementRetry(int id) {
    return customUpdate(
      'UPDATE sync_queue_table SET retry_count = retry_count + 1, last_attempt_at = ? WHERE id = ?',
      variables: [Variable.withDateTime(DateTime.now()), Variable.withInt(id)],
      updates: {syncQueueTable},
    );
  }

  Future<int> deleteCompleted() {
    return (delete(syncQueueTable)..where((tbl) => tbl.status.equals('completed'))).go();
  }
}
