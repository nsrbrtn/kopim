import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

class GoalContributionDao {
  GoalContributionDao(this._db);

  final db.AppDatabase _db;

  Future<void> insert({
    required String id,
    required String goalId,
    required String transactionId,
    required int amount,
    required DateTime createdAt,
  }) {
    return _db
        .into(_db.goalContributions)
        .insertOnConflictUpdate(
          db.GoalContributionsCompanion(
            id: Value<String>(id),
            goalId: Value<String>(goalId),
            transactionId: Value<String>(transactionId),
            amount: Value<int>(amount),
            createdAt: Value<DateTime>(createdAt),
          ),
        );
  }

  Future<db.GoalContributionRow?> findByTransactionId(String transactionId) {
    final SimpleSelectStatement<
      db.$GoalContributionsTable,
      db.GoalContributionRow
    >
    query = _db.select(_db.goalContributions)
      ..where(
        (db.$GoalContributionsTable tbl) =>
            tbl.transactionId.equals(transactionId),
      );
    return query.getSingleOrNull();
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(
      _db.goalContributions,
    )..where((db.$GoalContributionsTable tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteByTransactionId(String transactionId) async {
    await (_db.delete(_db.goalContributions)..where(
          (db.$GoalContributionsTable tbl) =>
              tbl.transactionId.equals(transactionId),
        ))
        .go();
  }
}
