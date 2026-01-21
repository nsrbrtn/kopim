import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class MonthlyExpenseAggregate {
  MonthlyExpenseAggregate({required this.month, required this.totalExpense});

  final DateTime month;
  final MoneyAmount totalExpense;
}

class MonthlyIncomeAggregate {
  MonthlyIncomeAggregate({required this.month, required this.totalIncome});

  final DateTime month;
  final MoneyAmount totalIncome;
}

class CategoryExpenseAggregate {
  CategoryExpenseAggregate({
    required this.categoryId,
    required this.displayName,
    required this.totalExpense,
    required this.color,
  });

  final String? categoryId;
  final String displayName;
  final MoneyAmount totalExpense;
  final String? color;
}

class CategoryIncomeAggregate {
  CategoryIncomeAggregate({
    required this.categoryId,
    required this.displayName,
    required this.totalIncome,
    required this.color,
  });

  final String? categoryId;
  final String displayName;
  final MoneyAmount totalIncome;
  final String? color;
}

class BudgetInstanceAggregate {
  BudgetInstanceAggregate({
    required this.budgetId,
    required this.title,
    required this.periodStart,
    required this.periodEnd,
    required this.allocated,
    required this.spent,
    required this.accountIds,
    required this.categoryIds,
  });

  final String budgetId;
  final String title;
  final DateTime periodStart;
  final DateTime periodEnd;
  final MoneyAmount allocated;
  final MoneyAmount spent;
  final List<String> accountIds;
  final List<String> categoryIds;
}

class AiAnalyticsDao {
  AiAnalyticsDao(this._db);

  final db.AppDatabase _db;

  Future<List<MonthlyExpenseAggregate>> getMonthlyExpenses(
    AiDataFilter filter,
  ) async {
    final QueryResult rows = await _monthlyExpenseQuery(filter).get();
    return _aggregateMonthlyExpenses(rows);
  }

  Stream<List<MonthlyExpenseAggregate>> watchMonthlyExpenses(
    AiDataFilter filter,
  ) {
    return _monthlyExpenseQuery(
      filter,
    ).watch().map((QueryResult rows) => _aggregateMonthlyExpenses(rows));
  }

  Future<List<MonthlyIncomeAggregate>> getMonthlyIncome(
    AiDataFilter filter,
  ) async {
    final QueryResult rows = await _monthlyIncomeQuery(filter).get();
    return _aggregateMonthlyIncome(rows);
  }

  Stream<List<MonthlyIncomeAggregate>> watchMonthlyIncome(AiDataFilter filter) {
    return _monthlyIncomeQuery(
      filter,
    ).watch().map((QueryResult rows) => _aggregateMonthlyIncome(rows));
  }

  Future<List<CategoryExpenseAggregate>> getTopCategories(
    AiDataFilter filter,
  ) async {
    final QueryResult rows = await _topCategoriesQuery(filter).get();
    return _aggregateCategoryExpenses(rows);
  }

  Stream<List<CategoryExpenseAggregate>> watchTopCategories(
    AiDataFilter filter,
  ) {
    return _topCategoriesQuery(
      filter,
    ).watch().map((QueryResult rows) => _aggregateCategoryExpenses(rows));
  }

  Future<List<CategoryIncomeAggregate>> getTopIncomeCategories(
    AiDataFilter filter,
  ) async {
    final QueryResult rows = await _topIncomeCategoriesQuery(filter).get();
    return _aggregateCategoryIncome(rows);
  }

  Stream<List<CategoryIncomeAggregate>> watchTopIncomeCategories(
    AiDataFilter filter,
  ) {
    return _topIncomeCategoriesQuery(
      filter,
    ).watch().map((QueryResult rows) => _aggregateCategoryIncome(rows));
  }

  Future<List<BudgetInstanceAggregate>> getBudgetForecasts(
    AiDataFilter filter,
  ) async {
    final QueryResult rows = await _budgetForecastQuery(filter).get();
    return rows.map(_mapBudgetInstance).toList(growable: false);
  }

