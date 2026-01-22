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
            openingBalance: const drift.Value<double>(100),
            openingBalanceMinor: const drift.Value<String>('10000'),
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
            openingBalance: const drift.Value<double>(50),
            openingBalanceMinor: const drift.Value<String>('5000'),
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
            name: const drift.Value<String>('Salary'),
            type: const drift.Value<String>('income'),
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
            name: const drift.Value<String>('Food'),
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
    String? transferAccountId,
    String? categoryId,
    bool isDeleted = false,
  }) async {
    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion(
            id: drift.Value<String>(id),
            accountId: drift.Value<String>(accountId),
            transferAccountId: drift.Value<String?>(transferAccountId),
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

  test('watchAnalyticsCategoryTotals агрегирует суммы по категориям', () async {
    final DateTime start = DateTime(2025, 1, 1);
    final DateTime end = DateTime(2025, 3, 1);

    await insertTx(
      id: 't1',
      accountId: 'a1',
      date: DateTime(2025, 1, 5),
      amount: MoneyAmount(minor: BigInt.from(200000), scale: 2),
      type: TransactionType.income,
      categoryId: 'c1',
    );
    await insertTx(
      id: 't2',
      accountId: 'a1',
      date: DateTime(2025, 1, 10),
      amount: MoneyAmount(minor: BigInt.from(50000), scale: 2),
      type: TransactionType.expense,
      categoryId: 'c2',
    );
    await insertTx(
      id: 't3',
      accountId: 'a1',
      date: DateTime(2025, 1, 15),
      amount: MoneyAmount(minor: BigInt.from(100000), scale: 2),
      type: TransactionType.transfer,
      transferAccountId: 'a2',
    );
    await insertTx(
      id: 't4',
      accountId: 'a2',
      date: DateTime(2025, 1, 20),
      amount: MoneyAmount(minor: BigInt.from(30000), scale: 2),
      type: TransactionType.income,
      categoryId: 'c1',
    );
    await insertTx(
      id: 't5',
      accountId: 'a2',
      date: DateTime(2025, 2, 5),
      amount: MoneyAmount(minor: BigInt.from(20000), scale: 2),
      type: TransactionType.expense,
      categoryId: null,
    );

    final List<AnalyticsCategoryTotalsRow> rows = await dao
        .watchAnalyticsCategoryTotals(start: start, end: end)
        .first;

    final Map<String?, AnalyticsCategoryTotalsRow> byCategory = {
      for (final AnalyticsCategoryTotalsRow row in rows) row.categoryId: row,
    };

    expect(byCategory['c1']!.income.minor, BigInt.from(230000));
    expect(byCategory['c1']!.expense.minor, BigInt.zero);
    expect(byCategory['c2']!.expense.minor, BigInt.from(50000));
    expect(byCategory[null]!.expense.minor, BigInt.from(20000));
  });

  test(
    'watchMonthlyCashflowTotals учитывает переводы и фильтр счетов',
    () async {
      final DateTime start = DateTime(2025, 1, 1);
      final DateTime end = DateTime(2025, 3, 1);
      final DateTime nowInclusive = DateTime(2025, 2, 15, 23, 59);

      await insertTx(
        id: 't1',
        accountId: 'a1',
        date: DateTime(2025, 1, 5),
        amount: MoneyAmount(minor: BigInt.from(200000), scale: 2),
        type: TransactionType.income,
      );
      await insertTx(
        id: 't2',
        accountId: 'a1',
        date: DateTime(2025, 1, 10),
        amount: MoneyAmount(minor: BigInt.from(50000), scale: 2),
        type: TransactionType.expense,
      );
      await insertTx(
        id: 't3',
        accountId: 'a1',
        date: DateTime(2025, 1, 15),
        amount: MoneyAmount(minor: BigInt.from(100000), scale: 2),
        type: TransactionType.transfer,
        transferAccountId: 'a2',
      );
      await insertTx(
        id: 't4',
        accountId: 'a2',
        date: DateTime(2025, 2, 10),
        amount: MoneyAmount(minor: BigInt.from(70000), scale: 2),
        type: TransactionType.transfer,
        transferAccountId: 'a1',
      );
      await insertTx(
        id: 't_future',
        accountId: 'a1',
        date: DateTime(2025, 2, 20),
        amount: MoneyAmount(minor: BigInt.from(15000), scale: 2),
        type: TransactionType.income,
      );

      final List<MonthlyCashflowTotalsRow> rows = await dao
          .watchMonthlyCashflowTotals(
            start: start,
            end: end,
            nowInclusive: nowInclusive,
            accountIds: <String>['a1'],
          )
          .first;

      final Map<String, MonthlyCashflowTotalsRow> byMonth = {
        for (final MonthlyCashflowTotalsRow row in rows) row.monthKey: row,
      };

      expect(byMonth['2025-01']!.income.minor, BigInt.from(200000));
      expect(byMonth['2025-01']!.expense.minor, BigInt.from(150000));
      expect(byMonth['2025-02']!.income.minor, BigInt.from(70000));
      expect(byMonth['2025-02']!.expense.minor, BigInt.zero);
    },
  );

  test(
    'watchMonthlyBalanceTotals возвращает максимум за месяц по счету',
    () async {
      final DateTime start = DateTime(2025, 1, 1);
      final DateTime end = DateTime(2025, 3, 1);

      await insertTx(
        id: 't1',
        accountId: 'a1',
        date: DateTime(2025, 1, 5),
        amount: MoneyAmount(minor: BigInt.from(200000), scale: 2),
        type: TransactionType.income,
      );
      await insertTx(
        id: 't2',
        accountId: 'a1',
        date: DateTime(2025, 1, 10),
        amount: MoneyAmount(minor: BigInt.from(50000), scale: 2),
        type: TransactionType.expense,
      );
      await insertTx(
        id: 't3',
        accountId: 'a1',
        date: DateTime(2025, 1, 15),
        amount: MoneyAmount(minor: BigInt.from(100000), scale: 2),
        type: TransactionType.transfer,
        transferAccountId: 'a2',
      );
      await insertTx(
        id: 't4',
        accountId: 'a2',
        date: DateTime(2025, 2, 10),
        amount: MoneyAmount(minor: BigInt.from(70000), scale: 2),
        type: TransactionType.transfer,
        transferAccountId: 'a1',
      );

      final List<MonthlyBalanceTotalsRow> rows = await dao
          .watchMonthlyBalanceTotals(
            start: start,
            end: end,
            accountIds: <String>['a1'],
          )
          .first;

      final Map<String, MonthlyBalanceTotalsRow> byMonth = {
        for (final MonthlyBalanceTotalsRow row in rows) row.monthKey: row,
      };

      expect(byMonth['2025-01']!.maxBalance.minor, BigInt.from(210000));
      expect(byMonth['2025-02']!.maxBalance.minor, BigInt.from(130000));
    },
  );
}
