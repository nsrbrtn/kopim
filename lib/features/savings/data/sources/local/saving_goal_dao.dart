import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

class SavingGoalDao {
  SavingGoalDao(this._db);

  final db.AppDatabase _db;

  Stream<List<SavingGoal>> watchGoals({required bool includeArchived}) {
    final SimpleSelectStatement<db.$SavingGoalsTable, db.SavingGoalRow> query =
        _db.select(
          _db.savingGoals,
        )..orderBy(<OrderingTerm Function(db.$SavingGoalsTable)>[
          (db.$SavingGoalsTable tbl) =>
              OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
        ]);
    if (!includeArchived) {
      query.where((db.$SavingGoalsTable tbl) => tbl.archivedAt.isNull());
    }
    return query.watch().map(
      (List<db.SavingGoalRow> rows) =>
          rows.map(_mapRowToEntity).toList(growable: false),
    );
  }

  Future<List<SavingGoal>> getGoals({required bool includeArchived}) async {
    final SimpleSelectStatement<db.$SavingGoalsTable, db.SavingGoalRow> query =
        _db.select(
          _db.savingGoals,
        )..orderBy(<OrderingTerm Function(db.$SavingGoalsTable)>[
          (db.$SavingGoalsTable tbl) =>
              OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
        ]);
    if (!includeArchived) {
      query.where((db.$SavingGoalsTable tbl) => tbl.archivedAt.isNull());
    }
    final List<db.SavingGoalRow> rows = await query.get();
    return rows.map(_mapRowToEntity).toList(growable: false);
  }

  Future<SavingGoal?> findById(String id) async {
    final db.SavingGoalRow? row =
        await (_db.select(_db.savingGoals)
              ..where((db.$SavingGoalsTable tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapRowToEntity(row);
  }

  Future<SavingGoal?> findByName({
    required String userId,
    required String name,
  }) async {
    final db.SavingGoalRow? row =
        await (_db.select(_db.savingGoals)..where(
              (db.$SavingGoalsTable tbl) =>
                  tbl.userId.equals(userId) & tbl.name.equals(name),
            ))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapRowToEntity(row);
  }

  Future<void> upsert(SavingGoal goal) async {
    await _db
        .into(_db.savingGoals)
        .insertOnConflictUpdate(_mapToCompanion(goal));
  }

  Future<void> upsertAll(List<SavingGoal> goals) async {
    if (goals.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.savingGoals,
          goals.map(_mapToCompanion).toList(growable: false),
        );
      });
    });
  }

  Future<void> archive(String id, DateTime archivedAt) {
    return (_db.update(
      _db.savingGoals,
    )..where((db.$SavingGoalsTable tbl) => tbl.id.equals(id))).write(
      db.SavingGoalsCompanion(
        archivedAt: Value<DateTime?>(archivedAt),
        updatedAt: Value<DateTime>(archivedAt),
      ),
    );
  }

  db.SavingGoalsCompanion _mapToCompanion(SavingGoal goal) {
    return db.SavingGoalsCompanion(
      id: Value<String>(goal.id),
      userId: Value<String>(goal.userId),
      name: Value<String>(goal.name),
      targetAmount: Value<int>(goal.targetAmount),
      currentAmount: Value<int>(goal.currentAmount),
      note: Value<String?>(goal.note),
      createdAt: Value<DateTime>(goal.createdAt),
      updatedAt: Value<DateTime>(goal.updatedAt),
      archivedAt: Value<DateTime?>(goal.archivedAt),
    );
  }

  SavingGoal _mapRowToEntity(db.SavingGoalRow row) {
    return SavingGoal(
      id: row.id,
      userId: row.userId,
      name: row.name,
      targetAmount: row.targetAmount,
      currentAmount: row.currentAmount,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }
}
