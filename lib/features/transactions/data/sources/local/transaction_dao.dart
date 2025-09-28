import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class TransactionDao {
  TransactionDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.TransactionRow>> watchActiveTransactions() {
    final query = _db.select(_db.transactions)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.TransactionRow>> getActiveTransactions() {
    final query = _db.select(_db.transactions)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<db.TransactionRow?> findById(String id) {
    final query = _db.select(_db.transactions)
      ..where((tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(TransactionEntity transaction) {
    return _db
        .into(_db.transactions)
        .insertOnConflictUpdate(_mapToCompanion(transaction));
  }

  Future<void> upsertAll(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.transactions,
        transactions.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.transactions,
    )..where((tbl) => tbl.id.equals(id))).write(
      db.TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  db.TransactionsCompanion _mapToCompanion(TransactionEntity transaction) {
    return db.TransactionsCompanion(
      id: Value(transaction.id),
      accountId: Value(transaction.accountId),
      categoryId: Value(transaction.categoryId),
      amount: Value(transaction.amount),
      date: Value(transaction.date),
      note: Value(transaction.note),
      type: Value(transaction.type),
      createdAt: Value(transaction.createdAt),
      updatedAt: Value(transaction.updatedAt),
      isDeleted: Value(transaction.isDeleted),
    );
  }
}
