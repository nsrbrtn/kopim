import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AiToolCurrencyTotal {
  const AiToolCurrencyTotal({
    required this.currency,
    required this.total,
    required this.count,
  });

  final String currency;
  final MoneyAmount total;
  final int count;
}

class AiToolTransactionRow {
  const AiToolTransactionRow({
    required this.id,
    required this.amount,
    required this.currency,
    required this.type,
    required this.date,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    required this.note,
  });

  final String id;
  final MoneyAmount amount;
  final String currency;
  final String type;
  final DateTime date;
  final String accountId;
  final String accountName;
  final String? categoryId;
  final String? categoryName;
  final String? note;
}

class AiToolCategoryMatch {
  const AiToolCategoryMatch({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });

  final String id;
  final String name;
  final String type;
  final String? color;
}

class AiToolAccountMatch {
  const AiToolAccountMatch({
    required this.id,
    required this.name,
    required this.currency,
    required this.type,
  });

  final String id;
  final String name;
  final String currency;
  final String type;
}

class AiToolBudgetCategorySpend {
  const AiToolBudgetCategorySpend({
    required this.categoryId,
    required this.name,
    required this.spent,
  });

  final String? categoryId;
  final String name;
  final MoneyAmount spent;
}

class AiAssistantToolDao {
  AiAssistantToolDao(this._db);

  final db.AppDatabase _db;

  Future<List<AiToolCurrencyTotal>> getTotalsByCurrency({
    required String transactionType,
    DateTime? startDate,
    DateTime? endDate,
    List<String> accountIds = const <String>[],
    List<String> categoryIds = const <String>[],
  }) async {
    final StringBuffer sql = StringBuffer('''
SELECT a.currency AS currency,
       t.amount_scale AS amount_scale,
       COALESCE(SUM(CAST(t.amount_minor AS INTEGER)), 0) AS total_minor,
       COUNT(t.id) AS count
FROM transactions t
INNER JOIN accounts a ON a.id = t.account_id
WHERE t.is_deleted = 0
  AND a.is_deleted = 0
  AND t.type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(transactionType),
    ];
    _applyTransactionFilters(
      sql,
      variables,
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tableAlias: 't',
    );
    sql.write('GROUP BY a.currency, t.amount_scale ORDER BY total_minor DESC');

    final List<QueryRow> rows = await _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{
            _db.transactions,
            _db.accounts,
          },
        )
        .get();

    final Map<String, MoneyAccumulator> totals = <String, MoneyAccumulator>{};
    final Map<String, int> counts = <String, int>{};
    for (final QueryRow row in rows) {
      final String currency = row.read<String>('currency');
      final int scale = row.read<int>('amount_scale');
      final int totalMinor = row.read<int>('total_minor');
      final MoneyAccumulator accumulator = totals.putIfAbsent(
        currency,
        MoneyAccumulator.new,
      );
      accumulator.add(
        MoneyAmount(minor: BigInt.from(totalMinor), scale: scale),
      );
      counts[currency] = (counts[currency] ?? 0) + row.read<int>('count');
    }

    final List<AiToolCurrencyTotal> items = totals.entries
        .map(
          (MapEntry<String, MoneyAccumulator> entry) => AiToolCurrencyTotal(
            currency: entry.key,
            total: MoneyAmount(
              minor: entry.value.minor,
              scale: entry.value.scale,
            ),
            count: counts[entry.key] ?? 0,
          ),
        )
        .toList(growable: false);
    items.sort((AiToolCurrencyTotal a, AiToolCurrencyTotal b) {
      return b.total.toDouble().compareTo(a.total.toDouble());
    });
    return items;
  }

  Future<List<AiToolTransactionRow>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<String> accountIds = const <String>[],
    List<String> categoryIds = const <String>[],
    String? transactionType,
    int limit = 200,
  }) async {
    final StringBuffer sql = StringBuffer('''
SELECT t.id AS id,
       t.amount_minor AS amount_minor,
       t.amount_scale AS amount_scale,
       t.type AS type,
       t.date AS date,
       t.note AS note,
       a.id AS account_id,
       a.name AS account_name,
       a.currency AS currency,
       c.id AS category_id,
       c.name AS category_name
FROM transactions t
INNER JOIN accounts a ON a.id = t.account_id
LEFT JOIN categories c ON c.id = t.category_id
WHERE t.is_deleted = 0
  AND a.is_deleted = 0
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[];
    if (transactionType != null && transactionType.isNotEmpty) {
      sql.write('AND t.type = ? ');
      variables.add(Variable<String>(transactionType));
    }
    _applyTransactionFilters(
      sql,
      variables,
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tableAlias: 't',
    );
    sql.write('ORDER BY t.date DESC LIMIT ?');
    variables.add(Variable<int>(limit));

    final List<QueryRow> rows = await _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{
            _db.transactions,
            _db.accounts,
            _db.categories,
          },
        )
        .get();

    return rows
        .map(
          (QueryRow row) => AiToolTransactionRow(
            id: row.read<String>('id'),
            amount: MoneyAmount(
              minor: BigInt.parse(row.read<String>('amount_minor')),
              scale: row.read<int>('amount_scale'),
            ),
            type: row.read<String>('type'),
            date: row.read<DateTime>('date'),
            note: row.read<String?>('note'),
            accountId: row.read<String>('account_id'),
            accountName: row.read<String>('account_name'),
            currency: row.read<String>('currency'),
            categoryId: row.read<String?>('category_id'),
            categoryName: row.read<String?>('category_name'),
          ),
        )
        .toList(growable: false);
  }

