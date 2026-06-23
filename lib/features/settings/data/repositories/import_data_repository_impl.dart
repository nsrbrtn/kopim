import 'package:drift/drift.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_debug_reporter.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_diagnostics_service.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/accounts/data/services/account_type_backfill_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/savings/data/mappers/saving_goal_storage_accounts_mapper.dart';
import 'package:kopim/features/savings/data/services/goal_contribution_rebuild_service.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_schema.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Репозиторий, сохраняющий импортированные данные через Drift DAO.
class ImportDataRepositoryImpl implements ImportDataRepository {
  ImportDataRepositoryImpl({
    required db.AppDatabase database,
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required TagDao tagDao,
    required TransactionTagsDao transactionTagsDao,
    required CreditDao creditDao,
    required CreditCardDao creditCardDao,
    required DebtDao debtDao,
    required CreditPaymentDao creditPaymentDao,
    required BudgetDao budgetDao,
    required BudgetInstanceDao budgetInstanceDao,
    required SavingGoalDao savingGoalDao,
    required GoalAccountLinkDao goalAccountLinkDao,
    required UpcomingPaymentsDao upcomingPaymentsDao,
    required PaymentRemindersDao paymentRemindersDao,
    required TransactionDao transactionDao,
    required ProfileDao profileDao,
    required OutboxDao outboxDao,
    MigrationWriteGuard? migrationWriteGuard,
    required LevelPolicy levelPolicy,
    LoggerService? loggerService,
    AnalyticsService? analyticsService,
    AccountTypeBackfillService? accountTypeBackfillService,
    GoalContributionRebuildService? goalContributionRebuildService,
    LocalSyncIntegrityDiagnosticsService? integrityDiagnosticsService,
    LocalSyncIntegrityDebugReporter? integrityDebugReporter,
  }) : _database = database,
       _accountDao = accountDao,
       _categoryDao = categoryDao,
       _tagDao = tagDao,
       _transactionTagsDao = transactionTagsDao,
       _creditDao = creditDao,
       _creditCardDao = creditCardDao,
       _debtDao = debtDao,
       _creditPaymentDao = creditPaymentDao,
       _budgetDao = budgetDao,
       _budgetInstanceDao = budgetInstanceDao,
       _savingGoalDao = savingGoalDao,
       _goalAccountLinkDao = goalAccountLinkDao,
       _upcomingPaymentsDao = upcomingPaymentsDao,
       _paymentRemindersDao = paymentRemindersDao,
       _transactionDao = transactionDao,
       _profileDao = profileDao,
       _outboxDao = outboxDao,
       _migrationWriteGuard =
           migrationWriteGuard ?? const NoopMigrationWriteGuard(),
       _levelPolicy = levelPolicy,
       _logger = loggerService,
       _analytics = analyticsService,
       _accountTypeBackfillService = accountTypeBackfillService,
       _goalContributionRebuildService =
           goalContributionRebuildService ??
           GoalContributionRebuildService(
             database,
             migrationWriteGuard:
                 migrationWriteGuard ?? const NoopMigrationWriteGuard(),
           ),
       _integrityDiagnosticsService =
           integrityDiagnosticsService ??
           LocalSyncIntegrityDiagnosticsService(database),
       _integrityDebugReporter =
           integrityDebugReporter ??
           LocalSyncIntegrityDebugReporter(
             diagnosticsService:
                 integrityDiagnosticsService ??
                 LocalSyncIntegrityDiagnosticsService(database),
             formatter: const LocalSyncIntegrityReportFormatter(),
             logger: loggerService ?? LoggerService(),
           );

  final db.AppDatabase _database;
  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final TagDao _tagDao;
  final TransactionTagsDao _transactionTagsDao;
  final CreditDao _creditDao;
  final CreditCardDao _creditCardDao;
  final DebtDao _debtDao;
  final CreditPaymentDao _creditPaymentDao;
  final BudgetDao _budgetDao;
  final BudgetInstanceDao _budgetInstanceDao;
  final SavingGoalDao _savingGoalDao;
  final GoalAccountLinkDao _goalAccountLinkDao;
  final UpcomingPaymentsDao _upcomingPaymentsDao;
  final PaymentRemindersDao _paymentRemindersDao;
  final TransactionDao _transactionDao;
  final ProfileDao _profileDao;
  final OutboxDao _outboxDao;
  final MigrationWriteGuard _migrationWriteGuard;
  final LevelPolicy _levelPolicy;
  final LoggerService? _logger;
  final AnalyticsService? _analytics;
  final AccountTypeBackfillService? _accountTypeBackfillService;
  final GoalContributionRebuildService _goalContributionRebuildService;
  final LocalSyncIntegrityDiagnosticsService _integrityDiagnosticsService;
  final LocalSyncIntegrityDebugReporter _integrityDebugReporter;
  static const ExportBundleIntegrityService _integrityService =
      ExportBundleIntegrityService();

  static const String _accountEntityType = 'account';
  static const String _categoryEntityType = 'category';
  static const String _tagEntityType = 'tag';
  static const String _transactionTagEntityType = 'transaction_tag';
  static const String _savingGoalEntityType = 'saving_goal';
  static const String _transactionEntityType = 'transaction';
  static const String _creditEntityType = 'credit';
  static const String _creditCardEntityType = 'credit_card';
  static const String _debtEntityType = 'debt';
  static const String _creditPaymentGroupEntityType = 'credit_payment_group';
  static const String _creditPaymentScheduleEntityType =
      'credit_payment_schedule';
  static const String _budgetEntityType = 'budget';
  static const String _budgetInstanceEntityType = 'budget_instance';
  static const String _upcomingPaymentEntityType = 'upcoming_payment';
  static const String _paymentReminderEntityType = 'payment_reminder';
  static const String _profileEntityType = 'profile';

