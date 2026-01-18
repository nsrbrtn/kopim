import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  late db.AppDatabase database;
  late TransactionDao transactionDao;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late CreditDao creditDao;
  late SavingGoalDao savingGoalDao;
  late GoalContributionDao contributionDao;
  late OutboxDao outboxDao;
  late TransactionRepositoryImpl repository;
  final DateTime now = DateTime.utc(2024, 6, 1, 9);

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    transactionDao = TransactionDao(database);
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    creditDao = CreditDao(database);
    savingGoalDao = SavingGoalDao(database);
    contributionDao = GoalContributionDao(database);
    outboxDao = OutboxDao(database);
    repository = TransactionRepositoryImpl(
      database: database,
      transactionDao: transactionDao,
      accountDao: accountDao,
      creditDao: creditDao,
      savingGoalDao: savingGoalDao,
      goalContributionDao: contributionDao,
      outboxDao: outboxDao,
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedAccount({
    required String id,
    required double balance,
  }) async {
    final AccountEntity account = AccountEntity(
      id: id,
      name: 'Account $id',
      balance: balance,
      currency: 'USD',
      type: 'card',
      createdAt: now,
      updatedAt: now,
    );
    await accountDao.upsert(account);
  }

  test('upsert applies expense delta to account balance', () async {
    await seedAccount(id: 'acc-1', balance: 100);

    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-1',
      accountId: 'acc-1',
      amount: 30,
      date: now,
      type: TransactionType.expense.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await repository.upsert(transaction);

    final db.AccountRow? updated = await accountDao.findById('acc-1');
    expect(updated, isNotNull);
    expect(updated!.balance, closeTo(70, 1e-9));
  });

  test('upsert applies transfer delta to both accounts', () async {
    await seedAccount(id: 'acc-1', balance: 100);
    await seedAccount(id: 'acc-2', balance: 50);

    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-2',
      accountId: 'acc-1',
      transferAccountId: 'acc-2',
      amount: 40,
      date: now,
      type: TransactionType.transfer.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await repository.upsert(transaction);

    final db.AccountRow? source = await accountDao.findById('acc-1');
    final db.AccountRow? target = await accountDao.findById('acc-2');
    expect(source, isNotNull);
    expect(target, isNotNull);
    expect(source!.balance, closeTo(60, 1e-9));
    expect(target!.balance, closeTo(90, 1e-9));
  });

  test('upsert applies credit repayment to credit account', () async {
    await seedAccount(id: 'acc-1', balance: 200);
    await seedAccount(id: 'credit-1', balance: -500);

    final Category category = Category(
      id: 'cat-credit',
      name: 'Credit',
      type: 'expense',
      icon: const PhosphorIconDescriptor(
        name: 'credit-card',
        style: PhosphorIconStyle.bold,
      ),
      color: '#000000',
      parentId: null,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      isSystem: true,
    );
    await categoryDao.upsert(category);

    final CreditEntity credit = CreditEntity(
      id: 'credit-entity',
      accountId: 'credit-1',
      categoryId: 'cat-credit',
      totalAmount: 1000,
      interestRate: 0,
      termMonths: 12,
      startDate: now,
      createdAt: now,
      updatedAt: now,
    );
    await creditDao.upsert(credit);

    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-3',
      accountId: 'acc-1',
      categoryId: 'cat-credit',
      amount: 100,
      date: now,
      type: TransactionType.expense.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await repository.upsert(transaction);

    final db.AccountRow? source = await accountDao.findById('acc-1');
    final db.AccountRow? creditAccount = await accountDao.findById('credit-1');
    expect(source, isNotNull);
    expect(creditAccount, isNotNull);
    expect(source!.balance, closeTo(100, 1e-9));
    expect(creditAccount!.balance, closeTo(-400, 1e-9));
  });

  test('softDelete reverses transaction effect', () async {
    await seedAccount(id: 'acc-1', balance: 100);

    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-4',
      accountId: 'acc-1',
      amount: 40,
      date: now,
      type: TransactionType.expense.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await repository.upsert(transaction);
    await repository.softDelete(transaction.id);

    final db.AccountRow? updated = await accountDao.findById('acc-1');
    expect(updated, isNotNull);
    expect(updated!.balance, closeTo(100, 1e-9));
  });
}
