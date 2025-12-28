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
import 'package:kopim/core/services/sync/sync_data_sanitizer.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/remote/recurring_rule_remote_data_source.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerService extends Mock implements LoggerService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class ThrowingAccountRemoteDataSource extends AccountRemoteDataSource {
  ThrowingAccountRemoteDataSource(super.firestore);

  @override
  void upsertInTransaction(
    Transaction transaction,
    String userId,
    AccountEntity account,
  ) {
    throw FirebaseException(plugin: 'cloud_firestore', message: 'boom');
  }
}

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
  late FirebaseFirestore firestore;
  late MockLoggerService logger;
  late MockAnalyticsService analytics;
  late BudgetRemoteDataSource budgetRemote;
  late BudgetInstanceRemoteDataSource budgetInstanceRemote;
  late SavingGoalRemoteDataSource savingGoalRemote;
  late RecurringRuleRemoteDataSource recurringRuleRemote;
  late SyncDataSanitizer sanitizer;

  AuthSyncService buildService({
    AccountRemoteDataSource? accountRemoteDataSource,
    BudgetRemoteDataSource? budgetRemoteDataSource,
    BudgetInstanceRemoteDataSource? budgetInstanceRemoteDataSource,
    SavingGoalRemoteDataSource? savingGoalRemoteDataSource,
    RecurringRuleRemoteDataSource? recurringRuleRemoteDataSource,
  }) {
    return AuthSyncService(
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
      accountRemoteDataSource:
          accountRemoteDataSource ?? AccountRemoteDataSource(firestore),
      categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
      transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
      budgetRemoteDataSource: budgetRemoteDataSource ?? budgetRemote,
      budgetInstanceRemoteDataSource:
          budgetInstanceRemoteDataSource ?? budgetInstanceRemote,
      savingGoalRemoteDataSource:
          savingGoalRemoteDataSource ?? savingGoalRemote,
      recurringRuleRemoteDataSource:
          recurringRuleRemoteDataSource ?? recurringRuleRemote,
      profileRemoteDataSource: ProfileRemoteDataSource(firestore),
      firestore: firestore,
      loggerService: logger,
      analyticsService: analytics,
      dataSanitizer: sanitizer,
    );
  }

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
    budgetRemote = BudgetRemoteDataSource(firestore);
    budgetInstanceRemote = BudgetInstanceRemoteDataSource(firestore);
    savingGoalRemote = SavingGoalRemoteDataSource(firestore);
    savingGoalRemote = SavingGoalRemoteDataSource(firestore);
    recurringRuleRemote = RecurringRuleRemoteDataSource(firestore);
    sanitizer = SyncDataSanitizer(logger: logger);

    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => analytics.reportError(any(), any())).thenReturn(null);
    when(() => logger.logInfo(any())).thenReturn(null);
    when(() => logger.logError(any(), any())).thenReturn(null);
  });

  tearDown(() async {
    await database.close();
  });

  group('AuthSyncService', () {
    test(
      'replays outbox entries, merges remote data and profile on login',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-1';
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Main',
          balance: 1500,
          currency: 'RUB',
          type: 'checking',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
          isDeleted: false,
        );

        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(account.id)
            .set(<String, dynamic>{
              'id': account.id,
              'name': 'Legacy',
              'balance': 300,
              'currency': 'RUB',
              'type': 'checking',
              'createdAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
              'updatedAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
              'isDeleted': false,
            });

        await firestore
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('profile')
            .set(<String, dynamic>{
              'uid': userId,
              'name': 'Old Name',
              'currency': 'RUB',
              'locale': 'en',
              'updatedAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
            });

        await outboxDao.enqueue(
          entityType: 'account',
          entityId: account.id,
          operation: OutboxOperation.upsert,
          payload: account.toJson()
            ..['updatedAt'] = account.updatedAt.toIso8601String()
            ..['createdAt'] = account.createdAt.toIso8601String(),
        );

        const Map<String, String> profilePayload = <String, String>{
          'uid': userId,
          'name': 'Alice',
          'currency': 'eur',
          'locale': 'de',
          'updatedAt': '2024-02-01T00:00:00.000Z',
        };

        await outboxDao.enqueue(
          entityType: 'profile',
          entityId: userId,
          operation: OutboxOperation.upsert,
          payload: profilePayload,
        );

        final Budget localBudget = Budget(
          id: 'budget-1',
          title: 'Groceries',
          period: BudgetPeriod.monthly,
          startDate: DateTime.utc(2024, 1, 1, 0, 1),
          endDate: null,
          amount: 500,
          scope: BudgetScope.all,
          categories: const <String>[],
          accounts: const <String>[],
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
        );

        await outboxDao.enqueue(
          entityType: 'budget',
          entityId: localBudget.id,
          operation: OutboxOperation.upsert,
          payload: localBudget.toJson()
            ..['startDate'] = localBudget.startDate.toIso8601String()
            ..['endDate'] = localBudget.endDate?.toIso8601String()
            ..['createdAt'] = localBudget.createdAt.toIso8601String()
            ..['updatedAt'] = localBudget.updatedAt.toIso8601String(),
        );

        final Budget remoteBudget = Budget(
          id: 'budget-remote',
          title: 'Travel Remote',
          period: BudgetPeriod.custom,
          startDate: DateTime.utc(2023, 12, 1, 0, 1),
          endDate: DateTime.utc(2023, 12, 31, 0, 1),
          amount: 800,
          scope: BudgetScope.all,
          categories: const <String>[],
          accounts: const <String>[],
          createdAt: DateTime.utc(2023, 12, 1),
          updatedAt: DateTime.utc(2024, 3, 1),
        );

        await budgetDao.upsert(
          remoteBudget.copyWith(
            title: 'Travel Local',
            updatedAt: DateTime.utc(2024, 2, 1),
          ),
        );

        final BudgetInstance remoteInstance = BudgetInstance(
          id: 'budget-remote-2024-03',
          budgetId: remoteBudget.id,
          periodStart: DateTime.utc(2024, 3, 1, 0, 1),
          periodEnd: DateTime.utc(2024, 4, 1, 0, 1),
          amount: remoteBudget.amount,
          spent: 150,
          status: BudgetInstanceStatus.active,
          createdAt: DateTime.utc(2024, 3, 1),
          updatedAt: DateTime.utc(2024, 3, 5),
        );

        await budgetInstanceDao.upsert(
          remoteInstance.copyWith(
            spent: 60,
            updatedAt: DateTime.utc(2024, 3, 3),
          ),
        );

        await budgetRemote.upsert(userId, remoteBudget);
        await budgetInstanceRemote.upsert(userId, remoteInstance);

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'user@kopim.app',
          displayName: 'User',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: DateTime.utc(2024, 1, 1),
          lastSignInTime: DateTime.utc(2024, 1, 2),
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final DocumentSnapshot<Map<String, dynamic>> remoteDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(account.id)
            .get();

        expect(remoteDoc.exists, isTrue);
        expect(remoteDoc.data()?['balance'], equals(1500));

        final List<AccountEntity> localAccounts = await accountDao
            .getAllAccounts();
        expect(localAccounts, hasLength(1));
        expect(localAccounts.single.balance, equals(1500));

        final DocumentSnapshot<Map<String, dynamic>> profileDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('profile')
                .doc('profile')
                .get();
        expect(profileDoc.exists, isTrue);
        expect(profileDoc.data()?['name'], equals('Alice'));
        expect(profileDoc.data()?['currency'], equals('EUR'));
        expect(profileDoc.data()?['locale'], equals('de'));

        final Profile? localProfile = await profileDao.getProfile(userId);
        expect(localProfile, isNotNull);
        expect(localProfile!.name, equals('Alice'));
        expect(localProfile.currency, equals(ProfileCurrency.eur));
        expect(localProfile.locale, equals('de'));

        final List<Budget> storedBudgets = await budgetDao.getAllBudgets();
        expect(
          storedBudgets.map((Budget b) => b.id),
          containsAll(<String>{localBudget.id, remoteBudget.id}),
        );
        final Budget mergedRemoteBudget = storedBudgets.firstWhere(
          (Budget b) => b.id == remoteBudget.id,
        );
        expect(mergedRemoteBudget.title, equals(remoteBudget.title));
        expect(
          mergedRemoteBudget.updatedAt.isAtSameMomentAs(remoteBudget.updatedAt),
          isTrue,
        );

        final Budget mergedLocalBudget = storedBudgets.firstWhere(
          (Budget b) => b.id == localBudget.id,
        );
        expect(mergedLocalBudget.amount, equals(localBudget.amount));
        expect(mergedLocalBudget.scope, equals(BudgetScope.all));

        final List<BudgetInstance> storedInstances = await budgetInstanceDao
            .getAllInstances();
        expect(storedInstances, hasLength(1));
        expect(storedInstances.single.spent, equals(remoteInstance.spent));
        expect(
          storedInstances.single.status,
          equals(BudgetInstanceStatus.active),
        );

        final List<Budget> remoteBudgets = await budgetRemote.fetchAll(userId);
        expect(remoteBudgets.map((Budget b) => b.id), contains(localBudget.id));
        final Budget remoteStoredBudget = remoteBudgets.firstWhere(
          (Budget b) => b.id == localBudget.id,
        );
        expect(
          remoteStoredBudget.updatedAt.isAtSameMomentAs(localBudget.updatedAt),
          isTrue,
        );

        final List<BudgetInstance> remoteInstances = await budgetInstanceRemote
            .fetchAll(userId);
        expect(
          remoteInstances.map((BudgetInstance i) => i.id),
          contains(remoteInstance.id),
        );

        expect(await outboxDao.pendingCount(), equals(0));

        verify(() => analytics.logEvent('auth_sync_start', any())).called(1);
        verify(() => analytics.logEvent('auth_sync_success', any())).called(1);
      },
    );

    test(
      'replays legacy category outbox payload with string icon descriptor',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-legacy';

        await outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-1',
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{
            'id': 'cat-1',
            'name': 'Food',
            'type': 'expense',
            'icon': 'bowl-food',
            'iconStyle': 'BOLD',
            'color': '#FF0000',
            'createdAt': '2023-01-01T00:00:00.000Z',
            'updatedAt': '2023-01-02T00:00:00.000Z',
            'isDeleted': false,
          },
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          isAnonymous: false,
          emailVerified: true,
          creationTime: DateTime.utc(2023, 1, 1),
          lastSignInTime: DateTime.utc(2023, 1, 2),
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final DocumentSnapshot<Map<String, dynamic>> remoteCategoryDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('categories')
                .doc('cat-1')
                .get();

        expect(remoteCategoryDoc.exists, isTrue);
        final Map<String, dynamic>? remoteData = remoteCategoryDoc.data();
        expect(remoteData?['iconDescriptor'], isA<Map<String, dynamic>>());
        final Map<String, dynamic> descriptor =
            (remoteData?['iconDescriptor'] as Map<String, dynamic>?) ??
            const <String, dynamic>{};
        expect(descriptor['name'], equals('bowl-food'));
        expect(descriptor['style'], equals('bold'));

        final List<Category> storedCategories = await categoryDao
            .getAllCategories();
        expect(storedCategories, hasLength(1));
        expect(storedCategories.single.icon?.name, equals('bowl-food'));
        expect(
          storedCategories.single.icon?.style,
          equals(PhosphorIconStyle.bold),
        );

        expect(await outboxDao.pendingCount(), equals(0));
      },
    );

    test('нормализует связь родителя категории после дедупликации', () async {
      final AuthSyncService service = buildService();
      const String userId = 'user-category-conflict';

      final Category legacyParent = Category(
        id: 'cat-legacy',
        name: 'Food Legacy',
        type: 'expense',
        createdAt: DateTime.utc(2023, 1, 1),
        updatedAt: DateTime.utc(2023, 2, 1),
      );
      final Category child = Category(
        id: 'cat-child',
        name: 'Restaurants',
        type: 'expense',
        parentId: legacyParent.id,
        createdAt: DateTime.utc(2023, 1, 5),
        updatedAt: DateTime.utc(2023, 2, 5),
      );

      await categoryDao.upsertAll(<Category>[legacyParent, child]);

      final Category remoteLegacy = legacyParent.copyWith(
        name: 'Food',
        updatedAt: DateTime.utc(2023, 2, 2),
      );
      final Category canonicalParent = remoteLegacy.copyWith(
        id: 'cat-canonical',
        updatedAt: DateTime.utc(2024, 3, 1),
      );
      final CategoryRemoteDataSource categoryRemoteDataSource =
          CategoryRemoteDataSource(firestore);
      await categoryRemoteDataSource.upsert(userId, remoteLegacy);
      await categoryRemoteDataSource.upsert(userId, canonicalParent);

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      await service.synchronizeOnLogin(user: authUser, previousUser: null);

      final List<Category> storedCategories = await categoryDao
          .getAllCategories();
      final Category storedChild = storedCategories.firstWhere(
        (Category category) => category.id == child.id,
      );
      expect(storedChild.parentId, equals(canonicalParent.id));

      final Category storedCanonical = storedCategories.firstWhere(
        (Category category) => category.id == canonicalParent.id,
      );
      expect(storedCanonical.parentId, isNull);
    });

    test('resets outbox entries when transaction fails', () async {
      final ThrowingAccountRemoteDataSource throwingDataSource =
          ThrowingAccountRemoteDataSource(firestore);
      final AuthSyncService service = buildService(
        accountRemoteDataSource: throwingDataSource,
      );
      const String userId = 'user-2';

      final AccountEntity account = AccountEntity(
        id: 'acc-2',
        name: 'Savings',
        balance: 200,
        currency: 'RUB',
        type: 'savings',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 5),
        isDeleted: false,
      );

      await outboxDao.enqueue(
        entityType: 'account',
        entityId: account.id,
        operation: OutboxOperation.upsert,
        payload: account.toJson()
          ..['updatedAt'] = account.updatedAt.toIso8601String()
          ..['createdAt'] = account.createdAt.toIso8601String(),
      );

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      expect(
        () => service.synchronizeOnLogin(user: authUser, previousUser: null),
        throwsA(isA<AuthFailure>()),
      );

      final List<db.OutboxEntryRow> entries = await database
          .select(database.outboxEntries)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.status, equals(OutboxStatus.pending.name));
    });
  });
}