  @override
  Future<void> importData({required ExportBundle bundle}) async {
    return _migrationWriteGuard.runImportMutation(
      action: () async {
        final List<AccountEntity> accounts = bundle.accounts;
        final List<Category> categories = bundle.categories;
        final List<TagEntity> tags = bundle.tags;
        final List<TransactionTagEntity> transactionTags =
            bundle.transactionTags;
        final List<SavingGoal> savingGoals = bundle.savingGoals;
        final List<CreditEntity> credits = bundle.credits;
        final List<CreditCardEntity> creditCards = bundle.creditCards;
        final List<DebtEntity> debts = bundle.debts;
        final List<CreditPaymentGroupEntity> creditPaymentGroups =
            bundle.creditPaymentGroups;
        final List<CreditPaymentScheduleEntity> creditPaymentSchedules =
            bundle.creditPaymentSchedules;
        final List<Budget> budgets = bundle.budgets;
        final List<BudgetInstance> budgetInstances = bundle.budgetInstances;
        final List<UpcomingPayment> upcomingPayments = bundle.upcomingPayments;
        final List<PaymentReminder> paymentReminders = bundle.paymentReminders;
        final ExportBundleSchemaVersion schemaVersion =
            ExportBundleSchema.parseAndValidate(bundle.schemaVersion);
        final List<TransactionEntity> transactions = bundle.transactions
            .map(
              (TransactionEntity transaction) =>
                  _normalizeImportedTransaction(transaction, schemaVersion),
            )
            .toList(growable: false);
        final Set<String> importedCreditPaymentGroupIds = creditPaymentGroups
            .map((CreditPaymentGroupEntity group) => group.id)
            .toSet();
        final List<Category> localCategories = await _categoryDao
            .getAllCategories();
        final Set<String> existingCategoryIds = <String>{
          ...categories.map((Category c) => c.id),
          ...localCategories.map((Category c) => c.id),
        };
        final Set<String> usedCategoryIds = transactions
            .map((TransactionEntity tx) => tx.categoryId)
            .whereType<String>()
            .toSet();

        final List<Category> placeholdersToInsert = <Category>[];
        final List<String> missingCategoryIds = <String>[];

        for (final String catId in usedCategoryIds) {
          if (!existingCategoryIds.contains(catId)) {
            missingCategoryIds.add(catId);
            placeholdersToInsert.add(
              Category(
                id: catId,
                name: 'Категория недоступна ($catId)',
                type: 'expense',
                isSystem: true,
                isDeleted: true,
                isHidden: true,
                isFavorite: false,
                createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
              ),
            );
          }
        }

        final List<Category> finalCategories = <Category>[
          ...categories,
          ...placeholdersToInsert,
        ];

        _logger?.logInfo(
          'ImportDataRepository: start restore '
          'accounts=${accounts.length}, '
          'goals=${savingGoals.length}, '
          'transactions=${transactions.length}',
        );
        try {
          if (bundle.integrity != null) {
            _integrityService.verify(bundle);
          }
          await _database
              .into(_database.currentSyncStates)
              .insertOnConflictUpdate(
                const db.CurrentSyncStatesCompanion(
                  id: Value<int>(1),
                  importInProgress: Value<bool>(true),
                ),
              );
          try {
            await _database.transaction(() async {
              final SyncConflictDao conflictDao = SyncConflictDao(_database);
              for (final String catId in missingCategoryIds) {
                final String conflictKey = 'missing_category_$catId';
                await conflictDao.upsertConflict(
                  conflictKey: conflictKey,
                  entityType: 'category',
                  entityId: catId,
                  conflictType: 'missingOptionalReference',
                  severity: 'warning',
                  status: 'pending',
                  metadataJson:
                      '{"missingEntityType":"category","missingEntityId":"$catId"}',
                );
              }

              final List<String> importedCategoryIds = categories
                  .where((Category c) => !c.isMissingReferencePlaceholder)
                  .map((Category c) => c.id)
                  .toList();
              await conflictDao.resolvePendingMissingReferences(
                'category',
                importedCategoryIds,
              );

              await _accountDao.upsertAll(accounts);
              await _categoryDao.upsertAll(finalCategories);
              await _tagDao.upsertAll(tags);
              await _creditDao.upsertAll(credits);
              await _creditCardDao.upsertAll(creditCards);
              await _debtDao.upsertAll(debts);
              await _creditPaymentDao.upsertSchedule(creditPaymentSchedules);
              await _creditPaymentDao.upsertPaymentGroups(creditPaymentGroups);
              await _budgetDao.upsertAll(budgets);
              await _budgetInstanceDao.upsertAll(budgetInstances);
              await _savingGoalDao.upsertAll(savingGoals);
              await _goalAccountLinkDao.replaceLinksByGoal(
                accountIdsByGoalId: <String, Iterable<String>>{
                  for (final SavingGoal goal in savingGoals)
                    goal.id: goal.effectiveStorageAccountIds,
                },
              );
              await _upsertUpcomingPayments(upcomingPayments);
              await _upsertPaymentReminders(paymentReminders);
              final List<TransactionEntity> validatedTransactions =
                  _validateImportedTransactionGroupReferences(
                    transactions,
                    schemaVersion: schemaVersion,
                    validGroupIds: importedCreditPaymentGroupIds,
                  );
              await _transactionDao.upsertAll(validatedTransactions);
              await _goalContributionRebuildService.rebuild();
              await _transactionTagsDao.upsertAll(transactionTags);
              if (bundle.profile != null) {
                await _profileDao.upsertInTransaction(bundle.profile!);
              }
              await _recalculateAccountBalances();

              final List<AccountEntity> persistedAccounts =
                  await _loadImportedAccounts(accounts);
              await _enqueueAccounts(persistedAccounts);
              await _enqueueCategories(finalCategories);
              await _enqueueTags(tags);
              await _enqueueCredits(credits);
              await _enqueueCreditCards(creditCards);
              await _enqueueDebts(debts);
              await _enqueueCreditPaymentSchedules(creditPaymentSchedules);
              await _enqueueCreditPaymentGroups(creditPaymentGroups);
              await _enqueueBudgets(budgets);
              await _enqueueBudgetInstances(budgetInstances);
              await _enqueueSavingGoals(savingGoals);
              await _enqueueUpcomingPayments(upcomingPayments);
              await _enqueuePaymentReminders(paymentReminders);
              await _enqueueTransactions(validatedTransactions);
              await _enqueueTransactionTags(transactionTags);
              if (bundle.profile != null) {
                await _enqueueProfile(bundle.profile!);
              }
              if (bundle.integrity != null) {
                final ExportBundle
                importedSnapshot = await _buildImportedBundleForIds(
                  expected: bundle.copyWith(transactions: transactions),
                  accountIds: accounts.map(
                    (AccountEntity account) => account.id,
                  ),
                  categoryIds: categories.map(
                    (Category category) => category.id,
                  ),
                  tagIds: tags.map((TagEntity tag) => tag.id),
                  transactionTagKeys: transactionTags.map(_transactionTagKey),
                  savingGoalIds: savingGoals.map((SavingGoal goal) => goal.id),
                  creditIds: credits.map((CreditEntity credit) => credit.id),
                  creditCardIds: creditCards.map(
                    (CreditCardEntity creditCard) => creditCard.id,
                  ),
                  debtIds: debts.map((DebtEntity debt) => debt.id),
                  creditPaymentGroupIds: creditPaymentGroups.map(
                    (CreditPaymentGroupEntity group) => group.id,
                  ),
                  creditPaymentScheduleIds: creditPaymentSchedules.map(
                    (CreditPaymentScheduleEntity item) => item.id,
                  ),
                  budgetIds: budgets.map((Budget budget) => budget.id),
                  budgetInstanceIds: budgetInstances.map(
                    (BudgetInstance instance) => instance.id,
                  ),
                  upcomingPaymentIds: upcomingPayments.map(
                    (UpcomingPayment payment) => payment.id,
                  ),
                  paymentReminderIds: paymentReminders.map(
                    (PaymentReminder reminder) => reminder.id,
                  ),
                  transactionIds: validatedTransactions.map(
                    (TransactionEntity transaction) => transaction.id,
                  ),
                );
                _integrityService.verify(
                  importedSnapshot.copyWith(
                    integrity: bundle.integrity,
                    transactions: validatedTransactions,
                  ),
                );
              }
            });
          } finally {
            await _database
                .into(_database.currentSyncStates)
                .insertOnConflictUpdate(
                  const db.CurrentSyncStatesCompanion(
                    id: Value<int>(1),
                    importInProgress: Value<bool>(false),
                  ),
                );
          }
          _logger?.logInfo(
            'ImportDataRepository: restore completed '
            'accounts=${accounts.length}, '
            'goals=${savingGoals.length}, '
            'transactions=${transactions.length}',
          );
          if (_accountTypeBackfillService != null) {
            final AccountTypeBackfillResult result =
                await _accountTypeBackfillService.run();
            _logger?.logInfo(
              'ImportDataRepository: deferred account type backfill after restore '
              'updated=${result.updatedCount}, scanned=${result.scannedCount}',
            );
          }
          await _runIntegrityDiagnostics();
          if (_analytics != null) {
            await _analytics
                .logEvent('import_restore_completed', <String, dynamic>{
                  'accounts': accounts.length,
                  'goals': savingGoals.length,
                  'transactions': transactions.length,
                  'categories': categories.length,
                  'creditPaymentGroups': creditPaymentGroups.length,
                  'creditPaymentSchedules': creditPaymentSchedules.length,
                });
          }
        } catch (error, stackTrace) {
          _logger?.logError('ImportDataRepository: restore failed', error);
          _analytics?.reportError(error, stackTrace);
          if (_analytics != null) {
            await _analytics
                .logEvent('import_restore_failed', <String, dynamic>{
                  'accounts': accounts.length,
                  'goals': savingGoals.length,
                  'transactions': transactions.length,
                  'categories': categories.length,
                  'creditPaymentGroups': creditPaymentGroups.length,
                  'creditPaymentSchedules': creditPaymentSchedules.length,
                });
          }
          rethrow;
        }
      },
    );
  }

