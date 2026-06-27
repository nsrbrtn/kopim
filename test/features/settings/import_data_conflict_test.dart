// test/features/settings/import_data_conflict_test.dart
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
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
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/settings/data/repositories/export_data_repository_impl.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoggerService extends Mock implements LoggerService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

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
  late _MockLoggerService logger;
  late _MockAnalyticsService analytics;
  late AccountTypeBackfillService backfillService;

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
      authRepository: _MockAuthRepository(),
      levelPolicy: const SimpleLevelPolicy(),
    );
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {}
  });

  ExportBundle bundleFactory({
    List<AccountEntity> accounts = const <AccountEntity>[],
    List<Category> categories = const <Category>[],
    List<TransactionEntity> transactions = const <TransactionEntity>[],
  }) {
    return ExportBundle(
      schemaVersion: '1.8.0',
      generatedAt: DateTime.utc(2026, 1, 1),
      accounts: accounts,
      transactions: transactions,
      categories: categories,
      tags: const <TagEntity>[],
      transactionTags: const <TransactionTagEntity>[],
      savingGoals: const <SavingGoal>[],
      credits: const <CreditEntity>[],
      creditCards: const <CreditCardEntity>[],
      debts: const <DebtEntity>[],
      creditPaymentGroups: const <CreditPaymentGroupEntity>[],
      budgets: const <Budget>[],
      budgetInstances: const <BudgetInstance>[],
      upcomingPayments: const <UpcomingPayment>[],
      paymentReminders: const <PaymentReminder>[],
    );
  }

  group('Import / Export - Тесты конфликтов категорий (TASK-001B)', () {
    test(
      'Импорт транзакции с отсутствующей в бэкапе категорией создает конфликт missingOptionalReference и local-only placeholder, не зануляя categoryId',
      () async {
        final DateTime now = DateTime.utc(2026, 6, 13, 12);
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Карта',
          balanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        );

        final TransactionEntity transaction = TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-missing-import',
          amountMinor: BigInt.from(1500),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        );

        // Импортируем bundle
        await importRepository.importData(
          bundle: bundleFactory(
            accounts: <AccountEntity>[account],
            transactions: <TransactionEntity>[transaction],
          ),
        );

        // Проверяем, что в БД создался local-only placeholder
        final db.CategoryRow? placeholder = await categoryDao.findById(
          'cat-missing-import',
        );
        expect(placeholder, isNotNull);
        expect(placeholder!.name, 'Категория недоступна (cat-missing-import)');
        expect(placeholder.isSystem, isTrue);
        expect(placeholder.isDeleted, isTrue);

        // Проверяем, что categoryId в транзакции НЕ занулился
        final db.TransactionRow? tx = await transactionDao.findById('tx-1');
        expect(tx, isNotNull);
        expect(tx!.categoryId, 'cat-missing-import');

        // Проверяем наличие конфликта в SyncConflictDao
        final SyncConflictDao conflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await conflictDao
            .getPendingConflicts();
        expect(conflicts.length, 1);
        expect(conflicts[0].conflictType, 'missingOptionalReference');
        expect(conflicts[0].entityId, 'cat-missing-import');
        expect(conflicts[0].status, 'pending');
      },
    );

    test(
      'Категория-плейсхолдер не попадает во внешнюю очередь (Outbox) и исключается из экспорта',
      () async {
        final DateTime now = DateTime.utc(2026, 6, 13, 12);
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Карта',
          balanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        );

        final TransactionEntity transaction = TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-missing-import',
          amountMinor: BigInt.from(1500),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        );

        // Импортируем bundle
        await importRepository.importData(
          bundle: bundleFactory(
            accounts: <AccountEntity>[account],
            transactions: <TransactionEntity>[transaction],
          ),
        );

        // Проверяем Outbox. В Outbox не должно быть записи для категории 'cat-missing-import'
        final List<db.OutboxEntryRow> pendingOutbox = await outboxDao
            .fetchPending(limit: 50);
        final List<db.OutboxEntryRow> categoryOutbox = pendingOutbox
            .where(
              (db.OutboxEntryRow entry) =>
                  entry.entityType == 'category' &&
                  entry.entityId == 'cat-missing-import',
            )
            .toList();
        expect(categoryOutbox, isEmpty);

        // Проверяем Экспорт. Плейсхолдер не должен экспортироваться
        final List<Category> exportedCategories = await exportRepository
            .fetchCategories();
        final List<Category> placeholderExport = exportedCategories
            .where((Category c) => c.id == 'cat-missing-import')
            .toList();
        expect(placeholderExport, isEmpty);
      },
    );

    test(
      'Удаленная в бэкапе категория (tombstone) сохраняет оригинальное имя при импорте',
      () async {
        final DateTime now = DateTime.utc(2026, 6, 13, 12);
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Карта',
          balanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        );

        final Category deletedCategory = Category(
          id: 'cat-deleted',
          name: 'Еда',
          type: 'expense',
          isDeleted: true,
          isSystem: false,
          isHidden: false,
          isFavorite: false,
          createdAt: now,
          updatedAt: now,
        );

        final TransactionEntity transaction = TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-deleted',
          amountMinor: BigInt.from(1500),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        );

        // Импортируем bundle
        await importRepository.importData(
          bundle: bundleFactory(
            accounts: <AccountEntity>[account],
            categories: <Category>[deletedCategory],
            transactions: <TransactionEntity>[transaction],
          ),
        );

        // Проверяем, что категория в локальной БД сохранила имя "Еда" и isDeleted = true
        final db.CategoryRow? category = await categoryDao.findById(
          'cat-deleted',
        );
        expect(category, isNotNull);
        expect(category!.name, 'Еда');
        expect(category.isDeleted, isTrue);
        expect(category.isSystem, isFalse);

        // Проверяем, что конфликт не создался
        final SyncConflictDao conflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await conflictDao
            .getPendingConflicts();
        expect(conflicts, isEmpty);
      },
    );

    test(
      'Восстановление категории при повторном импорте разрешает конфликт resolved/referenceRestored',
      () async {
        final DateTime now = DateTime.utc(2026, 6, 13, 12);
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Карта',
          balanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        );

        final TransactionEntity transaction = TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-restore-import',
          amountMinor: BigInt.from(1500),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        );

        // Первый импорт (без категории)
        await importRepository.importData(
          bundle: bundleFactory(
            accounts: <AccountEntity>[account],
            transactions: <TransactionEntity>[transaction],
          ),
        );

        final SyncConflictDao conflictDao = SyncConflictDao(database);
        List<db.SyncConflictRow> pending = await conflictDao
            .getPendingConflicts();
        expect(pending.length, 1);
        expect(pending[0].status, 'pending');

        // Вторым импортом привносим категорию
        final Category restoredCategory = Category(
          id: 'cat-restore-import',
          name: 'Авто',
          type: 'expense',
          isDeleted: false,
          isSystem: false,
          isHidden: false,
          isFavorite: false,
          createdAt: now,
          updatedAt: now,
        );

        await importRepository.importData(
          bundle: bundleFactory(
            accounts: <AccountEntity>[account],
            categories: <Category>[restoredCategory],
            transactions: <TransactionEntity>[transaction],
          ),
        );

        // Проверяем, что плейсхолдер обновился до реальной категории
        final db.CategoryRow? category = await categoryDao.findById(
          'cat-restore-import',
        );
        expect(category, isNotNull);
        expect(category!.name, 'Авто');
        expect(category.isSystem, isFalse);

        // Проверяем статус конфликта
        pending = await conflictDao.getPendingConflicts();
        expect(pending, isEmpty);

        final db.SyncConflictRow? conflict = await conflictDao.getConflictByKey(
          'missing_category_cat-restore-import',
        );
        expect(conflict, isNotNull);
        expect(conflict!.status, 'resolved');
        expect(conflict.resolution, 'referenceRestored');
      },
    );

    test(
      'Missing category placeholder is system local-only and does not create normal category row',
      () async {
        final DateTime now = DateTime.utc(2026, 6, 13, 12);
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Карта',
          balanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        );

        final TransactionEntity transaction = TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-1',
          categoryId: 'cat-never-existed',
          amountMinor: BigInt.from(1500),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        );

        await importRepository.importData(
          bundle: bundleFactory(
            accounts: <AccountEntity>[account],
            transactions: <TransactionEntity>[transaction],
          ),
        );

        // Проверяем, что в БД создался плейсхолдер с флагами isSystem=true и isDeleted=true
        final db.CategoryRow? category = await categoryDao.findById(
          'cat-never-existed',
        );
        expect(category, isNotNull);
        expect(category!.name, 'Категория недоступна (cat-never-existed)');
        expect(category.isSystem, isTrue);
        expect(category.isDeleted, isTrue);
      },
    );
  });
}
