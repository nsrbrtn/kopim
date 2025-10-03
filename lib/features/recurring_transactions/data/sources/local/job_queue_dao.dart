import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

class JobQueueDao {
  JobQueueDao(this._database);

  final db.AppDatabase _database;

  Future<int> enqueue({
    required String type,
    required String payload,
    required DateTime runAt,
  }) {
    return _database
        .into(_database.jobQueue)
        .insert(
          db.JobQueueCompanion.insert(
            type: type,
            payload: payload,
            runAt: runAt.toUtc(),
          ),
        );
  }

  Stream<List<db.JobQueueRow>> watchPending() {
    final SimpleSelectStatement<db.$JobQueueTable, db.JobQueueRow> query =
        _database.select(_database.jobQueue)
          ..orderBy(<OrderingTerm Function(db.$JobQueueTable)>[
            (db.$JobQueueTable tbl) => OrderingTerm(expression: tbl.runAt),
          ]);
    return query.watch();
  }

  Future<void> markAttempt(int jobId, {String? error}) async {
    final db.JobQueueRow? row =
        await (_database.select(_database.jobQueue)
              ..where((db.$JobQueueTable tbl) => tbl.id.equals(jobId)))
            .getSingleOrNull();
    final int attempts = (row?.attempts ?? 0) + 1;
    await (_database.update(
      _database.jobQueue,
    )..where((db.$JobQueueTable tbl) => tbl.id.equals(jobId))).write(
      db.JobQueueCompanion(
        attempts: Value<int>(attempts),
        lastError: Value<String?>(error),
      ),
    );
  }
}
