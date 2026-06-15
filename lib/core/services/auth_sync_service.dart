import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:intl/intl.dart';
import 'package:kopim/core/services/sync/sync_conflict_types.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/data/outbox/outbox_payload_normalizer.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_debug_reporter.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_diagnostics_service.dart';
import 'package:kopim/core/services/sync/sync_data_sanitizer.dart';
import 'package:kopim/core/services/sync/sync_metadata_repository.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/features/accounts/data/services/account_type_backfill_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/liability_account_links.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/savings/data/mappers/saving_goal_storage_accounts_mapper.dart';
import 'package:kopim/features/savings/data/services/goal_contribution_rebuild_service.dart';
import 'package:kopim/features/savings/data/sources/local/goal_account_link_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/data/sources/remote/tag_remote_data_source.dart';
import 'package:kopim/features/tags/data/sources/remote/transaction_tag_remote_data_source.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/credits/data/sources/local/credit_card_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/debt_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_card_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_payment_group_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_payment_schedule_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AuthSyncService {
  AuthSyncService({
    required AppDatabase database,
    required OutboxDao outboxDao,
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required TagDao tagDao,
    required TransactionDao transactionDao,
    required TransactionTagsDao transactionTagsDao,
    required CreditCardDao creditCardDao,
    required CreditDao creditDao,
    required DebtDao debtDao,
    required CreditPaymentDao creditPaymentDao,
    required BudgetDao budgetDao,
    required BudgetInstanceDao budgetInstanceDao,
    required SavingGoalDao savingGoalDao,
    required GoalAccountLinkDao goalAccountLinkDao,
    required UpcomingPaymentsDao upcomingPaymentsDao,
    required PaymentRemindersDao paymentRemindersDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required TransactionTagRemoteDataSource transactionTagRemoteDataSource,
    required CreditCardRemoteDataSource creditCardRemoteDataSource,
    required CreditRemoteDataSource creditRemoteDataSource,
    required DebtRemoteDataSource debtRemoteDataSource,
    required CreditPaymentGroupRemoteDataSource
    creditPaymentGroupRemoteDataSource,
    required CreditPaymentScheduleRemoteDataSource
    creditPaymentScheduleRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource,
    required SavingGoalRemoteDataSource savingGoalRemoteDataSource,
    required UpcomingPaymentRemoteDataSource upcomingPaymentRemoteDataSource,
    required PaymentReminderRemoteDataSource paymentReminderRemoteDataSource,
    required ProfileDao profileDao,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required FirebaseFirestore firestore,
    required LoggerService loggerService,
    required AnalyticsService analyticsService,
    required SyncDataSanitizer dataSanitizer,
    required SyncMetadataRepository syncMetadataRepository,
    AccountTypeBackfillService? accountTypeBackfillService,
    GoalContributionRebuildService? goalContributionRebuildService,
    LocalSyncIntegrityDiagnosticsService? integrityDiagnosticsService,
    LocalSyncIntegrityDebugReporter? integrityDebugReporter,
    OutboxPayloadNormalizer payloadNormalizer = const OutboxPayloadNormalizer(),
  }) : _database = database,
       _outboxDao = outboxDao,
       _accountDao = accountDao,
       _categoryDao = categoryDao,
       _tagDao = tagDao,
       _transactionDao = transactionDao,
       _transactionTagsDao = transactionTagsDao,
       _creditCardDao = creditCardDao,
       _creditDao = creditDao,
       _debtDao = debtDao,
       _creditPaymentDao = creditPaymentDao,
       _budgetDao = budgetDao,
       _budgetInstanceDao = budgetInstanceDao,
       _savingGoalDao = savingGoalDao,
       _goalAccountLinkDao = goalAccountLinkDao,
       _upcomingPaymentsDao = upcomingPaymentsDao,
       _paymentRemindersDao = paymentRemindersDao,
       _profileDao = profileDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _tagRemoteDataSource = tagRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _transactionTagRemoteDataSource = transactionTagRemoteDataSource,
       _creditCardRemoteDataSource = creditCardRemoteDataSource,
       _creditRemoteDataSource = creditRemoteDataSource,
       _debtRemoteDataSource = debtRemoteDataSource,
       _creditPaymentGroupRemoteDataSource = creditPaymentGroupRemoteDataSource,
       _creditPaymentScheduleRemoteDataSource =
           creditPaymentScheduleRemoteDataSource,
       _budgetRemoteDataSource = budgetRemoteDataSource,
       _budgetInstanceRemoteDataSource = budgetInstanceRemoteDataSource,
       _savingGoalRemoteDataSource = savingGoalRemoteDataSource,
       _upcomingPaymentRemoteDataSource = upcomingPaymentRemoteDataSource,
       _paymentReminderRemoteDataSource = paymentReminderRemoteDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _firestore = firestore,
       _logger = loggerService,
       _analyticsService = analyticsService,
       _accountTypeBackfillService = accountTypeBackfillService,
       _goalContributionRebuildService =
           goalContributionRebuildService ??
           GoalContributionRebuildService(database),
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
             logger: loggerService,
           ),
       _dataSanitizer = dataSanitizer,
       _syncMetadataRepository = syncMetadataRepository,
       _payloadNormalizer = payloadNormalizer;

  static const String entityTypeTransaction = 'transaction';
  static const String entityTypeTransactionTag = 'transaction_tag';
  static const String entityTypeCategory = 'category';
  static const String entityTypeAccount = 'account';
  static const String entityTypeTag = 'tag';
  static const String entityTypeCredit = 'credit';
  static const String entityTypeCreditCard = 'credit_card';
  static const String entityTypeDebt = 'debt';
  static const String entityTypeCreditPaymentGroup = 'credit_payment_group';
  static const String entityTypeCreditPaymentSchedule =
      'credit_payment_schedule';
  static const String entityTypeBudget = 'budget';
  static const String entityTypeBudgetInstance = 'budget_instance';
  static const String entityTypeSavingGoal = 'saving_goal';
  static const String entityTypeUpcomingPayment = 'upcoming_payment';
  static const String entityTypePaymentReminder = 'payment_reminder';
  static const String entityTypeProfile = 'profile';

  late final SyncConflictDao _syncConflictDao = SyncConflictDao(_database);
  int _pushBatchSize = 200;

  int get pushBatchSize => _pushBatchSize;
  set pushBatchSize(int value) {
    _pushBatchSize = value.clamp(50, 300);
  }

  static const Duration _staleSendingRecoveryWindow = Duration(minutes: 5);

  static const int _outboxBatchSize = 500;
  static const int maxRegistryEntriesPerShardSoftLimit = 3000;

  final AppDatabase _database;
  final OutboxDao _outboxDao;
  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final TagDao _tagDao;
  final TransactionDao _transactionDao;
  final TransactionTagsDao _transactionTagsDao;
  final CreditCardDao _creditCardDao;
  final CreditDao _creditDao;
  final DebtDao _debtDao;
  final CreditPaymentDao _creditPaymentDao;
  final BudgetDao _budgetDao;
  final BudgetInstanceDao _budgetInstanceDao;
  final SavingGoalDao _savingGoalDao;
  final GoalAccountLinkDao _goalAccountLinkDao;
  final UpcomingPaymentsDao _upcomingPaymentsDao;
  final PaymentRemindersDao _paymentRemindersDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TagRemoteDataSource _tagRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final TransactionTagRemoteDataSource _transactionTagRemoteDataSource;
  final CreditCardRemoteDataSource _creditCardRemoteDataSource;
  final CreditRemoteDataSource _creditRemoteDataSource;
  final DebtRemoteDataSource _debtRemoteDataSource;
  final CreditPaymentGroupRemoteDataSource _creditPaymentGroupRemoteDataSource;
  final CreditPaymentScheduleRemoteDataSource
  _creditPaymentScheduleRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final BudgetInstanceRemoteDataSource _budgetInstanceRemoteDataSource;
  final SavingGoalRemoteDataSource _savingGoalRemoteDataSource;
  final UpcomingPaymentRemoteDataSource _upcomingPaymentRemoteDataSource;
  final PaymentReminderRemoteDataSource _paymentReminderRemoteDataSource;
  final ProfileDao _profileDao;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final FirebaseFirestore _firestore;
  final LoggerService _logger;
  final AnalyticsService _analyticsService;
  final AccountTypeBackfillService? _accountTypeBackfillService;
  final GoalContributionRebuildService _goalContributionRebuildService;
  final LocalSyncIntegrityDiagnosticsService _integrityDiagnosticsService;
  final LocalSyncIntegrityDebugReporter _integrityDebugReporter;
  final OutboxPayloadNormalizer _payloadNormalizer;
  final SyncDataSanitizer _dataSanitizer;
  final SyncMetadataRepository _syncMetadataRepository;

  bool _inProgress = false;

  Future<void> synchronizeOnLogin({
    required AuthUser user,
    AuthUser? previousUser,
  }) async {
    if (_inProgress) {
      _logger.logInfo('AuthSyncService: synchronization already running, skip');
      return;
    }
    if (user.isAnonymous) {
      _logger.logInfo(
        'AuthSyncService: skip sync for anonymous user ${user.uid}.',
      );
      return;
    }

    _inProgress = true;
    final bool upgradingFromAnonymous =
        (previousUser?.isAnonymous ?? false) && !user.isAnonymous;

    final Map<String, dynamic> syncContext = <String, dynamic>{
      'userId': user.uid,
      'upgradedFromAnonymous': upgradingFromAnonymous ? 1 : 0,
    };

    await _analyticsService.logEvent('auth_sync_start', syncContext);
    _logger.logInfo(
      'AuthSyncService: starting login sync for ${user.uid}, upgraded: $upgradingFromAnonymous.',
    );

    List<db.OutboxEntryRow> preparedEntries = <db.OutboxEntryRow>[];
    bool wasFallbackUsed = false;
    try {
      // 1. recoverStaleSending()
      await _outboxDao.resetStaleSendingToPending(
        cutoff: DateTime.now().subtract(_staleSendingRecoveryWindow),
      );

      // 2. pullRemoteRegistry()
      final _RemoteRegistryPullResult registryResult =
          await _pullRemoteRegistry(user.uid);
      final Map<String, Map<String, _RemoteEntityMetadata>> remoteMetadata =
          registryResult.metadata;
      wasFallbackUsed = registryResult.wasFallbackUsed;

      // 3. readOutbox()
      final List<db.OutboxEntryRow> allPending = await _outboxDao.fetchPending(
        limit: 10000,
      );

      // 4. classifyOutboxEntries()
      final List<db.OutboxEntryRow> safeEntries = <db.OutboxEntryRow>[];
      final List<db.OutboxEntryRow> conflictedEntries = <db.OutboxEntryRow>[];
      final List<db.OutboxEntryRow> staleEntries = <db.OutboxEntryRow>[];

      for (final db.OutboxEntryRow entry in allPending) {
        final Map<String, dynamic> payload = _payloadNormalizer.normalize(
          entry.entityType,
          _outboxDao.decodePayload(entry),
        );

        if (entry.entityType == entityTypeCategory) {
          final Category category = Category.fromJson(payload);
          if (category.isMissingReferencePlaceholder) {
            continue;
          }
        }

        final _RemoteEntityMetadata? remoteMeta =
            remoteMetadata[entry.entityType]?[_registryEntityKey(
              entityType: entry.entityType,
              entityId: entry.entityId,
            )];

        if (remoteMeta != null) {
          final DateTime? localUpdatedAt = _extractOutboxUpdatedAt(
            entry.entityType,
            payload,
          );
          bool isStale = false;

          if (entry.entityType == entityTypeAccount) {
            final int localTypeVersion = _extractAccountTypeVersion(payload);
            final int remoteTypeVersion = remoteMeta.typeVersion ?? 0;
            if (localTypeVersion < remoteTypeVersion) {
              isStale = true;
              _logger.logInfo(
                'AuthSyncService: prevented legacy rollback for account '
                '${entry.entityId} (local=$localTypeVersion, remote=$remoteTypeVersion).',
              );
              unawaited(
                _analyticsService.logEvent(
                  'account_type_rollback_prevented',
                  <String, dynamic>{
                    'localTypeVersion': localTypeVersion,
                    'remoteTypeVersion': remoteTypeVersion,
                  },
                ),
              );
            }
          }

          if (!isStale && localUpdatedAt != null) {
            if (localUpdatedAt.isBefore(remoteMeta.updatedAt)) {
              isStale = true;
            }
          }

          if (isStale) {
            staleEntries.add(entry);
            continue;
          }
        }

        if (_hasRemoteChangedSinceBase(
          remote: remoteMeta,
          outboxEntry: entry,
        )) {
          conflictedEntries.add(entry);
        } else {
          safeEntries.add(entry);
        }
      }

      // 5. persistConflicts()
      for (final db.OutboxEntryRow entry in conflictedEntries) {
        final Map<String, dynamic> payload = _payloadNormalizer.normalize(
          entry.entityType,
          _outboxDao.decodePayload(entry),
        );
        final DateTime localUpdatedAt =
            _extractOutboxUpdatedAt(entry.entityType, payload) ??
            DateTime.now();
        final _RemoteEntityMetadata? remoteMeta =
            remoteMetadata[entry.entityType]?[_registryEntityKey(
              entityType: entry.entityType,
              entityId: entry.entityId,
            )];

        final SyncConflictType conflictType =
            (entry.operation == 'delete' || (remoteMeta?.isDeleted ?? false))
            ? SyncConflictType.deleteUpdate
            : SyncConflictType.updateUpdate;

        final String conflictKey =
            '${entry.entityType}_${entry.entityId}_${conflictType.value}';
        final Map<String, String> metadata = <String, String>{
          'localUpdatedAt': localUpdatedAt.toIso8601String(),
          'operation': entry.operation,
        };
        if (remoteMeta != null) {
          metadata['remoteUpdatedAt'] = remoteMeta.updatedAt.toIso8601String();
        }

        await _syncConflictDao.upsertConflict(
          conflictKey: conflictKey,
          entityType: entry.entityType,
          entityId: entry.entityId,
          conflictType: conflictType.value,
          severity: 'warning',
          status: 'pending',
          localPayloadJson: jsonEncode(payload),
          metadataJson: jsonEncode(metadata),
        );
      }

      // 6. pushSafeEntriesInChunks()
      final List<db.OutboxEntryRow> successfullyPushed = <db.OutboxEntryRow>[];

      if (staleEntries.isNotEmpty) {
        final List<int> staleIds = staleEntries
            .map((db.OutboxEntryRow e) => e.id)
            .toList();
        await _outboxDao.markBatchAsSent(staleIds);
        await _outboxDao.pruneSent();
        successfullyPushed.addAll(staleEntries);
      }

      int currentBatchSize = pushBatchSize;
      int chunkIdx = 0;

      while (chunkIdx < safeEntries.length) {
        final int chunkSize = (chunkIdx + currentBatchSize > safeEntries.length)
            ? safeEntries.length - chunkIdx
            : currentBatchSize;
        final List<db.OutboxEntryRow> chunk = safeEntries.sublist(
          chunkIdx,
          chunkIdx + chunkSize,
        );

        final List<int> chunkIds = chunk
            .map((db.OutboxEntryRow e) => e.id)
            .toList();
        await _database.transaction(() async {
          for (final db.OutboxEntryRow entry in chunk) {
            await _outboxDao.prepareForSend(entry);
          }
        });

        try {
          final _PushChunkResult result = await _pushSafeChunkWithRegistryGuard(
            user.uid,
            chunk,
          );

          if (result.conflicted.isNotEmpty) {
            final List<int> conflictedIds = result.conflicted
                .map((db.OutboxEntryRow e) => e.id)
                .toList();
            await _outboxDao.resetAllToPending(conflictedIds);

            for (final db.OutboxEntryRow entry in result.conflicted) {
              final Map<String, dynamic> payload = _payloadNormalizer.normalize(
                entry.entityType,
                _outboxDao.decodePayload(entry),
              );
              final DateTime localUpdatedAt =
                  _extractOutboxUpdatedAt(entry.entityType, payload) ??
                  DateTime.now();
              const SyncConflictType conflictType =
                  SyncConflictType.updateUpdate;
              final String conflictKey =
                  '${entry.entityType}_${entry.entityId}_${conflictType.value}';
              final Map<String, String> metadata = <String, String>{
                'localUpdatedAt': localUpdatedAt.toIso8601String(),
                'operation': entry.operation,
                'note': 'Registry changed during transaction',
              };

              await _syncConflictDao.upsertConflict(
                conflictKey: conflictKey,
                entityType: entry.entityType,
                entityId: entry.entityId,
                conflictType: conflictType.value,
                severity: 'warning',
                status: 'pending',
                localPayloadJson: jsonEncode(payload),
                metadataJson: jsonEncode(metadata),
              );
            }
          }

          if (result.pushed.isNotEmpty) {
            successfullyPushed.addAll(result.pushed);
            final List<int> pushedIds = result.pushed
                .map((db.OutboxEntryRow e) => e.id)
                .toList();
            await _outboxDao.markBatchAsSent(pushedIds);
            await _outboxDao.pruneSent();
          }

          chunkIdx += chunkSize;
        } catch (e) {
          final bool isRetryable =
              e.toString().contains('RESOURCE_EXHAUSTED') ||
              e.toString().contains('ABORTED') ||
              e.toString().contains('ResourceExhausted');

          if (isRetryable && currentBatchSize > 50) {
            currentBatchSize = (currentBatchSize / 2).floor().clamp(50, 300);
            _logger.logInfo(
              'AuthSyncService: Resource exhausted or aborted, retrying chunk with batch size: $currentBatchSize',
            );
            await _outboxDao.resetAllToPending(chunkIds);
            continue;
          } else {
            await _outboxDao.resetAllToPending(chunkIds);
            rethrow;
          }
        }
      }

      preparedEntries = successfullyPushed;

      // 8. fullPullAndMerge()
      final _RemoteSnapshot remoteSnapshot = await _fetchRemoteSnapshot(
        user.uid,
      );
      await _persistMergedState(
        remoteSnapshot: remoteSnapshot,
        processedEntries: successfullyPushed,
        user: user,
      );

      final DateTime syncCompletionTime = DateTime.now().toUtc();
      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null) {
          await _syncMetadataRepository.setLastPulledAt(
            user.uid,
            entry.outboxEntityType!,
            syncCompletionTime,
          );
        }
      }

      final List<db.OutboxEntryRow> backfillEntries =
          await _runDeferredAccountTypeBackfill(user.uid);
      if (backfillEntries.isNotEmpty) {
        preparedEntries = <db.OutboxEntryRow>[
          ...preparedEntries,
          ...backfillEntries,
        ];
      }

      // 9. bootstrapRegistry()
      if (wasFallbackUsed) {
        await _bootstrapRegistry(user.uid);
      }

      await _runIntegrityDiagnostics(context: 'auth_sync');
      await _analyticsService.logEvent('auth_sync_success', <String, dynamic>{
        ...syncContext,
        'pendingEntries': preparedEntries.length,
        'remoteAccounts': remoteSnapshot.accounts.length,
        'remoteCategories': remoteSnapshot.categories.length,
        'remoteTransactions': remoteSnapshot.transactions.length,
        'remoteCredits': remoteSnapshot.credits.length,
        'remoteCreditCards': remoteSnapshot.creditCards.length,
        'remoteDebts': remoteSnapshot.debts.length,
        'remoteCreditPaymentGroups': remoteSnapshot.creditPaymentGroups.length,
        'remoteCreditPaymentSchedules':
            remoteSnapshot.creditPaymentSchedules.length,
        'remoteBudgets': remoteSnapshot.budgets.length,
        'remoteBudgetInstances': remoteSnapshot.budgetInstances.length,
        'remoteSavingGoals': remoteSnapshot.savingGoals.length,
        'remoteRecurringPayments': remoteSnapshot.upcomingPayments.length,
      });

      _logger.logInfo(
        'AuthSyncService: login sync completed for ${user.uid}. '
        'Accounts: ${remoteSnapshot.accounts.length}, '
        'Categories: ${remoteSnapshot.categories.length}, '
        'Transactions: ${remoteSnapshot.transactions.length}.',
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'AuthSyncService: synchronization failed for ${user.uid}',
        error,
      );
      // ignore: avoid_print
      print('CRITICAL SYNC ERROR: $error');
      // ignore: avoid_print
      print(stackTrace);
      _analyticsService.reportError(error, stackTrace);
      if (preparedEntries.isNotEmpty) {
        await _outboxDao.resetAllToPending(
          preparedEntries.map((db.OutboxEntryRow entry) => entry.id),
        );
      }
      throw const AuthFailure(
        code: 'sync-failed',
        message: 'Failed to synchronize data. Please try again later.',
      );
    } finally {
      _inProgress = false;
    }
  }

  List<T> _filterChanged<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) getId,
    required DateTime Function(T) getUpdatedAt,
  }) {
    final Map<String, T> localMap = <String, T>{
      for (final T item in local) getId(item): item,
    };
    final List<T> changed = <T>[];
    for (final T remoteItem in remote) {
      final String id = getId(remoteItem);
      final T? localItem = localMap[id];
      if (localItem == null) {
        changed.add(remoteItem);
      } else {
        final DateTime remoteTime = getUpdatedAt(remoteItem);
        final DateTime localTime = getUpdatedAt(localItem);
        if (remoteTime.isAfter(localTime)) {
          changed.add(remoteItem);
        }
      }
    }
    return changed;
  }

  Future<int> performIncrementalSync(String userId) async {
    final Map<String, DateTime> updatedCursors = <String, DateTime>{};
    final Map<String, DateTime> cursors = <String, DateTime>{};

    for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
      if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
        final DateTime? lastPulled = await _syncMetadataRepository
            .getLastPulledAt(userId, entry.outboxEntityType!);
        if (lastPulled == null) {
          _logger.logWarning(
            'AuthSyncService: lastPulledAt is null for ${entry.outboxEntityType}. Full sync required.',
          );
          throw StateError('full_sync_required');
        }
        cursors[entry.outboxEntityType!] = lastPulled;
      }
    }

    final List<AccountEntity> pulledAccounts = <AccountEntity>[];
    final List<Category> pulledCategories = <Category>[];
    final List<TagEntity> pulledTags = <TagEntity>[];
    final List<TransactionTagEntity> pulledTransactionTags =
        <TransactionTagEntity>[];
    final List<TransactionEntity> pulledTransactions = <TransactionEntity>[];
    final List<CreditEntity> pulledCredits = <CreditEntity>[];
    final List<CreditCardEntity> pulledCreditCards = <CreditCardEntity>[];
    final List<DebtEntity> pulledDebts = <DebtEntity>[];
    final List<CreditPaymentGroupEntity> pulledCreditPaymentGroups =
        <CreditPaymentGroupEntity>[];
    final List<CreditPaymentScheduleEntity> pulledCreditPaymentSchedules =
        <CreditPaymentScheduleEntity>[];
    final List<Budget> pulledBudgets = <Budget>[];
    final List<BudgetInstance> pulledBudgetInstances = <BudgetInstance>[];
    final List<SavingGoal> pulledSavingGoals = <SavingGoal>[];
    final List<UpcomingPayment> pulledUpcomingPayments = <UpcomingPayment>[];
    final List<PaymentReminder> pulledPaymentReminders = <PaymentReminder>[];
    Profile? pulledProfile;

    final List<Future<void>> fetchTasks = <Future<void>>[];

    void addFetchTask<T>({
      required SyncEntityManifestEntry entry,
      required String timeField,
      required bool isMs,
      required T Function(QueryDocumentSnapshot<Map<String, dynamic>> doc)
      fromDocument,
      required void Function(List<T> items) onFetched,
      required DateTime Function(T) getUpdatedAt,
    }) {
      fetchTasks.add(() async {
        final DateTime since = cursors[entry.outboxEntityType!]!.subtract(
          const Duration(seconds: 5),
        );
        final dynamic sinceVal = isMs
            ? since.millisecondsSinceEpoch
            : Timestamp.fromDate(since);

        Query<Map<String, dynamic>> query = _firestore
            .collection('users')
            .doc(userId)
            .collection(entry.remoteCollection!)
            .where(timeField, isGreaterThan: sinceVal)
            .orderBy(timeField)
            .limit(100);

        QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
        final List<T> parsedDocs = snapshot.docs.map(fromDocument).toList();

        while (snapshot.docs.length == 100) {
          final QueryDocumentSnapshot<Map<String, dynamic>> lastDoc =
              snapshot.docs.last;
          final dynamic lastVal = lastDoc.data()[timeField];
          if (lastVal == null) break;

          query = _firestore
              .collection('users')
              .doc(userId)
              .collection(entry.remoteCollection!)
              .where(timeField, isGreaterThan: sinceVal)
              .orderBy(timeField)
              .startAfter(<dynamic>[lastVal])
              .limit(100);

          snapshot = await query.get();
          parsedDocs.addAll(snapshot.docs.map(fromDocument));
        }

        if (parsedDocs.isNotEmpty) {
          onFetched(parsedDocs);
          DateTime maxTime = getUpdatedAt(parsedDocs.first);
          for (final T item in parsedDocs) {
            final DateTime itemTime = getUpdatedAt(item);
            if (itemTime.isAfter(maxTime)) {
              maxTime = itemTime;
            }
          }
          updatedCursors[entry.outboxEntityType!] = maxTime;
        }
      }());
    }

    for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
      if (entry.outboxEntityType == null || !entry.participatesInLoginSync) {
        continue;
      }

      switch (entry.outboxEntityType) {
        case 'account':
          addFetchTask<AccountEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _accountRemoteDataSource.fromDocument,
            onFetched: pulledAccounts.addAll,
            getUpdatedAt: (AccountEntity e) => e.updatedAt,
          );
          break;
        case 'category':
          addFetchTask<Category>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _categoryRemoteDataSource.fromDocument,
            onFetched: pulledCategories.addAll,
            getUpdatedAt: (Category e) => e.updatedAt,
          );
          break;
        case 'tag':
          addFetchTask<TagEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _tagRemoteDataSource.fromDocument,
            onFetched: pulledTags.addAll,
            getUpdatedAt: (TagEntity e) => e.updatedAt,
          );
          break;
        case 'transaction_tag':
          addFetchTask<TransactionTagEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _transactionTagRemoteDataSource.fromDocument,
            onFetched: pulledTransactionTags.addAll,
            getUpdatedAt: (TransactionTagEntity e) => e.updatedAt,
          );
          break;
        case 'transaction':
          addFetchTask<TransactionEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _transactionRemoteDataSource.fromDocument,
            onFetched: pulledTransactions.addAll,
            getUpdatedAt: (TransactionEntity e) => e.updatedAt,
          );
          break;
        case 'credit':
          addFetchTask<CreditEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _creditRemoteDataSource.fromDocument,
            onFetched: pulledCredits.addAll,
            getUpdatedAt: (CreditEntity e) => e.updatedAt,
          );
          break;
        case 'credit_card':
          addFetchTask<CreditCardEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _creditCardRemoteDataSource.fromDocument,
            onFetched: pulledCreditCards.addAll,
            getUpdatedAt: (CreditCardEntity e) => e.updatedAt,
          );
          break;
        case 'debt':
          addFetchTask<DebtEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _debtRemoteDataSource.fromDocument,
            onFetched: pulledDebts.addAll,
            getUpdatedAt: (DebtEntity e) => e.updatedAt,
          );
          break;
        case 'credit_payment_group':
          addFetchTask<CreditPaymentGroupEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _creditPaymentGroupRemoteDataSource.fromDocument,
            onFetched: pulledCreditPaymentGroups.addAll,
            getUpdatedAt: (CreditPaymentGroupEntity e) =>
                e.updatedAt ?? e.createdAt ?? e.paidAt,
          );
          break;
        case 'credit_payment_schedule':
          addFetchTask<CreditPaymentScheduleEntity>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _creditPaymentScheduleRemoteDataSource.fromDocument,
            onFetched: pulledCreditPaymentSchedules.addAll,
            getUpdatedAt: (CreditPaymentScheduleEntity e) =>
                e.updatedAt ?? e.createdAt ?? e.dueDate,
          );
          break;
        case 'budget':
          addFetchTask<Budget>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _budgetRemoteDataSource.fromDocument,
            onFetched: pulledBudgets.addAll,
            getUpdatedAt: (Budget e) => e.updatedAt,
          );
          break;
        case 'budget_instance':
          addFetchTask<BudgetInstance>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _budgetInstanceRemoteDataSource.fromDocument,
            onFetched: pulledBudgetInstances.addAll,
            getUpdatedAt: (BudgetInstance e) => e.updatedAt,
          );
          break;
        case 'saving_goal':
          addFetchTask<SavingGoal>(
            entry: entry,
            timeField: 'updatedAt',
            isMs: false,
            fromDocument: _savingGoalRemoteDataSource.fromDocument,
            onFetched: pulledSavingGoals.addAll,
            getUpdatedAt: (SavingGoal e) => e.updatedAt,
          );
          break;
        case 'upcoming_payment':
          addFetchTask<UpcomingPayment>(
            entry: entry,
            timeField: 'updatedAtMs',
            isMs: true,
            fromDocument: _upcomingPaymentRemoteDataSource.fromDocument,
            onFetched: pulledUpcomingPayments.addAll,
            getUpdatedAt: (UpcomingPayment e) =>
                DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
          );
          break;
        case 'payment_reminder':
          addFetchTask<PaymentReminder>(
            entry: entry,
            timeField: 'updatedAtMs',
            isMs: true,
            fromDocument: _paymentReminderRemoteDataSource.fromDocument,
            onFetched: pulledPaymentReminders.addAll,
            getUpdatedAt: (PaymentReminder e) =>
                DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
          );
          break;
      }
    }

    fetchTasks.add(() async {
      final Profile? profile = await _profileRemoteDataSource.fetch(userId);
      if (profile != null) {
        pulledProfile = profile;
        final DateTime profileTime = profile.updatedAt;
        final DateTime? lastPulled = await _syncMetadataRepository
            .getLastPulledAt(userId, 'profile');
        if (lastPulled == null || profileTime.isAfter(lastPulled)) {
          updatedCursors['profile'] = profileTime;
        }
      }
    }());

    await Future.wait(fetchTasks);

    final int totalPulled =
        pulledAccounts.length +
        pulledCategories.length +
        pulledTags.length +
        pulledTransactionTags.length +
        pulledTransactions.length +
        pulledCredits.length +
        pulledCreditCards.length +
        pulledDebts.length +
        pulledCreditPaymentGroups.length +
        pulledCreditPaymentSchedules.length +
        pulledBudgets.length +
        pulledBudgetInstances.length +
        pulledSavingGoals.length +
        pulledUpcomingPayments.length +
        pulledPaymentReminders.length +
        (pulledProfile != null ? 1 : 0);

    if (totalPulled == 0) {
      return 0;
    }

    final List<AccountEntity> localAccounts = await _accountDao
        .getAllAccounts();
    final List<Category> localCategories = await _categoryDao
        .getAllCategories();
    final List<TagEntity> localTags = await _tagDao.getAllTags();
    final List<TransactionEntity> localTransactions = await _transactionDao
        .getAllTransactions();
    final List<TransactionTagEntity> localTransactionTags =
        (await _transactionTagsDao.getAllTransactionTags())
            .map(_transactionTagsDao.mapRowToEntity)
            .toList();
    final List<CreditEntity> localCredits = (await _creditDao.getAllCredits())
        .map(_creditDao.mapRowToEntity)
        .toList();
    final List<CreditCardEntity> localCreditCards =
        (await _creditCardDao.getAllCreditCards())
            .map(_creditCardDao.mapRowToEntity)
            .toList();
    final List<DebtEntity> localDebts = (await _debtDao.getAllDebts())
        .map(_debtDao.mapRowToEntity)
        .toList();
    final List<CreditPaymentGroupEntity> localCreditPaymentGroups =
        await _creditPaymentDao.getAllPaymentGroups();
    final List<CreditPaymentScheduleEntity> localCreditPaymentSchedules =
        await _creditPaymentDao.getAllScheduleItems();
    final List<Budget> localBudgets = await _budgetDao.getAllBudgets();
    final List<BudgetInstance> localBudgetInstances = await _budgetInstanceDao
        .getAllInstances();
    final List<SavingGoal> localSavingGoals =
        await _loadLocalSavingGoalsWithStorageAccounts();
    final List<UpcomingPayment> localUpcomingPayments =
        await _upcomingPaymentsDao.getAll();
    final List<PaymentReminder> localPaymentReminders =
        await _paymentRemindersDao.getAll();

    final List<AccountEntity> changedAccounts = _filterChanged(
      local: localAccounts,
      remote: pulledAccounts,
      getId: (AccountEntity e) => e.id,
      getUpdatedAt: (AccountEntity e) => e.updatedAt,
    );
    final List<TagEntity> changedTags = _filterChanged(
      local: localTags,
      remote: pulledTags,
      getId: (TagEntity e) => e.id,
      getUpdatedAt: (TagEntity e) => e.updatedAt,
    );
    final List<TransactionTagEntity> changedTransactionTags = _filterChanged(
      local: localTransactionTags,
      remote: pulledTransactionTags,
      getId: _transactionTagKey,
      getUpdatedAt: (TransactionTagEntity e) => e.updatedAt,
    );
    final List<CreditEntity> changedCredits = _filterChanged(
      local: localCredits,
      remote: pulledCredits,
      getId: (CreditEntity e) => e.id,
      getUpdatedAt: (CreditEntity e) => e.updatedAt,
    );
    final List<CreditCardEntity> changedCreditCards = _filterChanged(
      local: localCreditCards,
      remote: pulledCreditCards,
      getId: (CreditCardEntity e) => e.id,
      getUpdatedAt: (CreditCardEntity e) => e.updatedAt,
    );
    final List<DebtEntity> changedDebts = _filterChanged(
      local: localDebts,
      remote: pulledDebts,
      getId: (DebtEntity e) => e.id,
      getUpdatedAt: (DebtEntity e) => e.updatedAt,
    );
    final List<CreditPaymentGroupEntity> changedCreditPaymentGroups =
        _filterChanged(
          local: localCreditPaymentGroups,
          remote: pulledCreditPaymentGroups,
          getId: (CreditPaymentGroupEntity e) => e.id,
          getUpdatedAt: (CreditPaymentGroupEntity e) =>
              e.updatedAt ?? e.createdAt ?? e.paidAt,
        );
    final List<CreditPaymentScheduleEntity> changedCreditPaymentSchedules =
        _filterChanged(
          local: localCreditPaymentSchedules,
          remote: pulledCreditPaymentSchedules,
          getId: (CreditPaymentScheduleEntity e) => e.id,
          getUpdatedAt: (CreditPaymentScheduleEntity e) =>
              e.updatedAt ?? e.createdAt ?? e.dueDate,
        );
    final List<BudgetInstance> changedBudgetInstances = _filterChanged(
      local: localBudgetInstances,
      remote: pulledBudgetInstances,
      getId: (BudgetInstance e) => e.id,
      getUpdatedAt: (BudgetInstance e) => e.updatedAt,
    );
    final List<SavingGoal> changedSavingGoals = _filterChanged(
      local: localSavingGoals,
      remote: pulledSavingGoals,
      getId: (SavingGoal e) => e.id,
      getUpdatedAt: (SavingGoal e) => e.updatedAt,
    );
    final List<UpcomingPayment> changedUpcomingPayments = _filterChanged(
      local: localUpcomingPayments,
      remote: pulledUpcomingPayments,
      getId: (UpcomingPayment e) => e.id,
      getUpdatedAt: (UpcomingPayment e) =>
          DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
    );
    final List<PaymentReminder> changedPaymentReminders = _filterChanged(
      local: localPaymentReminders,
      remote: pulledPaymentReminders,
      getId: (PaymentReminder e) => e.id,
      getUpdatedAt: (PaymentReminder e) =>
          DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
    );

    final List<Category> allMergedCategories = _mergeEntities<Category>(
      local: localCategories,
      remote: pulledCategories,
      getId: (Category e) => e.id,
      getUpdatedAt: (Category e) => e.updatedAt,
    );
    final _CategorySanitizationResult sanitizedCategories = _sanitizeCategories(
      allMergedCategories,
    );
    final List<Category> normalizedCategories = sanitizedCategories.categories;
    final Map<String, String> categoryIdMapping = sanitizedCategories.idMapping;

    final List<Category> changedNormalizedCategories = _filterChanged(
      local: localCategories,
      remote: normalizedCategories,
      getId: (Category e) => e.id,
      getUpdatedAt: (Category e) => e.updatedAt,
    );

    final List<TransactionEntity> normalizedTransactions =
        _normalizeTransactions(
          _mergeEntities<TransactionEntity>(
            local: localTransactions,
            remote: pulledTransactions,
            getId: (TransactionEntity e) => e.id,
            getUpdatedAt: (TransactionEntity e) => e.updatedAt,
          ),
          categoryIdMapping,
        );
    final List<TransactionEntity> changedNormalizedTransactions =
        _filterChanged(
          local: localTransactions,
          remote: normalizedTransactions,
          getId: (TransactionEntity e) => e.id,
          getUpdatedAt: (TransactionEntity e) => e.updatedAt,
        );

    final List<Budget> normalizedBudgets = _normalizeBudgets(
      _mergeEntities<Budget>(
        local: localBudgets,
        remote: pulledBudgets,
        getId: (Budget e) => e.id,
        getUpdatedAt: (Budget e) => e.updatedAt,
      ),
      categoryIdMapping,
    );
    final List<Budget> changedNormalizedBudgets = _filterChanged(
      local: localBudgets,
      remote: normalizedBudgets,
      getId: (Budget e) => e.id,
      getUpdatedAt: (Budget e) => e.updatedAt,
    );

    await _database.transaction(() async {
      // Tier 1: Base
      if (changedAccounts.isNotEmpty) {
        await _accountDao.upsertAll(changedAccounts);
      }
      if (changedNormalizedCategories.isNotEmpty) {
        await _categoryDao.upsertAll(changedNormalizedCategories);
      }
      if (changedTags.isNotEmpty) {
        await _tagDao.upsertAll(changedTags);
      }

      final List<AccountEntity> finalMergedAccounts =
          _mergeEntities<AccountEntity>(
            local: localAccounts,
            remote: pulledAccounts,
            getId: (AccountEntity e) => e.id,
            getUpdatedAt: (AccountEntity e) => e.updatedAt,
          );
      final Set<String> validAccountIds = finalMergedAccounts
          .map((AccountEntity e) => e.id)
          .toSet();
      final Set<String> validCategoryIds = normalizedCategories
          .map((Category e) => e.id)
          .toSet();
      final Set<String> validTagIds = _mergeEntities<TagEntity>(
        local: localTags,
        remote: pulledTags,
        getId: (TagEntity e) => e.id,
        getUpdatedAt: (TagEntity e) => e.updatedAt,
      ).map((TagEntity e) => e.id).toSet();

      // Tier 2: Credits, Debts, Goals
      if (changedCredits.isNotEmpty) {
        final List<CreditEntity> sanitizedCredits = _dataSanitizer
            .sanitizeCredits(
              credits: _mergeEntities<CreditEntity>(
                local: localCredits,
                remote: pulledCredits,
                getId: (CreditEntity e) => e.id,
                getUpdatedAt: (CreditEntity e) => e.updatedAt,
              ),
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
            );
        final List<CreditEntity> finalChangedCredits = _filterChanged(
          local: localCredits,
          remote: sanitizedCredits,
          getId: (CreditEntity e) => e.id,
          getUpdatedAt: (CreditEntity e) => e.updatedAt,
        );
        if (finalChangedCredits.isNotEmpty) {
          await _creditDao.upsertAll(finalChangedCredits);
        }
      }

      if (changedCreditCards.isNotEmpty) {
        final List<CreditCardEntity> sanitizedCards = _dataSanitizer
            .sanitizeCreditCards(
              creditCards: _mergeEntities<CreditCardEntity>(
                local: localCreditCards,
                remote: pulledCreditCards,
                getId: (CreditCardEntity e) => e.id,
                getUpdatedAt: (CreditCardEntity e) => e.updatedAt,
              ),
              validAccountIds: validAccountIds,
            );
        final List<CreditCardEntity> finalChangedCards = _filterChanged(
          local: localCreditCards,
          remote: sanitizedCards,
          getId: (CreditCardEntity e) => e.id,
          getUpdatedAt: (CreditCardEntity e) => e.updatedAt,
        );
        if (finalChangedCards.isNotEmpty) {
          await _creditCardDao.upsertAll(finalChangedCards);
        }
      }

      if (changedDebts.isNotEmpty) {
        final List<DebtEntity> sanitizedDebts = _dataSanitizer.sanitizeDebts(
          debts: _mergeEntities<DebtEntity>(
            local: localDebts,
            remote: pulledDebts,
            getId: (DebtEntity e) => e.id,
            getUpdatedAt: (DebtEntity e) => e.updatedAt,
          ),
          validAccountIds: validAccountIds,
        );
        final List<DebtEntity> finalChangedDebts = _filterChanged(
          local: localDebts,
          remote: sanitizedDebts,
          getId: (DebtEntity e) => e.id,
          getUpdatedAt: (DebtEntity e) => e.updatedAt,
        );
        if (finalChangedDebts.isNotEmpty) {
          await _debtDao.upsertAll(finalChangedDebts);
        }
      }

      if (changedSavingGoals.isNotEmpty) {
        await _savingGoalDao.upsertAll(changedSavingGoals);
        await _goalAccountLinkDao.replaceLinksByGoal(
          accountIdsByGoalId: <String, Iterable<String>>{
            for (final SavingGoal goal in changedSavingGoals)
              goal.id: goal.effectiveStorageAccountIds,
          },
        );
      }

      final List<SavingGoal> finalMergedGoals = _mergeEntities<SavingGoal>(
        local: localSavingGoals,
        remote: pulledSavingGoals,
        getId: (SavingGoal e) => e.id,
        getUpdatedAt: (SavingGoal e) => e.updatedAt,
      );
      final Set<String> validSavingGoalIds = finalMergedGoals
          .map((SavingGoal e) => e.id)
          .toSet();

      final List<CreditEntity> finalMergedCredits =
          _mergeEntities<CreditEntity>(
            local: localCredits,
            remote: pulledCredits,
            getId: (CreditEntity e) => e.id,
            getUpdatedAt: (CreditEntity e) => e.updatedAt,
          );
      final Set<String> validCreditIds = finalMergedCredits
          .map((CreditEntity e) => e.id)
          .toSet();

      // Tier 3: Schedules, Groups, Transactions, Rules
      if (changedCreditPaymentSchedules.isNotEmpty) {
        final List<CreditPaymentScheduleEntity> sanitizedSchedules =
            _dataSanitizer.sanitizeCreditPaymentSchedules(
              schedules: _mergeEntities<CreditPaymentScheduleEntity>(
                local: localCreditPaymentSchedules,
                remote: pulledCreditPaymentSchedules,
                getId: (CreditPaymentScheduleEntity e) => e.id,
                getUpdatedAt: (CreditPaymentScheduleEntity e) =>
                    e.updatedAt ?? e.createdAt ?? e.dueDate,
              ),
              validCreditIds: validCreditIds,
            );
        final List<CreditPaymentScheduleEntity> finalChangedSchedules =
            _filterChanged(
              local: localCreditPaymentSchedules,
              remote: sanitizedSchedules,
              getId: (CreditPaymentScheduleEntity e) => e.id,
              getUpdatedAt: (CreditPaymentScheduleEntity e) =>
                  e.updatedAt ?? e.createdAt ?? e.dueDate,
            );
        if (finalChangedSchedules.isNotEmpty) {
          await _creditPaymentDao.upsertSchedule(finalChangedSchedules);
        }
      }

      final List<CreditPaymentScheduleEntity> finalMergedSchedules =
          _mergeEntities<CreditPaymentScheduleEntity>(
            local: localCreditPaymentSchedules,
            remote: pulledCreditPaymentSchedules,
            getId: (CreditPaymentScheduleEntity e) => e.id,
            getUpdatedAt: (CreditPaymentScheduleEntity e) =>
                e.updatedAt ?? e.createdAt ?? e.dueDate,
          );
      final Set<String> validScheduleIds = finalMergedSchedules
          .where((CreditPaymentScheduleEntity e) => !e.isDeleted)
          .map((CreditPaymentScheduleEntity e) => e.id)
          .toSet();

      if (changedCreditPaymentGroups.isNotEmpty) {
        final List<CreditPaymentGroupEntity> sanitizedGroups = _dataSanitizer
            .sanitizeCreditPaymentGroups(
              groups: _mergeEntities<CreditPaymentGroupEntity>(
                local: localCreditPaymentGroups,
                remote: pulledCreditPaymentGroups,
                getId: (CreditPaymentGroupEntity e) => e.id,
                getUpdatedAt: (CreditPaymentGroupEntity e) =>
                    e.updatedAt ?? e.createdAt ?? e.paidAt,
              ),
              validCreditIds: validCreditIds,
              validAccountIds: validAccountIds,
              validScheduleIds: validScheduleIds,
            );
        final List<CreditPaymentGroupEntity> finalChangedGroups =
            _filterChanged(
              local: localCreditPaymentGroups,
              remote: sanitizedGroups,
              getId: (CreditPaymentGroupEntity e) => e.id,
              getUpdatedAt: (CreditPaymentGroupEntity e) =>
                  e.updatedAt ?? e.createdAt ?? e.paidAt,
            );
        if (finalChangedGroups.isNotEmpty) {
          await _creditPaymentDao.upsertPaymentGroups(finalChangedGroups);
        }
      }

      final List<CreditPaymentGroupEntity> finalMergedGroups =
          _mergeEntities<CreditPaymentGroupEntity>(
            local: localCreditPaymentGroups,
            remote: pulledCreditPaymentGroups,
            getId: (CreditPaymentGroupEntity e) => e.id,
            getUpdatedAt: (CreditPaymentGroupEntity e) =>
                e.updatedAt ?? e.createdAt ?? e.paidAt,
          );
      final Set<String> validPaymentGroupIds = finalMergedGroups
          .where((CreditPaymentGroupEntity e) => !e.isDeleted)
          .map((CreditPaymentGroupEntity e) => e.id)
          .toSet();
      final Set<String> allPhysicalPaymentGroupIds = finalMergedGroups
          .map((CreditPaymentGroupEntity e) => e.id)
          .toSet();

      if (changedNormalizedTransactions.isNotEmpty) {
        final List<TransactionEntity> repairedTransactions =
            await _resolveOrphanedCreditPaymentLinks(
              transactions: normalizedTransactions,
              validPaymentGroupIds: validPaymentGroupIds,
              allPhysicalPaymentGroupIds: allPhysicalPaymentGroupIds,
            );
        final List<TransactionEntity> sanitizedTransactions = _dataSanitizer
            .sanitizeTransactions(
              transactions: repairedTransactions,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
              validSavingGoalIds: validSavingGoalIds,
              validPaymentGroupIds: allPhysicalPaymentGroupIds,
            );
        final List<TransactionEntity> finalChangedTransactions = _filterChanged(
          local: localTransactions,
          remote: sanitizedTransactions,
          getId: (TransactionEntity e) => e.id,
          getUpdatedAt: (TransactionEntity e) => e.updatedAt,
        );
        if (finalChangedTransactions.isNotEmpty) {
          await _transactionDao.upsertAll(finalChangedTransactions);
        }
      }

      if (changedTransactionTags.isNotEmpty) {
        final List<TransactionTagEntity> finalMergedTransactionTags =
            _mergeEntities<TransactionTagEntity>(
              local: localTransactionTags,
              remote: pulledTransactionTags,
              getId: _transactionTagKey,
              getUpdatedAt: (TransactionTagEntity e) => e.updatedAt,
            );
        final List<TransactionEntity> finalMergedTransactions =
            _mergeEntities<TransactionEntity>(
              local: localTransactions,
              remote: pulledTransactions,
              getId: (TransactionEntity e) => e.id,
              getUpdatedAt: (TransactionEntity e) => e.updatedAt,
            );
        final Set<String> validTransactionIds = finalMergedTransactions
            .map((TransactionEntity e) => e.id)
            .toSet();
        final List<TransactionTagEntity> sanitizedTransactionTags =
            _dataSanitizer.sanitizeTransactionTags(
              transactionTags: finalMergedTransactionTags,
              validTransactionIds: validTransactionIds,
              validTagIds: validTagIds,
            );
        final List<TransactionTagEntity> finalChangedTransactionTags =
            _filterChanged(
              local: localTransactionTags,
              remote: sanitizedTransactionTags,
              getId: _transactionTagKey,
              getUpdatedAt: (TransactionTagEntity e) => e.updatedAt,
            );
        if (finalChangedTransactionTags.isNotEmpty) {
          await _transactionTagsDao.upsertAll(finalChangedTransactionTags);
        }
      }

      if (changedUpcomingPayments.isNotEmpty) {
        final List<UpcomingPayment> sanitizedPayments = _dataSanitizer
            .sanitizeUpcomingPayments(
              payments: _mergeEntities<UpcomingPayment>(
                local: localUpcomingPayments,
                remote: pulledUpcomingPayments,
                getId: (UpcomingPayment e) => e.id,
                getUpdatedAt: (UpcomingPayment e) =>
                    DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
              ),
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
            );
        final List<UpcomingPayment> finalChangedPayments = _filterChanged(
          local: localUpcomingPayments,
          remote: sanitizedPayments,
          getId: (UpcomingPayment e) => e.id,
          getUpdatedAt: (UpcomingPayment e) =>
              DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
        );
        for (final UpcomingPayment payment in finalChangedPayments) {
          await _upcomingPaymentsDao.upsert(payment);
        }
      }

      if (changedPaymentReminders.isNotEmpty) {
        for (final PaymentReminder reminder in changedPaymentReminders) {
          await _paymentRemindersDao.upsert(reminder);
        }
      }

      if (changedNormalizedBudgets.isNotEmpty) {
        await _budgetDao.upsertAll(changedNormalizedBudgets);
      }

      final List<Budget> finalMergedBudgets = _mergeEntities<Budget>(
        local: localBudgets,
        remote: pulledBudgets,
        getId: (Budget e) => e.id,
        getUpdatedAt: (Budget e) => e.updatedAt,
      );
      final Set<String> validBudgetIds = finalMergedBudgets
          .map((Budget e) => e.id)
          .toSet();

      // Tier 4: Strongly Dependent
      if (changedBudgetInstances.isNotEmpty) {
        final List<BudgetInstance> sanitizedInstances = _dataSanitizer
            .sanitizeBudgetInstances(
              instances: _mergeEntities<BudgetInstance>(
                local: localBudgetInstances,
                remote: pulledBudgetInstances,
                getId: (BudgetInstance e) => e.id,
                getUpdatedAt: (BudgetInstance e) => e.updatedAt,
              ),
              validBudgetIds: validBudgetIds,
            );
        final List<BudgetInstance> finalChangedInstances = _filterChanged(
          local: localBudgetInstances,
          remote: sanitizedInstances,
          getId: (BudgetInstance e) => e.id,
          getUpdatedAt: (BudgetInstance e) => e.updatedAt,
        );
        if (finalChangedInstances.isNotEmpty) {
          await _budgetInstanceDao.upsertAll(finalChangedInstances);
        }
      }

      if (pulledProfile != null) {
        final Profile? mergedProfile = _mergeProfile(
          await _profileDao.getProfile(userId),
          pulledProfile,
        );
        if (mergedProfile != null) {
          await _profileDao.upsert(mergedProfile);
        }
      }

      // 6. Recalculate balances if needed
      if (pulledTransactions.isNotEmpty || pulledAccounts.isNotEmpty) {
        final List<TransactionEntity> finalMergedTransactions =
            _mergeEntities<TransactionEntity>(
              local: localTransactions,
              remote: pulledTransactions,
              getId: (TransactionEntity e) => e.id,
              getUpdatedAt: (TransactionEntity e) => e.updatedAt,
            );
        final List<AccountEntity> recalculatedAccounts =
            await _recalculateBalances(
              accounts: finalMergedAccounts,
              transactions: finalMergedTransactions,
            );
        final Map<String, AccountEntity> localAccountsMap =
            <String, AccountEntity>{
              for (final AccountEntity a in localAccounts) a.id: a,
            };
        final List<AccountEntity> accountsToUpdate = recalculatedAccounts.where(
          (AccountEntity a) {
            final AccountEntity? local = localAccountsMap[a.id];
            return local == null || local.balanceMinor != a.balanceMinor;
          },
        ).toList();
        if (accountsToUpdate.isNotEmpty) {
          await _accountDao.upsertAll(accountsToUpdate);
        }
      }

      // 7. Rebuild contributions
      if (pulledTransactions.isNotEmpty || pulledSavingGoals.isNotEmpty) {
        await _goalContributionRebuildService.rebuild();
      }
    });

    // 8. Update cursors in SharedPreferences only after successful commit
    for (final MapEntry<String, DateTime> entry in updatedCursors.entries) {
      await _syncMetadataRepository.setLastPulledAt(
        userId,
        entry.key,
        entry.value,
      );
    }

    return totalPulled;
  }

  Future<void> _runIntegrityDiagnostics({required String context}) async {
    final LocalSyncIntegrityReport report = await _integrityDiagnosticsService
        .run();
    _integrityDebugReporter.logReport(context: context, report: report);
    if (!report.hasIssues) {
      _logger.logInfo(
        'AuthSyncService: integrity diagnostics clean after $context.',
      );
      return;
    }
    _logger.logError(
      'AuthSyncService: integrity diagnostics found ${report.issueCount} issue(s) '
      'after $context.',
    );
    await _analyticsService.logEvent('local_db_integrity_issues', <
      String,
      dynamic
    >{
      'context': context,
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

  Future<List<db.OutboxEntryRow>> _runDeferredAccountTypeBackfill(
    String userId,
  ) async {
    if (_accountTypeBackfillService == null) {
      return const <db.OutboxEntryRow>[];
    }
    final AccountTypeBackfillResult result = await _accountTypeBackfillService
        .run();
    if (result.updatedCount == 0) {
      _logger.logInfo(
        'AuthSyncService: deferred account type backfill has nothing to migrate.',
      );
      return const <db.OutboxEntryRow>[];
    }
    _logger.logInfo(
      'AuthSyncService: deferred account type backfill updated '
      '${result.updatedCount} account(s); propagating canonical types to sync.',
    );
    await _analyticsService
        .logEvent('account_type_backfill_sync_propagation', <String, dynamic>{
          'updated': result.updatedCount,
          'scanned': result.scannedCount,
          'skippedUnknown': result.skippedUnknownCount,
          'skippedUpToDate': result.skippedUpToDateCount,
        });
    return _applyAllPendingOutbox(userId);
  }

  Future<List<SavingGoal>> _loadLocalSavingGoalsWithStorageAccounts() async {
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

  Future<List<db.OutboxEntryRow>> _preparePendingEntries() async {
    return _database.transaction(() async {
      await _outboxDao.resetStaleSendingToPending(
        cutoff: DateTime.now().subtract(_staleSendingRecoveryWindow),
      );
      final List<OutboxEntryRow> pending = await _outboxDao.fetchPending(
        limit: _outboxBatchSize,
      );
      final List<OutboxEntryRow> prepared = <db.OutboxEntryRow>[];
      for (final OutboxEntryRow entry in pending) {
        prepared.add(await _outboxDao.prepareForSend(entry));
      }
      return prepared;
    });
  }

  Future<List<db.OutboxEntryRow>> _applyAllPendingOutbox(String userId) async {
    final List<db.OutboxEntryRow> preparedEntries = <db.OutboxEntryRow>[];
    while (true) {
      final List<db.OutboxEntryRow> batch = await _preparePendingEntries();
      if (batch.isEmpty) {
        break;
      }
      await _applyOutboxToFirestore(userId, batch);
      preparedEntries.addAll(batch);
      if (batch.length < _outboxBatchSize) {
        break;
      }
    }
    return preparedEntries;
  }

  Future<void> _applyOutboxToFirestore(
    String userId,
    List<db.OutboxEntryRow> entries, {
    Transaction? transaction,
    bool useRegistryFreshnessCheck = false,
  }) async {
    if (entries.isEmpty) return;

    if (transaction == null) {
      await _firestore.runTransaction((Transaction tx) async {
        await _applyOutboxToFirestore(
          userId,
          entries,
          transaction: tx,
          useRegistryFreshnessCheck: useRegistryFreshnessCheck,
        );
      });
      return;
    }

    final Map<int, Map<String, dynamic>> normalizedPayloads =
        <int, Map<String, dynamic>>{};
    for (final OutboxEntryRow entry in entries) {
      normalizedPayloads[entry.id] = _payloadNormalizer.normalize(
        entry.entityType,
        _outboxDao.decodePayload(entry),
      );
    }

    final Map<int, bool> shouldApplyByEntryId = <int, bool>{};

    if (useRegistryFreshnessCheck) {
      final Set<String> affectedShardIds = <String>{};
      for (final db.OutboxEntryRow entry in entries) {
        if (entry.entityType == entityTypeCategory) {
          final Map<String, dynamic> payload = normalizedPayloads[entry.id]!;
          final Category category = Category.fromJson(payload);
          if (category.isMissingReferencePlaceholder) {
            continue;
          }
        }
        affectedShardIds.add(
          _registryShardId(
            entityType: entry.entityType,
            entityId: entry.entityId,
          ),
        );
      }

      final Map<String, Map<String, dynamic>> currentRegistryData =
          <String, Map<String, dynamic>>{};
      for (final String shardId in affectedShardIds) {
        final DocumentReference<Map<String, dynamic>> docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .doc(shardId);
        final DocumentSnapshot<Map<String, dynamic>> docSnap = await transaction
            .get(docRef);
        final Map<String, dynamic>? data = docSnap.data();
        final Map<String, dynamic> metadata =
            data?['metadata'] as Map<String, dynamic>? ?? <String, dynamic>{};
        currentRegistryData[shardId] = metadata;
      }

      for (final db.OutboxEntryRow entry in entries) {
        if (entry.entityType == entityTypeCategory) {
          final Map<String, dynamic> payload = normalizedPayloads[entry.id]!;
          final Category category = Category.fromJson(payload);
          if (category.isMissingReferencePlaceholder) {
            shouldApplyByEntryId[entry.id] = false;
            continue;
          }
        }

        final String shardId = _registryShardId(
          entityType: entry.entityType,
          entityId: entry.entityId,
        );
        final Map<String, dynamic>? remoteMetaMap =
            currentRegistryData[shardId]?[_registryEntityKey(
                  entityType: entry.entityType,
                  entityId: entry.entityId,
                )]
                as Map<String, dynamic>?;
        if (remoteMetaMap != null) {
          final dynamic remoteUpdatedAtVal = remoteMetaMap['updatedAt'];
          DateTime? remoteUpdatedAt;
          if (remoteUpdatedAtVal is Timestamp) {
            remoteUpdatedAt = remoteUpdatedAtVal.toDate().toUtc();
          } else if (remoteUpdatedAtVal is String) {
            remoteUpdatedAt = DateTime.tryParse(remoteUpdatedAtVal)?.toUtc();
          }

          if (remoteUpdatedAt != null) {
            final DateTime? baseRemoteUpdatedAt = entry.baseRemoteUpdatedAt;
            if (baseRemoteUpdatedAt == null) {
              throw RegistryConflictException(
                'Registry changed unexpectedly (legacy base was null, but remote document exists) for ${entry.entityType} ${entry.entityId}',
              );
            }
            if (remoteUpdatedAt != baseRemoteUpdatedAt) {
              throw RegistryConflictException(
                'Registry changed unexpectedly for ${entry.entityType} ${entry.entityId}. '
                'Base: $baseRemoteUpdatedAt, Server: $remoteUpdatedAt',
              );
            }
          }
        }
        shouldApplyByEntryId[entry.id] = true;
      }
    } else {
      for (final OutboxEntryRow entry in entries) {
        shouldApplyByEntryId[entry.id] = await _shouldApplyOutboxEntry(
          userId: userId,
          entry: entry,
          payload: normalizedPayloads[entry.id]!,
        );
      }
    }

    final Map<String, Map<String, dynamic>> registryUpdates =
        <String, Map<String, dynamic>>{};

    for (final OutboxEntryRow entry in entries) {
      final Map<String, dynamic> payload = normalizedPayloads[entry.id]!;
      final bool shouldApply = shouldApplyByEntryId[entry.id] ?? true;
      if (!shouldApply) {
        continue;
      }
      final OutboxOperation operation = OutboxOperation.values.byName(
        entry.operation,
      );
      switch (entry.entityType) {
        case 'account':
          final AccountEntity account = _applyAccountMoney(
            AccountEntity.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _accountRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              account,
            );
          } else {
            _accountRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              account,
            );
          }
          break;
        case 'category':
          final Category category = Category.fromJson(payload);
          if (operation == OutboxOperation.delete) {
            _categoryRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              category,
            );
          } else {
            _categoryRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              category,
            );
          }
          break;
        case 'tag':
          final TagEntity tag = TagEntity.fromJson(payload);
          if (operation == OutboxOperation.delete) {
            _tagRemoteDataSource.deleteInTransaction(transaction, userId, tag);
          } else {
            _tagRemoteDataSource.upsertInTransaction(transaction, userId, tag);
          }
          break;
        case 'transaction':
          final TransactionEntity transactionEntity = _applyTransactionMoney(
            TransactionEntity.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _transactionRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              transactionEntity,
            );
          } else {
            _transactionRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              transactionEntity,
            );
          }
          break;
        case 'transaction_tag':
          final TransactionTagEntity link = TransactionTagEntity.fromJson(
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _transactionTagRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              link,
            );
          } else {
            _transactionTagRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              link,
            );
          }
          break;
        case 'credit':
          final CreditEntity credit = _applyCreditMoney(
            CreditEntity.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _creditRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              credit,
            );
          } else {
            _creditRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              credit,
            );
          }
          break;
        case 'credit_card':
          final CreditCardEntity creditCard = _applyCreditCardMoney(
            CreditCardEntity.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _creditCardRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              creditCard,
            );
          } else {
            _creditCardRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              creditCard,
            );
          }
          break;
        case 'debt':
          final DebtEntity debt = _applyDebtMoney(
            DebtEntity.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _debtRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              debt,
            );
          } else {
            _debtRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              debt,
            );
          }
          break;
        case 'credit_payment_group':
          final CreditPaymentGroupEntity group = _groupFromPayload(payload);
          if (operation == OutboxOperation.delete) {
            _creditPaymentGroupRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              group.copyWith(isDeleted: true),
            );
          } else {
            _creditPaymentGroupRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              group.copyWith(isDeleted: false),
            );
          }
          break;
        case 'credit_payment_schedule':
          final CreditPaymentScheduleEntity schedule = _scheduleFromPayload(
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _creditPaymentScheduleRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              schedule.copyWith(isDeleted: true),
            );
          } else {
            _creditPaymentScheduleRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              schedule.copyWith(isDeleted: false),
            );
          }
          break;
        case 'profile':
          if (operation == OutboxOperation.delete) {
            continue;
          }
          final Profile profile = Profile.fromJson(payload);
          _profileRemoteDataSource.upsertInTransaction(
            transaction,
            userId,
            profile,
          );
          break;
        case 'budget':
          final Budget budget = _applyBudgetMoney(
            Budget.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _budgetRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              budget,
            );
          } else {
            _budgetRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              budget,
            );
          }
          break;
        case 'budget_instance':
          final BudgetInstance instance = _applyBudgetInstanceMoney(
            BudgetInstance.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _budgetInstanceRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              instance,
            );
          } else {
            _budgetInstanceRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              instance,
            );
          }
          break;
        case 'saving_goal':
          final SavingGoal goal = SavingGoal.fromJson(payload);
          if (operation == OutboxOperation.delete) {
            _savingGoalRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              goal,
            );
          } else {
            _savingGoalRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              goal,
            );
          }
          break;
        case 'upcoming_payment':
          final UpcomingPayment payment = _applyUpcomingPaymentMoney(
            UpcomingPayment.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _upcomingPaymentRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              payment,
            );
          } else {
            _upcomingPaymentRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              payment,
            );
          }
          break;
        case 'payment_reminder':
          final PaymentReminder reminder = _applyPaymentReminderMoney(
            PaymentReminder.fromJson(payload),
            payload,
          );
          if (operation == OutboxOperation.delete) {
            _paymentReminderRemoteDataSource.deleteInTransaction(
              transaction,
              userId,
              reminder,
            );
          } else {
            _paymentReminderRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              reminder,
            );
          }
          break;
        default:
          throw UnsupportedError(
            'Unsupported outbox entity type ${entry.entityType}',
          );
      }

      final DateTime? localUpdatedAt = _extractOutboxUpdatedAt(
        entry.entityType,
        payload,
      );
      if (localUpdatedAt != null) {
        bool skipRegistry = false;
        if (entry.entityType == entityTypeCategory) {
          final Category category = Category.fromJson(payload);
          if (category.isMissingReferencePlaceholder) {
            skipRegistry = true;
          }
        }
        if (!skipRegistry) {
          final String shardId = _registryShardId(
            entityType: entry.entityType,
            entityId: entry.entityId,
          );
          final Map<String, dynamic> shardUpdates = registryUpdates.putIfAbsent(
            shardId,
            () => <String, dynamic>{},
          );
          final bool isDeleted = operation == OutboxOperation.delete;
          int? typeVersion;
          if (entry.entityType == entityTypeAccount) {
            typeVersion = _extractAccountTypeVersion(payload);
          }

          final Map<String, dynamic> updateData = <String, dynamic>{
            'updatedAt': Timestamp.fromDate(localUpdatedAt),
            'isDeleted': isDeleted,
          };
          if (typeVersion != null) {
            updateData['typeVersion'] = typeVersion;
          }
          shardUpdates[_registryEntityKey(
                entityType: entry.entityType,
                entityId: entry.entityId,
              )] =
              updateData;
        }
      }
    }

    registryUpdates.forEach((String shardId, Map<String, dynamic> metadataMap) {
      if (metadataMap.length > maxRegistryEntriesPerShardSoftLimit) {
        _logger.logWarning(
          'AuthSyncService: sync_registry shard $shardId exceeds soft limit of $maxRegistryEntriesPerShardSoftLimit entries (${metadataMap.length})',
        );
      }
      final DocumentReference<Map<String, dynamic>> docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_registry')
          .doc(shardId);
      transaction.set(docRef, <String, dynamic>{
        'metadata': metadataMap,
      }, SetOptions(merge: true));
    });
  }

  Future<_PushChunkResult> _pushSafeChunkWithRegistryGuard(
    String userId,
    List<db.OutboxEntryRow> entries,
  ) async {
    if (entries.isEmpty) {
      return _PushChunkResult(
        pushed: const <db.OutboxEntryRow>[],
        conflicted: const <db.OutboxEntryRow>[],
      );
    }

    try {
      await _firestore.runTransaction((Transaction tx) async {
        await _applyOutboxToFirestore(
          userId,
          entries,
          transaction: tx,
          useRegistryFreshnessCheck: true,
        );
      });
      return _PushChunkResult(
        pushed: entries,
        conflicted: const <db.OutboxEntryRow>[],
      );
    } catch (e) {
      if (e is RegistryConflictException) {
        _logger.logInfo(
          'AuthSyncService: registry conflict detected during push: $e',
        );
        return _PushChunkResult(
          pushed: const <db.OutboxEntryRow>[],
          conflicted: entries,
        );
      }
      rethrow;
    }
  }

  Future<bool> _shouldApplyOutboxEntry({
    required String userId,
    required db.OutboxEntryRow entry,
    required Map<String, dynamic> payload,
  }) async {
    final DateTime? localUpdatedAt = _extractOutboxUpdatedAt(
      entry.entityType,
      payload,
    );
    if (localUpdatedAt == null) {
      return true;
    }
    final DocumentReference<Map<String, dynamic>>? docRef = _remoteDocRef(
      userId: userId,
      entityType: entry.entityType,
      entityId: entry.entityId,
    );
    if (docRef == null) {
      return true;
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();
    final Map<String, dynamic>? remoteData = snapshot.data();
    if (remoteData == null) {
      return true;
    }
    if (entry.entityType == 'account') {
      final int localTypeVersion = _extractAccountTypeVersion(payload);
      final int remoteTypeVersion = _extractAccountTypeVersion(remoteData);
      if (localTypeVersion > remoteTypeVersion) {
        _logger.logInfo(
          'AuthSyncService: local account typeVersion wins for '
          '${entry.entityId} (local=$localTypeVersion, remote=$remoteTypeVersion).',
        );
        return true;
      }
      if (localTypeVersion < remoteTypeVersion) {
        _logger.logInfo(
          'AuthSyncService: prevented legacy rollback for account '
          '${entry.entityId} (local=$localTypeVersion, remote=$remoteTypeVersion).',
        );
        await _analyticsService
            .logEvent('account_type_rollback_prevented', <String, dynamic>{
              'localTypeVersion': localTypeVersion,
              'remoteTypeVersion': remoteTypeVersion,
            });
        return false;
      }
    }
    final DateTime? remoteUpdatedAt = _extractRemoteUpdatedAt(
      entry.entityType,
      remoteData,
    );
    if (remoteUpdatedAt == null) {
      return true;
    }
    return !remoteUpdatedAt.isAfter(localUpdatedAt);
  }

  DocumentReference<Map<String, dynamic>>? _remoteDocRef({
    required String userId,
    required String entityType,
    required String entityId,
  }) {
    final DocumentReference<Map<String, dynamic>> userRef = _firestore
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
      case 'credit':
        return userRef.collection('credits').doc(entityId);
      case 'credit_card':
        return userRef.collection('credit_cards').doc(entityId);
      case 'debt':
        return userRef.collection('debts').doc(entityId);
      case 'credit_payment_group':
        return userRef.collection('credit_payment_groups').doc(entityId);
      case 'credit_payment_schedule':
        return userRef.collection('credit_payment_schedules').doc(entityId);
      case 'budget':
        return userRef.collection('budgets').doc(entityId);
      case 'budget_instance':
        return userRef.collection('budget_instances').doc(entityId);
      case 'saving_goal':
        return userRef.collection('saving_goals').doc(entityId);
      case 'upcoming_payment':
        return userRef.collection('recurring_payments').doc(entityId);
      case 'payment_reminder':
        return userRef.collection('reminders').doc(entityId);
      case 'profile':
        return userRef.collection('profile').doc('profile');
      default:
        return null;
    }
  }

  DateTime? _extractOutboxUpdatedAt(
    String entityType,
    Map<String, dynamic> payload,
  ) {
    switch (entityType) {
      case 'upcoming_payment':
      case 'payment_reminder':
        final Object? millis = payload['updatedAtMs'];
        if (millis is num) {
          return DateTime.fromMillisecondsSinceEpoch(
            millis.toInt(),
            isUtc: true,
          );
        }
        if (millis != null) {
          final int? parsed = int.tryParse(millis.toString());
          if (parsed != null) {
            return DateTime.fromMillisecondsSinceEpoch(parsed, isUtc: true);
          }
        }
        return null;
      default:
        return _coerceDateTime(payload['updatedAt']);
    }
  }

  DateTime? _extractRemoteUpdatedAt(
    String entityType,
    Map<String, dynamic> payload,
  ) {
    switch (entityType) {
      case 'upcoming_payment':
      case 'payment_reminder':
        final Object? millis = payload['updatedAtMs'];
        if (millis is num) {
          return DateTime.fromMillisecondsSinceEpoch(
            millis.toInt(),
            isUtc: true,
          );
        }
        if (millis != null) {
          final int? parsed = int.tryParse(millis.toString());
          if (parsed != null) {
            return DateTime.fromMillisecondsSinceEpoch(parsed, isUtc: true);
          }
        }
        return null;
      default:
        return _coerceDateTime(payload['updatedAt']);
    }
  }

  int _stableHash(String value) {
    int hash = 0;
    for (int i = 0; i < value.length; i++) {
      hash = (31 * hash + value.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }

  String _registryShardId({
    required String entityType,
    required String entityId,
  }) {
    if (entityType == entityTypeTransaction ||
        entityType == entityTypeTransactionTag) {
      const int shardCount = 16;
      final int shardIndex = _stableHash(entityId) % shardCount;
      final String suffix = shardIndex.toString().padLeft(2, '0');
      return '${entityType}s_$suffix';
    }
    return entityType;
  }

  String _registryEntityKey({
    required String entityType,
    required String entityId,
  }) {
    if (entityType == entityTypeProfile) {
      return 'profile';
    }
    return entityId;
  }

  bool _hasRemoteChangedSinceBase({
    required _RemoteEntityMetadata? remote,
    required db.OutboxEntryRow outboxEntry,
  }) {
    if (remote == null) {
      return false;
    }

    if (outboxEntry.baseRemoteUpdatedAt == null) {
      if (remote != null) {
        try {
          final Map<String, dynamic> payload = _payloadNormalizer.normalize(
            outboxEntry.entityType,
            _outboxDao.decodePayload(outboxEntry),
          );
          final DateTime? localUpdatedAt = _extractOutboxUpdatedAt(
            outboxEntry.entityType,
            payload,
          );
          if (localUpdatedAt != null &&
              localUpdatedAt.isAfter(remote.updatedAt)) {
            if (outboxEntry.entityType == entityTypeAccount) {
              final int localTypeVersion = _extractAccountTypeVersion(payload);
              final int remoteTypeVersion = remote.typeVersion ?? 0;
              if (localTypeVersion < remoteTypeVersion) {
                return true;
              }
              if (localTypeVersion > remoteTypeVersion) {
                return false;
              }
            }
            return false; // LWW побеждает, конфликта нет
          }
        } catch (_) {}
      }
      return true; // Равенство дат или ошибка разбора -> считаем конфликтом
    }

    final bool isDeletedDiff =
        (outboxEntry.baseRemoteIsDeleted ?? false) != remote.isDeleted;
    final bool typeVersionDiff =
        outboxEntry.entityType == entityTypeAccount &&
        outboxEntry.baseRemoteTypeVersion != null &&
        outboxEntry.baseRemoteTypeVersion != remote.typeVersion;
    final bool updatedAtDiff =
        outboxEntry.baseRemoteUpdatedAt != remote.updatedAt;

    return isDeletedDiff || typeVersionDiff || updatedAtDiff;
  }

  @visibleForTesting
  Future<void> bootstrapRegistryForTest(String userId) =>
      _bootstrapRegistry(userId);

  Future<void> _bootstrapRegistry(String userId) async {
    _logger.logInfo('AuthSyncService: starting sync_registry bootstrap...');

    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    final List<Category> categories = await _categoryDao.getAllCategories();
    final List<TagEntity> tags = await _tagDao.getAllTags();
    final List<TransactionEntity> transactions = await _transactionDao
        .getAllTransactions();
    final List<TransactionTagEntity> transactionTags =
        (await _transactionTagsDao.getAllTransactionTags())
            .map(_transactionTagsDao.mapRowToEntity)
            .toList();
    final List<CreditEntity> credits = (await _creditDao.getAllCredits())
        .map(_creditDao.mapRowToEntity)
        .toList();
    final List<CreditCardEntity> creditCards =
        (await _creditCardDao.getAllCreditCards())
            .map(_creditCardDao.mapRowToEntity)
            .toList();
    final List<DebtEntity> debts = (await _debtDao.getAllDebts())
        .map(_debtDao.mapRowToEntity)
        .toList();
    final List<CreditPaymentGroupEntity> creditPaymentGroups =
        await _creditPaymentDao.getAllPaymentGroups();
    final List<CreditPaymentScheduleEntity> creditPaymentSchedules =
        await _creditPaymentDao.getAllScheduleItems();
    final List<Budget> budgets = await _budgetDao.getAllBudgets();
    final List<BudgetInstance> budgetInstances = await _budgetInstanceDao
        .getAllInstances();
    final List<SavingGoal> savingGoals =
        await _loadLocalSavingGoalsWithStorageAccounts();
    final List<UpcomingPayment> upcomingPayments = await _upcomingPaymentsDao
        .getAll();
    final List<PaymentReminder> paymentReminders = await _paymentRemindersDao
        .getAll();
    final Profile? profile = await _profileDao.getProfile(userId);

    final List<db.OutboxEntryRow> outboxEntries = await _outboxDao.fetchPending(
      limit: 10000,
    );
    final Map<String, db.OutboxEntryRow>
    outboxMap = <String, db.OutboxEntryRow>{
      for (final db.OutboxEntryRow entry in outboxEntries)
        '${entry.entityType}_${_registryEntityKey(entityType: entry.entityType, entityId: entry.entityId)}':
            entry,
    };

    final Map<String, Map<String, dynamic>> shardMetadata =
        <String, Map<String, dynamic>>{};

    void add(
      String entityType,
      String id,
      DateTime updatedAt, {
      int? typeVersion,
      bool isDeleted = false,
    }) {
      final String entityKey = _registryEntityKey(
        entityType: entityType,
        entityId: id,
      );
      final String key = '${entityType}_$entityKey';
      final db.OutboxEntryRow? outboxEntry = outboxMap[key];

      if (outboxEntry != null) {
        final DateTime? baseUpdatedAt = outboxEntry.baseRemoteUpdatedAt;
        if (baseUpdatedAt == null) {
          // If the entry is new locally (no base remote metadata), it shouldn't
          // be in the remote registry yet because it hasn't been pushed.
          return;
        }

        final String shardId = _registryShardId(
          entityType: entityType,
          entityId: id,
        );
        final Map<String, dynamic> shardMap = shardMetadata.putIfAbsent(
          shardId,
          () => <String, dynamic>{},
        );
        final Map<String, dynamic> entryData = <String, dynamic>{
          'updatedAt': Timestamp.fromDate(baseUpdatedAt),
          'isDeleted': outboxEntry.baseRemoteIsDeleted ?? false,
        };
        if (outboxEntry.baseRemoteTypeVersion != null) {
          entryData['typeVersion'] = outboxEntry.baseRemoteTypeVersion;
        }
        shardMap[entityKey] = entryData;
        return;
      }

      final String shardId = _registryShardId(
        entityType: entityType,
        entityId: id,
      );
      final Map<String, dynamic> shardMap = shardMetadata.putIfAbsent(
        shardId,
        () => <String, dynamic>{},
      );
      final Map<String, dynamic> entryData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(updatedAt),
        'isDeleted': isDeleted,
      };
      if (typeVersion != null) {
        entryData['typeVersion'] = typeVersion;
      }
      shardMap[entityKey] = entryData;
    }

    for (final AccountEntity e in accounts) {
      add(
        entityTypeAccount,
        e.id,
        e.updatedAt,
        typeVersion: e.typeVersion,
        isDeleted: e.isDeleted,
      );
    }
    for (final Category e in categories) {
      if (e.isSystem && e.isDeleted) {
        continue; // Пропускаем missingOptionalReference плейсхолдеры
      }
      add(entityTypeCategory, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final TagEntity e in tags) {
      add(entityTypeTag, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final TransactionEntity e in transactions) {
      add(entityTypeTransaction, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final TransactionTagEntity e in transactionTags) {
      add(
        entityTypeTransactionTag,
        _transactionTagKey(e),
        e.updatedAt,
        isDeleted: e.isDeleted,
      );
    }
    for (final CreditEntity e in credits) {
      add(entityTypeCredit, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final CreditCardEntity e in creditCards) {
      add(entityTypeCreditCard, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final DebtEntity e in debts) {
      add(entityTypeDebt, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final CreditPaymentGroupEntity e in creditPaymentGroups) {
      add(
        entityTypeCreditPaymentGroup,
        e.id,
        e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        isDeleted: e.isDeleted,
      );
    }
    for (final CreditPaymentScheduleEntity e in creditPaymentSchedules) {
      add(
        entityTypeCreditPaymentSchedule,
        e.id,
        e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        isDeleted: e.isDeleted,
      );
    }
    for (final Budget e in budgets) {
      add(entityTypeBudget, e.id, e.updatedAt, isDeleted: e.isDeleted);
    }
    for (final BudgetInstance e in budgetInstances) {
      add(entityTypeBudgetInstance, e.id, e.updatedAt);
    }
    for (final SavingGoal e in savingGoals) {
      add(entityTypeSavingGoal, e.id, e.updatedAt);
    }
    for (final UpcomingPayment e in upcomingPayments) {
      add(
        entityTypeUpcomingPayment,
        e.id,
        DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
      );
    }
    for (final PaymentReminder e in paymentReminders) {
      add(
        entityTypePaymentReminder,
        e.id,
        DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
      );
    }
    if (profile != null) {
      add(entityTypeProfile, 'profile', profile.updatedAt);
    }

    final WriteBatch batch = _firestore.batch();
    shardMetadata.forEach((String shardId, Map<String, dynamic> metadataMap) {
      if (metadataMap.length > maxRegistryEntriesPerShardSoftLimit) {
        _logger.logWarning(
          'AuthSyncService: sync_registry shard $shardId during bootstrap exceeds soft limit of $maxRegistryEntriesPerShardSoftLimit entries (${metadataMap.length})',
        );
      }
      final DocumentReference<Map<String, dynamic>> docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_registry')
          .doc(shardId);
      batch.set(docRef, <String, dynamic>{
        'metadata': metadataMap,
      }, SetOptions(merge: true));
    });

    await batch.commit();
    _logger.logInfo(
      'AuthSyncService: sync_registry bootstrap completed successfully.',
    );
  }

  Future<_RemoteRegistryPullResult> _pullRemoteRegistry(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> registrySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('sync_registry')
              .get();

      if (registrySnapshot.docs.isEmpty) {
        _logger.logInfo(
          'AuthSyncService: sync_registry is empty, falling back to full fetchRemoteSnapshot',
        );
        final _RemoteSnapshot fullSnapshot = await _fetchRemoteSnapshot(userId);
        return _RemoteRegistryPullResult(
          metadata: _buildMetadataFromRemoteSnapshot(fullSnapshot),
          wasFallbackUsed: true,
        );
      }

      final Map<String, Map<String, _RemoteEntityMetadata>> result =
          <String, Map<String, _RemoteEntityMetadata>>{};
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in registrySnapshot.docs) {
        final String docId = doc.id;
        final Map<String, dynamic> data = doc.data();
        final Map<String, dynamic>? metadataMap =
            data['metadata'] as Map<String, dynamic>?;
        if (metadataMap == null) continue;

        String entityType = docId;
        if (docId.contains('_')) {
          final List<String> parts = docId.split('_');
          if (parts[0] == 'transactions') {
            entityType = entityTypeTransaction;
          } else if (parts[0] == 'transaction' && parts[1] == 'tags') {
            entityType = entityTypeTransactionTag;
          }
        } else {
          entityType = docId;
        }

        final Map<String, _RemoteEntityMetadata> typeMeta = result.putIfAbsent(
          entityType,
          () => <String, _RemoteEntityMetadata>{},
        );
        metadataMap.forEach((String id, dynamic val) {
          if (val is Map<String, dynamic>) {
            final dynamic updatedAtVal = val['updatedAt'];
            DateTime? updatedAt;
            if (updatedAtVal is Timestamp) {
              updatedAt = updatedAtVal.toDate().toUtc();
            } else if (updatedAtVal is String) {
              updatedAt = DateTime.tryParse(updatedAtVal)?.toUtc();
            }
            if (updatedAt != null) {
              typeMeta[id] = _RemoteEntityMetadata(
                id: id,
                entityType: entityType,
                updatedAt: updatedAt,
                typeVersion: val['typeVersion'] as int?,
                isDeleted: val['isDeleted'] as bool? ?? false,
              );
            }
          }
        });
      }
      return _RemoteRegistryPullResult(
        metadata: result,
        wasFallbackUsed: false,
      );
    } catch (e, stackTrace) {
      _logger.logError(
        'AuthSyncService: error loading sync_registry, falling back to full fetchRemoteSnapshot',
        e,
      );
      _analyticsService.reportError(e, stackTrace);
      final _RemoteSnapshot fullSnapshot = await _fetchRemoteSnapshot(userId);
      return _RemoteRegistryPullResult(
        metadata: _buildMetadataFromRemoteSnapshot(fullSnapshot),
        wasFallbackUsed: true,
      );
    }
  }

  Map<String, Map<String, _RemoteEntityMetadata>>
  _buildMetadataFromRemoteSnapshot(_RemoteSnapshot snapshot) {
    final Map<String, Map<String, _RemoteEntityMetadata>> result =
        <String, Map<String, _RemoteEntityMetadata>>{};

    void add<T>({
      required List<T> entities,
      required String entityType,
      required String Function(T) getId,
      required DateTime Function(T) getUpdatedAt,
      int Function(T)? getTypeVersion,
      bool Function(T)? getIsDeleted,
    }) {
      final Map<String, _RemoteEntityMetadata> typeMeta = result.putIfAbsent(
        entityType,
        () => <String, _RemoteEntityMetadata>{},
      );
      for (final T entity in entities) {
        final String id = getId(entity);
        typeMeta[id] = _RemoteEntityMetadata(
          id: id,
          entityType: entityType,
          updatedAt: getUpdatedAt(entity),
          typeVersion: getTypeVersion?.call(entity),
          isDeleted: getIsDeleted?.call(entity) ?? false,
        );
      }
    }

    add<AccountEntity>(
      entities: snapshot.accounts,
      entityType: entityTypeAccount,
      getId: (AccountEntity e) => e.id,
      getUpdatedAt: (AccountEntity e) => e.updatedAt,
      getTypeVersion: (AccountEntity e) => e.typeVersion,
      getIsDeleted: (AccountEntity e) => e.isDeleted,
    );
    add<Category>(
      entities: snapshot.categories,
      entityType: entityTypeCategory,
      getId: (Category e) => e.id,
      getUpdatedAt: (Category e) => e.updatedAt,
      getIsDeleted: (Category e) => e.isDeleted,
    );
    add<TagEntity>(
      entities: snapshot.tags,
      entityType: entityTypeTag,
      getId: (TagEntity e) => e.id,
      getUpdatedAt: (TagEntity e) => e.updatedAt,
      getIsDeleted: (TagEntity e) => e.isDeleted,
    );
    add<TransactionEntity>(
      entities: snapshot.transactions,
      entityType: entityTypeTransaction,
      getId: (TransactionEntity e) => e.id,
      getUpdatedAt: (TransactionEntity e) => e.updatedAt,
      getIsDeleted: (TransactionEntity e) => e.isDeleted,
    );
    add<TransactionTagEntity>(
      entities: snapshot.transactionTags,
      entityType: entityTypeTransactionTag,
      getId: _transactionTagKey,
      getUpdatedAt: (TransactionTagEntity e) => e.updatedAt,
      getIsDeleted: (TransactionTagEntity e) => e.isDeleted,
    );
    add<CreditEntity>(
      entities: snapshot.credits,
      entityType: entityTypeCredit,
      getId: (CreditEntity e) => e.id,
      getUpdatedAt: (CreditEntity e) => e.updatedAt,
      getIsDeleted: (CreditEntity e) => e.isDeleted,
    );
    add<CreditCardEntity>(
      entities: snapshot.creditCards,
      entityType: entityTypeCreditCard,
      getId: (CreditCardEntity e) => e.id,
      getUpdatedAt: (CreditCardEntity e) => e.updatedAt,
      getIsDeleted: (CreditCardEntity e) => e.isDeleted,
    );
    add<DebtEntity>(
      entities: snapshot.debts,
      entityType: entityTypeDebt,
      getId: (DebtEntity e) => e.id,
      getUpdatedAt: (DebtEntity e) => e.updatedAt,
      getIsDeleted: (DebtEntity e) => e.isDeleted,
    );
    add<CreditPaymentGroupEntity>(
      entities: snapshot.creditPaymentGroups,
      entityType: entityTypeCreditPaymentGroup,
      getId: (CreditPaymentGroupEntity e) => e.id,
      getUpdatedAt: (CreditPaymentGroupEntity e) =>
          e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      getIsDeleted: (CreditPaymentGroupEntity e) => e.isDeleted,
    );
    add<CreditPaymentScheduleEntity>(
      entities: snapshot.creditPaymentSchedules,
      entityType: entityTypeCreditPaymentSchedule,
      getId: (CreditPaymentScheduleEntity e) => e.id,
      getUpdatedAt: (CreditPaymentScheduleEntity e) =>
          e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      getIsDeleted: (CreditPaymentScheduleEntity e) => e.isDeleted,
    );
    add<Budget>(
      entities: snapshot.budgets,
      entityType: entityTypeBudget,
      getId: (Budget e) => e.id,
      getUpdatedAt: (Budget e) => e.updatedAt,
      getIsDeleted: (Budget e) => e.isDeleted,
    );
    add<BudgetInstance>(
      entities: snapshot.budgetInstances,
      entityType: entityTypeBudgetInstance,
      getId: (BudgetInstance e) => e.id,
      getUpdatedAt: (BudgetInstance e) => e.updatedAt,
    );
    add<SavingGoal>(
      entities: snapshot.savingGoals,
      entityType: entityTypeSavingGoal,
      getId: (SavingGoal e) => e.id,
      getUpdatedAt: (SavingGoal e) => e.updatedAt,
    );
    add<UpcomingPayment>(
      entities: snapshot.upcomingPayments,
      entityType: entityTypeUpcomingPayment,
      getId: (UpcomingPayment e) => e.id,
      getUpdatedAt: (UpcomingPayment e) =>
          DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
    );
    add<PaymentReminder>(
      entities: snapshot.paymentReminders,
      entityType: entityTypePaymentReminder,
      getId: (PaymentReminder e) => e.id,
      getUpdatedAt: (PaymentReminder e) =>
          DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs),
    );

    if (snapshot.profile != null) {
      result[entityTypeProfile] = <String, _RemoteEntityMetadata>{
        'profile': _RemoteEntityMetadata(
          id: 'profile',
          entityType: entityTypeProfile,
          updatedAt: snapshot.profile!.updatedAt,
        ),
      };
    }

    return result;
  }

  DateTime? _coerceDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }

  int _extractAccountTypeVersion(Map<String, dynamic> payload) {
    return _readInt(payload['typeVersion']) ?? 0;
  }

  AccountEntity _applyAccountMoney(
    AccountEntity account,
    Map<String, dynamic> payload,
  ) {
    return account.copyWith(
      balanceMinor: _readBigInt(payload['balanceMinor']),
      openingBalanceMinor: _readBigInt(payload['openingBalanceMinor']),
      currencyScale: _readInt(payload['currencyScale']),
      typeVersion: _extractAccountTypeVersion(payload),
    );
  }

  TransactionEntity _applyTransactionMoney(
    TransactionEntity transaction,
    Map<String, dynamic> payload,
  ) {
    return transaction.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  CreditEntity _applyCreditMoney(
    CreditEntity credit,
    Map<String, dynamic> payload,
  ) {
    return credit.copyWith(
      totalAmountMinor: _readBigInt(payload['totalAmountMinor']),
      totalAmountScale: _readInt(payload['totalAmountScale']),
    );
  }

  CreditCardEntity _applyCreditCardMoney(
    CreditCardEntity creditCard,
    Map<String, dynamic> payload,
  ) {
    return creditCard.copyWith(
      creditLimitMinor: _readBigInt(payload['creditLimitMinor']),
      creditLimitScale: _readInt(payload['creditLimitScale']),
    );
  }

  DebtEntity _applyDebtMoney(DebtEntity debt, Map<String, dynamic> payload) {
    return debt.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  CreditPaymentGroupEntity _groupFromPayload(Map<String, dynamic> payload) {
    final int scale = _readInt(payload['totalOutflowScale']) ?? 2;
    return CreditPaymentGroupEntity(
      id: payload['id'] as String? ?? '',
      creditId: payload['creditId'] as String? ?? '',
      sourceAccountId: payload['sourceAccountId'] as String? ?? '',
      scheduleItemId: payload['scheduleItemId'] as String?,
      paidAt: _coerceDateTime(payload['paidAt']) ?? DateTime.now().toUtc(),
      totalOutflow: Money.fromMinor(
        _readBigInt(payload['totalOutflowMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      principalPaid: Money.fromMinor(
        _readBigInt(payload['principalPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      interestPaid: Money.fromMinor(
        _readBigInt(payload['interestPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      feesPaid: Money.fromMinor(
        _readBigInt(payload['feesPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      note: payload['note'] as String?,
      idempotencyKey: payload['idempotencyKey'] as String?,
      createdAt: _coerceDateTime(payload['createdAt']),
      updatedAt: _coerceDateTime(payload['updatedAt']),
      isDeleted: payload['isDeleted'] as bool? ?? false,
    );
  }

  CreditPaymentScheduleEntity _scheduleFromPayload(
    Map<String, dynamic> payload,
  ) {
    final int scale = _readInt(payload['amountScale']) ?? 2;
    return CreditPaymentScheduleEntity(
      id: payload['id'] as String? ?? '',
      creditId: payload['creditId'] as String? ?? '',
      periodKey: payload['periodKey'] as String? ?? '',
      dueDate: _coerceDateTime(payload['dueDate']) ?? DateTime.now().toUtc(),
      status: CreditPaymentStatus.values.byName(
        payload['status'] as String? ?? CreditPaymentStatus.planned.name,
      ),
      principalAmount: Money.fromMinor(
        _readBigInt(payload['principalAmountMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      interestAmount: Money.fromMinor(
        _readBigInt(payload['interestAmountMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      totalAmount: Money.fromMinor(
        _readBigInt(payload['totalAmountMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      principalPaid: Money.fromMinor(
        _readBigInt(payload['principalPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      interestPaid: Money.fromMinor(
        _readBigInt(payload['interestPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      paidAt: _coerceDateTime(payload['paidAt']),
      createdAt: _coerceDateTime(payload['createdAt']),
      updatedAt: _coerceDateTime(payload['updatedAt']),
      isDeleted: payload['isDeleted'] as bool? ?? false,
    );
  }

  Budget _applyBudgetMoney(Budget budget, Map<String, dynamic> payload) {
    return budget.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  BudgetInstance _applyBudgetInstanceMoney(
    BudgetInstance instance,
    Map<String, dynamic> payload,
  ) {
    return instance.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      spentMinor: _readBigInt(payload['spentMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  UpcomingPayment _applyUpcomingPaymentMoney(
    UpcomingPayment payment,
    Map<String, dynamic> payload,
  ) {
    return payment.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  PaymentReminder _applyPaymentReminderMoney(
    PaymentReminder reminder,
    Map<String, dynamic> payload,
  ) {
    return reminder.copyWith(
      amountMinor: _readBigInt(payload['amountMinor']),
      amountScale: _readInt(payload['amountScale']),
    );
  }

  BigInt? _readBigInt(Object? value) {
    if (value == null) return null;
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    return BigInt.tryParse(value.toString());
  }

  int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<_RemoteSnapshot> _fetchRemoteSnapshot(String userId) async {
    final List<List<Object>> results = await Future.wait(<Future<List<Object>>>[
      _accountRemoteDataSource.fetchAll(userId),
      _categoryRemoteDataSource.fetchAll(userId),
      _tagRemoteDataSource.fetchAll(userId),
      _transactionRemoteDataSource.fetchAll(userId),
      _transactionTagRemoteDataSource.fetchAll(userId),
      _creditRemoteDataSource.fetchAll(userId),
      _creditCardRemoteDataSource.fetchAll(userId),
      _debtRemoteDataSource.fetchAll(userId),
      _creditPaymentGroupRemoteDataSource.fetchAll(userId),
      _creditPaymentScheduleRemoteDataSource.fetchAll(userId),
      _budgetRemoteDataSource.fetchAll(userId),
      _budgetInstanceRemoteDataSource.fetchAll(userId),
      _savingGoalRemoteDataSource.fetchAll(userId),
      _upcomingPaymentRemoteDataSource.fetchAll(userId),
      _paymentReminderRemoteDataSource.fetchAll(userId),
    ]);
    final Profile? profile = await _profileRemoteDataSource.fetch(userId);
    return _RemoteSnapshot(
      accounts: results[0] as List<AccountEntity>,
      categories: results[1] as List<Category>,
      tags: results[2] as List<TagEntity>,
      transactions: results[3] as List<TransactionEntity>,
      transactionTags: results[4] as List<TransactionTagEntity>,
      credits: results[5] as List<CreditEntity>,
      creditCards: results[6] as List<CreditCardEntity>,
      debts: results[7] as List<DebtEntity>,
      creditPaymentGroups: results[8] as List<CreditPaymentGroupEntity>,
      creditPaymentSchedules: results[9] as List<CreditPaymentScheduleEntity>,
      budgets: results[10] as List<Budget>,
      budgetInstances: results[11] as List<BudgetInstance>,
      savingGoals: results[12] as List<SavingGoal>,
      upcomingPayments: results[13] as List<UpcomingPayment>,
      paymentReminders: results[14] as List<PaymentReminder>,
      profile: profile,
    );
  }

  Future<void> _persistMergedState({
    required _RemoteSnapshot remoteSnapshot,
    required List<db.OutboxEntryRow> processedEntries,
    required AuthUser user,
  }) async {
    final String userId = user.uid;
    final List<int> processedIds = processedEntries
        .map((OutboxEntryRow entry) => entry.id)
        .toList();
    _AccountMergeResult? accountMergeResult;
    await _database.transaction(() async {
      if (processedIds.isNotEmpty) {
        await _outboxDao.markBatchAsSent(processedIds);
        await _outboxDao.pruneSent();
      }

      final List<AccountEntity> localAccounts = await _accountDao
          .getAllAccounts();
      final List<Category> localCategories = await _categoryDao
          .getAllCategories();
      final List<TagEntity> localTags = await _tagDao.getAllTags();
      final List<TransactionEntity> localTransactions = await _transactionDao
          .getAllTransactions();
      final List<TransactionTagEntity> localTransactionTags =
          (await _transactionTagsDao.getAllTransactionTags())
              .map(_transactionTagsDao.mapRowToEntity)
              .toList();
      final List<CreditEntity> localCredits = (await _creditDao.getAllCredits())
          .map(_creditDao.mapRowToEntity)
          .toList();
      final List<CreditCardEntity> localCreditCards =
          (await _creditCardDao.getAllCreditCards())
              .map(_creditCardDao.mapRowToEntity)
              .toList();
      final List<DebtEntity> localDebts = (await _debtDao.getAllDebts())
          .map(_debtDao.mapRowToEntity)
          .toList();
      final List<CreditPaymentGroupEntity> localCreditPaymentGroups =
          await _creditPaymentDao.getAllPaymentGroups();
      final List<CreditPaymentScheduleEntity> localCreditPaymentSchedules =
          await _creditPaymentDao.getAllScheduleItems();
      final List<Budget> localBudgets = await _budgetDao.getAllBudgets();
      final List<BudgetInstance> localBudgetInstances = await _budgetInstanceDao
          .getAllInstances();
      final List<SavingGoal> localSavingGoals =
          await _loadLocalSavingGoalsWithStorageAccounts();
      final List<UpcomingPayment> localUpcomingPayments =
          await _upcomingPaymentsDao.getAll();
      final List<PaymentReminder> localPaymentReminders =
          await _paymentRemindersDao.getAll();

      accountMergeResult = _mergeAccounts(
        localAccounts,
        remoteSnapshot.accounts,
      );
      final List<AccountEntity> mergedAccounts = accountMergeResult!.accounts;
      final List<Category> mergedCategories = _mergeEntities<Category>(
        local: localCategories,
        remote: remoteSnapshot.categories,
        getId: (Category entity) => entity.id,
        getUpdatedAt: (Category entity) => entity.updatedAt,
      );
      final List<TagEntity> mergedTags = _mergeEntities<TagEntity>(
        local: localTags,
        remote: remoteSnapshot.tags,
        getId: (TagEntity entity) => entity.id,
        getUpdatedAt: (TagEntity entity) => entity.updatedAt,
      );
      final _CategorySanitizationResult sanitizedCategories =
          _sanitizeCategories(mergedCategories);
      final List<Category> normalizedCategories =
          sanitizedCategories.categories;
      final Map<String, String> categoryIdMapping =
          sanitizedCategories.idMapping;

      final List<TransactionEntity> mergedTransactions =
          _mergeEntities<TransactionEntity>(
            local: localTransactions,
            remote: remoteSnapshot.transactions,
            getId: (TransactionEntity entity) => entity.id,
            getUpdatedAt: (TransactionEntity entity) => entity.updatedAt,
          );
      final List<TransactionTagEntity> mergedTransactionTags =
          _mergeEntities<TransactionTagEntity>(
            local: localTransactionTags,
            remote: remoteSnapshot.transactionTags,
            getId: _transactionTagKey,
            getUpdatedAt: (TransactionTagEntity entity) => entity.updatedAt,
          );
      final List<TransactionEntity> normalizedTransactions =
          _normalizeTransactions(mergedTransactions, categoryIdMapping);
      final List<CreditEntity> mergedCredits = _mergeEntities<CreditEntity>(
        local: localCredits,
        remote: remoteSnapshot.credits,
        getId: (CreditEntity entity) => entity.id,
        getUpdatedAt: (CreditEntity entity) => entity.updatedAt,
      );
      final List<CreditCardEntity> mergedCreditCards =
          _mergeEntities<CreditCardEntity>(
            local: localCreditCards,
            remote: remoteSnapshot.creditCards,
            getId: (CreditCardEntity entity) => entity.id,
            getUpdatedAt: (CreditCardEntity entity) => entity.updatedAt,
          );
      final List<DebtEntity> mergedDebts = _mergeEntities<DebtEntity>(
        local: localDebts,
        remote: remoteSnapshot.debts,
        getId: (DebtEntity entity) => entity.id,
        getUpdatedAt: (DebtEntity entity) => entity.updatedAt,
      );
      final List<CreditPaymentGroupEntity> mergedCreditPaymentGroups =
          _mergeEntities<CreditPaymentGroupEntity>(
            local: localCreditPaymentGroups,
            remote: remoteSnapshot.creditPaymentGroups,
            getId: (CreditPaymentGroupEntity entity) => entity.id,
            getUpdatedAt: (CreditPaymentGroupEntity entity) =>
                entity.updatedAt ?? entity.createdAt ?? entity.paidAt,
          );
      final List<CreditPaymentScheduleEntity> mergedCreditPaymentSchedules =
          _mergeEntities<CreditPaymentScheduleEntity>(
            local: localCreditPaymentSchedules,
            remote: remoteSnapshot.creditPaymentSchedules,
            getId: (CreditPaymentScheduleEntity entity) => entity.id,
            getUpdatedAt: (CreditPaymentScheduleEntity entity) =>
                entity.updatedAt ?? entity.createdAt ?? entity.dueDate,
          );
      final List<Budget> mergedBudgets = _mergeEntities<Budget>(
        local: localBudgets,
        remote: remoteSnapshot.budgets,
        getId: (Budget entity) => entity.id,
        getUpdatedAt: (Budget entity) => entity.updatedAt,
      );
      final List<Budget> normalizedBudgets = _normalizeBudgets(
        mergedBudgets,
        categoryIdMapping,
      );
      final List<BudgetInstance> mergedBudgetInstances =
          _mergeEntities<BudgetInstance>(
            local: localBudgetInstances,
            remote: remoteSnapshot.budgetInstances,
            getId: (BudgetInstance entity) => entity.id,
            getUpdatedAt: (BudgetInstance entity) => entity.updatedAt,
          );
      final List<SavingGoal> mergedSavingGoals = _mergeEntities<SavingGoal>(
        local: localSavingGoals,
        remote: remoteSnapshot.savingGoals,
        getId: (SavingGoal goal) => goal.id,
        getUpdatedAt: (SavingGoal goal) => goal.updatedAt,
      );
      final List<UpcomingPayment> mergedUpcomingPayments =
          _mergeEntities<UpcomingPayment>(
            local: localUpcomingPayments,
            remote: remoteSnapshot.upcomingPayments,
            getId: (UpcomingPayment payment) => payment.id,
            getUpdatedAt: (UpcomingPayment payment) =>
                DateTime.fromMillisecondsSinceEpoch(payment.updatedAtMs),
          );
      final List<PaymentReminder> mergedPaymentReminders =
          _mergeEntities<PaymentReminder>(
            local: localPaymentReminders,
            remote: remoteSnapshot.paymentReminders,
            getId: (PaymentReminder reminder) => reminder.id,
            getUpdatedAt: (PaymentReminder reminder) =>
                DateTime.fromMillisecondsSinceEpoch(reminder.updatedAtMs),
          );

      final Set<String> usedCategoryIds = normalizedTransactions
          .map((TransactionEntity tx) => tx.categoryId)
          .whereType<String>()
          .toSet();
      final Set<String> existingCategoryIds = normalizedCategories
          .map((Category c) => c.id)
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
        ...normalizedCategories,
        ...placeholdersToInsert,
      ];

      final Profile? mergedProfile = _mergeProfile(
        await _profileDao.getProfile(userId),
        remoteSnapshot.profile,
      );

      // --- Tiered Insertion Strategy ---

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

        final List<String> restoredCategoryIds = remoteSnapshot.categories
            .where((Category c) => !c.isMissingReferencePlaceholder)
            .map((Category c) => c.id)
            .toList();
        await conflictDao.resolvePendingMissingReferences(
          'category',
          restoredCategoryIds,
        );

        // Tier 1: Base Entities (Accounts, Categories, Tags)
        await _accountDao.upsertAll(mergedAccounts);
        await _categoryDao.upsertAll(finalCategories);
        await _tagDao.upsertAll(mergedTags);

        final Set<String> validAccountIds = mergedAccounts
            .map((AccountEntity e) => e.id)
            .toSet();
        final Set<String> validCategoryIds = finalCategories
            .map((Category e) => e.id)
            .toSet();
        final Set<String> validTagIds = mergedTags
            .map((TagEntity e) => e.id)
            .toSet();

        // Tier 2: Dependent Entities - Goals
        final List<CreditEntity> sanitizedCredits = _dataSanitizer
            .sanitizeCredits(
              credits: mergedCredits,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
            );
        await _creditDao.upsertAll(sanitizedCredits);

        final List<CreditCardEntity> sanitizedCreditCards = _dataSanitizer
            .sanitizeCreditCards(
              creditCards: mergedCreditCards,
              validAccountIds: validAccountIds,
            );
        await _creditCardDao.upsertAll(sanitizedCreditCards);

        final List<DebtEntity> sanitizedDebts = _dataSanitizer.sanitizeDebts(
          debts: mergedDebts,
          validAccountIds: validAccountIds,
        );
        await _debtDao.upsertAll(sanitizedDebts);
        final List<AccountEntity> repairedAccounts =
            markOrphanedLiabilityAccountsDeleted(
              accounts: mergedAccounts,
              activeLiabilityAccountIds: collectActiveLiabilityAccountIds(
                credits: sanitizedCredits,
                creditCards: sanitizedCreditCards,
                debts: sanitizedDebts,
              ),
            );

        await _savingGoalDao.upsertAll(mergedSavingGoals);
        await _goalAccountLinkDao.replaceLinksByGoal(
          accountIdsByGoalId: <String, Iterable<String>>{
            for (final SavingGoal goal in mergedSavingGoals)
              goal.id: goal.effectiveStorageAccountIds,
          },
        );
        final Set<String> validSavingGoalIds = mergedSavingGoals
            .map((SavingGoal e) => e.id)
            .toSet();

        final Set<String> validCreditIds = sanitizedCredits
            .map((CreditEntity e) => e.id)
            .toSet();
        final List<CreditPaymentScheduleEntity>
        sanitizedCreditPaymentSchedules = _dataSanitizer
            .sanitizeCreditPaymentSchedules(
              schedules: mergedCreditPaymentSchedules,
              validCreditIds: validCreditIds,
            );
        await _creditPaymentDao.upsertSchedule(sanitizedCreditPaymentSchedules);

        final Set<String> validScheduleIds = sanitizedCreditPaymentSchedules
            .where((CreditPaymentScheduleEntity e) => !e.isDeleted)
            .map((CreditPaymentScheduleEntity e) => e.id)
            .toSet();
        final List<CreditPaymentGroupEntity> sanitizedCreditPaymentGroups =
            _dataSanitizer.sanitizeCreditPaymentGroups(
              groups: mergedCreditPaymentGroups,
              validCreditIds: validCreditIds,
              validAccountIds: validAccountIds,
              validScheduleIds: validScheduleIds,
            );
        await _creditPaymentDao.upsertPaymentGroups(
          sanitizedCreditPaymentGroups,
        );

        final Set<String> validPaymentGroupIds = sanitizedCreditPaymentGroups
            .where((CreditPaymentGroupEntity e) => !e.isDeleted)
            .map((CreditPaymentGroupEntity e) => e.id)
            .toSet();

        final Set<String> allPhysicalPaymentGroupIds =
            sanitizedCreditPaymentGroups
                .map((CreditPaymentGroupEntity e) => e.id)
                .toSet();

        final List<TransactionEntity> repairedTransactions =
            await _resolveOrphanedCreditPaymentLinks(
              transactions: normalizedTransactions,
              validPaymentGroupIds: validPaymentGroupIds,
              allPhysicalPaymentGroupIds: allPhysicalPaymentGroupIds,
            );

        _assertResolvableCreditPaymentLinks(
          transactions: repairedTransactions,
          validPaymentGroupIds: validPaymentGroupIds,
        );

        // Tier 3: Core Entities (Transactions, Rules, Budgets)
        // Sanitize transactions
        final List<TransactionEntity> sanitizedTransactions = _dataSanitizer
            .sanitizeTransactions(
              transactions: repairedTransactions,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
              validSavingGoalIds: validSavingGoalIds,
              validPaymentGroupIds: allPhysicalPaymentGroupIds,
            );

        final List<UpcomingPayment> sanitizedUpcomingPayments = _dataSanitizer
            .sanitizeUpcomingPayments(
              payments: mergedUpcomingPayments,
              validAccountIds: validAccountIds,
              validCategoryIds: validCategoryIds,
            );

        await _transactionDao.upsertAll(sanitizedTransactions);
        final List<AccountEntity> recalculatedAccounts =
            await _recalculateBalances(
              accounts: repairedAccounts,
              transactions: sanitizedTransactions,
            );
        await _accountDao.upsertAll(recalculatedAccounts);

        final Set<String> validTransactionIds = sanitizedTransactions
            .map((TransactionEntity e) => e.id)
            .toSet();
        final List<TransactionTagEntity> sanitizedTransactionTags =
            _dataSanitizer.sanitizeTransactionTags(
              transactionTags: mergedTransactionTags,
              validTransactionIds: validTransactionIds,
              validTagIds: validTagIds,
            );
        await _transactionTagsDao.upsertAll(sanitizedTransactionTags);
        await _goalContributionRebuildService.rebuild();

        for (final UpcomingPayment payment in sanitizedUpcomingPayments) {
          await _upcomingPaymentsDao.upsert(payment);
        }
        for (final PaymentReminder reminder in mergedPaymentReminders) {
          await _paymentRemindersDao.upsert(reminder);
        }

        await _budgetDao.upsertAll(normalizedBudgets);
        final Set<String> validBudgetIds = normalizedBudgets
            .map((Budget e) => e.id)
            .toSet();

        // Tier 4: Strongly Dependent Entities (Budget Instances)
        // Sanitize budget instances
        final List<BudgetInstance> sanitizedBudgetInstances = _dataSanitizer
            .sanitizeBudgetInstances(
              instances: mergedBudgetInstances,
              validBudgetIds: validBudgetIds,
            );

        await _budgetInstanceDao.upsertAll(sanitizedBudgetInstances);

        // Upsert profile last (least dependent, mostly meta)
        if (mergedProfile != null) {
          await _profileDao.upsert(mergedProfile);
        }
      });
      final Profile? profile = _mergeProfile(
        await _profileDao.getProfile(userId),
        remoteSnapshot.profile,
      );

      // If profile is missing or is a fallback profile, initialize it with user data
      if (profile == null || profile.updatedAt.millisecondsSinceEpoch == 0) {
        final String systemLocale = kIsWeb
            ? Intl.systemLocale.split('_').first
            : Platform.localeName.split('_').first;
        final Profile newProfile =
            (profile ?? Profile(uid: userId, updatedAt: DateTime.now().toUtc()))
                .copyWith(
                  name: user.displayName ?? '',
                  locale: systemLocale,
                  updatedAt: DateTime.now().toUtc(),
                );
        await _profileDao.upsertInTransaction(newProfile);

        // Also queue an update to sync this new profile to remote
        await _outboxDao.enqueue(
          entityType: 'profile',
          entityId: userId,
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{
            'uid': newProfile.uid,
            'name': newProfile.name,
            'currency': newProfile.currency.name,
            'locale': newProfile.locale,
            'photoUrl': newProfile.photoUrl,
            'updatedAt': newProfile.updatedAt.toIso8601String(),
          },
        );
      } else if (profile != null) {
        await _profileDao.upsertInTransaction(profile);
      }
    });
    if (accountMergeResult != null) {
      await _emitAccountMergeObservability(
        userId: userId,
        result: accountMergeResult!,
      );
    }
  }

  Future<List<AccountEntity>> _recalculateBalances({
    required List<AccountEntity> accounts,
    required List<TransactionEntity> transactions,
  }) async {
    final Map<String, MoneyAccumulator> deltas = <String, MoneyAccumulator>{};
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
      final TransactionType type = parseTransactionType(transaction.type);
      final MoneyAmount amount = transaction.amountValue.abs();

      if (type.isTransfer) {
        final String? targetId = transaction.transferAccountId;
        if (targetId == null || targetId == transaction.accountId) {
          continue;
        }
        _applyMoneyDelta(
          deltas,
          transaction.accountId,
          _negateMoneyAmount(amount),
        );
        _applyMoneyDelta(deltas, targetId, amount);
        continue;
      }

      if (creditAccountId != null) {
        final MoneyAmount repaymentDelta = type.isExpense
            ? amount
            : _negateMoneyAmount(amount);
        if (transaction.accountId != creditAccountId) {
          final MoneyAmount accountDelta = type.isIncome
              ? amount
              : _negateMoneyAmount(amount);
          _applyMoneyDelta(deltas, transaction.accountId, accountDelta);
          _applyMoneyDelta(deltas, creditAccountId, repaymentDelta);
        } else {
          _applyMoneyDelta(deltas, creditAccountId, repaymentDelta);
        }
        continue;
      }

      final MoneyAmount delta = type.isIncome
          ? amount
          : _negateMoneyAmount(amount);
      _applyMoneyDelta(deltas, transaction.accountId, delta);
    }

    return accounts
        .map((AccountEntity account) {
          final int scale =
              account.currencyScale ?? resolveCurrencyScale(account.currency);
          final MoneyAmount netAmount = _normalizeAccumulator(
            deltas[account.id],
            scale,
          );
          final BigInt openingBalanceMinor = _resolveOpeningBalanceMinor(
            account: account,
            scale: scale,
          );
          final BigInt balanceMinor = openingBalanceMinor + netAmount.minor;
          return account.copyWith(
            openingBalanceMinor: openingBalanceMinor,
            balanceMinor: balanceMinor,
            currencyScale: scale,
          );
        })
        .toList(growable: false);
  }

  BigInt _resolveOpeningBalanceMinor({
    required AccountEntity account,
    required int scale,
  }) {
    final BigInt existing = account.openingBalanceMinor ?? BigInt.zero;
    final int existingScale = account.currencyScale ?? scale;
    return _convertMinorScale(existing, existingScale, scale);
  }

  void _applyMoneyDelta(
    Map<String, MoneyAccumulator> deltas,
    String accountId,
    MoneyAmount amount,
  ) {
    final MoneyAccumulator accumulator = deltas.putIfAbsent(
      accountId,
      MoneyAccumulator.new,
    );
    accumulator.add(amount);
  }

  MoneyAmount _normalizeAccumulator(
    MoneyAccumulator? accumulator,
    int targetScale,
  ) {
    if (accumulator == null || accumulator.minor == BigInt.zero) {
      return MoneyAmount(minor: BigInt.zero, scale: targetScale);
    }
    final int sourceScale = accumulator.scale;
    final BigInt minor = _convertMinorScale(
      accumulator.minor,
      sourceScale,
      targetScale,
    );
    return MoneyAmount(minor: minor, scale: targetScale);
  }

  BigInt _convertMinorScale(BigInt minor, int fromScale, int toScale) {
    if (fromScale == toScale) {
      return minor;
    }
    final Money source = Money(minor: minor, currency: 'XXX', scale: fromScale);
    return Money.fromDecimalString(
      source.toDecimalString(),
      currency: 'XXX',
      scale: toScale,
    ).minor;
  }

  MoneyAmount _negateMoneyAmount(MoneyAmount amount) {
    return MoneyAmount(minor: -amount.minor, scale: amount.scale);
  }

  String _transactionTagKey(TransactionTagEntity link) {
    return '${link.transactionId}::${link.tagId}';
  }

  _AccountMergeResult _mergeAccounts(
    List<AccountEntity> local,
    List<AccountEntity> remote,
  ) {
    // TODO(credit-sync): Усилить merge account/entity pair:
    // простой LWW по updatedAt недостаточен для связки credit + account,
    // потому что orphaned active account может победить tombstone удаленного кредита.
    final _AccountMergeObservability observability =
        _AccountMergeObservability();
    _collectAccountNormalizationObservability(
      accounts: local,
      source: 'local',
      observability: observability,
    );
    _collectAccountNormalizationObservability(
      accounts: remote,
      source: 'remote',
      observability: observability,
    );
    final Map<String, AccountEntity> merged = <String, AccountEntity>{
      for (final AccountEntity item in local) item.id: item,
    };

    for (final AccountEntity remoteItem in remote) {
      final AccountEntity? localItem = merged[remoteItem.id];
      if (localItem == null) {
        merged[remoteItem.id] = remoteItem;
        continue;
      }

      final AccountEntity base =
          localItem.updatedAt.isAfter(remoteItem.updatedAt)
          ? localItem
          : remoteItem;

      if (localItem.typeVersion == remoteItem.typeVersion) {
        if (localItem.type != remoteItem.type) {
          observability.equalVersionTypeMismatchCount += 1;
        }
        merged[remoteItem.id] = base;
        continue;
      }

      observability.typeVersionConflictCount += 1;
      final AccountEntity typeWinner =
          localItem.typeVersion > remoteItem.typeVersion
          ? localItem
          : remoteItem;
      if (identical(typeWinner, localItem)) {
        observability.localTypeWins += 1;
      } else {
        observability.remoteTypeWins += 1;
      }
      merged[remoteItem.id] = base.copyWith(
        type: typeWinner.type,
        typeVersion: typeWinner.typeVersion,
      );
    }

    return _AccountMergeResult(
      accounts: merged.values.toList(),
      observability: observability,
    );
  }

  void _collectAccountNormalizationObservability({
    required List<AccountEntity> accounts,
    required String source,
    required _AccountMergeObservability observability,
  }) {
    for (final AccountEntity account in accounts) {
      final String rawType = account.type.trim().toLowerCase();
      final String normalizedType = normalizeAccountType(account.type);
      if (normalizedType.isEmpty) {
        continue;
      }
      if (normalizedType != rawType) {
        observability.fallbackNormalizationCount += 1;
      }
      if (normalizedType == kAccountTypeLegacyUnknown) {
        observability.unknownLegacyTypeCount += 1;
        if (rawType.isNotEmpty) {
          observability.unknownLegacyTypes.add('$source:$rawType');
        }
      }
    }
  }

  Future<void> _emitAccountMergeObservability({
    required String userId,
    required _AccountMergeResult result,
  }) async {
    final _AccountMergeObservability observability = result.observability;
    if (!observability.hasSignals) {
      return;
    }
    _logger.logInfo(
      'AuthSyncService: account type observability for $userId '
      'fallback_normalization=${observability.fallbackNormalizationCount}, '
      'unknown_legacy=${observability.unknownLegacyTypeCount}, '
      'type_conflicts=${observability.typeVersionConflictCount}, '
      'local_type_wins=${observability.localTypeWins}, '
      'remote_type_wins=${observability.remoteTypeWins}, '
      'equal_version_mismatches=${observability.equalVersionTypeMismatchCount}, '
      'unknown_types=${observability.unknownLegacyTypes.join(', ')}.',
    );
    await _analyticsService
        .logEvent('account_type_sync_observability', <String, dynamic>{
          'fallbackNormalization': observability.fallbackNormalizationCount,
          'unknownLegacy': observability.unknownLegacyTypeCount,
          'typeConflicts': observability.typeVersionConflictCount,
          'localTypeWins': observability.localTypeWins,
          'remoteTypeWins': observability.remoteTypeWins,
          'equalVersionMismatches': observability.equalVersionTypeMismatchCount,
          'unknownTypeCount': observability.unknownLegacyTypes.length,
        });
  }

  List<T> _mergeEntities<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) getId,
    required DateTime Function(T) getUpdatedAt,
  }) {
    final Map<String, T> merged = <String, T>{
      for (final T item in local) getId(item): item,
    };

    for (final T remoteItem in remote) {
      final String key = getId(remoteItem);
      final T? existing = merged[key];
      if (existing == null) {
        merged[key] = remoteItem;
        continue;
      }
      final DateTime existingUpdatedAt = getUpdatedAt(existing);
      final DateTime remoteUpdatedAt = getUpdatedAt(remoteItem);
      if (!existingUpdatedAt.isAfter(remoteUpdatedAt)) {
        merged[key] = remoteItem;
      }
    }

    return merged.values.toList();
  }

  Profile? _mergeProfile(Profile? local, Profile? remote) {
    if (local == null) {
      return remote;
    }
    if (remote == null) {
      return local;
    }
    return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
  }

  _CategorySanitizationResult _sanitizeCategories(List<Category> categories) {
    if (categories.isEmpty) {
      return const _CategorySanitizationResult(
        categories: <Category>[],
        idMapping: <String, String>{},
      );
    }

    final Map<String, List<Category>> groupedByName =
        <String, List<Category>>{};
    final Map<String, String> idMapping = <String, String>{};
    final List<Category> sanitized = <Category>[];
    final Set<String> deduplicatedNames = <String>{};

    for (final Category category in categories) {
      if (category.isMissingReferencePlaceholder) {
        sanitized.add(category);
        idMapping[category.id] = category.id;
        continue;
      }
      final String key = category.name.trim().toLowerCase();
      groupedByName.putIfAbsent(key, () => <Category>[]).add(category);
    }

    for (final List<Category> group in groupedByName.values) {
      if (group.isEmpty) {
        continue;
      }
      group.sort((Category a, Category b) {
        final int deletionComparison = (a.isDeleted ? 1 : 0).compareTo(
          b.isDeleted ? 1 : 0,
        );
        if (deletionComparison != 0) {
          return deletionComparison;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });

      final Category canonical = group.first;
      sanitized.add(canonical);
      for (final Category item in group) {
        idMapping[item.id] = canonical.id;
      }

      if (group.length > 1) {
        deduplicatedNames.add(canonical.name);
      }
    }

    if (deduplicatedNames.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: deduplicated categories with identical names: '
        '${deduplicatedNames.join(', ')}.',
      );
    }

    final List<Category> normalized = _normalizeCategoryParents(
      sanitized,
      idMapping,
    );
    // Sort topologically to ensure parents are inserted before children
    normalized.sort((Category a, Category b) {
      if (a.parentId == b.id) return 1; // a depends on b, so b comes first
      if (b.parentId == a.id) return -1; // b depends on a, so a comes first
      // If no direct dependency, sort by depth (parents have null parentId)
      if (a.parentId == null && b.parentId != null) return -1;
      if (b.parentId == null && a.parentId != null) return 1;
      return a.name.compareTo(b.name);
    });
    return _CategorySanitizationResult(
      categories: normalized,
      idMapping: idMapping,
    );
  }

  List<Category> _normalizeCategoryParents(
    List<Category> categories,
    Map<String, String> idMapping,
  ) {
    if (categories.isEmpty || idMapping.isEmpty) {
      return categories;
    }

    final Map<String, int> cleared = <String, int>{};
    final Map<String, int> remapped = <String, int>{};
    final List<Category> normalized = <Category>[];

    for (final Category category in categories) {
      final String? parentId = category.parentId;
      if (parentId == null) {
        normalized.add(category);
        continue;
      }

      final String? canonicalParentId = idMapping[parentId];
      if (canonicalParentId == null || canonicalParentId == category.id) {
        cleared[parentId] = (cleared[parentId] ?? 0) + 1;
        normalized.add(category.copyWith(parentId: null));
        continue;
      }

      if (canonicalParentId != parentId) {
        remapped[canonicalParentId] = (remapped[canonicalParentId] ?? 0) + 1;
        normalized.add(category.copyWith(parentId: canonicalParentId));
        continue;
      }

      normalized.add(category);
    }

    if (cleared.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: removed parent assignments for categories due to '
        'missing canonical references: ${_formatIdCounts(cleared)}.',
      );
    }
    if (remapped.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: remapped category parent references to canonical IDs: '
        '${_formatIdCounts(remapped)}.',
      );
    }

    return normalized;
  }

  List<TransactionEntity> _normalizeTransactions(
    List<TransactionEntity> transactions,
    Map<String, String> categoryIdMapping,
  ) {
    if (transactions.isEmpty || categoryIdMapping.isEmpty) {
      return transactions;
    }

    final Map<String, int> cleared = <String, int>{};
    final Map<String, int> remapped = <String, int>{};
    final List<TransactionEntity> normalized = <TransactionEntity>[];

    for (final TransactionEntity transaction in transactions) {
      final String? categoryId = transaction.categoryId;
      if (categoryId == null) {
        normalized.add(transaction);
        continue;
      }

      final String? canonicalId = categoryIdMapping[categoryId];
      if (canonicalId == null) {
        // Сохраняем оригинальный categoryId, отсутствующие ссылки обработаем позже
        normalized.add(transaction);
        continue;
      }

      if (canonicalId != categoryId) {
        remapped[canonicalId] = (remapped[canonicalId] ?? 0) + 1;
        normalized.add(transaction.copyWith(categoryId: canonicalId));
        continue;
      }

      normalized.add(transaction);
    }

    if (cleared.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: removed category assignments for transactions due to '
        'missing categories: ${_formatIdCounts(cleared)}.',
      );
    }
    if (remapped.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: remapped transaction categories to canonical IDs: '
        '${_formatIdCounts(remapped)}.',
      );
    }

    return normalized;
  }

  List<Budget> _normalizeBudgets(
    List<Budget> budgets,
    Map<String, String> categoryIdMapping,
  ) {
    if (budgets.isEmpty || categoryIdMapping.isEmpty) {
      return budgets;
    }

    final Map<String, int> removed = <String, int>{};
    final List<Budget> normalized = <Budget>[];

    for (final Budget budget in budgets) {
      final LinkedHashSet<String> mappedCategories = LinkedHashSet<String>();
      bool changed = false;
      for (final String categoryId in budget.categories) {
        final String? canonicalId = categoryIdMapping[categoryId];
        if (canonicalId == null) {
          removed[categoryId] = (removed[categoryId] ?? 0) + 1;
          changed = true;
          continue;
        }
        if (canonicalId != categoryId) {
          changed = true;
        }
        mappedCategories.add(canonicalId);
      }

      if (!changed &&
          mappedCategories.length == budget.categories.length &&
          _listsEqual(mappedCategories.toList(), budget.categories)) {
        normalized.add(budget);
      } else {
        normalized.add(budget.copyWith(categories: mappedCategories.toList()));
      }
    }

    if (removed.isNotEmpty) {
      _logger.logInfo(
        'AuthSyncService: removed unknown categories from budgets: '
        '${_formatIdCounts(removed)}.',
      );
    }

    return normalized;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  String _formatIdCounts(Map<String, int> counts) {
    return counts.entries
        .map((MapEntry<String, int> entry) => '${entry.key}(${entry.value})')
        .join(', ');
  }

  Future<List<TransactionEntity>> _resolveOrphanedCreditPaymentLinks({
    required List<TransactionEntity> transactions,
    required Set<String> validPaymentGroupIds,
    required Set<String> allPhysicalPaymentGroupIds,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final List<TransactionEntity> repaired = <TransactionEntity>[];

    for (final TransactionEntity transaction in transactions) {
      if (!transaction.isDeleted &&
          transaction.groupId != null &&
          !validPaymentGroupIds.contains(transaction.groupId)) {
        _logger.logWarning(
          'AuthSyncService: Found orphaned active transaction ${transaction.id} '
          'pointing to missing/deleted group ${transaction.groupId}. Soft-deleting.',
        );

        final bool groupExistsPhysically = allPhysicalPaymentGroupIds.contains(
          transaction.groupId,
        );

        final TransactionEntity updatedTx = transaction.copyWith(
          isDeleted: true,
          updatedAt: now,
          groupId: groupExistsPhysically ? transaction.groupId : null,
        );
        repaired.add(updatedTx);

        final bool alreadyQueued = await _outboxDao.hasPendingDeleteForEntity(
          entityType: entityTypeTransaction,
          entityId: transaction.id,
        );

        if (!alreadyQueued) {
          await _outboxDao.enqueue(
            entityType: entityTypeTransaction,
            entityId: transaction.id,
            operation: OutboxOperation.delete,
            payload: _mapTransactionPayload(updatedTx),
            baseRemoteUpdatedAt: transaction.updatedAt,
            baseRemoteIsDeleted: transaction.isDeleted,
          );
        }
      } else {
        repaired.add(transaction);
      }
    }
    return repaired;
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

  void _assertResolvableCreditPaymentLinks({
    required List<TransactionEntity> transactions,
    required Set<String> validPaymentGroupIds,
  }) {
    final List<TransactionEntity> unresolved = transactions
        .where(
          (TransactionEntity transaction) =>
              !transaction.isDeleted &&
              transaction.groupId != null &&
              !validPaymentGroupIds.contains(transaction.groupId),
        )
        .toList(growable: false);
    if (unresolved.isEmpty) {
      return;
    }

    final String sample = unresolved
        .take(3)
        .map(
          (TransactionEntity transaction) =>
              '${transaction.id}:${transaction.groupId}',
        )
        .join(', ');
    throw StateError(
      'Login sync получил active transactions с отсутствующими '
      'credit_payment_groups. Примеры: $sample',
    );
  }
}

class _CategorySanitizationResult {
  const _CategorySanitizationResult({
    required this.categories,
    required this.idMapping,
  });

  final List<Category> categories;
  final Map<String, String> idMapping;
}

class _AccountMergeResult {
  const _AccountMergeResult({
    required this.accounts,
    required this.observability,
  });

  final List<AccountEntity> accounts;
  final _AccountMergeObservability observability;
}

class _AccountMergeObservability {
  int fallbackNormalizationCount = 0;
  int unknownLegacyTypeCount = 0;
  int typeVersionConflictCount = 0;
  int localTypeWins = 0;
  int remoteTypeWins = 0;
  int equalVersionTypeMismatchCount = 0;
  final Set<String> unknownLegacyTypes = <String>{};

  bool get hasSignals =>
      fallbackNormalizationCount > 0 ||
      unknownLegacyTypeCount > 0 ||
      typeVersionConflictCount > 0 ||
      equalVersionTypeMismatchCount > 0;
}

class _RemoteSnapshot {
  _RemoteSnapshot({
    required this.accounts,
    required this.categories,
    required this.tags,
    required this.transactions,
    required this.transactionTags,
    required this.credits,
    required this.creditCards,
    required this.debts,
    required this.creditPaymentGroups,
    required this.creditPaymentSchedules,
    required this.budgets,
    required this.budgetInstances,
    required this.savingGoals,
    required this.upcomingPayments,
    required this.paymentReminders,
    required this.profile,
  });

  final List<AccountEntity> accounts;
  final List<Category> categories;
  final List<TagEntity> tags;
  final List<TransactionEntity> transactions;
  final List<TransactionTagEntity> transactionTags;
  final List<CreditEntity> credits;
  final List<CreditCardEntity> creditCards;
  final List<DebtEntity> debts;
  final List<CreditPaymentGroupEntity> creditPaymentGroups;
  final List<CreditPaymentScheduleEntity> creditPaymentSchedules;
  final List<Budget> budgets;
  final List<BudgetInstance> budgetInstances;
  final List<SavingGoal> savingGoals;
  final List<UpcomingPayment> upcomingPayments;
  final List<PaymentReminder> paymentReminders;
  final Profile? profile;
}

class RegistryConflictException implements Exception {
  RegistryConflictException(this.message);

  final String message;

  @override
  String toString() => 'RegistryConflictException: $message';
}

class _RemoteEntityMetadata {
  _RemoteEntityMetadata({
    required this.id,
    required this.entityType,
    required this.updatedAt,
    this.typeVersion,
    this.isDeleted = false,
  });

  final String id;
  final String entityType;
  final DateTime updatedAt;
  final int? typeVersion;
  final bool isDeleted;
}

class _RemoteRegistryPullResult {
  _RemoteRegistryPullResult({
    required this.metadata,
    required this.wasFallbackUsed,
  });

  final Map<String, Map<String, _RemoteEntityMetadata>> metadata;
  final bool wasFallbackUsed;
}

class _PushChunkResult {
  _PushChunkResult({required this.pushed, required this.conflicted});

  final List<db.OutboxEntryRow> pushed;
  final List<db.OutboxEntryRow> conflicted;
}
