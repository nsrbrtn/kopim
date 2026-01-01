import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AiToolCurrencyTotal {
  const AiToolCurrencyTotal({
    required this.currency,
    required this.total,
    required this.count,
  });

  final String currency;
  final double total;
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
  final double amount;
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
       COALESCE(SUM(t.amount), 0) AS total,
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
    sql.write('GROUP BY a.currency ORDER BY total DESC');

    final List<QueryRow> rows = await _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{_db.transactions, _db.accounts},
    ).get();

    return rows
        .map(
          (QueryRow row) => AiToolCurrencyTotal(
            currency: row.read<String>('currency'),
            total: row.read<double>('total'),
            count: row.read<int>('count'),
          ),
        )
        .toList(growable: false);
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
       t.amount AS amount,
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

    final List<QueryRow> rows = await _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: <TableInfo<dynamic, dynamic>>{
        _db.transactions,
        _db.accounts,
        _db.categories,
      },
    ).get();

    return rows
        .map(
          (QueryRow row) => AiToolTransactionRow(
            id: row.read<String>('id'),
            amount: row.read<double>('amount'),
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
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const <AiToolCategoryMatch>[];
    }
    final List<QueryRow> rows = await _db.customSelect(
      '''
SELECT id, name, type, color
FROM categories
WHERE is_deleted = 0
  AND LOWER(name) LIKE ?
ORDER BY name ASC
LIMIT ?
''',
      variables: <Variable<Object>>[
        Variable<String>('%$normalized%'),
        Variable<int>(limit),
      ],
      readsFrom: <TableInfo<dynamic, dynamic>>{_db.categories},
    ).get();

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
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const <AiToolAccountMatch>[];
    }
    final List<QueryRow> rows = await _db.customSelect(
      '''
SELECT id, name, currency, type
FROM accounts
WHERE is_deleted = 0
  AND is_hidden = 0
  AND LOWER(name) LIKE ?
ORDER BY name ASC
LIMIT ?
''',
      variables: <Variable<Object>>[
        Variable<String>('%$normalized%'),
        Variable<int>(limit),
      ],
      readsFrom: <TableInfo<dynamic, dynamic>>{_db.accounts},
    ).get();

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
    if (type == TransactionType.expense.name ||
        type == TransactionType.expense.storageValue) {
      return TransactionType.expense.storageValue;
    }
    return type;
  }
}
