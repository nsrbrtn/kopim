import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/savings/data/repositories/saving_goal_repository_impl.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockLoggerService extends Mock implements LoggerService {}

void main() {
  late db.AppDatabase database;
  late SavingGoalDao savingGoalDao;
  late CategoryDao categoryDao;
  late AccountDao accountDao;
  late TransactionDao transactionDao;
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
    categoryDao = CategoryDao(database);
    accountDao = AccountDao(database);
    transactionDao = TransactionDao(database);
    contributionDao = GoalContributionDao(database);
    outboxDao = OutboxDao(database);
    analytics = _MockAnalyticsService();
    logger = _MockLoggerService();
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => logger.logInfo(any())).thenAnswer((_) {});
    repository = SavingGoalRepositoryImpl(
      database: database,
      savingGoalDao: savingGoalDao,
      categoryDao: categoryDao,
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
      savingGoalDao: savingGoalDao,
      goalContributionDao: contributionDao,
      outboxDao: outboxDao,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('create auto provisions system category', () async {
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

    final db.CategoryRow? category =
        await (database.select(database.categories)
              ..where((db.$CategoriesTable tbl) => tbl.name.equals('Vacation')))
            .getSingleOrNull();
    expect(category, isNotNull);
    expect(category!.type, 'expense');
    expect(category.isSystem, isTrue);
    verify(() => analytics.logEvent('savings_goal_create', any())).called(1);
  });

  test(
    'addContribution persists transaction, updates goal and account',
    () async {
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Cash',
        balance: 150.0,
        currency: 'USD',
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
      expect(txRow!.amount, closeTo(-25.0, 1e-9));
      expect(txRow.note, 'Savings: Emergency Fund — Initial boost');

      final db.CategoryRow? category =
          await (database.select(database.categories)..where(
                (db.$CategoriesTable tbl) => tbl.name.equals('Emergency Fund'),
              ))
              .getSingleOrNull();
      expect(category, isNotNull);
      expect(txRow.categoryId, category!.id);

      final db.AccountRow? accountRow =
          await (database.select(database.accounts)
                ..where((db.$AccountsTable tbl) => tbl.id.equals('acc-1')))
              .getSingleOrNull();
      expect(accountRow, isNotNull);
      expect(accountRow!.balance, closeTo(125.0, 1e-9));

      final db.GoalContributionRow? contribution =
          await (database.select(database.goalContributions)..where(
                (db.$GoalContributionsTable tbl) => tbl.goalId.equals(goal.id),
              ))
              .getSingleOrNull();
      expect(contribution, isNotNull);
      expect(contribution!.amount, 2_500);
      verify(
        () => analytics.logEvent('savings_goal_contribution', any()),
      ).called(1);
    },
  );

  test('softDelete on transaction rolls back saving goal progress', () async {
    final AccountEntity account = AccountEntity(
      id: 'acc-2',
      name: 'Savings',
      balance: 300.0,
      currency: 'USD',
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

    final List<db.GoalContributionRow> contributions = await database
        .select(database.goalContributions)
        .get();
    expect(contributions, isEmpty);
  });
}
