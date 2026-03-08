import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late CreditDao creditDao;
  late SavingGoalDao savingGoalDao;
  late TransactionDao transactionDao;
  late OutboxDao outboxDao;
  late ImportDataRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    creditDao = CreditDao(database);
    savingGoalDao = SavingGoalDao(database);
    transactionDao = TransactionDao(database);
    outboxDao = OutboxDao(database);
    repository = ImportDataRepositoryImpl(
      database: database,
      accountDao: accountDao,
      categoryDao: categoryDao,
      creditDao: creditDao,
      savingGoalDao: savingGoalDao,
      transactionDao: transactionDao,
      outboxDao: outboxDao,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('пересчитывает балансы после импорта транзакций', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account1 = AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balanceMinor: BigInt.from(6000),
      currency: 'USD',
      currencyScale: 2,
      type: 'card',
      createdAt: now,
      updatedAt: now,
    );
    final AccountEntity account2 = AccountEntity(
      id: 'acc-2',
      name: 'Cash',
      balanceMinor: BigInt.from(1000),
      currency: 'USD',
      currencyScale: 2,
      type: 'cash',
      createdAt: now,
      updatedAt: now,
    );

    await repository.importData(
      accounts: <AccountEntity>[account1, account2],
      categories: <Category>[],
      savingGoals: <SavingGoal>[],
      transactions: <TransactionEntity>[],
    );

    final List<TransactionEntity> transactions = <TransactionEntity>[
      TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        amountMinor: BigInt.from(10000),
        amountScale: 2,
        date: now,
        type: TransactionType.income.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
      TransactionEntity(
        id: 'tx-2',
        accountId: 'acc-1',
        amountMinor: BigInt.from(3000),
        amountScale: 2,
        date: now,
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
      TransactionEntity(
        id: 'tx-3',
        accountId: 'acc-1',
        transferAccountId: 'acc-2',
        amountMinor: BigInt.from(1000),
        amountScale: 2,
        date: now,
        type: TransactionType.transfer.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await repository.importData(
      accounts: <AccountEntity>[account1, account2],
      categories: <Category>[],
      savingGoals: <SavingGoal>[],
      transactions: transactions,
    );

    final List<AccountEntity> accounts = await accountDao.getAllAccounts();
    final AccountEntity updated1 = accounts.firstWhere(
      (AccountEntity account) => account.id == 'acc-1',
    );
    final AccountEntity updated2 = accounts.firstWhere(
      (AccountEntity account) => account.id == 'acc-2',
    );

    expect(updated1.balanceAmount.toDouble(), closeTo(60, 1e-9));
    expect(updated2.balanceAmount.toDouble(), closeTo(10, 1e-9));
  });

  test('ставит импортированные сущности в outbox для синхронизации', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balanceMinor: BigInt.from(12000),
      currency: 'USD',
      currencyScale: 2,
      type: 'card',
      createdAt: now,
      updatedAt: now,
    );
    final Category category = Category(
      id: 'cat-1',
      name: 'Food',
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );
    final SavingGoal goal = SavingGoal(
      id: 'goal-1',
      userId: 'user-1',
      name: 'Vacation',
      accountId: 'acc-1',
      targetAmount: 50000,
      currentAmount: 1200,
      createdAt: now,
      updatedAt: now,
    );
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-1',
      accountId: 'acc-1',
      categoryId: 'cat-1',
      savingGoalId: 'goal-1',
      amountMinor: BigInt.from(3000),
      amountScale: 2,
      date: now,
      type: TransactionType.expense.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await repository.importData(
      accounts: <AccountEntity>[account],
      categories: <Category>[category],
      savingGoals: <SavingGoal>[goal],
      transactions: <TransactionEntity>[transaction],
    );

    final List<db.OutboxEntryRow> pending = await outboxDao.fetchPending(
      limit: 20,
    );
    expect(pending, hasLength(4));
    expect(
      pending.map((db.OutboxEntryRow entry) => entry.entityType).toSet(),
      <String>{'account', 'category', 'saving_goal', 'transaction'},
    );

    final db.OutboxEntryRow accountEntry = pending.firstWhere(
      (db.OutboxEntryRow entry) => entry.entityType == 'account',
    );
    final Map<String, dynamic> payload =
        jsonDecode(accountEntry.payload) as Map<String, dynamic>;
    expect(payload['balanceMinor'], '12000');
    expect(payload['openingBalanceMinor'], '15000');
  });
}