  Future<void> _runIntegrityDiagnostics() async {
    final LocalSyncIntegrityReport report = await _integrityDiagnosticsService
        .run();
    _integrityDebugReporter.logReport(
      context: 'import_restore',
      report: report,
    );
    if (!report.hasIssues) {
      _logger?.logInfo(
        'ImportDataRepository: integrity diagnostics clean after restore.',
      );
      return;
    }
    _logger?.logError(
      'ImportDataRepository: integrity diagnostics found '
      '${report.issueCount} issue(s) after restore.',
    );
    if (_analytics == null) {
      return;
    }
    await _analytics.logEvent('local_db_integrity_issues', <String, dynamic>{
      'context': 'import_restore',
      'dbSchemaVersion': _database.schemaVersion,
      'issueCount': report.issueCount,
      'distinctTypes': report.issues
          .map((LocalSyncIntegrityIssue issue) => issue.type)
          .toSet()
          .length,
      'staleSending': report.countByType(
        LocalSyncIntegrityIssueType.staleSendingOutbox,
      ),
      'unsupportedOutbox': report.countByType(
        LocalSyncIntegrityIssueType.unsupportedOutboxEntityType,
      ),
      'orphanTransactions':
          report.countByType(
            LocalSyncIntegrityIssueType.orphanTransactionAccount,
          ) +
          report.countByType(
            LocalSyncIntegrityIssueType.orphanTransactionCategory,
          ) +
          report.countByType(LocalSyncIntegrityIssueType.invalidTransferLink),
      'accountBalances': report.countByType(
        LocalSyncIntegrityIssueType.accountBalanceMismatch,
      ),
      'savingGoals':
          report.countByType(
            LocalSyncIntegrityIssueType.invalidSavingGoalLink,
          ) +
          report.countByType(
            LocalSyncIntegrityIssueType.savingGoalCurrentAmountMismatch,
          ) +
          report.countByType(
            LocalSyncIntegrityIssueType.savingGoalMissingStorageAccount,
          ),
      'creditArtifacts':
          report.countByType(
            LocalSyncIntegrityIssueType.invalidCreditGroupLink,
          ) +
          report.countByType(LocalSyncIntegrityIssueType.invalidCreditSchedule),
      'moneyFields': report.countByType(
        LocalSyncIntegrityIssueType.invalidMoneyField,
      ),
    });
  }

