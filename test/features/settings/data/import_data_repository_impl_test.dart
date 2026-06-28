import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/profile/data/migration_freeze_state_repository.dart';
import 'package:kopim/features/accounts/data/services/account_type_backfill_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle_integrity.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoggerService extends Mock implements LoggerService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TagDao tagDao;
  late TransactionTagsDao transactionTagsDao;
  late CreditDao creditDao;
  late CreditCardDao creditCardDao;
  late DebtDao debtDao;
  late CreditPaymentDao creditPaymentDao;
  late BudgetDao budgetDao;
  late BudgetInstanceDao budgetInstanceDao;
  late SavingGoalDao savingGoalDao;
  late GoalAccountLinkDao goalAccountLinkDao;
  late UpcomingPaymentsDao upcomingPaymentsDao;
  late PaymentRemindersDao paymentRemindersDao;
  late TransactionDao transactionDao;
  late ProfileDao profileDao;
  late OutboxDao outboxDao;
  late ImportDataRepositoryImpl repository;
  late _MockLoggerService logger;
  late _MockAnalyticsService analytics;
  late AccountTypeBackfillService backfillService;

  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
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
    creditPaymentDao = CreditPaymentDao(database);
    budgetDao = BudgetDao(database);
    budgetInstanceDao = BudgetInstanceDao(database);
    savingGoalDao = SavingGoalDao(database);
    goalAccountLinkDao = GoalAccountLinkDao(database);
    upcomingPaymentsDao = UpcomingPaymentsDao(database);
    paymentRemindersDao = PaymentRemindersDao(database);
    transactionDao = TransactionDao(database);
    profileDao = ProfileDao(database);
    outboxDao = OutboxDao(database, () => 'local-user-1');
    logger = _MockLoggerService();
    analytics = _MockAnalyticsService();
    backfillService = AccountTypeBackfillService(
      database: database,
      accountDao: accountDao,
      outboxDao: outboxDao,
      loggerService: logger,
      analyticsService: analytics,
    );
    when(() => logger.logInfo(any())).thenReturn(null);
    when(() => logger.logError(any(), any())).thenReturn(null);
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => analytics.reportError(any(), any())).thenReturn(null);
    repository = ImportDataRepositoryImpl(
      database: database,
      accountDao: accountDao,
      categoryDao: categoryDao,
      tagDao: tagDao,
      transactionTagsDao: transactionTagsDao,
      creditDao: creditDao,
      creditCardDao: creditCardDao,
      debtDao: debtDao,
      creditPaymentDao: creditPaymentDao,
      budgetDao: budgetDao,
      budgetInstanceDao: budgetInstanceDao,
      savingGoalDao: savingGoalDao,
      goalAccountLinkDao: goalAccountLinkDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
      transactionDao: transactionDao,
      profileDao: profileDao,
      outboxDao: outboxDao,
      levelPolicy: const SimpleLevelPolicy(),
      loggerService: logger,
      analyticsService: analytics,
      accountTypeBackfillService: backfillService,
    );
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {}
  });

  ExportBundle bundleFactory({
    String schemaVersion = '1.7.0',
    List<AccountEntity> accounts = const <AccountEntity>[],
    List<Category> categories = const <Category>[],
    List<TagEntity> tags = const <TagEntity>[],
    List<TransactionTagEntity> transactionTags = const <TransactionTagEntity>[],
    List<SavingGoal> savingGoals = const <SavingGoal>[],
    List<CreditEntity> credits = const <CreditEntity>[],
    List<CreditCardEntity> creditCards = const <CreditCardEntity>[],
    List<DebtEntity> debts = const <DebtEntity>[],
    List<CreditPaymentGroupEntity> creditPaymentGroups =
        const <CreditPaymentGroupEntity>[],
    List<Budget> budgets = const <Budget>[],
    List<BudgetInstance> budgetInstances = const <BudgetInstance>[],
    List<UpcomingPayment> upcomingPayments = const <UpcomingPayment>[],
    List<PaymentReminder> paymentReminders = const <PaymentReminder>[],
    List<TransactionEntity> transactions = const <TransactionEntity>[],
  }) {
    return ExportBundle(
      schemaVersion: schemaVersion,
      generatedAt: DateTime.utc(2024, 1, 1),
      accounts: accounts,
      transactions: transactions,
      categories: categories,
      tags: tags,
      transactionTags: transactionTags,
      savingGoals: savingGoals,
      credits: credits,
      creditCards: creditCards,
      debts: debts,
      creditPaymentGroups: creditPaymentGroups,
      budgets: budgets,
      budgetInstances: budgetInstances,
      upcomingPayments: upcomingPayments,
      paymentReminders: paymentReminders,
    );
  }

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
      bundle: bundleFactory(accounts: <AccountEntity>[account1, account2]),
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
      bundle: bundleFactory(
        accounts: <AccountEntity>[account1, account2],
        transactions: transactions,
      ),
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
    final List<dynamic> loggedMessages = verify(
      () => logger.logInfo(captureAny()),
    ).captured;
    expect(
      loggedMessages.any(
        (dynamic value) => value.toString().contains('restore completed'),
      ),
      isTrue,
    );
    verify(
      () => analytics.logEvent('import_restore_completed', any()),
    ).called(2);
  });

  test('import блокируется во время migration freeze', () async {
    final SharedPrefsMigrationWriteGuard guard = SharedPrefsMigrationWriteGuard(
      database: database,
      stateRepository: SharedPrefsMigrationFreezeStateRepository(),
    );
    outboxDao = OutboxDao(database, null, null, guard);
    backfillService = AccountTypeBackfillService(
      database: database,
      accountDao: accountDao,
      outboxDao: outboxDao,
      migrationWriteGuard: guard,
      loggerService: logger,
      analyticsService: analytics,
    );
    repository = ImportDataRepositoryImpl(
      database: database,
      accountDao: accountDao,
      categoryDao: categoryDao,
      tagDao: tagDao,
      transactionTagsDao: transactionTagsDao,
      creditDao: creditDao,
      creditCardDao: creditCardDao,
      debtDao: debtDao,
      creditPaymentDao: creditPaymentDao,
      budgetDao: budgetDao,
      budgetInstanceDao: budgetInstanceDao,
      savingGoalDao: savingGoalDao,
      goalAccountLinkDao: goalAccountLinkDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
      transactionDao: transactionDao,
      profileDao: profileDao,
      outboxDao: outboxDao,
      migrationWriteGuard: guard,
      levelPolicy: const SimpleLevelPolicy(),
      loggerService: logger,
      analyticsService: analytics,
      accountTypeBackfillService: backfillService,
    );
    await guard.activateFreeze(
      uid: 'cloud-user-1',
      phase: 'pre_inventory_capture',
    );

    await expectLater(
      repository.importData(
        bundle: bundleFactory(
          accounts: <AccountEntity>[
            AccountEntity(
              id: 'acc-1',
              name: 'Main',
              balanceMinor: BigInt.zero,
              currency: 'USD',
              currencyScale: 2,
              type: 'bank',
              createdAt: DateTime.utc(2024, 1, 1),
              updatedAt: DateTime.utc(2024, 1, 1),
            ),
          ],
        ),
      ),
      throwsA(isA<MigrationFreezeActive>()),
    );
  });

  test(
    'merge-only import пересчитывает баланс по полному локальному snapshot, а не только по imported subset',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Main',
        balanceMinor: BigInt.from(100000),
        openingBalanceMinor: BigInt.from(100000),
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );

      await repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      );

      await transactionDao.upsertAll(<TransactionEntity>[
        TransactionEntity(
          id: 'tx-existing-income',
          accountId: account.id,
          amountMinor: BigInt.from(20000),
          amountScale: 2,
          date: now,
          type: TransactionType.income.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-existing-expense',
          accountId: account.id,
          amountMinor: BigInt.from(5000),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      await repository.importData(
        bundle: bundleFactory(
          accounts: <AccountEntity>[account],
          transactions: <TransactionEntity>[
            TransactionEntity(
              id: 'tx-imported-expense',
              accountId: account.id,
              amountMinor: BigInt.from(3000),
              amountScale: 2,
              date: now,
              type: TransactionType.expense.storageValue,
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
      );

      final AccountEntity updated = (await accountDao.getAllAccounts()).single;
      expect(updated.balanceMinor, BigInt.from(112000));
    },
  );

  test(
    'восстанавливает goal contributions и currentAmount после импорта',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity source = AccountEntity(
        id: 'acc-source',
        name: 'Source',
        balanceMinor: BigInt.from(50_000),
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );
      final AccountEntity storage = AccountEntity(
        id: 'acc-storage',
        name: 'Storage',
        balanceMinor: BigInt.zero,
        currency: 'USD',
        currencyScale: 2,
        type: 'savings',
        createdAt: now,
        updatedAt: now,
      );
      final SavingGoal goal = SavingGoal(
        id: 'goal-1',
        userId: 'user-1',
        name: 'Emergency',
        accountId: storage.id,
        storageAccountIds: <String>[storage.id],
        targetAmount: 10_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      final TransactionEntity contribution = TransactionEntity(
        id: 'tx-goal-1',
        accountId: source.id,
        transferAccountId: storage.id,
        savingGoalId: goal.id,
        amountMinor: BigInt.from(2_500),
        amountScale: 2,
        date: now,
        type: TransactionType.transfer.storageValue,
        createdAt: now,
        updatedAt: now,
      );

      await repository.importData(
        bundle: bundleFactory(
          accounts: <AccountEntity>[source, storage],
          savingGoals: <SavingGoal>[goal],
          transactions: <TransactionEntity>[contribution],
        ),
      );

      final SavingGoal? restoredGoal = await savingGoalDao.findById(goal.id);
      final List<db.GoalContributionRow> contributions =
          await (database.select(database.goalContributions)..where(
                (db.$GoalContributionsTable tbl) =>
                    tbl.transactionId.equals(contribution.id),
              ))
              .get();

      expect(restoredGoal, isNotNull);
      expect(restoredGoal!.currentAmount, 2_500);
      expect(contributions, hasLength(1));
      expect(contributions.single.id, contribution.id);
      expect(contributions.single.goalId, goal.id);
      expect(contributions.single.storageAccountId, storage.id);
      expect(contributions.single.amount, 2_500);
    },
  );

  test('ставит импортированные сущности в outbox для синхронизации', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balanceMinor: BigInt.from(12000),
      currency: 'USD',
      currencyScale: 2,
      type: 'card',
      typeVersion: 1,
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
      bundle: bundleFactory(
        accounts: <AccountEntity>[account],
        categories: <Category>[category],
        savingGoals: <SavingGoal>[goal],
        transactions: <TransactionEntity>[transaction],
      ),
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
    expect(payload['typeVersion'], 1);
  });

  test('очищает groupId у транзакций при restore из legacy backup', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balanceMinor: BigInt.zero,
      currency: 'USD',
      currencyScale: 2,
      type: 'card',
      createdAt: now,
      updatedAt: now,
    );
    final Category category = Category(
      id: 'cat-1',
      name: 'Credit',
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-legacy-group',
      accountId: account.id,
      categoryId: category.id,
      groupId: 'missing-group',
      amountMinor: BigInt.from(8333),
      amountScale: 2,
      date: now,
      type: TransactionType.expense.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await repository.importData(
      bundle: bundleFactory(
        accounts: <AccountEntity>[account],
        categories: <Category>[category],
        transactions: <TransactionEntity>[transaction],
      ),
    );

    final db.TransactionRow? row =
        await (database.select(database.transactions)
              ..where((db.Transactions tbl) => tbl.id.equals(transaction.id)))
            .getSingleOrNull();

    expect(row, isNotNull);
    expect(row!.groupId, isNull);
  });

  test(
    'сохраняет groupId при modern import, если credit payment group присутствует в snapshot',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Main',
        balanceMinor: BigInt.zero,
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );
      final AccountEntity sourceAccount = AccountEntity(
        id: 'acc-source',
        name: 'Source',
        balanceMinor: BigInt.from(100000),
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );
      final Category category = Category(
        id: 'cat-1',
        name: 'Credit',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final CreditEntity credit = CreditEntity(
        id: 'credit-1',
        accountId: account.id,
        categoryId: category.id,
        totalAmountMinor: BigInt.from(100000),
        totalAmountScale: 2,
        interestRate: 12,
        termMonths: 12,
        startDate: now,
        paymentDay: 10,
        createdAt: now,
        updatedAt: now,
      );
      final CreditPaymentGroupEntity group = CreditPaymentGroupEntity(
        id: 'group-1',
        creditId: credit.id,
        sourceAccountId: sourceAccount.id,
        paidAt: now,
        totalOutflow: Money.fromMinor(
          BigInt.from(10000),
          currency: 'USD',
          scale: 2,
        ),
        principalPaid: Money.fromMinor(
          BigInt.from(9000),
          currency: 'USD',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(1000),
          currency: 'USD',
          scale: 2,
        ),
        feesPaid: Money.fromMinor(BigInt.zero, currency: 'USD', scale: 2),
        createdAt: now,
        updatedAt: now,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-modern-group',
        accountId: sourceAccount.id,
        categoryId: category.id,
        groupId: group.id,
        amountMinor: BigInt.from(10000),
        amountScale: 2,
        date: now,
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      );

      await repository.importData(
        bundle: bundleFactory(
          schemaVersion: '1.8.0',
          accounts: <AccountEntity>[account, sourceAccount],
          categories: <Category>[category],
          credits: <CreditEntity>[credit],
          transactions: <TransactionEntity>[transaction],
          creditPaymentGroups: <CreditPaymentGroupEntity>[group],
        ),
      );

      final db.TransactionRow? row = await transactionDao.findById(
        transaction.id,
      );
      expect(row, isNotNull);
      expect(row!.groupId, group.id);
    },
  );

  test(
    'отклоняет modern import, если active transaction ссылается на отсутствующую credit payment group',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Main',
        balanceMinor: BigInt.zero,
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );
      final Category category = Category(
        id: 'cat-1',
        name: 'Credit',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-missing-group',
        accountId: account.id,
        categoryId: category.id,
        groupId: 'missing-group',
        amountMinor: BigInt.from(8333),
        amountScale: 2,
        date: now,
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      );

      await expectLater(
        () => repository.importData(
          bundle: bundleFactory(
            schemaVersion: '1.8.0',
            accounts: <AccountEntity>[account],
            categories: <Category>[category],
            transactions: <TransactionEntity>[transaction],
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test(
    'restore запускает deferred backfill для legacy account types',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-legacy',
        name: 'Legacy card',
        balanceMinor: BigInt.from(12000),
        openingBalanceMinor: BigInt.from(12000),
        currency: 'USD',
        currencyScale: 2,
        type: 'card',
        typeVersion: 0,
        createdAt: now,
        updatedAt: now,
      );

      await repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      );

      final db.AccountRow row =
          await (database.select(database.accounts)
                ..where((db.$AccountsTable tbl) => tbl.id.equals(account.id)))
              .getSingle();
      expect(row.type, 'bank');
      expect(row.typeVersion, 1);

      final List<db.OutboxEntryRow> outbox = await database
          .select(database.outboxEntries)
          .get();
      expect(
        outbox.any((db.OutboxEntryRow entry) => entry.entityId == account.id),
        isTrue,
      );
    },
  );

  test(
    'restore восстанавливает goal_account_links из storageAccountIds',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity accountA = AccountEntity(
        id: 'acc-a',
        name: 'Main',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      final AccountEntity accountB = AccountEntity(
        id: 'acc-b',
        name: 'Shared',
        balanceMinor: BigInt.from(25000),
        currency: 'USD',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      final SavingGoal goal = SavingGoal(
        id: 'goal-multi',
        userId: 'user-1',
        name: 'Vacation',
        accountId: 'acc-a',
        storageAccountIds: const <String>['acc-a', 'acc-b'],
        targetAmount: 50000,
        currentAmount: 1200,
        createdAt: now,
        updatedAt: now,
      );

      await repository.importData(
        bundle: bundleFactory(
          accounts: <AccountEntity>[accountA, accountB],
          savingGoals: <SavingGoal>[goal],
        ),
      );

      expect(await goalAccountLinkDao.findAccountIdsByGoalId(goal.id), <String>[
        'acc-a',
        'acc-b',
      ]);
    },
  );

  test(
    'делает merge-only import и сохраняет существующие локальные данные',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      await repository.importData(
        bundle: bundleFactory(
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
        ),
      );

      await repository.importData(
        bundle: bundleFactory(
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
        ),
      );

      final List<AccountEntity> accounts = await accountDao.getAllAccounts();
      final List<db.DebtRow> debts = await debtDao.getAllDebts();
      final List<TransactionEntity> transactions = await transactionDao
          .getAllTransactions();

      expect(
        accounts.map((AccountEntity account) => account.id).toSet(),
        <String>{'stale-account', 'fresh-account'},
      );
      expect(debts.map((db.DebtRow debt) => debt.id), <String>['stale-debt']);
      expect(
        transactions.map((TransactionEntity transaction) => transaction.id),
        <String>['stale-tx'],
      );
    },
  );

  test(
    'не ставит delete-маркеры для сущностей, отсутствующих в backup',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      await repository.importData(
        bundle: bundleFactory(
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
        ),
      );

      await repository.importData(
        bundle: bundleFactory(
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
        ),
      );

      final List<db.OutboxEntryRow> pending = await outboxDao.fetchPending(
        limit: 50,
      );
      final List<db.OutboxEntryRow> deleteEntries = pending
          .where((db.OutboxEntryRow entry) => entry.operation == 'delete')
          .toList(growable: false);

      expect(deleteEntries, isEmpty);
    },
  );

  test(
    'import поверх существующих данных добавляет snapshot по id и не угадывает дубли',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Main',
        balanceMinor: BigInt.from(100000),
        currency: 'RUB',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );

      await repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      );

      final TransactionEntity existing = TransactionEntity(
        id: 'tx-existing',
        accountId: account.id,
        amountMinor: BigInt.from(5000),
        amountScale: 2,
        date: now,
        note: 'coffee',
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      );
      await transactionDao.upsert(existing);

      final TransactionEntity importedSameDataButDifferentId =
          TransactionEntity(
            id: 'tx-imported',
            accountId: account.id,
            amountMinor: BigInt.from(5000),
            amountScale: 2,
            date: now,
            note: 'coffee',
            type: TransactionType.expense.storageValue,
            createdAt: now,
            updatedAt: now,
          );

      await repository.importData(
        bundle: bundleFactory(
          accounts: <AccountEntity>[account],
          transactions: <TransactionEntity>[importedSameDataButDifferentId],
        ),
      );

      final List<TransactionEntity> transactions = await transactionDao
          .getAllTransactions();
      expect(
        transactions.map((TransactionEntity tx) => tx.id).toSet(),
        <String>{'tx-existing', 'tx-imported'},
      );
    },
  );

  test(
    'отклоняет неподдерживаемую схему до локальных изменений и outbox side effects',
    () async {
      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity existingAccount = AccountEntity(
        id: 'acc-existing',
        name: 'Existing',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'cash',
        createdAt: now,
        updatedAt: now,
      );

      await accountDao.upsert(existingAccount);

      await expectLater(
        () => repository.importData(
          bundle: ExportBundle(
            schemaVersion: '9.0.0',
            generatedAt: now,
            accounts: <AccountEntity>[
              AccountEntity(
                id: 'acc-imported',
                name: 'Imported',
                balanceMinor: BigInt.from(10000),
                currency: 'USD',
                currencyScale: 2,
                type: 'cash',
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        ),
        throwsA(isA<FormatException>()),
      );

      final List<AccountEntity> accounts = await accountDao.getAllAccounts();
      final List<db.OutboxEntryRow> outboxEntries = await database
          .select(database.outboxEntries)
          .get();

      expect(accounts.map((AccountEntity account) => account.id), <String>[
        existingAccount.id,
      ]);
      expect(outboxEntries, isEmpty);
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
      bundle: bundleFactory(
        accounts: <AccountEntity>[account],
        credits: <CreditEntity>[credit],
        creditCards: <CreditCardEntity>[creditCard],
        debts: <DebtEntity>[debt],
      ),
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

  test(
    'importInProgress is set to true during import and reset to false on success',
    () async {
      final DateTime now = DateTime.now();
      final AccountEntity account = AccountEntity(
        id: 'acc-test-1',
        name: 'Card',
        balanceMinor: BigInt.from(1000),
        currency: 'USD',
        currencyScale: 2,
        type: 'regular',
        createdAt: now,
        updatedAt: now,
      );

      // Verify initial state
      db.CurrentSyncStateRow syncState = await database
          .select(database.currentSyncStates)
          .getSingle();
      expect(syncState.importInProgress, isFalse);

      // Run import
      await repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      );

      // Verify post-import state
      syncState = await database.select(database.currentSyncStates).getSingle();
      expect(syncState.importInProgress, isFalse);
    },
  );

  test('importInProgress is reset to false on import failure', () async {
    // Verify initial state
    db.CurrentSyncStateRow syncState = await database
        .select(database.currentSyncStates)
        .getSingle();
    expect(syncState.importInProgress, isFalse);

    // Run import with bundle that has mismatched integrity to trigger exception
    final ExportBundle invalidBundle = bundleFactory().copyWith(
      integrity: const ExportBundleIntegrity(
        format: 'v1',
        contentHash: 'invalid-hash',
      ),
    );

    await expectLater(
      repository.importData(bundle: invalidBundle),
      throwsException,
    );

    // Verify state after failure
    syncState = await database.select(database.currentSyncStates).getSingle();
    expect(syncState.importInProgress, isFalse);
  });

  test('import restores user rows as localOnly in offline mode', () async {
    await database.updateCurrentSyncState(null, false);

    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-import-1',
      name: 'Imported',
      balanceMinor: BigInt.from(1000),
      currency: 'USD',
      currencyScale: 2,
      type: 'regular',
      createdAt: now,
      updatedAt: now,
    );

    await repository.importData(
      bundle: bundleFactory(accounts: <AccountEntity>[account]),
    );

    final db.LocalRowOwnershipRow? ownership = await database.getOwnership(
      'account',
      'acc-import-1',
    );
    expect(ownership, isNotNull);
    expect(ownership!.ownershipState, 'localOnly');
    expect(ownership.ownerUid, isNull);
    expect(ownership.source, 'import_restore');
  });

  test('import restores user rows as cloudOwned in online mode', () async {
    await database.updateCurrentSyncState('cloud-user-1', true);

    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-import-1',
      name: 'Imported',
      balanceMinor: BigInt.from(1000),
      currency: 'USD',
      currencyScale: 2,
      type: 'regular',
      createdAt: now,
      updatedAt: now,
    );

    await repository.importData(
      bundle: bundleFactory(accounts: <AccountEntity>[account]),
    );

    final db.LocalRowOwnershipRow? ownership = await database.getOwnership(
      'account',
      'acc-import-1',
    );
    expect(ownership, isNotNull);
    expect(ownership!.ownershipState, 'cloudOwned');
    expect(ownership.ownerUid, 'cloud-user-1');
  });

  test(
    'beforeOpen recovery clears importInProgress and resets sending to pending',
    () async {
      // 1. Manually set importInProgress = true and insert a sending outbox entry
      await database
          .into(database.currentSyncStates)
          .insertOnConflictUpdate(
            const db.CurrentSyncStatesCompanion(
              id: Value<int>(1),
              importInProgress: Value<bool>(true),
            ),
          );
      await database
          .into(database.outboxEntries)
          .insert(
            db.OutboxEntriesCompanion(
              entityType: const Value<String>('account'),
              entityId: const Value<String>('acc-1'),
              operation: const Value<String>('create'),
              payload: const Value<String>('{}'),
              status: Value<String>(OutboxStatus.sending.name),
              attemptCount: const Value<int>(1),
              updatedAt: Value<DateTime>(DateTime.now()),
            ),
          );

      // 2. Re-open the database to trigger beforeOpen
      await database.close();
      final db.AppDatabase newDatabase = db.AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(() => newDatabase.close());

      // Wait for database to open
      final db.CurrentSyncStateRow syncState = await newDatabase
          .select(newDatabase.currentSyncStates)
          .getSingle();
      expect(syncState.importInProgress, isFalse);

      // Verify sending entry is reset to pending
      final List<db.OutboxEntryRow> entries = await newDatabase
          .select(newDatabase.outboxEntries)
          .get();
      expect(
        entries.every(
          (db.OutboxEntryRow e) => e.status == OutboxStatus.pending.name,
        ),
        isTrue,
      );
    },
  );

  test(
    'rollback inside transaction rolls back business rows, outbox, and ownership',
    () async {
      await database.updateCurrentSyncState('cloud-user-1', true);

      final DateTime now = DateTime.utc(2024, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-rollback-1',
        name: 'Rollback Acc',
        balanceMinor: BigInt.from(1000),
        currency: 'USD',
        currencyScale: 2,
        type: 'regular',
        createdAt: now,
        updatedAt: now,
      );

      // We create a transaction tag link that points to a non-existent transaction to trigger foreign key violation inside the transaction.
      final TransactionTagEntity invalidLink = TransactionTagEntity(
        transactionId: 'non-existent-tx-id',
        tagId: 'tag-1',
        createdAt: now,
        updatedAt: now,
      );

      final ExportBundle invalidBundle = bundleFactory(
        accounts: <AccountEntity>[account],
        transactionTags: <TransactionTagEntity>[invalidLink],
      );

      await expectLater(
        repository.importData(bundle: invalidBundle),
        throwsA(isA<Exception>()),
      );

      // Verify rollback of account
      final List<db.AccountRow> accountsInDb = await database
          .select(database.accounts)
          .get();
      expect(
        accountsInDb.any((db.AccountRow a) => a.id == 'acc-rollback-1'),
        isFalse,
      );

      // Verify rollback of ownership
      final db.LocalRowOwnershipRow? ownership = await database.getOwnership(
        'account',
        'acc-rollback-1',
      );
      expect(ownership, isNull);

      // Verify importInProgress is reset to false by finally block
      final db.CurrentSyncStateRow syncState = await database
          .select(database.currentSyncStates)
          .getSingle();
      expect(syncState.importInProgress, isFalse);
    },
  );

  test(
    'prepareForSend throws StateError if importInProgress is true',
    () async {
      await database
          .into(database.currentSyncStates)
          .insertOnConflictUpdate(
            const db.CurrentSyncStatesCompanion(
              id: Value<int>(1),
              importInProgress: Value<bool>(true),
            ),
          );

      final db.OutboxEntryRow entry = db.OutboxEntryRow(
        id: 1,
        entityType: 'account',
        entityId: 'acc-1',
        operation: 'create',
        payload: '{}',
        status: OutboxStatus.pending.name,
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => outboxDao.prepareForSend(entry), throwsA(isA<StateError>()));
    },
  );

  test('import blocked when any sending outbox entry exists', () async {
    await database.updateCurrentSyncState('cloud-user-1', true);
    await database
        .into(database.outboxEntries)
        .insert(
          db.OutboxEntriesCompanion(
            entityType: const Value<String>('account'),
            entityId: const Value<String>('acc-sending-1'),
            operation: const Value<String>('create'),
            payload: const Value<String>('{}'),
            status: Value<String>(OutboxStatus.sending.name),
            attemptCount: const Value<int>(1),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );

    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-import-sending-1',
      name: 'Imported Account',
      balanceMinor: BigInt.from(1000),
      currency: 'USD',
      currencyScale: 2,
      type: 'regular',
      createdAt: now,
      updatedAt: now,
    );

    expect(
      () => repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      ),
      throwsA(isA<StateError>()),
    );

    // Verify DB unchanged
    final List<db.AccountRow> accountsInDb = await database
        .select(database.accounts)
        .get();
    expect(
      accountsInDb.any((db.AccountRow a) => a.id == 'acc-import-sending-1'),
      isFalse,
    );
  });

  test('invalid currentUid blocks cloud-active import', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-uid-1',
      name: 'Imported',
      balanceMinor: BigInt.from(1000),
      currency: 'USD',
      currencyScale: 2,
      type: 'regular',
      createdAt: now,
      updatedAt: now,
    );

    // Test case 1: null uid
    await database.updateCurrentSyncState(null, true);
    expect(
      () => repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      ),
      throwsA(isA<StateError>()),
    );

    // Test case 2: empty uid
    await database.updateCurrentSyncState('', true);
    expect(
      () => repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      ),
      throwsA(isA<StateError>()),
    );

    // Test case 3: local uid
    await database.updateCurrentSyncState('local-1234', true);
    expect(
      () => repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'LWW LWW timestamp patching keeps createdAt but updates updatedAt in DB and outbox payload',
    () async {
      await database.updateCurrentSyncState('cloud-user-1', true);

      final DateTime createdDate = DateTime.utc(2023, 1, 1);
      final DateTime updatedDate = DateTime.utc(2023, 6, 1);
      final AccountEntity account = AccountEntity(
        id: 'acc-lww-1',
        name: 'LWW Account',
        balanceMinor: BigInt.from(1000),
        currency: 'USD',
        currencyScale: 2,
        type: 'regular',
        createdAt: createdDate,
        updatedAt: updatedDate,
      );

      await repository.importData(
        bundle: bundleFactory(accounts: <AccountEntity>[account]),
      );

      // Verify DB
      final db.AccountRow dbAccount =
          await (database.select(database.accounts)
                ..where((db.$AccountsTable tbl) => tbl.id.equals('acc-lww-1')))
              .getSingle();
      expect(dbAccount.createdAt.toUtc(), createdDate);
      expect(dbAccount.updatedAt, isNot(updatedDate));
      expect(dbAccount.updatedAt.isAfter(updatedDate), isTrue);

      // Verify Outbox payload
      final db.OutboxEntryRow outboxEntry =
          await (database.select(database.outboxEntries)..where(
                (db.$OutboxEntriesTable tbl) =>
                    tbl.entityType.equals('account') &
                    tbl.entityId.equals('acc-lww-1'),
              ))
              .getSingle();
      final Map<String, dynamic> payload =
          jsonDecode(outboxEntry.payload) as Map<String, dynamic>;
      expect(
        DateTime.parse(payload['createdAt'] as String).toUtc(),
        createdDate,
      );
      expect(payload['updatedAt'], isNot(updatedDate.toIso8601String()));
      expect(
        DateTime.parse(payload['updatedAt'] as String).toUtc(),
        dbAccount.updatedAt.toUtc(),
      );
    },
  );

  test('pending delete is replaced by import upsert in outbox', () async {
    await database.updateCurrentSyncState('cloud-user-1', true);

    // 1. Put pending delete in outbox for 'acc-del-1'
    await database
        .into(database.outboxEntries)
        .insert(
          db.OutboxEntriesCompanion(
            entityType: const Value<String>('account'),
            entityId: const Value<String>('acc-del-1'),
            operation: const Value<String>('delete'),
            payload: const Value<String>('{}'),
            status: Value<String>(OutboxStatus.pending.name),
            attemptCount: const Value<int>(0),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );

    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-del-1',
      name: 'Imported Upsert',
      balanceMinor: BigInt.from(1000),
      currency: 'USD',
      currencyScale: 2,
      type: 'regular',
      createdAt: now,
      updatedAt: now,
    );

    // 2. Run import
    await repository.importData(
      bundle: bundleFactory(accounts: <AccountEntity>[account]),
    );

    // 3. Verify that old pending delete is gone and new upsert is created
    final List<db.OutboxEntryRow> entries =
        await (database.select(database.outboxEntries)..where(
              (db.$OutboxEntriesTable tbl) =>
                  tbl.entityType.equals('account') &
                  tbl.entityId.equals('acc-del-1'),
            ))
            .get();

    expect(entries.length, 1);
    expect(entries.first.operation, 'upsert');
  });
}
