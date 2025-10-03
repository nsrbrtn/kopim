import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

class RecurringRuleExecutionDao {
  RecurringRuleExecutionDao(this._database);

  final db.AppDatabase _database;

  Future<db.RecurringRuleExecutionRow?> findById(String occurrenceId) {
    final SimpleSelectStatement<
      db.$RecurringRuleExecutionsTable,
      db.RecurringRuleExecutionRow
    >
    query = _database.select(_database.recurringRuleExecutions)
      ..where(
        (db.$RecurringRuleExecutionsTable tbl) =>
            tbl.occurrenceId.equals(occurrenceId),
      );
    return query.getSingleOrNull();
  }

  Future<void> insertExecution({
    required String occurrenceId,
    required String ruleId,
    required DateTime localDate,
    required DateTime appliedAt,
    String? transactionId,
  }) {
    return _database
        .into(_database.recurringRuleExecutions)
        .insertOnConflictUpdate(
          db.RecurringRuleExecutionsCompanion(
            occurrenceId: Value<String>(occurrenceId),
            ruleId: Value<String>(ruleId),
            localDate: Value<DateTime>(localDate.toUtc()),
            appliedAt: Value<DateTime>(appliedAt.toUtc()),
            transactionId: Value<String?>(transactionId),
            createdAt: Value<DateTime>(appliedAt.toUtc()),
            updatedAt: Value<DateTime>(appliedAt.toUtc()),
          ),
        );
  }
}
