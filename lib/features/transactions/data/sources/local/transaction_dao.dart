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

class AnalyticsCategoryTotalsRow {
  const AnalyticsCategoryTotalsRow({
    required this.categoryId,
    required this.rootCategoryId,
    required this.income,
    required this.expense,
  });

  final String? categoryId;
  final String? rootCategoryId;
  final MoneyAmount income;
  final MoneyAmount expense;
}

class MonthlyCashflowTotalsRow {
  const MonthlyCashflowTotalsRow({
    required this.monthKey,
    required this.income,
    required this.expense,
  });

  final String monthKey;
  final MoneyAmount income;
  final MoneyAmount expense;
}

class MonthlyBalanceTotalsRow {
  const MonthlyBalanceTotalsRow({
    required this.monthKey,
    required this.maxBalance,
  });

  final String monthKey;
  final MoneyAmount maxBalance;
}

class BudgetExpenseTotalsRow {
  const BudgetExpenseTotalsRow({
    required this.accountId,
    required this.categoryId,
    required this.expense,
  });

  final String accountId;
  final String? categoryId;
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

  Stream<List<AnalyticsCategoryTotalsRow>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) {
    final String incomeType = TransactionType.income.storageValue;
    final String expenseType = TransactionType.expense.storageValue;
    final StringBuffer sql = StringBuffer()
      ..writeln('SELECT')
      ..writeln('  t.category_id AS category_id,')
      ..writeln(
        '  CASE WHEN c.parent_id IS NULL THEN c.id ELSE c.parent_id END '
        'AS root_category_id,',
      )
      ..writeln('  t.amount_scale AS amount_scale,')
      ..writeln(
        '  COALESCE(SUM(CASE WHEN t.type = ? THEN '
        'ABS(CAST(t.amount_minor AS INTEGER)) ELSE 0 END), 0) '
        'AS income_minor,',
      )
      ..writeln(
        '  COALESCE(SUM(CASE WHEN t.type = ? THEN '
        'ABS(CAST(t.amount_minor AS INTEGER)) ELSE 0 END), 0) '
        'AS expense_minor',
      )
      ..writeln('FROM transactions t')
      ..writeln('LEFT JOIN categories c ON c.id = t.category_id')
      ..writeln('WHERE t.is_deleted = 0')
      ..writeln('  AND t.date >= ?')
      ..writeln('  AND t.date < ?')
      ..writeln('  AND t.type IN (?, ?)')
      ..writeln('  AND (t.category_id IS NULL OR c.is_deleted = 0)');

    final List<Variable<Object>> variables = <Variable<Object>>[
      Variable<String>(incomeType),
      Variable<String>(expenseType),
      Variable<DateTime>(start),
      Variable<DateTime>(end),
      Variable<String>(incomeType),
      Variable<String>(expenseType),
    ];

    if (accountIds.isNotEmpty) {
      sql.writeln(
        '  AND t.account_id IN (${_placeholders(accountIds.length)})',
      );
      variables.addAll(_stringVariables(accountIds));
    }
    if (accountId != null) {
      sql.writeln('  AND t.account_id = ?');
      variables.add(Variable<String>(accountId));
    }

    sql.writeln('GROUP BY t.category_id, root_category_id, t.amount_scale');

    return _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{
            _db.transactions,
            _db.categories,
          },
        )
        .watch()
        .map((List<QueryRow> rows) {
          return rows
              .map((QueryRow row) {
                final String? categoryId = row.read<String?>('category_id');
                final String? rootCategoryId = row.read<String?>(
                  'root_category_id',
                );
                final int scale = row.read<int>('amount_scale');
                final MoneyAmount income = MoneyAmount(
                  minor: BigInt.from(row.read<int>('income_minor')),
                  scale: scale,
                );
                final MoneyAmount expense = MoneyAmount(
                  minor: BigInt.from(row.read<int>('expense_minor')),
                  scale: scale,
                );
                return AnalyticsCategoryTotalsRow(
                  categoryId: categoryId,
                  rootCategoryId: rootCategoryId,
                  income: income,
                  expense: expense,
                );
              })
              .toList(growable: false);
        });
  }

  Stream<List<MonthlyCashflowTotalsRow>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) {
    final String incomeType = TransactionType.income.storageValue;
    final String expenseType = TransactionType.expense.storageValue;
    final String transferType = TransactionType.transfer.storageValue;
    if (accountIds.isEmpty) {
      return _db
          .customSelect(
            '''
WITH deltas AS (
  SELECT
    date AS date,
    amount_scale AS amount_scale,
    CASE
      WHEN type = ? THEN ABS(CAST(amount_minor AS INTEGER))
      WHEN type = ? THEN -ABS(CAST(amount_minor AS INTEGER))
      ELSE 0
    END AS delta_minor
  FROM transactions
  WHERE is_deleted = 0
    AND date >= ?
    AND date < ?
    AND date < ?
)
SELECT
  strftime('%Y-%m', date, 'unixepoch') AS month_key,
  amount_scale AS amount_scale,
  SUM(CASE WHEN delta_minor > 0 THEN delta_minor ELSE 0 END) AS income_minor,
  SUM(CASE WHEN delta_minor < 0 THEN -delta_minor ELSE 0 END) AS expense_minor
FROM deltas
WHERE delta_minor != 0
GROUP BY month_key, amount_scale
''',
            variables: <Variable<Object>>[
              Variable<String>(incomeType),
              Variable<String>(expenseType),
              Variable<DateTime>(start),
              Variable<DateTime>(end),
              Variable<DateTime>(nowInclusive),
            ],
            readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
          )
          .watch()
          .map(_mapMonthlyCashflowRows);
    }

    final String accountValues = _valuesClause(accountIds.length);
    return _db
        .customSelect(
          '''
WITH selected_accounts(id) AS (
  VALUES $accountValues
),
deltas AS (
  SELECT
    t.date AS date,
    t.amount_scale AS amount_scale,
    CASE
      WHEN t.type = ? AND t.transfer_account_id IS NOT NULL
        AND t.transfer_account_id != t.account_id THEN
        CASE
          WHEN t.account_id IN (SELECT id FROM selected_accounts)
            AND t.transfer_account_id NOT IN (SELECT id FROM selected_accounts)
            THEN -ABS(CAST(t.amount_minor AS INTEGER))
          WHEN t.account_id NOT IN (SELECT id FROM selected_accounts)
            AND t.transfer_account_id IN (SELECT id FROM selected_accounts)
            THEN ABS(CAST(t.amount_minor AS INTEGER))
          ELSE 0
        END
      WHEN t.type = ? AND t.account_id IN (SELECT id FROM selected_accounts)
        THEN ABS(CAST(t.amount_minor AS INTEGER))
      WHEN t.type = ? AND t.account_id IN (SELECT id FROM selected_accounts)
        THEN -ABS(CAST(t.amount_minor AS INTEGER))
      ELSE 0
    END AS delta_minor
  FROM transactions t
  WHERE t.is_deleted = 0
    AND t.date >= ?
    AND t.date < ?
    AND t.date < ?
)
SELECT
  strftime('%Y-%m', date, 'unixepoch') AS month_key,
  amount_scale AS amount_scale,
  SUM(CASE WHEN delta_minor > 0 THEN delta_minor ELSE 0 END) AS income_minor,
  SUM(CASE WHEN delta_minor < 0 THEN -delta_minor ELSE 0 END) AS expense_minor
FROM deltas
WHERE delta_minor != 0
GROUP BY month_key, amount_scale
''',
          variables: <Variable<Object>>[
            ..._stringVariables(accountIds),
            Variable<String>(transferType),
            Variable<String>(incomeType),
            Variable<String>(expenseType),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
            Variable<DateTime>(nowInclusive),
          ],
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
        )
        .watch()
        .map(_mapMonthlyCashflowRows);
  }

  Stream<List<MonthlyBalanceTotalsRow>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    if (accountIds.isEmpty) {
      return Stream<List<MonthlyBalanceTotalsRow>>.value(
        const <MonthlyBalanceTotalsRow>[],
      );
    }
    final String transferType = TransactionType.transfer.storageValue;
    final String incomeType = TransactionType.income.storageValue;
    final String expenseType = TransactionType.expense.storageValue;
    final List<DateTime> monthStarts = _monthStarts(start, end);
    final String monthValues = _valuesClause(monthStarts.length);
    final String accountValues = _valuesClause(accountIds.length);

    return _db
        .customSelect(
          '''
WITH selected_accounts(id) AS (
  VALUES $accountValues
),
month_starts(month_start) AS (
  VALUES $monthValues
),
opening AS (
  SELECT
    a.currency_scale AS scale,
    COALESCE(SUM(CAST(a.opening_balance_minor AS INTEGER)), 0) AS opening_minor
  FROM accounts a
  WHERE a.is_deleted = 0
    AND a.id IN (SELECT id FROM selected_accounts)
  GROUP BY a.currency_scale
),
deltas AS (
  SELECT
    t.id AS id,
    t.date AS date,
    t.amount_scale AS scale,
    CASE
      WHEN t.type = ? AND t.transfer_account_id IS NOT NULL
        AND t.transfer_account_id != t.account_id THEN
        CASE
          WHEN t.account_id IN (SELECT id FROM selected_accounts)
            AND t.transfer_account_id NOT IN (SELECT id FROM selected_accounts)
            THEN -ABS(CAST(t.amount_minor AS INTEGER))
          WHEN t.account_id NOT IN (SELECT id FROM selected_accounts)
            AND t.transfer_account_id IN (SELECT id FROM selected_accounts)
            THEN ABS(CAST(t.amount_minor AS INTEGER))
          ELSE 0
        END
      WHEN t.type = ? AND t.account_id IN (SELECT id FROM selected_accounts)
        THEN ABS(CAST(t.amount_minor AS INTEGER))
      WHEN t.type = ? AND t.account_id IN (SELECT id FROM selected_accounts)
        THEN -ABS(CAST(t.amount_minor AS INTEGER))
      ELSE 0
    END AS delta_minor
  FROM transactions t
  WHERE t.is_deleted = 0
    AND t.date < ?
),
scales AS (
  SELECT scale FROM opening
  UNION
  SELECT DISTINCT scale FROM deltas
),
base AS (
  SELECT
    s.scale AS scale,
    COALESCE(o.opening_minor, 0) +
      COALESCE(SUM(CASE WHEN d.date < ? THEN d.delta_minor ELSE 0 END), 0)
      AS base_minor
  FROM scales s
  LEFT JOIN opening o ON o.scale = s.scale
  LEFT JOIN deltas d ON d.scale = s.scale
  GROUP BY s.scale
),
events AS (
  SELECT d.date AS date,
         d.scale AS scale,
         d.delta_minor AS delta_minor,
         1 AS sort_order,
         d.id AS id
  FROM deltas d
  WHERE d.date >= ? AND d.date < ? AND d.delta_minor != 0
  UNION ALL
  SELECT m.month_start AS date,
         b.scale AS scale,
         0 AS delta_minor,
         0 AS sort_order,
         '' AS id
  FROM month_starts m
  CROSS JOIN base b
),
running AS (
  SELECT
    strftime('%Y-%m', date, 'unixepoch') AS month_key,
    e.scale AS scale,
    (b.base_minor + SUM(delta_minor) OVER (
      PARTITION BY e.scale
      ORDER BY date, sort_order, id
      ROWS UNBOUNDED PRECEDING
    )) AS running_minor
  FROM events e
  JOIN base b ON b.scale = e.scale
)
SELECT
  month_key,
  scale AS amount_scale,
  MAX(running_minor) AS max_minor
FROM running
GROUP BY month_key, scale
''',
          variables: <Variable<Object>>[
            ..._stringVariables(accountIds),
            ..._stringVariables(
              monthStarts.map((DateTime d) => d.toIso8601String()).toList(),
            ),
            Variable<String>(transferType),
            Variable<String>(incomeType),
            Variable<String>(expenseType),
            Variable<DateTime>(end),
            Variable<DateTime>(start),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
          ],
          readsFrom: <TableInfo<dynamic, dynamic>>{
            _db.transactions,
            _db.accounts,
          },
        )
        .watch()
        .map((List<QueryRow> rows) {
          return rows
              .map((QueryRow row) {
                final String? monthKey = row.read<String?>('month_key');
                if (monthKey == null) {
                  return null;
                }
                final int scale = row.read<int>('amount_scale');
                final MoneyAmount maxBalance = MoneyAmount(
                  minor: BigInt.from(row.read<int>('max_minor')),
                  scale: scale,
                );
                return MonthlyBalanceTotalsRow(
                  monthKey: monthKey,
                  maxBalance: maxBalance,
                );
              })
              .whereType<MonthlyBalanceTotalsRow>()
              .toList(growable: false);
        });
  }

  Stream<List<BudgetExpenseTotalsRow>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    final String expenseType = TransactionType.expense.storageValue;
    final StringBuffer sql = StringBuffer()
      ..writeln('SELECT')
      ..writeln('  account_id AS account_id,')
      ..writeln('  category_id AS category_id,')
      ..writeln('  amount_scale AS amount_scale,')
      ..writeln(
        '  COALESCE(SUM(ABS(CAST(amount_minor AS INTEGER))), 0) '
        'AS expense_minor',
      )
      ..writeln('FROM transactions')
      ..writeln('WHERE is_deleted = 0')
      ..writeln('  AND date >= ?')
      ..writeln('  AND date < ?')
      ..writeln('  AND type = ?');

    final List<Variable<Object>> variables = <Variable<Object>>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
      Variable<String>(expenseType),
    ];

    if (accountIds.isNotEmpty) {
      sql.writeln(
        '  AND account_id IN (${_placeholders(accountIds.length)})',
      );
      variables.addAll(_stringVariables(accountIds));
    }

    sql.writeln('GROUP BY account_id, category_id, amount_scale');

    return _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
        )
        .watch()
        .map((List<QueryRow> rows) {
          return rows
              .map((QueryRow row) {
                final String accountId = row.read<String>('account_id');
                final String? categoryId = row.read<String?>('category_id');
                final int scale = row.read<int>('amount_scale');
                final MoneyAmount expense = MoneyAmount(
                  minor: BigInt.from(row.read<int>('expense_minor')),
                  scale: scale,
                );
                return BudgetExpenseTotalsRow(
                  accountId: accountId,
                  categoryId: categoryId,
                  expense: expense,
                );
              })
              .toList(growable: false);
        });
  }

  Stream<List<db.TransactionRow>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) {
    if (categoryIds.isEmpty && !includeUncategorized) {
      return Stream<List<db.TransactionRow>>.value(const <db.TransactionRow>[]);
    }

    final StringBuffer sql = StringBuffer()
      ..writeln('SELECT * FROM transactions')
      ..writeln('WHERE is_deleted = 0')
      ..writeln('  AND date >= ?')
      ..writeln('  AND date < ?')
      ..writeln('  AND type = ?');

    final List<Variable<Object>> variables = <Variable<Object>>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
      Variable<String>(type),
    ];

    if (accountIds.isNotEmpty) {
      sql.writeln('  AND account_id IN (${_placeholders(accountIds.length)})');
      variables.addAll(_stringVariables(accountIds));
    }

    if (categoryIds.isNotEmpty && includeUncategorized) {
      sql.writeln(
        '  AND (category_id IN (${_placeholders(categoryIds.length)}) '
        'OR category_id IS NULL)',
      );
      variables.addAll(_stringVariables(categoryIds));
    } else if (categoryIds.isNotEmpty) {
      sql.writeln(
        '  AND category_id IN (${_placeholders(categoryIds.length)})',
      );
      variables.addAll(_stringVariables(categoryIds));
    } else if (includeUncategorized) {
      sql.writeln('  AND category_id IS NULL');
    }

    sql.writeln('ORDER BY date DESC');

    return _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
        )
        .watch()
        .map((List<QueryRow> rows) {
          return rows
              .map((QueryRow row) => _db.transactions.map(row.data))
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

  Future<db.TransactionRow?> findByIdempotencyKey(String idempotencyKey) {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where(
        (db.$TransactionsTable tbl) =>
            tbl.idempotencyKey.equals(idempotencyKey),
      )
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> upsert(TransactionEntity transaction) {
    return _db
        .into(_db.transactions)
        .insertOnConflictUpdate(_mapToCompanion(transaction));
  }

  Future<db.TransactionRow?> findLatestByCategoryId(String categoryId) {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where(
        (db.$TransactionsTable tbl) =>
            tbl.isDeleted.equals(false) & tbl.categoryId.equals(categoryId),
      )
      ..orderBy(<OrderClauseGenerator<db.$TransactionsTable>>[
        (db.$TransactionsTable tbl) => OrderingTerm(
          expression: tbl.date,
          mode: OrderingMode.desc,
        ),
        (db.$TransactionsTable tbl) => OrderingTerm(
          expression: tbl.updatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(1);
    return query.getSingleOrNull();
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
      idempotencyKey: Value<String?>(transaction.idempotencyKey),
      groupId: Value<String?>(transaction.groupId),
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
      idempotencyKey: row.idempotencyKey,
      groupId: row.groupId,
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

List<MonthlyCashflowTotalsRow> _mapMonthlyCashflowRows(List<QueryRow> rows) {
  return rows
      .map((QueryRow row) {
        final String? monthKey = row.read<String?>('month_key');
        if (monthKey == null) {
          return null;
        }
        final int scale = row.read<int>('amount_scale');
        final MoneyAmount income = MoneyAmount(
          minor: BigInt.from(row.read<int>('income_minor')),
          scale: scale,
        );
        final MoneyAmount expense = MoneyAmount(
          minor: BigInt.from(row.read<int>('expense_minor')),
          scale: scale,
        );
        return MonthlyCashflowTotalsRow(
          monthKey: monthKey,
          income: income,
          expense: expense,
        );
      })
      .whereType<MonthlyCashflowTotalsRow>()
      .toList(growable: false);
}

String _placeholders(int count) {
  return List<String>.filled(count, '?').join(', ');
}

String _valuesClause(int count) {
  return List<String>.filled(count, '(?)').join(', ');
}

List<Variable<Object>> _stringVariables(List<String> values) {
  return values.map((String value) => Variable<String>(value)).toList();
}

List<DateTime> _monthStarts(DateTime start, DateTime end) {
  final List<DateTime> months = <DateTime>[];
  DateTime current = DateTime(start.year, start.month);
  final DateTime limit = DateTime(end.year, end.month);
  while (current.isBefore(limit)) {
    months.add(current);
    current = DateTime(current.year, current.month + 1);
  }
  return months;
}

class _AccountTotalsAccumulator {
  final MoneyAccumulator income = MoneyAccumulator();
  final MoneyAccumulator expense = MoneyAccumulator();
}
