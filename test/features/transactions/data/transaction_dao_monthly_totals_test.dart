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
            currency: const drift.Value<String>('USD'),
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
            currency: const drift.Value<String>('USD'),
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
    bool isDeleted = false,
  }) async {
    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion(
            id: drift.Value<String>(id),
            accountId: drift.Value<String>(accountId),
            categoryId: const drift.Value<String?>('c1'),
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
    'watchAccountMonthlyTotals агрегирует суммы по счетам за месяц',
    () async {
      final DateTime start = DateTime(2025, 1, 1);
      final DateTime end = DateTime(2025, 2, 1);

      await insertTx(
        id: 't1',
        accountId: 'a1',
        date: DateTime(2025, 1, 1, 0, 0),
        amount: MoneyAmount(minor: BigInt.from(10000), scale: 2),
        type: TransactionType.income,
      );
      await insertTx(
        id: 't2',
        accountId: 'a1',
        date: DateTime(2025, 1, 15, 12, 0),
        amount: MoneyAmount(minor: BigInt.from(4000), scale: 2),
        type: TransactionType.expense,
      );
      await insertTx(
        id: 't3',
        accountId: 'a1',
        date: DateTime(2025, 2, 1, 0, 0),
        amount: MoneyAmount(minor: BigInt.from(500), scale: 2),
        type: TransactionType.expense,
      );
      await insertTx(
        id: 't4',
        accountId: 'a2',
        date: DateTime(2025, 1, 20),
        amount: MoneyAmount(minor: BigInt.from(-5000), scale: 2),
        type: TransactionType.income,
      );
      await insertTx(
        id: 't5',
        accountId: 'a2',
        date: DateTime(2025, 1, 25),
        amount: MoneyAmount(minor: BigInt.from(99900), scale: 2),
        type: TransactionType.expense,
        isDeleted: true,
      );

      final List<AccountMonthlyTotalsRow> rows = await dao
          .watchAccountMonthlyTotals(start: start, end: end)
          .first;

      final Map<String, AccountMonthlyTotalsRow> byAccount =
          <String, AccountMonthlyTotalsRow>{
            for (final AccountMonthlyTotalsRow row in rows) row.accountId: row,
          };

      expect(byAccount.keys.toSet(), <String>{'a1', 'a2'});
      expect(byAccount['a1']!.income.minor, BigInt.from(10000));
      expect(byAccount['a1']!.expense.minor, BigInt.from(4000));
      expect(byAccount['a2']!.income.minor, BigInt.from(5000));
      expect(byAccount['a2']!.expense.minor, BigInt.zero);
    },
  );

  test(
    'watchAccountMonthlyTotals возвращает пустой список без транзакций',
    () async {
      final List<AccountMonthlyTotalsRow> rows = await dao
          .watchAccountMonthlyTotals(
            start: DateTime(2025, 3, 1),
            end: DateTime(2025, 4, 1),
          )
          .first;
      expect(rows, isEmpty);
    },
  );
}