  Stream<List<BudgetInstanceAggregate>> watchBudgetForecasts(
    AiDataFilter filter,
  ) {
    return _budgetForecastQuery(filter).watch().map(
      (QueryResult rows) =>
          rows.map(_mapBudgetInstance).toList(growable: false),
    );
  }

  Future<List<db.BudgetRow>> getActiveBudgets() async {
    return (_db.select(
      _db.budgets,
    )..where((db.$BudgetsTable tbl) => tbl.isDeleted.equals(false))).get();
  }

  Stream<List<db.BudgetRow>> watchActiveBudgets() {
    return (_db.select(
      _db.budgets,
    )..where((db.$BudgetsTable tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<MoneyAmount> getBudgetSpent({
    required List<String> categoryIds,
    required List<String> accountIds,
    required DateTime start,
    required DateTime end,
  }) async {
    final SimpleSelectStatement<db.$TransactionsTable, db.TransactionRow>
    query = _db.select(_db.transactions)
      ..where(
        (db.$TransactionsTable tbl) =>
            tbl.type.equals('expense') &
            tbl.date.isBiggerOrEqualValue(start) &
            tbl.date.isSmallerThanValue(end),
      );

    if (categoryIds.isNotEmpty) {
      query.where(
        (db.$TransactionsTable tbl) => tbl.categoryId.isIn(categoryIds),
      );
    }

    if (accountIds.isNotEmpty) {
      query.where(
        (db.$TransactionsTable tbl) => tbl.accountId.isIn(accountIds),
      );
    }

    final List<db.TransactionRow> rows = await query.get();
    final MoneyAccumulator accumulator = MoneyAccumulator();
    for (final db.TransactionRow row in rows) {
      accumulator.add(
        MoneyAmount(
          minor: BigInt.parse(row.amountMinor),
          scale: row.amountScale,
        ).abs(),
      );
    }
    return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
  }

  Selectable<QueryRow> _monthlyExpenseQuery(AiDataFilter filter) {
    final StringBuffer sql = StringBuffer('''
SELECT strftime('%Y-%m-01', ${_getNormalizedDateExpr('date')}) AS month,
       amount_scale AS amount_scale,
       SUM(CAST(amount_minor AS INTEGER)) AS total_minor
FROM transactions
WHERE is_deleted = 0 AND type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.expense.storageValue),
    ];
    _applyTransactionFilters(sql, variables, filter);
    sql.write('GROUP BY month, amount_scale ORDER BY month DESC');
    return _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
    );
  }

  Selectable<QueryRow> _monthlyIncomeQuery(AiDataFilter filter) {
    final StringBuffer sql = StringBuffer('''
SELECT strftime('%Y-%m-01', ${_getNormalizedDateExpr('date')}) AS month,
       amount_scale AS amount_scale,
       SUM(CAST(amount_minor AS INTEGER)) AS total_minor
FROM transactions
WHERE is_deleted = 0 AND type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.income.storageValue),
    ];
    _applyTransactionFilters(sql, variables, filter);
    sql.write('GROUP BY month, amount_scale ORDER BY month DESC');
    return _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions},
    );
  }

  Selectable<QueryRow> _topCategoriesQuery(AiDataFilter filter) {
    final StringBuffer sql = StringBuffer('''
SELECT c.id AS category_id,
       COALESCE(c.name, 'Без категории') AS display_name,
       COALESCE(c.color, '') AS color,
       t.amount_scale AS amount_scale,
       SUM(CAST(t.amount_minor AS INTEGER)) AS total_minor
FROM transactions t
LEFT JOIN categories c ON c.id = t.category_id
WHERE t.is_deleted = 0 AND t.type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.expense.storageValue),
    ];
    _applyTransactionFilters(sql, variables, filter, tableAlias: 't');
    sql
      ..write(' GROUP BY c.id, c.name, c.color, t.amount_scale ')
      ..write('ORDER BY total_minor DESC ')
      ..write('LIMIT ${filter.topCategoriesLimit}');
    return _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{
        _db.transactions,
        _db.categories,
      },
    );
  }

  Selectable<QueryRow> _topIncomeCategoriesQuery(AiDataFilter filter) {
    final StringBuffer sql = StringBuffer('''
SELECT c.id AS category_id,
       COALESCE(c.name, 'Без категории') AS display_name,
       COALESCE(c.color, '') AS color,
       t.amount_scale AS amount_scale,
       SUM(CAST(t.amount_minor AS INTEGER)) AS total_minor
FROM transactions t
LEFT JOIN categories c ON c.id = t.category_id
WHERE t.is_deleted = 0 AND t.type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.income.storageValue),
    ];
    _applyTransactionFilters(sql, variables, filter, tableAlias: 't');
    sql
      ..write(' GROUP BY c.id, c.name, c.color, t.amount_scale ')
      ..write('ORDER BY total_minor DESC ')
      ..write('LIMIT ${filter.topCategoriesLimit}');
    return _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{
        _db.transactions,
        _db.categories,
      },
    );
  }

  Selectable<QueryRow> _budgetForecastQuery(AiDataFilter filter) {
    final StringBuffer sql = StringBuffer(
      'SELECT '
      'b.id AS budget_id, '
      'b.title AS title, '
      'b.categories AS categories, '
      'b.accounts AS accounts, '
      'i.period_start AS period_start, '
      'i.period_end AS period_end, '
      'i.amount_minor AS amount_minor, '
      'i.spent_minor AS spent_minor, '
      'i.amount_scale AS amount_scale '
      'FROM budget_instances i '
      'INNER JOIN budgets b ON b.id = i.budget_id '
      'WHERE b.is_deleted = 0 '
      'AND i.period_end >= ? '
      'AND i.period_start <= ?'
      ' ',
    );
    final DateTime start = filter.startDate ?? DateTime(1970, 1, 1);
    final DateTime end = filter.endDate ?? DateTime(9999, 12, 31);
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
    ];
    sql.write('ORDER BY i.period_start DESC');
    return _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{
        _db.budgetInstances,
        _db.budgets,
      },
    );
  }

  void _applyTransactionFilters(
    StringBuffer sql,
    // ignore: always_specify_types
    List<Variable> variables,
    AiDataFilter filter, {
    String tableAlias = 'transactions',
  }) {
    final String prefix = tableAlias.isEmpty ? '' : '$tableAlias.';
    final String dateField = '${prefix}date';
    final String normalizedDate = _getNormalizedDateExpr(dateField);

    if (filter.startDate != null) {
      sql.write('AND $normalizedDate >= ? ');
      variables.add(Variable<String>(_formatDate(filter.startDate!)));
    }
    if (filter.endDate != null) {
      sql.write('AND $normalizedDate <= ? ');
      variables.add(Variable<String>(_formatDate(filter.endDate!)));
    }
    if (filter.accountIds.isNotEmpty) {
      final String placeholders = List<String>.filled(
        filter.accountIds.length,
        '?',
      ).join(', ');
      sql.write('AND ${prefix}account_id IN ($placeholders) ');
      variables.addAll(
        filter.accountIds.map((String id) => Variable<String>(id)),
      );
    }
    if (filter.categoryIds.isNotEmpty) {
      final List<String> notEmpty = filter.categoryIds
          .where((String id) => id.isNotEmpty)
          .toList(growable: false);
      if (notEmpty.isNotEmpty) {
        final String placeholders = List<String>.filled(
          notEmpty.length,
          '?',
        ).join(', ');
        sql.write('AND ${prefix}category_id IN ($placeholders) ');
        variables.addAll(notEmpty.map((String id) => Variable<String>(id)));
      }
    }
  }

  List<MonthlyExpenseAggregate> _aggregateMonthlyExpenses(QueryResult rows) {
    final Map<DateTime, MoneyAccumulator> totals =
        <DateTime, MoneyAccumulator>{};
    for (final QueryRow row in rows) {
      final DateTime month = DateTime.parse(row.read<String>('month'));
      final MoneyAccumulator accumulator = totals.putIfAbsent(
        month,
        MoneyAccumulator.new,
      );
      accumulator.add(
        MoneyAmount(
          minor: BigInt.from(row.read<int>('total_minor')),
          scale: row.read<int>('amount_scale'),
        ),
      );
    }
    final List<MonthlyExpenseAggregate> items = totals.entries
        .map(
          (MapEntry<DateTime, MoneyAccumulator> entry) =>
              MonthlyExpenseAggregate(
                month: entry.key,
                totalExpense: MoneyAmount(
                  minor: entry.value.minor,
                  scale: entry.value.scale,
                ),
              ),
        )
        .toList(growable: false);
    items.sort((MonthlyExpenseAggregate a, MonthlyExpenseAggregate b) {
      return b.month.compareTo(a.month);
    });
    return items;
  }

  List<MonthlyIncomeAggregate> _aggregateMonthlyIncome(QueryResult rows) {
    final Map<DateTime, MoneyAccumulator> totals =
        <DateTime, MoneyAccumulator>{};
    for (final QueryRow row in rows) {
      final DateTime month = DateTime.parse(row.read<String>('month'));
      final MoneyAccumulator accumulator = totals.putIfAbsent(
        month,
        MoneyAccumulator.new,
      );
      accumulator.add(
        MoneyAmount(
          minor: BigInt.from(row.read<int>('total_minor')),
          scale: row.read<int>('amount_scale'),
        ),
      );
    }
    final List<MonthlyIncomeAggregate> items = totals.entries
        .map(
          (MapEntry<DateTime, MoneyAccumulator> entry) =>
              MonthlyIncomeAggregate(
                month: entry.key,
                totalIncome: MoneyAmount(
                  minor: entry.value.minor,
                  scale: entry.value.scale,
                ),
              ),
        )
        .toList(growable: false);
    items.sort((MonthlyIncomeAggregate a, MonthlyIncomeAggregate b) {
      return b.month.compareTo(a.month);
    });
    return items;
  }

  List<CategoryExpenseAggregate> _aggregateCategoryExpenses(QueryResult rows) {
    final Map<String?, _CategoryAccumulator> totals =
        <String?, _CategoryAccumulator>{};
    for (final QueryRow row in rows) {
      final String? categoryId = row.read<String?>('category_id');
      final String displayName = row.read<String>('display_name');
      final String color = row.read<String>('color');
      final _CategoryAccumulator accumulator = totals.putIfAbsent(
        categoryId,
        () => _CategoryAccumulator(
          displayName: displayName,
          color: color.isEmpty ? null : color,
        ),
      );
      accumulator.total.add(
        MoneyAmount(
          minor: BigInt.from(row.read<int>('total_minor')),
          scale: row.read<int>('amount_scale'),
        ),
      );
    }
    final List<CategoryExpenseAggregate> items = totals.entries
        .map(
          (MapEntry<String?, _CategoryAccumulator> entry) =>
              CategoryExpenseAggregate(
                categoryId: entry.key?.isEmpty ?? true ? null : entry.key,
                displayName: entry.value.displayName,
                totalExpense: MoneyAmount(
                  minor: entry.value.total.minor,
                  scale: entry.value.total.scale,
                ),
                color: entry.value.color,
              ),
        )
        .toList(growable: false);
    items.sort((CategoryExpenseAggregate a, CategoryExpenseAggregate b) {
      return b.totalExpense.toDouble().compareTo(a.totalExpense.toDouble());
    });
    return items;
  }

  List<CategoryIncomeAggregate> _aggregateCategoryIncome(QueryResult rows) {
    final Map<String?, _CategoryAccumulator> totals =
        <String?, _CategoryAccumulator>{};
    for (final QueryRow row in rows) {
      final String? categoryId = row.read<String?>('category_id');
      final String displayName = row.read<String>('display_name');
      final String color = row.read<String>('color');
      final _CategoryAccumulator accumulator = totals.putIfAbsent(
        categoryId,
        () => _CategoryAccumulator(
          displayName: displayName,
          color: color.isEmpty ? null : color,
        ),
      );
      accumulator.total.add(
        MoneyAmount(
          minor: BigInt.from(row.read<int>('total_minor')),
          scale: row.read<int>('amount_scale'),
        ),
      );
    }
    final List<CategoryIncomeAggregate> items = totals.entries
        .map(
          (MapEntry<String?, _CategoryAccumulator> entry) =>
              CategoryIncomeAggregate(
                categoryId: entry.key?.isEmpty ?? true ? null : entry.key,
                displayName: entry.value.displayName,
                totalIncome: MoneyAmount(
                  minor: entry.value.total.minor,
                  scale: entry.value.total.scale,
                ),
                color: entry.value.color,
              ),
        )
        .toList(growable: false);
    items.sort((CategoryIncomeAggregate a, CategoryIncomeAggregate b) {
      return b.totalIncome.toDouble().compareTo(a.totalIncome.toDouble());
    });
    return items;
  }

  BudgetInstanceAggregate _mapBudgetInstance(QueryRow row) {
    final String categoriesRaw = row.read<String>('categories');
    final String accountsRaw = row.read<String>('accounts');
    final List<String> categories = (jsonDecode(categoriesRaw) as List<dynamic>)
        .map((dynamic value) => value.toString())
        .toList(growable: false);
    final List<String> accounts = (jsonDecode(accountsRaw) as List<dynamic>)
        .map((dynamic value) => value.toString())
        .toList(growable: false);
    return BudgetInstanceAggregate(
      budgetId: row.read<String>('budget_id'),
      title: row.read<String>('title'),
      periodStart: row.read<DateTime>('period_start'),
      periodEnd: row.read<DateTime>('period_end'),
      allocated: MoneyAmount(
        minor: BigInt.parse(row.read<String>('amount_minor')),
        scale: row.read<int>('amount_scale'),
      ),
      spent: MoneyAmount(
        minor: BigInt.parse(row.read<String>('spent_minor')),
        scale: row.read<int>('amount_scale'),
      ),
      accountIds: accounts,
      categoryIds: categories,
    );
  }

  Future<Map<String, String>> getCategoryNames(List<String> ids) async {
    if (ids.isEmpty) {
      return <String, String>{};
    }
    final List<db.CategoryRow> rows = await (_db.select(
      _db.categories,
    )..where((db.Categories tbl) => tbl.id.isIn(ids))).get();

    return <String, String>{
      for (final db.CategoryRow row in rows) row.id: row.name,
    };
  }

  String _getNormalizedDateExpr(String field) {
    return '''
CASE
  WHEN typeof($field) IN ('integer', 'real') AND ABS($field) >= 1000000000000
    THEN datetime($field / 1000000.0, 'unixepoch')
  WHEN typeof($field) IN ('integer', 'real') AND ABS($field) >= 10000000000
    THEN datetime($field / 1000.0, 'unixepoch')
  WHEN typeof($field) IN ('integer', 'real')
    THEN datetime($field, 'unixepoch')
  ELSE datetime($field)
END
''';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toUtc());
  }
}

class _CategoryAccumulator {
  _CategoryAccumulator({required this.displayName, required this.color});

  final String displayName;
  final String? color;
  final MoneyAccumulator total = MoneyAccumulator();
}

typedef QueryResult = List<QueryRow>;
