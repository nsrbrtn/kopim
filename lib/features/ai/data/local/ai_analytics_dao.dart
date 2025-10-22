import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class MonthlyExpenseAggregate {
  MonthlyExpenseAggregate({required this.month, required this.totalExpense});

  final DateTime month;
  final double totalExpense;
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
  final double totalExpense;
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
  final double allocated;
  final double spent;
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
    return rows.map(_mapMonthlyExpense).toList(growable: false);
  }

  Stream<List<MonthlyExpenseAggregate>> watchMonthlyExpenses(
    AiDataFilter filter,
  ) {
    return _monthlyExpenseQuery(filter).watch().map(
      (QueryResult rows) =>
          rows.map(_mapMonthlyExpense).toList(growable: false),
    );
  }

  Future<List<CategoryExpenseAggregate>> getTopCategories(
    AiDataFilter filter,
  ) async {
    final QueryResult rows = await _topCategoriesQuery(filter).get();
    return rows.map(_mapCategoryExpense).toList(growable: false);
  }

  Stream<List<CategoryExpenseAggregate>> watchTopCategories(
    AiDataFilter filter,
  ) {
    return _topCategoriesQuery(filter).watch().map(
      (QueryResult rows) =>
          rows.map(_mapCategoryExpense).toList(growable: false),
    );
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

  Selectable<QueryRow> _monthlyExpenseQuery(AiDataFilter filter) {
    final StringBuffer sql = StringBuffer('''
SELECT strftime('%Y-%m-01', CASE
         WHEN typeof(date) IN ('integer', 'real') AND ABS(date) >= 1000000000000
           THEN datetime(date / 1000000.0, 'unixepoch')
         WHEN typeof(date) IN ('integer', 'real') AND ABS(date) >= 10000000000
           THEN datetime(date / 1000.0, 'unixepoch')
         WHEN typeof(date) IN ('integer', 'real')
           THEN datetime(date, 'unixepoch')
         ELSE datetime(date)
       END) AS month,
       SUM(amount) AS total
FROM transactions
WHERE is_deleted = 0 AND type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.expense.storageValue),
    ];
    _applyTransactionFilters(sql, variables, filter);
    sql.write('GROUP BY month ORDER BY month DESC');
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
       SUM(t.amount) AS total
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
      ..write(' GROUP BY c.id, c.name, c.color ')
      ..write('ORDER BY total DESC ')
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
      'i.amount AS allocated, '
      'i.spent AS spent '
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
    if (filter.startDate != null) {
      sql.write('AND ${prefix}date >= ? ');
      variables.add(Variable<DateTime>(filter.startDate!));
    }
    if (filter.endDate != null) {
      sql.write('AND ${prefix}date <= ? ');
      variables.add(Variable<DateTime>(filter.endDate!));
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

  MonthlyExpenseAggregate _mapMonthlyExpense(QueryRow row) {
    final String monthValue = row.read<String>('month');
    final DateTime month = DateTime.parse(monthValue);
    final double total = row.read<double?>('total') ?? 0;
    return MonthlyExpenseAggregate(month: month, totalExpense: total);
  }

  CategoryExpenseAggregate _mapCategoryExpense(QueryRow row) {
    final String? categoryId = row.read<String?>('category_id');
    final String displayName = row.read<String>('display_name');
    final String color = row.read<String>('color');
    final double total = row.read<double?>('total') ?? 0;
    return CategoryExpenseAggregate(
      categoryId: categoryId?.isEmpty ?? true ? null : categoryId,
      displayName: displayName,
      totalExpense: total,
      color: color.isEmpty ? null : color,
    );
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
      allocated: row.read<double>('allocated'),
      spent: row.read<double>('spent'),
      accountIds: accounts,
      categoryIds: categories,
    );
  }
}

typedef QueryResult = List<QueryRow>;
