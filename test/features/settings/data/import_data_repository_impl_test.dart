import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TagDao tagDao;
  late TransactionTagsDao transactionTagsDao;
  late CreditDao creditDao;
  late CreditCardDao creditCardDao;
  late DebtDao debtDao;
  late BudgetDao budgetDao;
  late BudgetInstanceDao budgetInstanceDao;
  late SavingGoalDao savingGoalDao;
  late UpcomingPaymentsDao upcomingPaymentsDao;
  late PaymentRemindersDao paymentRemindersDao;
  late TransactionDao transactionDao;
  late OutboxDao outboxDao;
  late ImportDataRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    tagDao = TagDao(database);
    transactionTagsDao = TransactionTagsDao(database);
    creditDao = CreditDao(database);
    creditCardDao = CreditCardDao(database);
    debtDao = DebtDao(database);
    budgetDao = BudgetDao(database);
    budgetInstanceDao = BudgetInstanceDao(database);
    savingGoalDao = SavingGoalDao(database);
    upcomingPaymentsDao = UpcomingPaymentsDao(database);
    paymentRemindersDao = PaymentRemindersDao(database);
    transactionDao = TransactionDao(database);
    outboxDao = OutboxDao(database);
    repository = ImportDataRepositoryImpl(
      database: database,
      accountDao: accountDao,
      categoryDao: categoryDao,
      tagDao: tagDao,
      transactionTagsDao: transactionTagsDao,
      creditDao: creditDao,
      creditCardDao: creditCardDao,
      debtDao: debtDao,
      budgetDao: budgetDao,
      budgetInstanceDao: budgetInstanceDao,
      savingGoalDao: savingGoalDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
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
      credits: <CreditEntity>[],
      creditCards: <CreditCardEntity>[],
      debts: <DebtEntity>[],
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
      credits: <CreditEntity>[],
      creditCards: <CreditCardEntity>[],
      debts: <DebtEntity>[],
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
      credits: <CreditEntity>[],
      creditCards: <CreditCardEntity>[],
      debts: <DebtEntity>[],
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

  test(
    'очищает старые локальные транзакции и obligations перед restore',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      await repository.importData(
        accounts: <AccountEntity>[
          AccountEntity(
            id: 'stale-account',
            name: 'Old',
            balanceMinor: BigInt.from(-500000),
            currency: 'RUB',
            currencyScale: 2,
            type: 'debt',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        categories: <Category>[],
        savingGoals: <SavingGoal>[],
        credits: <CreditEntity>[],
        creditCards: <CreditCardEntity>[],
        debts: <DebtEntity>[
          DebtEntity(
            id: 'stale-debt',
            accountId: 'stale-account',
            name: 'Old debt',
            amountMinor: BigInt.from(500000),
            amountScale: 2,
            dueDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        transactions: <TransactionEntity>[
          TransactionEntity(
            id: 'stale-tx',
            accountId: 'stale-account',
            amountMinor: BigInt.from(500000),
            amountScale: 2,
            date: now,
            type: TransactionType.expense.storageValue,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      await repository.importData(
        accounts: <AccountEntity>[
          AccountEntity(
            id: 'fresh-account',
            name: 'Fresh',
            balanceMinor: BigInt.from(100000),
            currency: 'RUB',
            currencyScale: 2,
            type: 'cash',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        categories: <Category>[],
        savingGoals: <SavingGoal>[],
        credits: <CreditEntity>[],
        creditCards: <CreditCardEntity>[],
        debts: <DebtEntity>[],
        transactions: <TransactionEntity>[],
      );

      final List<AccountEntity> accounts = await accountDao.getAllAccounts();
      final List<db.DebtRow> debts = await debtDao.getAllDebts();
      final List<TransactionEntity> transactions = await transactionDao
          .getAllTransactions();

      expect(accounts.map((AccountEntity account) => account.id), <String>[
        'fresh-account',
      ]);
      expect(debts, isEmpty);
      expect(
        transactions.map((TransactionEntity transaction) => transaction.id),
        isEmpty,
      );
    },
  );

  test(
    'ставит delete-маркеры для сущностей, пропавших из restore snapshot',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      await repository.importData(
        accounts: <AccountEntity>[
          AccountEntity(
            id: 'stale-account',
            name: 'Old',
            balanceMinor: BigInt.from(100000),
            currency: 'RUB',
            currencyScale: 2,
            type: 'cash',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        categories: <Category>[
          Category(
            id: 'stale-category',
            name: 'Old category',
            type: 'expense',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        savingGoals: <SavingGoal>[
          SavingGoal(
            id: 'stale-goal',
            userId: 'user-1',
            name: 'Old goal',
            targetAmount: 1000,
            currentAmount: 100,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        credits: <CreditEntity>[],
        creditCards: <CreditCardEntity>[],
        debts: <DebtEntity>[],
        transactions: <TransactionEntity>[
          TransactionEntity(
            id: 'stale-tx',
            accountId: 'stale-account',
            categoryId: 'stale-category',
            amountMinor: BigInt.from(500),
            amountScale: 2,
            date: now,
            type: TransactionType.expense.storageValue,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      await repository.importData(
        accounts: <AccountEntity>[
          AccountEntity(
            id: 'fresh-account',
            name: 'Fresh',
            balanceMinor: BigInt.from(250000),
            currency: 'RUB',
            currencyScale: 2,
            type: 'cash',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        categories: <Category>[],
        savingGoals: <SavingGoal>[],
        credits: <CreditEntity>[],
        creditCards: <CreditCardEntity>[],
        debts: <DebtEntity>[],
        transactions: <TransactionEntity>[],
      );

      final List<db.OutboxEntryRow> pending = await outboxDao.fetchPending(
        limit: 20,
      );
      final List<db.OutboxEntryRow> deleteEntries = pending
          .where((db.OutboxEntryRow entry) => entry.operation == 'delete')
          .toList(growable: false);

      expect(
        deleteEntries
            .map((db.OutboxEntryRow entry) => entry.entityType)
            .toSet(),
        <String>{'account', 'category', 'saving_goal', 'transaction'},
      );

      final db.OutboxEntryRow deletedAccount = deleteEntries.firstWhere(
        (db.OutboxEntryRow entry) => entry.entityType == 'account',
      );
      final Map<String, dynamic> accountPayload =
          jsonDecode(deletedAccount.payload) as Map<String, dynamic>;
      expect(accountPayload['id'], 'stale-account');
      expect(accountPayload['isDeleted'], true);
    },
  );

  test('ставит liability сущности в outbox и сохраняет их локально', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-credit',
      name: 'Credit account',
      balanceMinor: BigInt.from(-1200000),
      currency: 'RUB',
      currencyScale: 2,
      type: 'credit',
      createdAt: now,
      updatedAt: now,
    );
    final CreditEntity credit = CreditEntity(
      id: 'credit-1',
      accountId: account.id,
      totalAmountMinor: BigInt.from(1200000),
      totalAmountScale: 2,
      interestRate: 12.5,
      termMonths: 24,
      startDate: now,
      createdAt: now,
      updatedAt: now,
    );
    final CreditCardEntity creditCard = CreditCardEntity(
      id: 'card-1',
      accountId: account.id,
      creditLimitMinor: BigInt.from(300000),
      creditLimitScale: 2,
      statementDay: 15,
      paymentDueDays: 20,
      interestRateAnnual: 29.9,
      createdAt: now,
      updatedAt: now,
    );
    final DebtEntity debt = DebtEntity(
      id: 'debt-1',
      accountId: account.id,
      name: 'Friend',
      amountMinor: BigInt.from(250000),
      amountScale: 2,
      dueDate: now.add(const Duration(days: 30)),
      createdAt: now,
      updatedAt: now,
    );

    await repository.importData(
      accounts: <AccountEntity>[account],
      categories: <Category>[],
      savingGoals: <SavingGoal>[],
      credits: <CreditEntity>[credit],
      creditCards: <CreditCardEntity>[creditCard],
      debts: <DebtEntity>[debt],
      transactions: <TransactionEntity>[],
    );

    expect((await creditDao.getAllCredits()), hasLength(1));
    expect((await creditCardDao.getAllCreditCards()), hasLength(1));
    expect((await debtDao.getAllDebts()), hasLength(1));

    final List<db.OutboxEntryRow> pending = await outboxDao.fetchPending(
      limit: 20,
    );
    expect(
      pending.map((db.OutboxEntryRow entry) => entry.entityType).toSet(),
      containsAll(<String>{'credit', 'credit_card', 'debt'}),
    );
  });
}
