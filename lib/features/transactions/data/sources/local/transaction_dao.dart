import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class TransactionDao {
  TransactionDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.TransactionRow>> watchActiveTransactions() {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.TransactionRow>> getActiveTransactions() {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<TransactionEntity>> getAllTransactions() async {
    final List<db.TransactionRow> rows = await _db
        .select(_db.transactions)
        .get();
    return rows.map(_mapRowToEntity).toList();
  }

  Future<db.TransactionRow?> findById(String id) {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(TransactionEntity transaction) {
    return _db
        .into(_db.transactions)
        .insertOnConflictUpdate(_mapToCompanion(transaction));
  }

  Future<void> upsertAll(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.transactions,
          transactions.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.transactions,
    )..where((db.$TransactionsTable tbl) => tbl.id.equals(id))).write(
      db.TransactionsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.TransactionsCompanion _mapToCompanion(TransactionEntity transaction) {
    return db.TransactionsCompanion(
      id: Value<String>(transaction.id),
      accountId: Value<String>(transaction.accountId),
      categoryId: Value<String?>(transaction.categoryId),
      savingGoalId: Value<String?>(transaction.savingGoalId),
      amount: Value<double>(transaction.amount),
      date: Value<DateTime>(transaction.date),
      note: Value<String?>(transaction.note),
      type: Value<String>(transaction.type),
      createdAt: Value<DateTime>(transaction.createdAt),
      updatedAt: Value<DateTime>(transaction.updatedAt),
      isDeleted: Value<bool>(transaction.isDeleted),
    );
  }

  TransactionEntity _mapRowToEntity(db.TransactionRow row) {
    return TransactionEntity(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      savingGoalId: row.savingGoalId,
      amount: row.amount,
      date: row.date,
      note: row.note,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
