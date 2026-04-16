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
import 'package:kopim/features/accounts/data/services/account_type_backfill_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_card_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/data/sources/remote/tag_remote_data_source.dart';
import 'package:kopim/features/tags/data/sources/remote/transaction_tag_remote_data_source.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerService extends Mock implements LoggerService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class AuthSyncTestHarness {
  static bool _fallbacksRegistered = false;

  late db.AppDatabase database;
  late OutboxDao outboxDao;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late CreditCardDao creditCardDao;
  late CreditDao creditDao;
  late DebtDao debtDao;
  late BudgetDao budgetDao;
  late BudgetInstanceDao budgetInstanceDao;
  late SavingGoalDao savingGoalDao;
  late GoalAccountLinkDao goalAccountLinkDao;
  late UpcomingPaymentsDao upcomingPaymentsDao;
  late PaymentRemindersDao paymentRemindersDao;
  late TagDao tagDao;
  late TransactionTagsDao transactionTagsDao;
  late ProfileDao profileDao;
  late FakeFirebaseFirestore firestore;
  late MockLoggerService logger;
  late MockAnalyticsService analytics;
  late AccountTypeBackfillService accountTypeBackfillService;
  late BudgetRemoteDataSource budgetRemote;
  late BudgetInstanceRemoteDataSource budgetInstanceRemote;
  late SavingGoalRemoteDataSource savingGoalRemote;
  late CreditRemoteDataSource creditRemote;
  late CreditCardRemoteDataSource creditCardRemote;
  late DebtRemoteDataSource debtRemote;
  late UpcomingPaymentRemoteDataSource upcomingPaymentRemote;
  late PaymentReminderRemoteDataSource paymentReminderRemote;
  late SyncDataSanitizer sanitizer;
  late ImportDataRepositoryImpl importRepository;

  Future<void> setUp() async {
    _registerFallbacks();
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    outboxDao = OutboxDao(database);
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    transactionDao = TransactionDao(database);
    creditCardDao = CreditCardDao(database);
    creditDao = CreditDao(database);
    debtDao = DebtDao(database);
    budgetDao = BudgetDao(database);
    budgetInstanceDao = BudgetInstanceDao(database);
    savingGoalDao = SavingGoalDao(database);
    goalAccountLinkDao = GoalAccountLinkDao(database);
    upcomingPaymentsDao = UpcomingPaymentsDao(database);
    paymentRemindersDao = PaymentRemindersDao(database);
    tagDao = TagDao(database);
    transactionTagsDao = TransactionTagsDao(database);
    profileDao = ProfileDao(database);
    firestore = FakeFirebaseFirestore();
    logger = MockLoggerService();
    analytics = MockAnalyticsService();
    accountTypeBackfillService = AccountTypeBackfillService(
      database: database,
      accountDao: accountDao,
      outboxDao: outboxDao,
      loggerService: logger,
      analyticsService: analytics,
    );
    budgetRemote = BudgetRemoteDataSource(firestore);
    budgetInstanceRemote = BudgetInstanceRemoteDataSource(firestore);
    savingGoalRemote = SavingGoalRemoteDataSource(firestore);
    creditRemote = CreditRemoteDataSource(firestore);
    creditCardRemote = CreditCardRemoteDataSource(firestore);
    debtRemote = DebtRemoteDataSource(firestore);
    upcomingPaymentRemote = UpcomingPaymentRemoteDataSource(firestore);
    paymentReminderRemote = PaymentReminderRemoteDataSource(firestore);
    sanitizer = SyncDataSanitizer(logger: logger);
    importRepository = ImportDataRepositoryImpl(
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
      goalAccountLinkDao: goalAccountLinkDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
      transactionDao: transactionDao,
      profileDao: profileDao,
      outboxDao: outboxDao,
      levelPolicy: const SimpleLevelPolicy(),
      loggerService: logger,
      analyticsService: analytics,
      accountTypeBackfillService: accountTypeBackfillService,
    );

    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => analytics.reportError(any(), any())).thenReturn(null);
    when(() => logger.logInfo(any())).thenReturn(null);
    when(() => logger.logError(any(), any())).thenReturn(null);
  }

  static void _registerFallbacks() {
    if (_fallbacksRegistered) return;
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(StackTrace.empty);
    _fallbacksRegistered = true;
  }

  Future<void> tearDown() async {
    await database.close();
  }

  AuthSyncService buildService({
    AccountRemoteDataSource? accountRemoteDataSource,
    BudgetRemoteDataSource? budgetRemoteDataSource,
    BudgetInstanceRemoteDataSource? budgetInstanceRemoteDataSource,
    SavingGoalRemoteDataSource? savingGoalRemoteDataSource,
    UpcomingPaymentRemoteDataSource? upcomingPaymentRemoteDataSource,
    PaymentReminderRemoteDataSource? paymentReminderRemoteDataSource,
  }) {
    return AuthSyncService(
      database: database,
      outboxDao: outboxDao,
      accountDao: accountDao,
      categoryDao: categoryDao,
      tagDao: tagDao,
      transactionDao: transactionDao,
      transactionTagsDao: transactionTagsDao,
      creditCardDao: creditCardDao,
      creditDao: creditDao,
      debtDao: debtDao,
      budgetDao: budgetDao,
      budgetInstanceDao: budgetInstanceDao,
      savingGoalDao: savingGoalDao,
      goalAccountLinkDao: goalAccountLinkDao,
      upcomingPaymentsDao: upcomingPaymentsDao,
      paymentRemindersDao: paymentRemindersDao,
      profileDao: profileDao,
      accountRemoteDataSource:
          accountRemoteDataSource ?? AccountRemoteDataSource(firestore),
      categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
      tagRemoteDataSource: TagRemoteDataSource(firestore),
      transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
      transactionTagRemoteDataSource: TransactionTagRemoteDataSource(firestore),
      creditCardRemoteDataSource: CreditCardRemoteDataSource(firestore),
      creditRemoteDataSource: CreditRemoteDataSource(firestore),
      debtRemoteDataSource: DebtRemoteDataSource(firestore),
      budgetRemoteDataSource: budgetRemoteDataSource ?? budgetRemote,
      budgetInstanceRemoteDataSource:
          budgetInstanceRemoteDataSource ?? budgetInstanceRemote,
      savingGoalRemoteDataSource:
          savingGoalRemoteDataSource ?? savingGoalRemote,
      upcomingPaymentRemoteDataSource:
          upcomingPaymentRemoteDataSource ?? upcomingPaymentRemote,
      paymentReminderRemoteDataSource:
          paymentReminderRemoteDataSource ?? paymentReminderRemote,
      profileRemoteDataSource: ProfileRemoteDataSource(firestore),
      firestore: firestore,
      loggerService: logger,
      analyticsService: analytics,
      dataSanitizer: sanitizer,
      accountTypeBackfillService: accountTypeBackfillService,
    );
  }

  Future<void> seedRemoteSnapshot({
    required String userId,
    List<AccountEntity> accounts = const <AccountEntity>[],
    List<Category> categories = const <Category>[],
    List<TagEntity> tags = const <TagEntity>[],
    List<TransactionEntity> transactions = const <TransactionEntity>[],
    List<TransactionTagEntity> transactionTags = const <TransactionTagEntity>[],
    List<Budget> budgets = const <Budget>[],
    List<BudgetInstance> budgetInstances = const <BudgetInstance>[],
    List<SavingGoal> savingGoals = const <SavingGoal>[],
    List<CreditEntity> credits = const <CreditEntity>[],
    List<CreditCardEntity> creditCards = const <CreditCardEntity>[],
    List<DebtEntity> debts = const <DebtEntity>[],
    List<UpcomingPayment> upcomingPayments = const <UpcomingPayment>[],
    List<PaymentReminder> paymentReminders = const <PaymentReminder>[],
  }) async {
    for (final AccountEntity account in accounts) {
      await AccountRemoteDataSource(firestore).upsert(userId, account);
    }
    for (final Category category in categories) {
      await CategoryRemoteDataSource(firestore).upsert(userId, category);
    }
    for (final TagEntity tag in tags) {
      await TagRemoteDataSource(firestore).upsert(userId, tag);
    }
    for (final TransactionEntity transaction in transactions) {
      await TransactionRemoteDataSource(firestore).upsert(userId, transaction);
    }
    for (final TransactionTagEntity link in transactionTags) {
      await TransactionTagRemoteDataSource(firestore).upsert(userId, link);
    }
    for (final Budget budget in budgets) {
      await budgetRemote.upsert(userId, budget);
    }
    for (final BudgetInstance instance in budgetInstances) {
      await budgetInstanceRemote.upsert(userId, instance);
    }
    for (final SavingGoal goal in savingGoals) {
      await savingGoalRemote.upsert(userId, goal);
    }
    for (final CreditEntity credit in credits) {
      await creditRemote.upsert(userId, credit);
    }
    for (final CreditCardEntity creditCard in creditCards) {
      await creditCardRemote.upsert(userId, creditCard);
    }
    for (final DebtEntity debt in debts) {
      await debtRemote.upsert(userId, debt);
    }
    for (final UpcomingPayment payment in upcomingPayments) {
      await upcomingPaymentRemote.upsert(userId, payment);
    }
    for (final PaymentReminder reminder in paymentReminders) {
      await paymentReminderRemote.upsert(userId, reminder);
    }
  }

  Future<void> seedRemoteProfile({
    required String userId,
    required Profile profile,
  }) {
    return ProfileRemoteDataSource(firestore).upsert(userId, profile);
  }

  Future<Map<String, dynamic>?> fetchRemoteDocData({
    required String userId,
    required String entityType,
    required String entityId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _remoteDocRef(
      userId: userId,
      entityType: entityType,
      entityId: entityId,
    ).get();
    return snapshot.data();
  }

  Future<List<String>> readActiveLocalIds(String entityType) async {
    switch (entityType) {
      case 'account':
        return (await accountDao.getActiveAccounts())
            .map((db.AccountRow row) => row.id)
            .toList(growable: false);
      case 'category':
        return (await categoryDao.getActiveCategories())
            .map((db.CategoryRow row) => row.id)
            .toList(growable: false);
      case 'tag':
        return (await tagDao.getAllTags())
            .where((TagEntity entity) => !entity.isDeleted)
            .map((TagEntity entity) => entity.id)
            .toList(growable: false);
      case 'transaction':
        return (await transactionDao.getAllTransactions())
            .where((TransactionEntity entity) => !entity.isDeleted)
            .map((TransactionEntity entity) => entity.id)
            .toList(growable: false);
      case 'transaction_tag':
        return (await transactionTagsDao.getAllTransactionTags())
            .map(transactionTagsDao.mapRowToEntity)
            .where((TransactionTagEntity entity) => !entity.isDeleted)
            .map((TransactionTagEntity entity) => transactionTagKey(entity))
            .toList(growable: false);
      case 'budget':
        return (await budgetDao.getActiveBudgets())
            .map((Budget entity) => entity.id)
            .toList(growable: false);
      case 'saving_goal':
        return (await savingGoalDao.getGoals(
          includeArchived: true,
        )).map((SavingGoal entity) => entity.id).toList(growable: false);
      case 'credit':
        return (await creditDao.getActiveCredits())
            .map((db.CreditRow row) => row.id)
            .toList(growable: false);
      case 'credit_card':
        return (await creditCardDao.getActiveCreditCards())
            .map((db.CreditCardRow row) => row.id)
            .toList(growable: false);
      case 'debt':
        return (await debtDao.getActiveDebts())
            .map((db.DebtRow row) => row.id)
            .toList(growable: false);
      case 'upcoming_payment':
        return (await upcomingPaymentsDao.getAll())
            .where((UpcomingPayment entity) => entity.isActive)
            .map((UpcomingPayment entity) => entity.id)
            .toList(growable: false);
      case 'payment_reminder':
        return (await paymentRemindersDao.getAll())
            .where((PaymentReminder entity) => !entity.isDone)
            .map((PaymentReminder entity) => entity.id)
            .toList(growable: false);
      default:
        throw UnsupportedError('Unsupported entityType: $entityType');
    }
  }

  Future<bool> isLocalTombstone({
    required String entityType,
    required String entityId,
  }) async {
    switch (entityType) {
      case 'account':
        return (await accountDao.findById(entityId))?.isDeleted ?? false;
      case 'category':
        return (await categoryDao.findById(entityId))?.isDeleted ?? false;
      case 'tag':
        return (await tagDao.findById(entityId))?.isDeleted ?? false;
      case 'transaction':
        return (await transactionDao.findById(entityId))?.isDeleted ?? false;
      case 'budget':
        return (await budgetDao.findById(entityId))?.isDeleted ?? false;
      case 'credit':
        return (await creditDao.findById(entityId))?.isDeleted ?? false;
      case 'credit_card':
        return (await creditCardDao.findById(entityId))?.isDeleted ?? false;
      case 'debt':
        return (await debtDao.findById(entityId))?.isDeleted ?? false;
      default:
        throw UnsupportedError('Unsupported entityType: $entityType');
    }
  }

  Future<Profile?> fetchLocalProfile(String userId) {
    return profileDao.getProfile(userId);
  }

  String transactionTagKey(TransactionTagEntity entity) {
    return '${entity.transactionId}::${entity.tagId}';
  }

  Future<void> expectActiveLocalIds({
    required String entityType,
    required List<String> expected,
  }) async {
    expect(await readActiveLocalIds(entityType), equals(expected));
  }

  Future<void> expectLocalTombstone({
    required String entityType,
    required String entityId,
  }) async {
    expect(
      await isLocalTombstone(entityType: entityType, entityId: entityId),
      isTrue,
    );
  }

  Future<void> expectRemoteFieldEquals({
    required String userId,
    required String entityType,
    required String entityId,
    required String field,
    required Object? expected,
  }) async {
    expect(
      (await fetchRemoteDocData(
        userId: userId,
        entityType: entityType,
        entityId: entityId,
      ))?[field],
      equals(expected),
    );
  }

  DocumentReference<Map<String, dynamic>> _remoteDocRef({
    required String userId,
    required String entityType,
    required String entityId,
  }) {
    final DocumentReference<Map<String, dynamic>> userRef = firestore
        .collection('users')
        .doc(userId);
    switch (entityType) {
      case 'account':
        return userRef.collection('accounts').doc(entityId);
      case 'category':
        return userRef.collection('categories').doc(entityId);
      case 'tag':
        return userRef.collection('tags').doc(entityId);
      case 'transaction':
        return userRef.collection('transactions').doc(entityId);
      case 'transaction_tag':
        return userRef.collection('transaction_tags').doc(entityId);
      case 'budget':
        return userRef.collection('budgets').doc(entityId);
      case 'budget_instance':
        return userRef.collection('budget_instances').doc(entityId);
      case 'saving_goal':
        return userRef.collection('saving_goals').doc(entityId);
      case 'credit':
        return userRef.collection('credits').doc(entityId);
      case 'credit_card':
        return userRef.collection('credit_cards').doc(entityId);
      case 'debt':
        return userRef.collection('debts').doc(entityId);
      case 'upcoming_payment':
        return userRef.collection('recurring_payments').doc(entityId);
      case 'payment_reminder':
        return userRef.collection('reminders').doc(entityId);
      case 'profile':
        return userRef.collection('profile').doc('profile');
      default:
        throw UnsupportedError('Unsupported entityType: $entityType');
    }
  }
}