  Future<void> _recalculateAccountBalances() async {
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    final List<TransactionEntity> transactions = await _transactionDao
        .getAllTransactions();
    final Map<String, MoneyAmount> deltas = <String, MoneyAmount>{
      for (final AccountEntity account in accounts)
        account.id: MoneyAmount(
          minor: BigInt.zero,
          scale:
              account.currencyScale ?? resolveCurrencyScale(account.currency),
        ),
    };
    final List<db.CreditRow> creditRows = await _creditDao.getAllCredits();
    final Map<String, String> creditAccountByCategoryId = <String, String>{
      for (final db.CreditRow row in creditRows)
        if (row.categoryId != null) row.categoryId!: row.accountId,
    };

    for (final TransactionEntity transaction in transactions) {
      if (transaction.isDeleted) continue;
      final String? creditAccountId = transaction.categoryId != null
          ? creditAccountByCategoryId[transaction.categoryId!]
          : null;
      final Map<String, MoneyAmount> effect = buildTransactionEffect(
        transaction: transaction,
        creditAccountId: creditAccountId,
      );
      applyTransactionEffect(deltas, effect);
    }

    final List<AccountEntity> updatedAccounts = accounts
        .map((AccountEntity account) {
          final int scale =
              account.currencyScale ?? resolveCurrencyScale(account.currency);
          final MoneyAmount net = rescaleMoneyAmount(
            deltas[account.id] ?? MoneyAmount(minor: BigInt.zero, scale: scale),
            scale,
          );
          final MoneyAmount openingBalance = _resolveOpeningBalance(
            account: account,
            netDelta: net,
          );
          return account.copyWith(
            openingBalanceMinor: openingBalance.minor,
            balanceMinor: openingBalance.minor + net.minor,
            currencyScale: scale,
          );
        })
        .toList(growable: false);
    await _accountDao.upsertAll(updatedAccounts);
  }

  Future<List<SavingGoal>> _loadSavingGoalsWithStorageAccounts() async {
    final List<SavingGoal> goals = await _savingGoalDao.getGoals(
      includeArchived: true,
    );
    if (goals.isEmpty) {
      return const <SavingGoal>[];
    }
    final Map<String, List<String>> idsByGoal = await _goalAccountLinkDao
        .findAccountIdsByGoalIds(goals.map((SavingGoal goal) => goal.id));
    return goals
        .map(
          (SavingGoal goal) =>
              mapSavingGoalStorageAccounts(goal, idsByGoal[goal.id]),
        )
        .toList(growable: false);
  }

  Future<List<AccountEntity>> _loadImportedAccounts(
    List<AccountEntity> importedAccounts,
  ) async {
    final Set<String> importedIds = importedAccounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    return accounts
        .where((AccountEntity account) => importedIds.contains(account.id))
        .toList(growable: false);
  }

  Future<void> _enqueueAccounts(List<AccountEntity> accounts) async {
    for (final AccountEntity account in accounts) {
      await _outboxDao.enqueue(
        entityType: _accountEntityType,
        entityId: account.id,
        operation: OutboxOperation.upsert,
        payload: _mapAccountPayload(account),
      );
    }
  }

