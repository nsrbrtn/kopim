import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/savings/data/repositories/saving_goal_repository_impl.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockLoggerService extends Mock implements LoggerService {}

void main() {
  late db.AppDatabase database;
  late SavingGoalDao savingGoalDao;
  late AccountDao accountDao;
  late TransactionDao transactionDao;
  late CreditDao creditDao;
  late GoalAccountLinkDao goalAccountLinkDao;
  late GoalContributionDao contributionDao;
  late OutboxDao outboxDao;
  late SavingGoalRepositoryImpl repository;
  late TransactionRepository transactionRepository;
  late _MockAnalyticsService analytics;
  late _MockLoggerService logger;
  final DateTime now = DateTime.utc(2024, 5, 10, 8);

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    savingGoalDao = SavingGoalDao(database);
    accountDao = AccountDao(database);
    transactionDao = TransactionDao(database);
    creditDao = CreditDao(database);
    goalAccountLinkDao = GoalAccountLinkDao(database);
    contributionDao = GoalContributionDao(database);
    outboxDao = OutboxDao(database);
    analytics = _MockAnalyticsService();
    logger = _MockLoggerService();
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => logger.logInfo(any())).thenAnswer((_) {});
    repository = SavingGoalRepositoryImpl(
      database: database,
      savingGoalDao: savingGoalDao,
      goalAccountLinkDao: goalAccountLinkDao,
      accountDao: accountDao,
      transactionDao: transactionDao,
      goalContributionDao: contributionDao,
      outboxDao: outboxDao,
      analyticsService: analytics,
      loggerService: logger,
      uuidGenerator: const Uuid(),
      clock: () => now,
    );
    transactionRepository = TransactionRepositoryImpl(
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

  test('create auto provisions visible savings account', () async {
    final SavingGoal goal = SavingGoal(
      id: 'goal-1',
      userId: 'user-1',
      name: 'Vacation',
      targetAmount: 10_000,
      currentAmount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await repository.create(goal);
    final SavingGoal? storedGoal = await savingGoalDao.findById(goal.id);
    expect(storedGoal, isNotNull);
    expect(storedGoal!.accountId, isNotNull);

    final db.AccountRow? goalAccount =
        await (database.select(database.accounts)..where(
              (db.$AccountsTable tbl) => tbl.id.equals(storedGoal.accountId!),
            ))
            .getSingleOrNull();
    expect(goalAccount, isNotNull);
    expect(goalAccount!.type, 'savings');
    expect(goalAccount.isHidden, isFalse);
    verify(() => analytics.logEvent('savings_goal_create', any())).called(1);
    final List<dynamic> loggedMessages = verify(
      () => logger.logInfo(captureAny()),
    ).captured;
    expect(
      loggedMessages.any(
        (dynamic value) => value.toString().contains('storage_accounts=1'),
      ),
      isTrue,
    );
  });

  test(
    'create allows linking the same storage account to multiple goals',
    () async {
      await accountDao.upsert(
        AccountEntity(
          id: 'shared-acc',
          name: 'Shared account',
          balanceMinor: BigInt.zero,
          currency: 'USD',
          currencyScale: 2,
          type: 'bank',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final SavingGoal first = SavingGoal(
        id: 'goal-a',
        userId: 'user-1',
        name: 'First',
        accountId: 'shared-acc',
        targetAmount: 10_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(first);
      final SavingGoal? firstStored = await repository.findById(first.id);
      expect(firstStored, isNotNull);
      expect(firstStored!.accountId, 'shared-acc');

      final SavingGoal second = SavingGoal(
        id: 'goal-b',
        userId: 'user-1',
        name: 'Second',
        accountId: 'shared-acc',
        targetAmount: 12_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(second);

      final SavingGoal? secondStored = await repository.findById(second.id);
      expect(secondStored, isNotNull);
      expect(secondStored!.accountId, isNotNull);
      expect(secondStored.accountId, 'shared-acc');
      expect(secondStored.storageAccountIds, <String>['shared-acc']);
    },
  );

  test(
    'addContribution persists transaction, updates goal and account',
    () async {
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Cash',
        balanceMinor: BigInt.from(15000),
        currency: 'USD',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      await accountDao.upsert(account);

      final SavingGoal goal = SavingGoal(
        id: 'goal-2',
        userId: 'user-1',
        name: 'Emergency Fund',
        targetAmount: 5_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(goal);
      final SavingGoal stored = (await savingGoalDao.findById(goal.id))!;

      final SavingGoal updated = await repository.addContribution(
        goal: stored,
        appliedDelta: 2_500,
        newCurrentAmount: 2_500,
        contributedAt: now,
        sourceAccountId: 'acc-1',
        contributionNote: 'Initial boost',
      );

      expect(updated.currentAmount, 2_500);

      final db.TransactionRow? txRow =
          await (database.select(database.transactions)..where(
                (db.$TransactionsTable tbl) => tbl.savingGoalId.equals(goal.id),
              ))
              .getSingleOrNull();
      expect(txRow, isNotNull);
      expect(txRow!.amount, closeTo(25.0, 1e-9));
      expect(txRow.note, 'Накопление: Emergency Fund — Initial boost');
      expect(txRow.type, 'transfer');
      expect(txRow.categoryId, isNull);
      expect(txRow.transferAccountId, updated.accountId);
      verify(
        () => analytics.logEvent('savings_goal_contribution', any()),
      ).called(1);
      final List<dynamic> loggedMessages = verify(
        () => logger.logInfo(captureAny()),
      ).captured;
      expect(
        loggedMessages.any(
          (dynamic value) =>
              value.toString().contains('source=acc-1') &&
              value.toString().contains('storage='),
        ),
        isTrue,
      );

      final db.AccountRow? accountRow =
          await (database.select(database.accounts)
                ..where((db.$AccountsTable tbl) => tbl.id.equals('acc-1')))
              .getSingleOrNull();
      expect(accountRow, isNotNull);
      expect(accountRow!.balance, closeTo(125.0, 1e-9));
      final db.AccountRow? goalAccountRow =
          await (database.select(database.accounts)..where(
                (db.$AccountsTable tbl) =>
                    tbl.id.equals(updated.accountId ?? ''),
              ))
              .getSingleOrNull();
      expect(goalAccountRow, isNotNull);
      expect(goalAccountRow!.balance, closeTo(25.0, 1e-9));

      final db.GoalContributionRow? contribution =
          await (database.select(database.goalContributions)..where(
                (db.$GoalContributionsTable tbl) => tbl.goalId.equals(goal.id),
              ))
              .getSingleOrNull();
      expect(contribution, isNotNull);
      expect(contribution!.amount, 2_500);
      expect(contribution.storageAccountId, updated.accountId);
    },
  );

  test(
    'addContribution respects account currencyScale when it is not 2',
    () async {
      final AccountEntity account = AccountEntity(
        id: 'acc-scale-3',
        name: 'JPY-like 3dp',
        balanceMinor: BigInt.from(123456),
        currency: 'BHD',
        currencyScale: 3,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      await accountDao.upsert(account);

      final SavingGoal goal = SavingGoal(
        id: 'goal-scale-3',
        userId: 'user-1',
        name: 'Trip',
        targetAmount: 20_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(goal);
      final SavingGoal stored = (await savingGoalDao.findById(goal.id))!;

      final SavingGoal updated = await repository.addContribution(
        goal: stored,
        appliedDelta: 1_234,
        newCurrentAmount: 1_234,
        contributedAt: now,
        sourceAccountId: account.id,
        contributionNote: null,
      );

      final db.TransactionRow txRow =
          await (database.select(database.transactions)..where(
                (db.$TransactionsTable tbl) => tbl.savingGoalId.equals(goal.id),
              ))
              .getSingle();
      expect(txRow.amountMinor, '1234');
      expect(txRow.amountScale, 3);
      expect(txRow.amount, closeTo(1.234, 1e-9));

      final db.AccountRow sourceRow =
          await (database.select(database.accounts)
                ..where((db.$AccountsTable tbl) => tbl.id.equals(account.id)))
              .getSingle();
      expect(sourceRow.balanceMinor, '122222');
      expect(sourceRow.balance, closeTo(122.222, 1e-9));

      final db.AccountRow goalRow =
          await (database.select(database.accounts)..where(
                (db.$AccountsTable tbl) =>
                    tbl.id.equals(updated.accountId ?? ''),
              ))
              .getSingle();
      expect(goalRow.balanceMinor, '1234');
      expect(goalRow.balance, closeTo(1.234, 1e-9));
    },
  );

  test(
    'addContribution allows allocation-only when source equals storage account',
    () async {
      final SavingGoal goal = SavingGoal(
        id: 'goal-allocation-only',
        userId: 'user-1',
        name: 'Shared storage',
        targetAmount: 10_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(goal);
      final SavingGoal stored = (await repository.findById(goal.id))!;

      final db.AccountRow sourceBefore =
          await (database.select(database.accounts)..where(
                (db.$AccountsTable tbl) =>
                    tbl.id.equals(stored.accountId ?? ''),
              ))
              .getSingle();

      final SavingGoal updated = await repository.addContribution(
        goal: stored,
        appliedDelta: 2_000,
        newCurrentAmount: 2_000,
        contributedAt: now,
        sourceAccountId: stored.accountId!,
        storageAccountId: stored.accountId,
        contributionNote: 'Allocation only',
      );

      final db.TransactionRow txRow =
          await (database.select(database.transactions)..where(
                (db.$TransactionsTable tbl) => tbl.savingGoalId.equals(goal.id),
              ))
              .getSingle();
      expect(txRow.transferAccountId, stored.accountId);

      final db.AccountRow sourceAfter =
          await (database.select(database.accounts)..where(
                (db.$AccountsTable tbl) =>
                    tbl.id.equals(stored.accountId ?? ''),
              ))
              .getSingle();
      expect(sourceAfter.balanceMinor, sourceBefore.balanceMinor);

      final db.GoalContributionRow contribution =
          await (database.select(database.goalContributions)..where(
                (db.$GoalContributionsTable tbl) =>
                    tbl.transactionId.equals(txRow.id),
              ))
              .getSingle();
      expect(contribution.storageAccountId, stored.accountId);
      expect(updated.currentAmount, 2_000);
    },
  );

  test('softDelete on transaction rolls back saving goal progress', () async {
    final AccountEntity account = AccountEntity(
      id: 'acc-2',
      name: 'Savings',
      balanceMinor: BigInt.from(30000),
      currency: 'USD',
      currencyScale: 2,
      type: 'savings',
      createdAt: now,
      updatedAt: now,
    );
    await accountDao.upsert(account);

    final SavingGoal goal = SavingGoal(
      id: 'goal-3',
      userId: 'user-1',
      name: 'Car',
      targetAmount: 8_000,
      currentAmount: 0,
      createdAt: now,
      updatedAt: now,
    );
    await repository.create(goal);
    final SavingGoal stored = (await savingGoalDao.findById(goal.id))!;

    await repository.addContribution(
      goal: stored,
      appliedDelta: 4_000,
      newCurrentAmount: 4_000,
      contributedAt: now,
      sourceAccountId: 'acc-2',
      contributionNote: null,
    );

    final db.TransactionRow txRow =
        await (database.select(database.transactions)..where(
              (db.$TransactionsTable tbl) => tbl.savingGoalId.equals(goal.id),
            ))
            .getSingle();

    await transactionRepository.softDelete(txRow.id);

    final SavingGoal? refreshed = await savingGoalDao.findById(goal.id);
    expect(refreshed, isNotNull);
    expect(refreshed!.currentAmount, 0);
    final db.AccountRow sourceAfterDelete = await (database.select(
      database.accounts,
    )..where((db.$AccountsTable tbl) => tbl.id.equals('acc-2'))).getSingle();
    expect(sourceAfterDelete.balance, closeTo(300.0, 1e-9));
    final db.AccountRow goalAfterDelete =
        await (database.select(database.accounts)..where(
              (db.$AccountsTable tbl) =>
                  tbl.id.equals(refreshed.accountId ?? ''),
            ))
            .getSingle();
    expect(goalAfterDelete.balance, closeTo(0.0, 1e-9));

    final List<db.GoalContributionRow> contributions = await database
        .select(database.goalContributions)
        .get();
    expect(contributions, isEmpty);
  });

  test(
    'upsert recalculates contribution amount when transaction changes',
    () async {
      final AccountEntity source = AccountEntity(
        id: 'acc-update-source',
        name: 'Cash',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      await accountDao.upsert(source);

      final SavingGoal goal = SavingGoal(
        id: 'goal-update-amount',
        userId: 'user-1',
        name: 'Laptop',
        targetAmount: 10_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(goal);
      final SavingGoal stored = (await repository.findById(goal.id))!;

      await repository.addContribution(
        goal: stored,
        appliedDelta: 2_000,
        newCurrentAmount: 2_000,
        contributedAt: now,
        sourceAccountId: source.id,
        contributionNote: null,
      );

      final db.TransactionRow originalRow =
          await (database.select(database.transactions)..where(
                (db.$TransactionsTable tbl) => tbl.savingGoalId.equals(goal.id),
              ))
              .getSingle();

      await transactionRepository.upsert(
        TransactionEntity(
          id: originalRow.id,
          accountId: originalRow.accountId,
          transferAccountId: originalRow.transferAccountId,
          categoryId: originalRow.categoryId,
          savingGoalId: originalRow.savingGoalId,
          amountMinor: BigInt.from(3_500),
          amountScale: originalRow.amountScale,
          date: originalRow.date,
          note: originalRow.note,
          type: originalRow.type,
          createdAt: originalRow.createdAt,
          updatedAt: originalRow.updatedAt,
        ),
      );

      final SavingGoal refreshed = (await savingGoalDao.findById(goal.id))!;
      expect(refreshed.currentAmount, 3_500);

      final db.GoalContributionRow contribution =
          await (database.select(database.goalContributions)..where(
                (db.$GoalContributionsTable tbl) =>
                    tbl.transactionId.equals(originalRow.id),
              ))
              .getSingle();
      expect(contribution.amount, 3_500);
    },
  );

  test(
    'upsert detaches contribution when transaction is no longer linked to goal',
    () async {
      final AccountEntity source = AccountEntity(
        id: 'acc-detach-source',
        name: 'Cash',
        balanceMinor: BigInt.from(50000),
        currency: 'USD',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      await accountDao.upsert(source);

      final SavingGoal goal = SavingGoal(
        id: 'goal-detach',
        userId: 'user-1',
        name: 'Trip',
        targetAmount: 10_000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(goal);
      final SavingGoal stored = (await repository.findById(goal.id))!;

      await repository.addContribution(
        goal: stored,
        appliedDelta: 1_500,
        newCurrentAmount: 1_500,
        contributedAt: now,
        sourceAccountId: source.id,
        contributionNote: null,
      );

      final db.TransactionRow originalRow =
          await (database.select(database.transactions)..where(
                (db.$TransactionsTable tbl) => tbl.savingGoalId.equals(goal.id),
              ))
              .getSingle();

      await transactionRepository.upsert(
        TransactionEntity(
          id: originalRow.id,
          accountId: originalRow.accountId,
          transferAccountId: null,
          categoryId: null,
          savingGoalId: null,
          amountMinor: BigInt.from(1_500),
          amountScale: originalRow.amountScale,
          date: originalRow.date,
          note: originalRow.note,
          type: 'expense',
          createdAt: originalRow.createdAt,
          updatedAt: originalRow.updatedAt,
        ),
      );

      final SavingGoal refreshed = (await savingGoalDao.findById(goal.id))!;
      expect(refreshed.currentAmount, 0);

      final List<db.GoalContributionRow> contributions =
          await (database.select(database.goalContributions)..where(
                (db.$GoalContributionsTable tbl) =>
                    tbl.transactionId.equals(originalRow.id),
              ))
              .get();
      expect(contributions, isEmpty);
    },
  );

  test('create persists goal_account_links for provisioned account', () async {
    final SavingGoal goal = SavingGoal(
      id: 'goal-links',
      userId: 'user-1',
      name: 'Links',
      targetAmount: 15_000,
      currentAmount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await repository.create(goal);

    final SavingGoal stored = (await repository.findById(goal.id))!;
    final List<String> accountIds = await goalAccountLinkDao
        .findAccountIdsByGoalId(goal.id);

    expect(accountIds, <String>[stored.accountId!]);
    expect(stored.storageAccountIds, <String>[stored.accountId!]);
  });
}