  Future<List<AiToolCategoryMatch>> findCategories({
    required String query,
    int limit = 20,
  }) async {
    final String rawQuery = query.trim();
    final String normalized = rawQuery.toLowerCase();
    if (normalized.isEmpty) {
      return const <AiToolCategoryMatch>[];
    }
    final bool useAsciiLower = _isAscii(normalized);
    final List<QueryRow> rows = await _db
        .customSelect(
          '''
SELECT id, name, type, color
FROM categories
WHERE is_deleted = 0
  AND ${useAsciiLower ? 'LOWER(name)' : 'name'} LIKE ?
ORDER BY name ASC
LIMIT ?
''',
          variables: <Variable<Object>>[
            Variable<String>('%${useAsciiLower ? normalized : rawQuery}%'),
            Variable<int>(limit),
          ],
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.categories},
        )
        .get();

    return rows
        .map(
          (QueryRow row) => AiToolCategoryMatch(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            type: row.read<String>('type'),
            color: row.read<String?>('color'),
          ),
        )
        .toList(growable: false);
  }

  Future<List<AiToolAccountMatch>> findAccounts({
    required String query,
    int limit = 20,
  }) async {
    final String rawQuery = query.trim();
    final String normalized = rawQuery.toLowerCase();
    if (normalized.isEmpty) {
      return const <AiToolAccountMatch>[];
    }
    final bool useAsciiLower = _isAscii(normalized);
    final List<QueryRow> rows = await _db
        .customSelect(
          '''
SELECT id, name, currency, type
FROM accounts
WHERE is_deleted = 0
  AND is_hidden = 0
  AND ${useAsciiLower ? 'LOWER(name)' : 'name'} LIKE ?
ORDER BY name ASC
LIMIT ?
''',
          variables: <Variable<Object>>[
            Variable<String>('%${useAsciiLower ? normalized : rawQuery}%'),
            Variable<int>(limit),
          ],
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.accounts},
        )
        .get();

    return rows
        .map(
          (QueryRow row) => AiToolAccountMatch(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            currency: row.read<String>('currency'),
            type: row.read<String>('type'),
          ),
        )
        .toList(growable: false);
  }

  bool _isAscii(String value) {
    for (final int code in value.runes) {
      if (code > 0x7f) {
        return false;
      }
    }
    return true;
  }

  Future<List<String>> expandCategoryIds(List<String> categoryIds) async {
    final List<String> normalized = categoryIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalized.isEmpty) {
      return const <String>[];
    }

    final List<QueryRow> rows = await _db
        .customSelect(
          '''
SELECT id, parent_id
FROM categories
WHERE is_deleted = 0
''',
          readsFrom: <TableInfo<dynamic, dynamic>>{_db.categories},
        )
        .get();

    final Map<String, List<String>> childrenByParent = <String, List<String>>{};
    for (final QueryRow row in rows) {
      final String id = row.read<String>('id');
      final String? parentId = row.read<String?>('parent_id');
      if (parentId == null || parentId.isEmpty) {
        continue;
      }
      childrenByParent.putIfAbsent(parentId, () => <String>[]).add(id);
    }

    final Set<String> expanded = <String>{...normalized};
    final List<String> stack = List<String>.from(normalized);
    while (stack.isNotEmpty) {
      final String current = stack.removeLast();
      final List<String>? children = childrenByParent[current];
      if (children == null) {
        continue;
      }
      for (final String child in children) {
        if (expanded.add(child)) {
          stack.add(child);
        }
      }
    }

    return expanded.toList(growable: false);
  }

  Future<List<Budget>> getBudgets({String? budgetId}) async {
    final SimpleSelectStatement<db.$BudgetsTable, db.BudgetRow> query =
        _db.select(_db.budgets)
          ..where((db.$BudgetsTable tbl) => tbl.isDeleted.equals(false));
    if (budgetId != null && budgetId.isNotEmpty) {
      query.where((db.$BudgetsTable tbl) => tbl.id.equals(budgetId));
    }
    final List<db.BudgetRow> rows = await query.get();
    return rows.map(_mapBudgetRow).toList(growable: false);
  }

  Future<MoneyAmount> getBudgetTotalSpent({
    required DateTime startDate,
    required DateTime endDate,
    List<String> accountIds = const <String>[],
    List<String> categoryIds = const <String>[],
  }) async {
    final StringBuffer sql = StringBuffer('''
SELECT t.amount_scale AS amount_scale,
       COALESCE(SUM(CAST(t.amount_minor AS INTEGER)), 0) AS total_minor
FROM transactions t
INNER JOIN accounts a ON a.id = t.account_id
WHERE t.is_deleted = 0
  AND a.is_deleted = 0
  AND t.type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.expense.storageValue),
    ];
    _applyTransactionFilters(
      sql,
      variables,
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tableAlias: 't',
    );

    sql.write('GROUP BY t.amount_scale');

    final List<QueryRow> rows = await _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{
            _db.transactions,
            _db.accounts,
          },
        )
        .get();

    if (rows.isEmpty) {
      return const MoneyAmount(minor: BigInt.zero, scale: 2);
    }

    final MoneyAccumulator accumulator = MoneyAccumulator();
    for (final QueryRow row in rows) {
      accumulator.add(
        MoneyAmount(
          minor: BigInt.from(row.read<int>('total_minor')),
          scale: row.read<int>('amount_scale'),
        ),
      );
    }
    return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
  }

  Future<List<AiToolBudgetCategorySpend>> getBudgetCategorySpending({
    required DateTime startDate,
    required DateTime endDate,
    List<String> accountIds = const <String>[],
    List<String> categoryIds = const <String>[],
  }) async {
    final StringBuffer sql = StringBuffer('''
SELECT t.category_id AS category_id,
       COALESCE(c.name, 'Без категории') AS name,
       t.amount_scale AS amount_scale,
       COALESCE(SUM(CAST(t.amount_minor AS INTEGER)), 0) AS total_minor
FROM transactions t
INNER JOIN accounts a ON a.id = t.account_id
LEFT JOIN categories c ON c.id = t.category_id
WHERE t.is_deleted = 0
  AND a.is_deleted = 0
  AND t.type = ?
''');
    // ignore: always_specify_types
    final List<Variable> variables = <Variable>[
      Variable<String>(TransactionType.expense.storageValue),
    ];
    _applyTransactionFilters(
      sql,
      variables,
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tableAlias: 't',
    );
    sql.write(
      'GROUP BY t.category_id, c.name, t.amount_scale ORDER BY total_minor DESC',
    );

    final List<QueryRow> rows = await _db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: <TableInfo<dynamic, dynamic>>{
            _db.transactions,
            _db.accounts,
            _db.categories,
          },
        )
        .get();

    final Map<String?, _BudgetCategoryAccumulator> buckets =
        <String?, _BudgetCategoryAccumulator>{};
    for (final QueryRow row in rows) {
      final String? categoryId = row.read<String?>('category_id');
      final _BudgetCategoryAccumulator bucket = buckets.putIfAbsent(
        categoryId,
        () => _BudgetCategoryAccumulator(name: row.read<String>('name')),
      );
      bucket.total.add(
        MoneyAmount(
          minor: BigInt.from(row.read<int>('total_minor')),
          scale: row.read<int>('amount_scale'),
        ),
      );
    }

    final List<AiToolBudgetCategorySpend> items = buckets.entries
        .map(
          (MapEntry<String?, _BudgetCategoryAccumulator> entry) =>
              AiToolBudgetCategorySpend(
                categoryId: entry.key,
                name: entry.value.name,
                spent: MoneyAmount(
                  minor: entry.value.total.minor,
                  scale: entry.value.total.scale,
                ),
              ),
        )
        .toList(growable: false);
    items.sort((AiToolBudgetCategorySpend a, AiToolBudgetCategorySpend b) {
      return b.spent.toDouble().compareTo(a.spent.toDouble());
    });
    return items;
  }

  Budget _mapBudgetRow(db.BudgetRow row) {
    return Budget(
      id: row.id,
      title: row.title,
      period: BudgetPeriodX.fromStorage(row.period),
      startDate: row.startDate,
      endDate: row.endDate,
      amount: row.amount,
      scope: BudgetScopeX.fromStorage(row.scope),
      categories: row.categories,
      accounts: row.accounts,
      categoryAllocations: row.categoryAllocations
          .map(
            (Map<String, dynamic> json) =>
                BudgetCategoryAllocation.fromJson(json),
          )
          .toList(growable: false),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }

  void _applyTransactionFilters(
    StringBuffer sql,
    // ignore: always_specify_types
    List<Variable> variables, {
    DateTime? startDate,
    DateTime? endDate,
    List<String> accountIds = const <String>[],
    List<String> categoryIds = const <String>[],
    String tableAlias = 'transactions',
  }) {
    final String prefix = tableAlias.isEmpty ? '' : '$tableAlias.';

    if (startDate != null) {
      sql.write('AND ${prefix}date >= ? ');
      variables.add(Variable<DateTime>(startDate));
    }
    if (endDate != null) {
      sql.write('AND ${prefix}date <= ? ');
      variables.add(Variable<DateTime>(endDate));
    }
    if (accountIds.isNotEmpty) {
      final String placeholders = List<String>.filled(
        accountIds.length,
        '?',
      ).join(', ');
      sql.write('AND ${prefix}account_id IN ($placeholders) ');
      variables.addAll(accountIds.map((String id) => Variable<String>(id)));
    }
    if (categoryIds.isNotEmpty) {
      final List<String> notEmpty = categoryIds
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

  String toTransactionType(String type) {
    if (type == TransactionType.income.name ||
        type == TransactionType.income.storageValue) {
      return TransactionType.income.storageValue;
    }
    if (type == TransactionType.transfer.name ||
        type == TransactionType.transfer.storageValue) {
      return TransactionType.transfer.storageValue;
    }
    if (type == TransactionType.expense.name ||
        type == TransactionType.expense.storageValue) {
      return TransactionType.expense.storageValue;
    }
    return type;
  }
}

class _BudgetCategoryAccumulator {
  _BudgetCategoryAccumulator({required this.name});

  final String name;
  final MoneyAccumulator total = MoneyAccumulator();
}