  Future<void> _enqueueCategories(List<Category> categories) async {
    for (final Category category in categories) {
      if (category.isMissingReferencePlaceholder) {
        continue;
      }
      await _outboxDao.enqueue(
        entityType: _categoryEntityType,
        entityId: category.id,
        operation: OutboxOperation.upsert,
        payload: _mapCategoryPayload(category),
      );
    }
  }

  Future<void> _enqueueTags(List<TagEntity> tags) async {
    for (final TagEntity tag in tags) {
      await _outboxDao.enqueue(
        entityType: _tagEntityType,
        entityId: tag.id,
        operation: OutboxOperation.upsert,
        payload: _mapTagPayload(tag),
      );
    }
  }

  Future<void> _enqueueSavingGoals(List<SavingGoal> savingGoals) async {
    for (final SavingGoal goal in savingGoals) {
      await _outboxDao.enqueue(
        entityType: _savingGoalEntityType,
        entityId: goal.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(goal),
      );
    }
  }

  Future<void> _enqueueCredits(List<CreditEntity> credits) async {
    for (final CreditEntity credit in credits) {
      await _outboxDao.enqueue(
        entityType: _creditEntityType,
        entityId: credit.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditPayload(credit),
      );
    }
  }

  Future<void> _enqueueCreditCards(List<CreditCardEntity> creditCards) async {
    for (final CreditCardEntity creditCard in creditCards) {
      await _outboxDao.enqueue(
        entityType: _creditCardEntityType,
        entityId: creditCard.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditCardPayload(creditCard),
      );
    }
  }

  Future<void> _enqueueDebts(List<DebtEntity> debts) async {
    for (final DebtEntity debt in debts) {
      await _outboxDao.enqueue(
        entityType: _debtEntityType,
        entityId: debt.id,
        operation: OutboxOperation.upsert,
        payload: _mapDebtPayload(debt),
      );
    }
  }

  Future<void> _enqueueCreditPaymentGroups(
    List<CreditPaymentGroupEntity> groups,
  ) async {
    for (final CreditPaymentGroupEntity group in groups) {
      await _outboxDao.enqueue(
        entityType: _creditPaymentGroupEntityType,
        entityId: group.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditPaymentGroupPayload(group),
      );
    }
  }

  Future<void> _enqueueCreditPaymentSchedules(
    List<CreditPaymentScheduleEntity> items,
  ) async {
    for (final CreditPaymentScheduleEntity item in items) {
      await _outboxDao.enqueue(
        entityType: _creditPaymentScheduleEntityType,
        entityId: item.id,
        operation: OutboxOperation.upsert,
        payload: _mapCreditPaymentSchedulePayload(item),
      );
    }
  }

  Future<void> _enqueueBudgets(List<Budget> budgets) async {
    for (final Budget budget in budgets) {
      await _outboxDao.enqueue(
        entityType: _budgetEntityType,
        entityId: budget.id,
        operation: OutboxOperation.upsert,
        payload: _mapBudgetPayload(budget),
      );
    }
  }

  Future<void> _enqueueBudgetInstances(List<BudgetInstance> instances) async {
    for (final BudgetInstance instance in instances) {
      await _outboxDao.enqueue(
        entityType: _budgetInstanceEntityType,
        entityId: instance.id,
        operation: OutboxOperation.upsert,
        payload: _mapBudgetInstancePayload(instance),
      );
    }
  }

  Future<void> _enqueueTransactions(
    List<TransactionEntity> transactions,
  ) async {
    for (final TransactionEntity transaction in transactions) {
      await _outboxDao.enqueue(
        entityType: _transactionEntityType,
        entityId: transaction.id,
        operation: OutboxOperation.upsert,
        payload: _mapTransactionPayload(transaction),
      );
    }
  }

  Future<void> _enqueueUpcomingPayments(List<UpcomingPayment> payments) async {
    for (final UpcomingPayment payment in payments) {
      await _outboxDao.enqueue(
        entityType: _upcomingPaymentEntityType,
        entityId: payment.id,
        operation: OutboxOperation.upsert,
        payload: payment.toJson(),
      );
    }
  }

  Future<void> _enqueuePaymentReminders(List<PaymentReminder> reminders) async {
    for (final PaymentReminder reminder in reminders) {
      await _outboxDao.enqueue(
        entityType: _paymentReminderEntityType,
        entityId: reminder.id,
        operation: OutboxOperation.upsert,
        payload: reminder.toJson(),
      );
    }
  }

  Future<void> _enqueueTransactionTags(List<TransactionTagEntity> links) async {
    for (final TransactionTagEntity link in links) {
      await _outboxDao.enqueue(
        entityType: _transactionTagEntityType,
        entityId: _transactionTagKey(link),
        operation: OutboxOperation.upsert,
        payload: _mapTransactionTagPayload(link),
      );
    }
  }

  Future<void> _enqueueProfile(Profile profile) async {
    await _outboxDao.enqueue(
      entityType: _profileEntityType,
      entityId: profile.uid,
      operation: OutboxOperation.upsert,
      payload: _mapProfilePayload(profile),
    );
  }

