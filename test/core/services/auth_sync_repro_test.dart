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
import 'package:kopim/core/services/sync/sync_data_sanitizer.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerService extends Mock implements LoggerService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late db.AppDatabase database;
  late OutboxDao outboxDao;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late CreditDao creditDao;
  late DebtDao debtDao;
  late BudgetDao budgetDao;
  late BudgetInstanceDao budgetInstanceDao;
  late SavingGoalDao savingGoalDao;
  late UpcomingPaymentsDao upcomingPaymentsDao;
  late PaymentRemindersDao paymentRemindersDao;
  late ProfileDao profileDao;
  late FakeFirebaseFirestore firestore;
  late MockLoggerService logger;
  late MockAnalyticsService analytics;
  late SyncDataSanitizer sanitizer;

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
    creditDao = CreditDao(database);
    debtDao = DebtDao(database);
    budgetDao = BudgetDao(database);
    budgetInstanceDao = BudgetInstanceDao(database);
    savingGoalDao = SavingGoalDao(database);
    upcomingPaymentsDao = UpcomingPaymentsDao(database);
    paymentRemindersDao = PaymentRemindersDao(database);
    profileDao = ProfileDao(database);
    firestore = FakeFirebaseFirestore();
    logger = MockLoggerService();
    analytics = MockAnalyticsService();
    sanitizer = SyncDataSanitizer(logger: logger);

    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => analytics.reportError(any(), any())).thenReturn(null);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'Should reproduce FK error when transaction is synced before its saving goal',
    () async {
      // With the FIX enabled (sanitizer + reordering), this test should actually PASS now,
      // or fail differently if we want to confirm the fix works.
      // The original user intent was to REPRODUCE the error.
      // But now that we implemented the fix, we expect it to NOT THROW.
      // Wait, the reproduction test was designed to fail.
      // Now I should update it to expect SUCCESS because I expect my code to fix it.

      final AuthSyncService service = AuthSyncService(
        database: database,
        outboxDao: outboxDao,
        accountDao: accountDao,
        categoryDao: categoryDao,
        transactionDao: transactionDao,
        creditDao: creditDao,
        debtDao: debtDao,
        budgetDao: budgetDao,
        budgetInstanceDao: budgetInstanceDao,
        savingGoalDao: savingGoalDao,
        upcomingPaymentsDao: upcomingPaymentsDao,
        paymentRemindersDao: paymentRemindersDao,
        profileDao: profileDao,
        accountRemoteDataSource: AccountRemoteDataSource(firestore),
        categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
        transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
        creditRemoteDataSource: CreditRemoteDataSource(firestore),
        debtRemoteDataSource: DebtRemoteDataSource(firestore),
        budgetRemoteDataSource: BudgetRemoteDataSource(firestore),
        budgetInstanceRemoteDataSource: BudgetInstanceRemoteDataSource(
          firestore,
        ),
        savingGoalRemoteDataSource: SavingGoalRemoteDataSource(firestore),
        upcomingPaymentRemoteDataSource: UpcomingPaymentRemoteDataSource(
          firestore,
        ),
        paymentReminderRemoteDataSource: PaymentReminderRemoteDataSource(
          firestore,
        ),
        profileRemoteDataSource: ProfileRemoteDataSource(firestore),
        firestore: firestore,
        loggerService: logger,
        analyticsService: analytics,
        dataSanitizer: sanitizer,
      );

      const String userId = 'user-repro';
      const String accountId = 'acc_1';
      const String categoryId = 'cat_1';
      const String savingGoalId = 'goal_1';

      // 1. Setup remote data
      final DateTime now = DateTime.utc(2025, 1, 1);
      final AccountEntity account = AccountEntity(
        id: accountId,
        name: 'Account',
        balance: 1000,
        currency: 'RUB',
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      final Category category = Category(
        id: categoryId,
        name: 'Category',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final SavingGoal savingGoal = SavingGoal(
        id: savingGoalId,
        userId: userId,
        name: 'Goal',
        targetAmount: 10000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: accountId,
        categoryId: categoryId,
        savingGoalId: savingGoalId,
        amount: 100,
        date: now,
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );

      // Write to fake firestore
      final DocumentReference<Map<String, dynamic>> userRef = firestore
          .collection('users')
          .doc(userId);
      await userRef
          .collection('accounts')
          .doc(accountId)
          .set(
            account.toJson()
              ..['updatedAt'] = Timestamp.fromDate(account.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(account.createdAt),
          );
      await userRef
          .collection('categories')
          .doc(categoryId)
          .set(
            category.toJson()
              ..['updatedAt'] = Timestamp.fromDate(category.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(category.createdAt),
          );
      await userRef
          .collection('saving_goals')
          .doc(savingGoalId)
          .set(
            savingGoal.toJson()
              ..['updatedAt'] = Timestamp.fromDate(savingGoal.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(savingGoal.createdAt),
          );
      await userRef
          .collection('transactions')
          .doc(transaction.id)
          .set(
            transaction.toJson()
              ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
          );

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
      );

      // This previously failed. Now it should succeed.
      await service.synchronizeOnLogin(user: authUser);

      final db.TransactionRow? savedTx = await transactionDao.findById(
        transaction.id,
      );
      expect(savedTx, isNotNull);
      expect(savedTx?.savingGoalId, savingGoalId);
    },
  );

  test('Should sanitize transaction when saving goal is missing', () async {
    final AuthSyncService service = AuthSyncService(
      database: database,
      outboxDao: outboxDao,
      accountDao: accountDao,
      categoryDao: categoryDao,
      transactionDao: transactionDao,
      creditDao: creditDao,
      debtDao: debtDao,
      budgetDao: budgetDao,
      budgetInstanceDao: budgetInstanceDao,
      savingGoalDao: savingGoalDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
      profileDao: profileDao,
      accountRemoteDataSource: AccountRemoteDataSource(firestore),
      categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
      transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
      creditRemoteDataSource: CreditRemoteDataSource(firestore),
      debtRemoteDataSource: DebtRemoteDataSource(firestore),
      budgetRemoteDataSource: BudgetRemoteDataSource(firestore),
      budgetInstanceRemoteDataSource: BudgetInstanceRemoteDataSource(firestore),
      savingGoalRemoteDataSource: SavingGoalRemoteDataSource(firestore),
      upcomingPaymentRemoteDataSource: UpcomingPaymentRemoteDataSource(
        firestore,
      ),
      paymentReminderRemoteDataSource: PaymentReminderRemoteDataSource(
        firestore,
      ),
      profileRemoteDataSource: ProfileRemoteDataSource(firestore),
      firestore: firestore,
      loggerService: logger,
      analyticsService: analytics,
      dataSanitizer: sanitizer,
    );

    const String userId = 'user-sanitize';
    const String accId = 'acc-2';
    const String catId = 'cat-2';
    const String goalId = 'goal-missing';

    // 1. Setup remote data WITHOUT the goal
    final DateTime now = DateTime.now().toUtc();
    final AccountEntity account = AccountEntity(
      id: accId,
      name: 'Account',
      balance: 1000,
      currency: 'RUB',
      type: 'checking',
      createdAt: now,
      updatedAt: now,
    );
    final Category category = Category(
      id: catId,
      name: 'Category',
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-2',
      accountId: accId,
      categoryId: catId,
      savingGoalId: goalId, // Points to non-existent goal
      amount: 100,
      date: now,
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );

    // Write to fake firestore
    final DocumentReference<Map<String, dynamic>> userRef = firestore
        .collection('users')
        .doc(userId);
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
    // NOTE: We do NOT write the saving goal!
    await userRef
        .collection('transactions')
        .doc(transaction.id)
        .set(
          transaction.toJson()
            ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
            ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
        );

    final AuthUser authUser = AuthUser(
      uid: userId,
      isAnonymous: false,
      emailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
    );

    // This should SUCCEED if we implement sanitization correctly.
    // The transaction should be saved with savingGoalId = null.
    await service.synchronizeOnLogin(user: authUser);

    final db.TransactionRow? savedTx = await transactionDao.findById(
      transaction.id,
    );
    expect(savedTx, isNotNull);
    expect(savedTx?.savingGoalId, isNull);
  });

  test('Should skip transaction when account is missing', () async {
    final AuthSyncService service = AuthSyncService(
      database: database,
      outboxDao: outboxDao,
      accountDao: accountDao,
      categoryDao: categoryDao,
      transactionDao: transactionDao,
      creditDao: creditDao,
      debtDao: debtDao,
      budgetDao: budgetDao,
      budgetInstanceDao: budgetInstanceDao,
      savingGoalDao: savingGoalDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
      profileDao: profileDao,
      accountRemoteDataSource: AccountRemoteDataSource(firestore),
      categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
      transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
      creditRemoteDataSource: CreditRemoteDataSource(firestore),
      debtRemoteDataSource: DebtRemoteDataSource(firestore),
      budgetRemoteDataSource: BudgetRemoteDataSource(firestore),
      budgetInstanceRemoteDataSource: BudgetInstanceRemoteDataSource(firestore),
      savingGoalRemoteDataSource: SavingGoalRemoteDataSource(firestore),
      upcomingPaymentRemoteDataSource: UpcomingPaymentRemoteDataSource(
        firestore,
      ),
      paymentReminderRemoteDataSource: PaymentReminderRemoteDataSource(
        firestore,
      ),
      profileRemoteDataSource: ProfileRemoteDataSource(firestore),
      firestore: firestore,
      loggerService: logger,
      analyticsService: analytics,
      dataSanitizer: sanitizer,
    );

    const String userId = 'user-skip-tx';
    const String accId = 'acc-missing'; // Missing!

    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-skip',
      accountId: accId,
      amount: 100,
      date: DateTime.now().toUtc(),
      type: 'expense',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    // Only tx is on remote
    await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(
          transaction.toJson()
            ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
            ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
        );

    final AuthUser authUser = AuthUser(
      uid: userId,
      isAnonymous: false,
      emailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
    );

    await service.synchronizeOnLogin(user: authUser);

    final db.TransactionRow? savedTx = await transactionDao.findById(
      transaction.id,
    );
    expect(
      savedTx,
      isNull,
      reason: 'Transaction should be skipped because account is missing',
    );
  });
}
