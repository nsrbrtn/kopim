import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AccountMonthlyTotalsRow {
  const AccountMonthlyTotalsRow({
    required this.accountId,
    required this.income,
    required this.expense,
  });

  final String accountId;
  final double income;
  final double expense;
}

class TransactionDao {
  TransactionDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.TransactionRow>> watchActiveTransactions() {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Stream<List<AccountMonthlyTotalsRow>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    final String incomeType = TransactionType.income.storageValue;
    final String expenseType = TransactionType.expense.storageValue;
    return _db
        .customSelect(
          '''
SELECT
  account_id AS account_id,
  COALESCE(SUM(CASE WHEN type = ?1 THEN ABS(amount) ELSE 0 END), 0) AS income,
  COALESCE(SUM(CASE WHEN type = ?2 THEN ABS(amount) ELSE 0 END), 0) AS expense
FROM transactions
WHERE is_deleted = 0
  AND date >= ?3
  AND date < ?4
GROUP BY account_id
''',
          variables: <Variable<Object>>[
            Variable<String>(incomeType),
            Variable<String>(expenseType),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
          ],
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
        )
        .watch()
        .map((List<QueryRow> rows) {
          return rows
              .map(
                (QueryRow row) => AccountMonthlyTotalsRow(
                  accountId: row.read<String>('account_id'),
                  income: row.read<double>('income'),
                  expense: row.read<double>('expense'),
                ),
              )
              .toList(growable: false);
        });
  }

  Stream<List<db.TransactionRow>> watchRecentTransactions({
    int? limit,
  }) {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.isDeleted.equals(false))
      ..orderBy(
        <OrderingTerm Function(db.$TransactionsTable)>[
          (db.$TransactionsTable tbl) => OrderingTerm.desc(tbl.date),
        ],
      );
    if (limit != null && limit > 0) {
      query.limit(limit);
    }
    return query.watch();
  }

  Stream<int> watchActiveCount() {
    return _db
        .customSelect(
          'SELECT COUNT(*) AS count FROM transactions WHERE is_deleted = 0',
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
        )
        .watchSingle()
        .map((QueryRow row) => row.read<int>('count'));
  }

  Future<List<db.TransactionRow>> getActiveTransactions() {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<int> countActiveTransactions() async {
    final QueryRow row = await _db
        .customSelect(
          'SELECT COUNT(*) AS count FROM transactions WHERE is_deleted = 0',
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
        )
        .getSingle();
    return row.read<int>('count');
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