  Future<ExportBundle> _buildImportedBundleForIds({
    required ExportBundle expected,
    required Iterable<String> accountIds,
    required Iterable<String> categoryIds,
    required Iterable<String> tagIds,
    required Iterable<String> transactionTagKeys,
    required Iterable<String> savingGoalIds,
    required Iterable<String> creditIds,
    required Iterable<String> creditCardIds,
    required Iterable<String> debtIds,
    required Iterable<String> creditPaymentGroupIds,
    required Iterable<String> creditPaymentScheduleIds,
    required Iterable<String> budgetIds,
    required Iterable<String> budgetInstanceIds,
    required Iterable<String> upcomingPaymentIds,
    required Iterable<String> paymentReminderIds,
    required Iterable<String> transactionIds,
  }) async {
    final Set<String> accountIdSet = accountIds.toSet();
    final Set<String> categoryIdSet = categoryIds.toSet();
    final Set<String> tagIdSet = tagIds.toSet();
    final Set<String> transactionTagKeySet = transactionTagKeys.toSet();
    final Set<String> savingGoalIdSet = savingGoalIds.toSet();
    final Set<String> creditIdSet = creditIds.toSet();
    final Set<String> creditCardIdSet = creditCardIds.toSet();
    final Set<String> debtIdSet = debtIds.toSet();
    final Set<String> creditPaymentGroupIdSet = creditPaymentGroupIds.toSet();
    final Set<String> creditPaymentScheduleIdSet = creditPaymentScheduleIds
        .toSet();
    final Set<String> budgetIdSet = budgetIds.toSet();
    final Set<String> budgetInstanceIdSet = budgetInstanceIds.toSet();
    final Set<String> upcomingPaymentIdSet = upcomingPaymentIds.toSet();
    final Set<String> paymentReminderIdSet = paymentReminderIds.toSet();
    final Set<String> transactionIdSet = transactionIds.toSet();
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    final List<Category> categories = await _categoryDao.getAllCategories();
    final List<TagEntity> tags = await _tagDao.getAllTags();
    final List<TransactionTagEntity> transactionTags =
        (await _transactionTagsDao.getAllTransactionTags())
            .map(_transactionTagsDao.mapRowToEntity)
            .toList(growable: false);
    final List<SavingGoal> savingGoals =
        await _loadSavingGoalsWithStorageAccounts();
    final List<CreditEntity> credits = (await _creditDao.getAllCredits())
        .map(_creditDao.mapRowToEntity)
        .toList(growable: false);
    final List<CreditCardEntity> creditCards =
        (await _creditCardDao.getAllCreditCards())
            .map(_creditCardDao.mapRowToEntity)
            .toList(growable: false);
    final List<DebtEntity> debts = (await _debtDao.getAllDebts())
        .map(_debtDao.mapRowToEntity)
        .toList(growable: false);
    final List<CreditPaymentGroupEntity> creditPaymentGroups =
        await _creditPaymentDao.getAllPaymentGroups();
    final List<CreditPaymentScheduleEntity> creditPaymentSchedules =
        await _creditPaymentDao.getAllScheduleItems();
    final List<Budget> budgets = await _budgetDao.getAllBudgets();
    final List<BudgetInstance> budgetInstances = await _budgetInstanceDao
        .getAllInstances();
    final List<UpcomingPayment> upcomingPayments = await _upcomingPaymentsDao
        .getAll();
    final List<PaymentReminder> paymentReminders = await _paymentRemindersDao
        .getAllIncludingDone();
    final List<TransactionEntity> transactions = await _transactionDao
        .getAllTransactions();
    final Profile? profile = expected.profile == null
        ? null
        : await _profileDao.getProfile(expected.profile!.uid);

    return expected.copyWith(
      accounts: accounts
          .where((AccountEntity account) => accountIdSet.contains(account.id))
          .toList(growable: false),
      categories: categories
          .where((Category category) => categoryIdSet.contains(category.id))
          .toList(growable: false),
      tags: tags
          .where((TagEntity tag) => tagIdSet.contains(tag.id))
          .toList(growable: false),
      transactionTags: transactionTags
          .where(
            (TransactionTagEntity link) =>
                transactionTagKeySet.contains(_transactionTagKey(link)),
          )
          .toList(growable: false),
      savingGoals: savingGoals
          .where((SavingGoal goal) => savingGoalIdSet.contains(goal.id))
          .toList(growable: false),
      credits: credits
          .where((CreditEntity credit) => creditIdSet.contains(credit.id))
          .toList(growable: false),
      creditCards: creditCards
          .where(
            (CreditCardEntity creditCard) =>
                creditCardIdSet.contains(creditCard.id),
          )
          .toList(growable: false),
      debts: debts
          .where((DebtEntity debt) => debtIdSet.contains(debt.id))
          .toList(growable: false),
      creditPaymentGroups: creditPaymentGroups
          .where(
            (CreditPaymentGroupEntity group) =>
                creditPaymentGroupIdSet.contains(group.id),
          )
          .toList(growable: false),
      creditPaymentSchedules: creditPaymentSchedules
          .where(
            (CreditPaymentScheduleEntity item) =>
                creditPaymentScheduleIdSet.contains(item.id),
          )
          .toList(growable: false),
      budgets: budgets
          .where((Budget budget) => budgetIdSet.contains(budget.id))
          .toList(growable: false),
      budgetInstances: budgetInstances
          .where(
            (BudgetInstance instance) =>
                budgetInstanceIdSet.contains(instance.id),
          )
          .toList(growable: false),
      upcomingPayments: upcomingPayments
          .where(
            (UpcomingPayment payment) =>
                upcomingPaymentIdSet.contains(payment.id),
          )
          .toList(growable: false),
      paymentReminders: paymentReminders
          .where(
            (PaymentReminder reminder) =>
                paymentReminderIdSet.contains(reminder.id),
          )
          .toList(growable: false),
      transactions: transactions
          .where(
            (TransactionEntity transaction) =>
                transactionIdSet.contains(transaction.id),
          )
          .toList(growable: false),
      profile: profile,
      progress: _rebuildProgress(
        expectedProgress: expected.progress,
        transactions: transactions
            .where(
              (TransactionEntity transaction) =>
                  transactionIdSet.contains(transaction.id),
            )
            .toList(growable: false),
      ),
      integrity: expected.integrity,
    );
  }

