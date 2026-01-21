import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AccountMonthlyTotalsRow {
  const AccountMonthlyTotalsRow({
    required this.accountId,
    required this.income,
    required this.expense,
  });

  final String accountId;
  final MoneyAmount income;
  final MoneyAmount expense;
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
  amount_scale AS amount_scale,
  COALESCE(SUM(CASE WHEN type = ?1 THEN ABS(CAST(amount_minor AS INTEGER)) ELSE 0 END), 0) AS income_minor,
  COALESCE(SUM(CASE WHEN type = ?2 THEN ABS(CAST(amount_minor AS INTEGER)) ELSE 0 END), 0) AS expense_minor
FROM transactions
WHERE is_deleted = 0
  AND date >= ?3
  AND date < ?4
GROUP BY account_id, amount_scale
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
          final Map<String, _AccountTotalsAccumulator> totals =
              <String, _AccountTotalsAccumulator>{};
          for (final QueryRow row in rows) {
            final String accountId = row.read<String>('account_id');
            final _AccountTotalsAccumulator accumulator = totals.putIfAbsent(
              accountId,
              _AccountTotalsAccumulator.new,
            );
            final int scale = row.read<int>('amount_scale');
            accumulator.income.add(
              MoneyAmount(
                minor: BigInt.from(row.read<int>('income_minor')),
                scale: scale,
              ),
            );
            accumulator.expense.add(
              MoneyAmount(
                minor: BigInt.from(row.read<int>('expense_minor')),
                scale: scale,
              ),
            );
          }

          return totals.entries
              .map(
                (MapEntry<String, _AccountTotalsAccumulator> entry) =>
                    AccountMonthlyTotalsRow(
                      accountId: entry.key,
                      income: MoneyAmount(
                        minor: entry.value.income.minor,
                        scale: entry.value.income.scale,
                      ),
                      expense: MoneyAmount(
                        minor: entry.value.expense.minor,
                        scale: entry.value.expense.scale,
                      ),
                    ),
              )
              .toList(growable: false);
        });
  }

  Stream<List<db.TransactionRow>> watchRecentTransactions({int? limit}) {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where((db.$TransactionsTable tbl) => tbl.isDeleted.equals(false))
      ..orderBy(<OrderingTerm Function(db.$TransactionsTable)>[
        (db.$TransactionsTable tbl) => OrderingTerm.desc(tbl.date),
      ]);
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
    final MoneyAmount amount = transaction.amountValue.abs();
    final Money money = Money(
      minor: amount.minor,
      currency: 'XXX',
      scale: amount.scale,
    );
    return db.TransactionsCompanion(
      id: Value<String>(transaction.id),
      accountId: Value<String>(transaction.accountId),
      transferAccountId: Value<String?>(transaction.transferAccountId),
      categoryId: Value<String?>(transaction.categoryId),
      savingGoalId: Value<String?>(transaction.savingGoalId),
      amount: Value<double>(money.toDouble()),
      amountMinor: Value<String>(amount.minor.toString()),
      amountScale: Value<int>(amount.scale),
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
      transferAccountId: row.transferAccountId,
      categoryId: row.categoryId,
      savingGoalId: row.savingGoalId,
      amountMinor: BigInt.parse(row.amountMinor),
      amountScale: row.amountScale,
      date: row.date,
      note: row.note,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}

class _AccountTotalsAccumulator {
  final MoneyAccumulator income = MoneyAccumulator();
  final MoneyAccumulator expense = MoneyAccumulator();
}
