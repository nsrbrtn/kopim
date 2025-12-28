import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/remote/recurring_rule_remote_data_source.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerService extends Mock implements LoggerService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late db.AppDatabase database;
  late OutboxDao outboxDao;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late BudgetDao budgetDao;
  late BudgetInstanceDao budgetInstanceDao;
  late SavingGoalDao savingGoalDao;
  late RecurringRuleDao recurringRuleDao;
  late ProfileDao profileDao;
  late FakeFirebaseFirestore firestore;
  late MockLoggerService logger;
  late MockAnalyticsService analytics;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    outboxDao = OutboxDao(database);
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    transactionDao = TransactionDao(database);
    budgetDao = BudgetDao(database);
    budgetInstanceDao = BudgetInstanceDao(database);
    savingGoalDao = SavingGoalDao(database);
    recurringRuleDao = RecurringRuleDao(database);
    profileDao = ProfileDao(database);
    firestore = FakeFirebaseFirestore();
    logger = MockLoggerService();
    analytics = MockAnalyticsService();

    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => analytics.reportError(any(), any())).thenReturn(null);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'Should reproduce FK error when transaction is synced before its saving goal',
    () async {
      final service = AuthSyncService(
        database: database,
        outboxDao: outboxDao,
        accountDao: accountDao,
        categoryDao: categoryDao,
        transactionDao: transactionDao,
        budgetDao: budgetDao,
        budgetInstanceDao: budgetInstanceDao,
        savingGoalDao: savingGoalDao,
        recurringRuleDao: recurringRuleDao,
        profileDao: profileDao,
        accountRemoteDataSource: AccountRemoteDataSource(firestore),
        categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
        transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
        budgetRemoteDataSource: BudgetRemoteDataSource(firestore),
        budgetInstanceRemoteDataSource: BudgetInstanceRemoteDataSource(
          firestore,
        ),
        savingGoalRemoteDataSource: SavingGoalRemoteDataSource(firestore),
        recurringRuleRemoteDataSource: RecurringRuleRemoteDataSource(firestore),
        profileRemoteDataSource: ProfileRemoteDataSource(firestore),
        firestore: firestore,
        loggerService: logger,
        analyticsService: analytics,
      );

      const userId = 'user-repro';
      const accId = 'acc-1';
      const catId = 'cat-1';
      const goalId = 'goal-1';

      // 1. Setup remote data
      final now = DateTime.now().toUtc();
      final account = AccountEntity(
        id: accId,
        name: 'Account',
        balance: 1000,
        currency: 'RUB',
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      final category = Category(
        id: catId,
        name: 'Category',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final goal = SavingGoal(
        id: goalId,
        userId: userId,
        name: 'Goal',
        targetAmount: 10000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      final transaction = TransactionEntity(
        id: 'tx-1',
        accountId: accId,
        categoryId: catId,
        savingGoalId: goalId,
        amount: 100,
        date: now,
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );

      // Write to fake firestore
      final userRef = firestore.collection('users').doc(userId);
      await userRef
          .collection('accounts')
          .doc(accId)
          .set(
            account.toJson()
              ..['updatedAt'] = Timestamp.fromDate(account.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(account.createdAt),
          );
      await userRef
          .collection('categories')
          .doc(catId)
          .set(
            category.toJson()
              ..['updatedAt'] = Timestamp.fromDate(category.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(category.createdAt),
          );
      await userRef
          .collection('saving_goals')
          .doc(goalId)
          .set(
            goal.toJson()
              ..['updatedAt'] = Timestamp.fromDate(goal.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(goal.createdAt),
          );
      await userRef
          .collection('transactions')
          .doc(transaction.id)
          .set(
            transaction.toJson()
              ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
          );

      final authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
      );

      // This should fail with FK error
      try {
        await service.synchronizeOnLogin(user: authUser);
        fail('Should have thrown an error');
      } catch (e) {
        print('CAUGHT ERROR: $e');
        expect(e.toString(), contains('FOREIGN KEY constraint failed'));
      }
    },
  );
}