  UserProgress? _rebuildProgress({
    required UserProgress? expectedProgress,
    required List<TransactionEntity> transactions,
  }) {
    if (expectedProgress == null) {
      return null;
    }
    final int totalTx = transactions
        .where((TransactionEntity transaction) => !transaction.isDeleted)
        .length;
    final int level = _levelPolicy.levelFor(totalTx);
    return UserProgress(
      totalTx: totalTx,
      level: level,
      title: _levelPolicy.titleFor(level),
      nextThreshold: _levelPolicy.nextThreshold(totalTx),
      updatedAt: expectedProgress.updatedAt,
    );
  }

  MoneyAmount _resolveOpeningBalance({
    required AccountEntity account,
    required MoneyAmount netDelta,
  }) {
    final MoneyAmount balance = rescaleMoneyAmount(
      account.balanceAmount,
      netDelta.scale,
    );
    final MoneyAmount opening = rescaleMoneyAmount(
      account.openingBalanceAmount,
      netDelta.scale,
    );
    final BigInt derivedMinor = balance.minor - netDelta.minor;
    if (opening.minor == BigInt.zero && netDelta.minor != BigInt.zero) {
      return MoneyAmount(minor: derivedMinor, scale: netDelta.scale);
    }
    return opening;
  }

  TransactionEntity _normalizeImportedTransaction(
    TransactionEntity transaction,
    ExportBundleSchemaVersion version,
  ) {
    final TransactionEntity normalized =
        SyncContract.normalizeTransactionForPortableSync(transaction);
    if (!ExportBundleSchema.requiresCreditPaymentArtifacts(version)) {
      return normalized.copyWith(groupId: null);
    }
    return normalized;
  }

