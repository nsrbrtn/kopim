import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  late AppDatabase database;
  late TransactionDao dao;

  setUp(() async {
    database = AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    dao = TransactionDao(database);

    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion(
            id: const drift.Value<String>('a1'),
            name: const drift.Value<String>('Main'),
            balance: const drift.Value<double>(0),
            balanceMinor: const drift.Value<String>('0'),
            openingBalance: const drift.Value<double>(0),
            openingBalanceMinor: const drift.Value<String>('0'),
            currency: const drift.Value<String>('USD'),
            currencyScale: const drift.Value<int>(2),
            type: const drift.Value<String>('checking'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isPrimary: const drift.Value<bool>(true),
          ),
        );
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion(
            id: const drift.Value<String>('a2'),
            name: const drift.Value<String>('Secondary'),
            balance: const drift.Value<double>(0),
            balanceMinor: const drift.Value<String>('0'),
            openingBalance: const drift.Value<double>(0),
            openingBalanceMinor: const drift.Value<String>('0'),
            currency: const drift.Value<String>('USD'),
            currencyScale: const drift.Value<int>(2),
            type: const drift.Value<String>('checking'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isPrimary: const drift.Value<bool>(false),
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion(
            id: const drift.Value<String>('c1'),
            name: const drift.Value<String>('Food'),
            type: const drift.Value<String>('expense'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isSystem: const drift.Value<bool>(false),
            isFavorite: const drift.Value<bool>(false),
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion(
            id: const drift.Value<String>('c2'),
            name: const drift.Value<String>('Health'),
            type: const drift.Value<String>('expense'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isSystem: const drift.Value<bool>(false),
            isFavorite: const drift.Value<bool>(false),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertTx({
    required String id,
    required String accountId,
    required DateTime date,
    required MoneyAmount amount,
    required TransactionType type,
    String? categoryId,
    bool isDeleted = false,
  }) async {
    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion(
            id: drift.Value<String>(id),
            accountId: drift.Value<String>(accountId),
            categoryId: drift.Value<String?>(categoryId),
            amount: drift.Value<double>(amount.toDouble()),
            amountMinor: drift.Value<String>(amount.minor.toString()),
            amountScale: drift.Value<int>(amount.scale),
            date: drift.Value<DateTime>(date),
            type: drift.Value<String>(type.storageValue),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: drift.Value<bool>(isDeleted),
          ),
        );
  }

  test(
    'watchBudgetExpenseTotals суммирует расходы и фильтрует счета',
    () async {
      final DateTime start = DateTime(2025, 1, 1);
      final DateTime end = DateTime(2025, 2, 1);

      await insertTx(
        id: 't1',
        accountId: 'a1',
        date: DateTime(2025, 1, 5),
        amount: MoneyAmount(minor: BigInt.from(2500), scale: 2),
        type: TransactionType.expense,
        categoryId: 'c1',
      );
      await insertTx(
        id: 't2',
        accountId: 'a2',
        date: DateTime(2025, 1, 6),
        amount: MoneyAmount(minor: BigInt.from(1000), scale: 2),
        type: TransactionType.expense,
        categoryId: 'c1',
      );
      await insertTx(
        id: 't3',
        accountId: 'a1',
        date: DateTime(2025, 1, 7),
        amount: MoneyAmount(minor: BigInt.from(3000), scale: 2),
        type: TransactionType.income,
        categoryId: 'c1',
      );
      await insertTx(
        id: 't4',
        accountId: 'a1',
        date: DateTime(2025, 1, 8),
        amount: MoneyAmount(minor: BigInt.from(1500), scale: 2),
        type: TransactionType.transfer,
        categoryId: 'c2',
      );

      final List<BudgetExpenseTotalsRow> rows = await dao
          .watchBudgetExpenseTotals(
            start: start,
            end: end,
            accountIds: <String>['a1'],
          )
          .first;

      expect(rows, hasLength(1));
      expect(rows.single.accountId, 'a1');
      expect(rows.single.categoryId, 'c1');
      expect(rows.single.expense.minor, BigInt.from(2500));
    },
  );

  test('watchBudgetExpenseTotals выдерживает нагрузочный набор', () async {
    final DateTime start = DateTime(2025, 1, 1);
    final DateTime end = DateTime(2025, 2, 1);

    await database.batch((drift.Batch batch) {
      final List<TransactionsCompanion> rows = <TransactionsCompanion>[];
      for (int index = 0; index < 5000; index += 1) {
        rows.add(
          TransactionsCompanion(
            id: drift.Value<String>('t$index'),
            accountId: const drift.Value<String>('a1'),
            categoryId: drift.Value<String>(index.isEven ? 'c1' : 'c2'),
            amount: const drift.Value<double>(1),
            amountMinor: const drift.Value<String>('100'),
            amountScale: const drift.Value<int>(2),
            date: drift.Value<DateTime>(
              DateTime(2025, 1, 1).add(Duration(days: index % 25)),
            ),
            type: drift.Value<String>(TransactionType.expense.storageValue),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
          ),
        );
      }
      batch.insertAll(database.transactions, rows);
    });

    final List<BudgetExpenseTotalsRow> rows = await dao
        .watchBudgetExpenseTotals(start: start, end: end)
        .first;

    final Map<String?, BudgetExpenseTotalsRow> byCategory =
        <String?, BudgetExpenseTotalsRow>{
          for (final BudgetExpenseTotalsRow row in rows) row.categoryId: row,
        };

    expect(byCategory['c1']!.expense.minor, BigInt.from(250000));
    expect(byCategory['c2']!.expense.minor, BigInt.from(250000));
  });
}
