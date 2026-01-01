import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';

class DebtDao {
  DebtDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.DebtRow>> watchActiveDebts() {
    final SimpleSelectStatement<db.Debts, db.DebtRow> query =
        _db.select(_db.debts)
          ..where((db.Debts tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.DebtRow>> getActiveDebts() {
    final SimpleSelectStatement<db.Debts, db.DebtRow> query =
        _db.select(_db.debts)
          ..where((db.Debts tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<db.DebtRow>> getAllDebts() {
    return _db.select(_db.debts).get();
  }

  Future<db.DebtRow?> findById(String id) {
    final SimpleSelectStatement<db.Debts, db.DebtRow> query =
        _db.select(_db.debts)
          ..where((db.Debts tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(DebtEntity debt) {
    return _db.into(_db.debts).insertOnConflictUpdate(_mapToCompanion(debt));
  }

  Future<void> upsertAll(List<DebtEntity> debts) {
    if (debts.isEmpty) return Future<void>.value();
    return _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.debts,
        debts.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    final UpdateStatement<db.Debts, db.DebtRow> query =
        _db.update(_db.debts)..where((db.Debts tbl) => tbl.id.equals(id));
    await query.write(
      db.DebtsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.DebtsCompanion _mapToCompanion(DebtEntity debt) {
    return db.DebtsCompanion(
      id: Value<String>(debt.id),
      accountId: Value<String>(debt.accountId),
      amount: Value<double>(debt.amount),
      dueDate: Value<DateTime>(debt.dueDate),
      note: Value<String?>(debt.note),
      createdAt: Value<DateTime>(debt.createdAt),
      updatedAt: Value<DateTime>(debt.updatedAt),
      isDeleted: Value<bool>(debt.isDeleted),
    );
  }

  DebtEntity mapRowToEntity(db.DebtRow row) {
    return DebtEntity(
      id: row.id,
      accountId: row.accountId,
      amount: row.amount,
      dueDate: row.dueDate,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