  List<TransactionEntity> _validateImportedTransactionGroupReferences(
    List<TransactionEntity> transactions, {
    required ExportBundleSchemaVersion schemaVersion,
    required Set<String> validGroupIds,
  }) {
    if (!ExportBundleSchema.requiresCreditPaymentArtifacts(schemaVersion) ||
        transactions.isEmpty) {
      return transactions;
    }

    return transactions
        .map((TransactionEntity transaction) {
          final String? groupId = transaction.groupId;
          if (groupId == null || validGroupIds.contains(groupId)) {
            return transaction;
          }
          if (transaction.isDeleted) {
            return transaction.copyWith(groupId: null);
          }
          throw FormatException(
            'Транзакция ${transaction.id} ссылается на отсутствующую '
            'credit_payment_group $groupId в backup со схемой '
            '${schemaVersion.raw}.',
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _mapAccountPayload(AccountEntity account) {
    final Map<String, dynamic> json = account.toJson();
    json['updatedAt'] = account.updatedAt.toIso8601String();
    json['createdAt'] = account.createdAt.toIso8601String();
    json['isPrimary'] = account.isPrimary;
    json['color'] = account.color;
    json['gradientId'] = account.gradientId;
    json['iconName'] = account.iconName;
    json['iconStyle'] = account.iconStyle;
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount openingBalance = account.openingBalanceAmount;
    json['balance'] = balance.toDouble();
    json['openingBalance'] = openingBalance.toDouble();
    json['balanceMinor'] = balance.minor.toString();
    json['openingBalanceMinor'] = openingBalance.minor.toString();
    json['currencyScale'] = account.currencyScale;
    return json;
  }

  Map<String, dynamic> _mapCategoryPayload(Category category) {
    final Map<String, dynamic> json = category.toJson();
    json['iconName'] = category.icon?.name;
    json['iconStyle'] = category.icon?.style.label;
    json['parentId'] = category.parentId;
    json['createdAt'] = category.createdAt.toIso8601String();
    json['updatedAt'] = category.updatedAt.toIso8601String();
    json['isSystem'] = category.isSystem;
    json['isHidden'] = category.isHidden;
    json['isFavorite'] = category.isFavorite;
    return json;
  }

  Map<String, dynamic> _mapTagPayload(TagEntity tag) {
    final Map<String, dynamic> json = tag.toJson();
    json['createdAt'] = tag.createdAt.toIso8601String();
    json['updatedAt'] = tag.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    json['targetDate'] = goal.targetDate?.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    json['savingGoalId'] = transaction.savingGoalId;
    json['idempotencyKey'] = transaction.idempotencyKey;
    json['groupId'] = transaction.groupId;
    json['amountMinor'] = transaction.amountMinor?.toString();
    json['amountScale'] = transaction.amountScale;
    return json;
  }

  Map<String, dynamic> _mapCreditPayload(CreditEntity credit) {
    final Map<String, dynamic> json = credit.toJson();
    json['startDate'] = credit.startDate.toIso8601String();
    json['firstPaymentDate'] = credit.firstPaymentDate?.toIso8601String();
    json['createdAt'] = credit.createdAt.toIso8601String();
    json['updatedAt'] = credit.updatedAt.toIso8601String();
    json['totalAmountMinor'] = credit.totalAmountMinor?.toString();
    json['totalAmountScale'] = credit.totalAmountScale;
    return json;
  }

  Map<String, dynamic> _mapCreditCardPayload(CreditCardEntity creditCard) {
    final Map<String, dynamic> json = creditCard.toJson();
    json['createdAt'] = creditCard.createdAt.toIso8601String();
    json['updatedAt'] = creditCard.updatedAt.toIso8601String();
    json['creditLimitMinor'] = creditCard.creditLimitMinor?.toString();
    json['creditLimitScale'] = creditCard.creditLimitScale;
    return json;
  }

  Map<String, dynamic> _mapDebtPayload(DebtEntity debt) {
    final Map<String, dynamic> json = debt.toJson();
    json['dueDate'] = debt.dueDate.toIso8601String();
    json['createdAt'] = debt.createdAt.toIso8601String();
    json['updatedAt'] = debt.updatedAt.toIso8601String();
    json['amountMinor'] = debt.amountMinor?.toString();
    json['amountScale'] = debt.amountScale;
    return json;
  }

  Map<String, dynamic> _mapCreditPaymentGroupPayload(
    CreditPaymentGroupEntity group,
  ) {
    return <String, dynamic>{
      'id': group.id,
      'creditId': group.creditId,
      'sourceAccountId': group.sourceAccountId,
      'scheduleItemId': group.scheduleItemId,
      'paidAt': group.paidAt.toIso8601String(),
      'totalOutflowMinor': group.totalOutflow.minor.toString(),
      'totalOutflowScale': group.totalOutflow.scale,
      'principalPaidMinor': group.principalPaid.minor.toString(),
      'interestPaidMinor': group.interestPaid.minor.toString(),
      'feesPaidMinor': group.feesPaid.minor.toString(),
      'note': group.note,
      'idempotencyKey': group.idempotencyKey,
      'createdAt': (group.createdAt ?? group.paidAt).toIso8601String(),
      'updatedAt': (group.updatedAt ?? group.paidAt).toIso8601String(),
      'isDeleted': group.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapCreditPaymentSchedulePayload(
    CreditPaymentScheduleEntity item,
  ) {
    return <String, dynamic>{
      'id': item.id,
      'creditId': item.creditId,
      'periodKey': item.periodKey,
      'dueDate': item.dueDate.toIso8601String(),
      'status': item.status.name,
      'principalAmountMinor': item.principalAmount.minor.toString(),
      'interestAmountMinor': item.interestAmount.minor.toString(),
      'totalAmountMinor': item.totalAmount.minor.toString(),
      'amountScale': item.totalAmount.scale,
      'principalPaidMinor': item.principalPaid.minor.toString(),
      'interestPaidMinor': item.interestPaid.minor.toString(),
      'paidAt': item.paidAt?.toIso8601String(),
      'createdAt': (item.createdAt ?? item.dueDate).toIso8601String(),
      'updatedAt': (item.updatedAt ?? item.dueDate).toIso8601String(),
      'isDeleted': item.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapTransactionTagPayload(TransactionTagEntity link) {
    final Map<String, dynamic> json = link.toJson();
    json['createdAt'] = link.createdAt.toIso8601String();
    json['updatedAt'] = link.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapProfilePayload(Profile profile) {
    return <String, dynamic>{
      'uid': profile.uid,
      'name': profile.name,
      'currency': profile.currency.name,
      'locale': profile.locale,
      'photoUrl': profile.photoUrl,
      'updatedAt': profile.updatedAt.toIso8601String(),
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapBudgetPayload(Budget budget) {
    final Map<String, dynamic> json = budget.toJson();
    final MoneyAmount amount = budget.amountValue;
    json['startDate'] = budget.startDate.toIso8601String();
    json['endDate'] = budget.endDate?.toIso8601String();
    json['createdAt'] = budget.createdAt.toIso8601String();
    json['updatedAt'] = budget.updatedAt.toIso8601String();
    json['amount'] = amount.toDouble();
    json['amountMinor'] = amount.minor.toString();
    json['amountScale'] = amount.scale;
    return json;
  }

  Map<String, dynamic> _mapBudgetInstancePayload(
    BudgetInstance instance, {
    bool deleted = false,
  }) {
    final MoneyAmount amount = instance.amountValue;
    final MoneyAmount spent = instance.spentValue;
    return <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'spent': spent.toDouble(),
      'spentMinor': spent.minor.toString(),
      'amountScale': amount.scale,
      'status': instance.status.storageValue,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deleted': deleted,
    };
  }

  Future<void> _upsertUpcomingPayments(List<UpcomingPayment> payments) async {
    for (final UpcomingPayment payment in payments) {
      await _upcomingPaymentsDao.upsert(payment);
    }
  }

  Future<void> _upsertPaymentReminders(List<PaymentReminder> reminders) async {
    for (final PaymentReminder reminder in reminders) {
      await _paymentRemindersDao.upsert(reminder);
    }
  }

  String _transactionTagKey(TransactionTagEntity link) {
    return '${link.transactionId}::${link.tagId}';
  }
}
