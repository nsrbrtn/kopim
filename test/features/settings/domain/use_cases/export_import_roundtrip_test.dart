// test/features/settings/domain/use_cases/export_import_roundtrip_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/sync_metadata_repository.dart';
import 'package:kopim/features/accounts/data/services/account_type_backfill_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/user_account_cleanup_repository_impl.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/settings/data/repositories/export_data_repository_impl.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case_impl.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';

class _MockLoggerService extends Mock implements LoggerService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileAvatarRepository extends Mock
    implements ProfileAvatarRepository {}

class _MockSyncMetadataRepository extends Mock
    implements SyncMetadataRepository {}

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

  late ImportDataRepositoryImpl importRepository;
  late ExportDataRepositoryImpl exportRepository;
  late PrepareExportBundleUseCaseImpl prepareExportBundleUseCase;
  late UserAccountCleanupRepositoryImpl cleanupRepository;

  late _MockLoggerService logger;
  late _MockAnalyticsService analytics;
  late _MockAuthRepository authRepository;
  late _MockProfileAvatarRepository avatarRepository;
  late _MockSyncMetadataRepository metadataRepository;

  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(<String, dynamic>{});
  });

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
    creditPaymentDao = CreditPaymentDao(database);
    budgetDao = BudgetDao(database);
    budgetInstanceDao = BudgetInstanceDao(database);
    savingGoalDao = SavingGoalDao(database);
    goalAccountLinkDao = GoalAccountLinkDao(database);
    upcomingPaymentsDao = UpcomingPaymentsDao(database);
    paymentRemindersDao = PaymentRemindersDao(database);
    transactionDao = TransactionDao(database);
    profileDao = ProfileDao(database);
    outboxDao = OutboxDao(database, () => 'user-123');

    logger = _MockLoggerService();
    analytics = _MockAnalyticsService();
    authRepository = _MockAuthRepository();
    avatarRepository = _MockProfileAvatarRepository();
    metadataRepository = _MockSyncMetadataRepository();

    when(() => logger.logInfo(any())).thenReturn(null);
    when(() => logger.logError(any(), any())).thenReturn(null);
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(
        uid: 'user-123',
        email: 'user@example.com',
        isAnonymous: false,
      ),
    );
    when(() => metadataRepository.clear(any())).thenAnswer((_) async {});
    when(() => avatarRepository.delete(any())).thenAnswer((_) async {});

    final AccountTypeBackfillService backfillService =
        AccountTypeBackfillService(
          database: database,
          accountDao: accountDao,
          outboxDao: outboxDao,
          loggerService: logger,
          analyticsService: analytics,
        );

    importRepository = ImportDataRepositoryImpl(
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

    exportRepository = ExportDataRepositoryImpl(
      accountDao: accountDao,
      transactionDao: transactionDao,
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
      profileDao: profileDao,
      authRepository: authRepository,
      levelPolicy: const SimpleLevelPolicy(),
    );

    prepareExportBundleUseCase = PrepareExportBundleUseCaseImpl(
      repository: exportRepository,
      clock: () => DateTime.utc(2026, 1, 1),
    );

    cleanupRepository = UserAccountCleanupRepositoryImpl(
      firestore: FakeFirebaseFirestoreInstance(),
      database: database,
      profileAvatarRepository: avatarRepository,
      syncMetadataRepository: metadataRepository,
    );
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {}
  });

  test(
    'Export -> Reset -> Import roundtrip restores the entire user-visible financial graph',
    () async {
      final DateTime now = DateTime.utc(2026, 1, 1);

      // 1. Наполняем БД исходными данными
      await database
          .into(database.categories)
          .insert(
            db.CategoriesCompanion.insert(
              id: 'c1',
              name: 'Food',
              type: 'expense',
              isSystem: const Value<bool>(false),
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

      await database
          .into(database.accounts)
          .insert(
            db.AccountsCompanion.insert(
              id: 'a1',
              name: 'Main Wallet',
              balance: 950.0,
              balanceMinor: const Value<String>('95000'),
              openingBalance: const Value<double>(1000.0),
              openingBalanceMinor: const Value<String>('100000'),
              currencyScale: const Value<int>(2),
              currency: 'USD',
              type: 'checking',
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

      await database
          .into(database.tags)
          .insert(
            db.TagsCompanion.insert(
              id: 'tag1',
              name: 'Weekly',
              color: '#00ff00',
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

      await database
          .into(database.savingGoals)
          .insert(
            db.SavingGoalsCompanion.insert(
              id: 'sg1',
              userId: 'user-123',
              name: 'New Car',
              targetAmount: 50000,
              currentAmount: const Value<int>(5000),
              targetDate: Value<DateTime>(DateTime.utc(2028, 1, 1)),
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

      // Добавляем линк цели
      await database
          .into(database.goalAccountLinks)
          .insert(
            db.GoalAccountLinksCompanion.insert(
              goalId: 'sg1',
              accountId: 'a1',
              createdAt: Value<DateTime>(now),
            ),
          );

      await database
          .into(database.transactions)
          .insert(
            db.TransactionsCompanion.insert(
              id: 't1',
              accountId: 'a1',
              categoryId: const Value<String>('c1'),
              savingGoalId: const Value<String>('sg1'),
              amount: 50.0,
              amountMinor: const Value<String>('5000'),
              amountScale: const Value<int>(2),
              date: now,
              type: 'expense',
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

      await database
          .into(database.transactionTags)
          .insert(
            db.TransactionTagsCompanion.insert(
              transactionId: 't1',
              tagId: 'tag1',
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

      // Добавляем запись в outbox, чтобы проверить, что при импорте outbox очищается и не восстанавливается
      await outboxDao.enqueue(
        entityType: 'transaction',
        entityId: 't1',
        operation: OutboxOperation.upsert,
        payload: const <String, dynamic>{'amount': 50.0},
      );

      // 2. Делаем экспорт
      final ExportBundle exportedBundle = await prepareExportBundleUseCase();
      expect(exportedBundle.accounts.length, 1);
      expect(exportedBundle.transactions.length, 1);
      expect(exportedBundle.categories.length, 1);
      expect(exportedBundle.tags.length, 1);
      expect(exportedBundle.transactionTags.length, 1);
      expect(exportedBundle.savingGoals.length, 1);

      // 3. Выполняем сброс базы данных
      await cleanupRepository.deleteLocalUserData('user-123');

      // Проверяем, что БД пуста
      expect(await database.hasAnyUserData(), isFalse);
      expect(await outboxDao.pendingCount(), 0);

      // 4. Делаем импорт экспортированного бандла
      await importRepository.importData(bundle: exportedBundle);

      // 5. Проверяем, что все данные полностью восстановились
      final List<db.AccountRow> accounts = await database
          .select(database.accounts)
          .get();
      final List<db.TransactionRow> transactions = await database
          .select(database.transactions)
          .get();
      final List<db.CategoryRow> categories = await database
          .select(database.categories)
          .get();
      final List<db.TagRow> tags = await database.select(database.tags).get();
      final List<db.TransactionTagRow> transactionTags = await database
          .select(database.transactionTags)
          .get();
      final List<db.SavingGoalRow> savingGoals = await database
          .select(database.savingGoals)
          .get();

      expect(accounts.length, 1);
      expect(accounts.first.name, 'Main Wallet');

      expect(transactions.length, 1);
      expect(transactions.first.amount, 50.0);

      expect(categories.length, 1);
      expect(categories.first.name, 'Food');

      expect(tags.length, 1);
      expect(tags.first.name, 'Weekly');

      expect(transactionTags.length, 1);
      expect(transactionTags.first.transactionId, 't1');
      expect(transactionTags.first.tagId, 'tag1');

      expect(savingGoals.length, 1);
      expect(savingGoals.first.name, 'New Car');

      // Линки целей должны быть успешно восстановлены из effectiveStorageAccountIds
      final List<db.GoalAccountLinkRow> links = await database
          .select(database.goalAccountLinks)
          .get();
      expect(links.length, 1);
      expect(links.first.goalId, 'sg1');
      expect(links.first.accountId, 'a1');

      // Импортированные сущности должны быть поставлены в очередь outbox для последующей синхронизации
      final int outboxCount = await outboxDao.pendingCount();
      expect(outboxCount, 6);

      // Goal Contributions должны быть автоматически перестроены
      final List<db.GoalContributionRow> contributions = await database
          .select(database.goalContributions)
          .get();
      // (Поскольку транзакция с суммой 50.0 привязана к аккаунту a1, а аккаунт a1 привязан к цели sg1,
      // GoalContributionRebuildService должен сгенерировать запись вклада)
      expect(contributions.isNotEmpty, isTrue);
    },
  );
}

// Заглушка для FakeFirebaseFirestore
class FakeFirebaseFirestoreInstance extends Mock implements FirebaseFirestore {}
