import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/services/firebase_runtime_guard.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/outbox/outbox_payload_normalizer.dart';
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/services/sync/sync_conflict_types.dart';
import 'package:kopim/core/services/sync/sync_ownership_guard.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_card_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_payment_group_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_payment_schedule_remote_data_source.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/tags/data/sources/remote/tag_remote_data_source.dart';
import 'package:kopim/features/tags/data/sources/remote/transaction_tag_remote_data_source.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/core/services/sync_status.dart';
import 'package:kopim/core/services/auth_sync_service.dart';

abstract class SyncService {
  Future<void> initialize();
  Future<void> dispose();
  Future<void> syncPending();
  Future<SyncActionResult> triggerSync();
  Future<IncrementalSyncStatus> triggerManualSync();

  SyncStatus get status;
  Stream<SyncStatus> get statusStream;
}

class FirebaseSyncService implements SyncService {
  FirebaseSyncService({
    required OutboxDao outboxDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
    required TransactionTagRemoteDataSource transactionTagRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required CreditRemoteDataSource creditRemoteDataSource,
    required CreditCardRemoteDataSource creditCardRemoteDataSource,
    required DebtRemoteDataSource debtRemoteDataSource,
    required CreditPaymentGroupRemoteDataSource
    creditPaymentGroupRemoteDataSource,
    required CreditPaymentScheduleRemoteDataSource
    creditPaymentScheduleRemoteDataSource,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource,
    required SavingGoalRemoteDataSource savingGoalRemoteDataSource,
    required UpcomingPaymentRemoteDataSource upcomingPaymentRemoteDataSource,
    required PaymentReminderRemoteDataSource paymentReminderRemoteDataSource,
    required FirebaseAuth firebaseAuth,
    required AuthSyncService authSyncService,
    required SyncOwnershipGuard syncOwnershipGuard,
    required SyncConflictDao syncConflictDao,
    Connectivity? connectivity,
    OutboxPayloadNormalizer payloadNormalizer = const OutboxPayloadNormalizer(),
  }) : _outboxDao = outboxDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _tagRemoteDataSource = tagRemoteDataSource,
       _transactionTagRemoteDataSource = transactionTagRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _creditRemoteDataSource = creditRemoteDataSource,
       _creditCardRemoteDataSource = creditCardRemoteDataSource,
       _debtRemoteDataSource = debtRemoteDataSource,
       _creditPaymentGroupRemoteDataSource = creditPaymentGroupRemoteDataSource,
       _creditPaymentScheduleRemoteDataSource =
           creditPaymentScheduleRemoteDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _budgetRemoteDataSource = budgetRemoteDataSource,
       _budgetInstanceRemoteDataSource = budgetInstanceRemoteDataSource,
       _savingGoalRemoteDataSource = savingGoalRemoteDataSource,
       _upcomingPaymentRemoteDataSource = upcomingPaymentRemoteDataSource,
       _paymentReminderRemoteDataSource = paymentReminderRemoteDataSource,
       _auth = firebaseAuth,
       _connectivity = connectivity ?? Connectivity(),
       _authSyncService = authSyncService,
       _syncOwnershipGuard = syncOwnershipGuard,
       _syncConflictDao = syncConflictDao,
       _payloadNormalizer = payloadNormalizer;

  static const Duration _staleSendingRecoveryWindow = Duration(minutes: 5);

  final OutboxDao _outboxDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TagRemoteDataSource _tagRemoteDataSource;
  final TransactionTagRemoteDataSource _transactionTagRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final CreditRemoteDataSource _creditRemoteDataSource;
  final CreditCardRemoteDataSource _creditCardRemoteDataSource;
  final DebtRemoteDataSource _debtRemoteDataSource;
  final CreditPaymentGroupRemoteDataSource _creditPaymentGroupRemoteDataSource;
  final CreditPaymentScheduleRemoteDataSource
  _creditPaymentScheduleRemoteDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final BudgetInstanceRemoteDataSource _budgetInstanceRemoteDataSource;
  final SavingGoalRemoteDataSource _savingGoalRemoteDataSource;
  final UpcomingPaymentRemoteDataSource _upcomingPaymentRemoteDataSource;
  final PaymentReminderRemoteDataSource _paymentReminderRemoteDataSource;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;
  final AuthSyncService _authSyncService;
  final SyncOwnershipGuard _syncOwnershipGuard;
  final SyncConflictDao _syncConflictDao;
  final OutboxPayloadNormalizer _payloadNormalizer;

  StreamSubscription<List<db.OutboxEntryRow>>? _outboxSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  bool _isOnline = false;
  bool _isSyncing = false;
  bool _isManualSyncing = false;
  bool _initialized = false;
  SyncStatus _status = SyncStatus.offline;

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  @override
  SyncStatus get status => _status;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _handleConnectivity(await _connectivity.checkConnectivity());
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivity,
    );
    _outboxSubscription = _outboxDao.watchPending().listen((
      List<db.OutboxEntryRow> entries,
    ) {
      if (entries.isNotEmpty) {
        scheduleMicrotask(syncPending);
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _outboxSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _statusController.close();
  }

  @override
  Future<void> syncPending() async {
    _updateStatus();
    if (_isSyncing || !_isOnline) return;
    final User? user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    _updateStatus();
    try {
      await _outboxDao.resetStaleSendingToPending(
        cutoff: DateTime.now().subtract(_staleSendingRecoveryWindow),
      );
      await _outboxDao.deleteByEntityType('category_group');
      final OutboxPendingPlan plan = await _outboxDao.fetchPendingPlan(
        limit: 100,
      );
      await _recordDependencyCycle(plan.blockedByDependencyCycle);
      final List<db.OutboxEntryRow> pendingEntries = plan.dispatchableEntries;
      if (pendingEntries.isEmpty) return;

      for (final db.OutboxEntryRow entry in pendingEntries) {
        await _syncEntry(user.uid, entry);
      }

      await _outboxDao.pruneSent();
    } finally {
      _isSyncing = false;
      _updateStatus();
    }
  }

  @override
  Future<SyncActionResult> triggerSync() async {
    await initialize();
    if (!_isOnline) return SyncActionResult.offline;
    final User? user = _auth.currentUser;
    if (user == null) return SyncActionResult.unauthenticated;
    if (_isSyncing) return SyncActionResult.alreadySyncing;
    final bool hasPending = (await _outboxDao.fetchPending(
      limit: 1,
    )).isNotEmpty;
    if (!hasPending) return SyncActionResult.noChanges;
    await syncPending();
    return SyncActionResult.synced;
  }

  @override
  Future<IncrementalSyncStatus> triggerManualSync() async {
    await initialize();
    if (!_isOnline) {
      return const IncrementalSyncStatus(result: IncrementalSyncResult.offline);
    }
    final User? user = _auth.currentUser;
    if (user == null) {
      return const IncrementalSyncStatus(
        result: IncrementalSyncResult.unauthenticated,
      );
    }
    if (_isManualSyncing || _isSyncing) {
      return const IncrementalSyncStatus(
        result: IncrementalSyncResult.alreadySyncing,
      );
    }

    _isManualSyncing = true;
    _updateStatus();
    try {
      await syncPending();
      final OutboxPendingPlan cyclePlan = await _outboxDao.fetchPendingPlan(
        limit: 1,
      );
      if (cyclePlan.hasDependencyCycle) {
        return const IncrementalSyncStatus(
          result: IncrementalSyncResult.dependencyCycleDetected,
        );
      }

      final List<db.OutboxEntryRow> pending = await _outboxDao.fetchPending(
        limit: 1,
      );
      if (pending.isNotEmpty) {
        return const IncrementalSyncStatus(
          result: IncrementalSyncResult.pushFailed,
        );
      }

      final int pulledCount = await _authSyncService.performIncrementalSync(
        user.uid,
      );
      if (pulledCount == 0) {
        return const IncrementalSyncStatus(
          result: IncrementalSyncResult.noChanges,
        );
      }

      return IncrementalSyncStatus(
        result: IncrementalSyncResult.success,
        pulledCount: pulledCount,
      );
    } catch (e, stackTrace) {
      if (e is StateError && e.message == 'full_sync_required') {
        return const IncrementalSyncStatus(
          result: IncrementalSyncResult.error,
          errorMessage: 'full_sync_required',
        );
      }
      if (!AppRuntimeConfig.isOffline && hasFirebaseAppsSafely()) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'manual_sync_failed',
        );
      }
      return IncrementalSyncStatus(
        result: IncrementalSyncResult.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isManualSyncing = false;
      _updateStatus();
    }
  }

  Future<void> _syncEntry(String userId, db.OutboxEntryRow entry) async {
    if (userId.startsWith('local-') || entry.ownerUid != userId) {
      throw StateError(
        'Security violation: attempting to sync entry for owner ${entry.ownerUid} under session $userId',
      );
    }
    final db.OutboxEntryRow prepared = await _outboxDao.prepareForSend(entry);
    try {
      await _syncOwnershipGuard.ensureOutboxEntryCanBePushed(
        currentCloudUid: userId,
        entryOwnerUid: prepared.ownerUid,
        entityType: prepared.entityType,
        entityId: prepared.entityId,
        payload: prepared.payload,
      );
      final Map<String, dynamic> payload = _payloadNormalizer.normalize(
        prepared.entityType,
        _outboxDao.decodePayload(prepared),
      );
      final OutboxOperation operation = OutboxOperation.values.byName(
        prepared.operation,
      );

      switch (prepared.entityType) {
        case 'account':
          final AccountEntity account = _applyAccountMoney(
            AccountEntity.fromJson(payload),
            payload,
          );
          await _dispatchAccount(userId, account, operation);
          break;
        case 'category':
          final Category category = Category.fromJson(payload);
          await _dispatchCategory(userId, category, operation);
          break;
        case 'tag':
          final TagEntity tag = TagEntity.fromJson(payload);
          await _dispatchTag(userId, tag, operation);
          break;
        case 'transaction_tag':
          final TransactionTagEntity link = TransactionTagEntity.fromJson(
            payload,
          );
          await _dispatchTransactionTag(userId, link, operation);
          break;
        case 'transaction':
          final TransactionEntity transaction = _applyTransactionMoney(
            TransactionEntity.fromJson(payload),
            payload,
          );
          await _dispatchTransaction(userId, transaction, operation);
          break;
        case 'credit':
          final CreditEntity credit = _applyCreditMoney(
            CreditEntity.fromJson(payload),
            payload,
          );
          await _dispatchCredit(userId, credit, operation);
          break;
        case 'credit_card':
          final CreditCardEntity creditCard = _applyCreditCardMoney(
            CreditCardEntity.fromJson(payload),
            payload,
          );
          await _dispatchCreditCard(userId, creditCard, operation);
          break;
        case 'debt':
          final DebtEntity debt = _applyDebtMoney(
            DebtEntity.fromJson(payload),
            payload,
          );
          await _dispatchDebt(userId, debt, operation);
          break;
        case 'credit_payment_group':
          final CreditPaymentGroupEntity group = _groupFromPayload(payload);
          await _dispatchCreditPaymentGroup(userId, group, operation);
          break;
        case 'credit_payment_schedule':
          final CreditPaymentScheduleEntity schedule = _scheduleFromPayload(
            payload,
          );
          await _dispatchCreditPaymentSchedule(userId, schedule, operation);
          break;
        case 'profile':
          final Profile profile = Profile.fromJson(payload);
          await _dispatchProfile(userId, profile, operation);
          break;
        case 'budget':
          final Budget budget = _applyBudgetMoney(
            Budget.fromJson(payload),
            payload,
          );
          await _dispatchBudget(userId, budget, operation);
          break;
        case 'budget_instance':
          final BudgetInstance instance = _applyBudgetInstanceMoney(
            BudgetInstance.fromJson(payload),
            payload,
          );
          await _dispatchBudgetInstance(userId, instance, operation);
          break;
        case 'saving_goal':
          final SavingGoal goal = SavingGoal.fromJson(payload);
          await _dispatchSavingGoal(userId, goal, operation);
          break;
        case 'upcoming_payment':
          final UpcomingPayment payment = _applyUpcomingPaymentMoney(
            UpcomingPayment.fromJson(payload),
            payload,
          );
          await _dispatchUpcomingPayment(userId, payment, operation);
          break;
        case 'payment_reminder':
          final PaymentReminder reminder = _applyPaymentReminderMoney(
            PaymentReminder.fromJson(payload),
            payload,
          );
          await _dispatchPaymentReminder(userId, reminder, operation);
          break;
        default:
          throw UnsupportedError(
            'Unsupported entity type: ${prepared.entityType}',
          );
      }

      await _outboxDao.markAsSent(prepared.id);
    } catch (error, stackTrace) {
      await _outboxDao.markAsFailed(prepared.id, error.toString());
      if (!AppRuntimeConfig.isOffline && hasFirebaseAppsSafely()) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'sync_entry_failed',
        );
      }
    }
  }

  Future<void> _dispatchAccount(
    String userId,
    AccountEntity account,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _accountRemoteDataSource.delete(
        userId,
        account.copyWith(isDeleted: true),
      );
    }
    return _accountRemoteDataSource.upsert(
      userId,
      account.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchCategory(
    String userId,
    Category category,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _categoryRemoteDataSource.delete(
        userId,
        category.copyWith(isDeleted: true),
      );
    }
    return _categoryRemoteDataSource.upsert(
      userId,
      category.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchTag(
    String userId,
    TagEntity tag,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _tagRemoteDataSource.delete(userId, tag.copyWith(isDeleted: true));
    }
    return _tagRemoteDataSource.upsert(userId, tag.copyWith(isDeleted: false));
  }

  Future<void> _dispatchTransactionTag(
    String userId,
    TransactionTagEntity link,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _transactionTagRemoteDataSource.delete(
        userId,
        link.copyWith(isDeleted: true),
      );
    }
    return _transactionTagRemoteDataSource.upsert(
      userId,
      link.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchTransaction(
    String userId,
    TransactionEntity transaction,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _transactionRemoteDataSource.delete(
        userId,
        transaction.copyWith(isDeleted: true),
      );
    }
    return _transactionRemoteDataSource.upsert(
      userId,
      transaction.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchDebt(
    String userId,
    DebtEntity debt,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _debtRemoteDataSource.delete(
        userId,
        debt.copyWith(isDeleted: true),
      );
    }
    return _debtRemoteDataSource.upsert(
      userId,
      debt.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchCreditPaymentGroup(
    String userId,
    CreditPaymentGroupEntity group,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _creditPaymentGroupRemoteDataSource.delete(
        userId,
        group.copyWith(isDeleted: true),
      );
    }
    return _creditPaymentGroupRemoteDataSource.upsert(
      userId,
      group.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchCreditPaymentSchedule(
    String userId,
    CreditPaymentScheduleEntity schedule,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _creditPaymentScheduleRemoteDataSource.delete(
        userId,
        schedule.copyWith(isDeleted: true),
      );
    }
    return _creditPaymentScheduleRemoteDataSource.upsert(
      userId,
      schedule.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchCredit(
    String userId,
    CreditEntity credit,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _creditRemoteDataSource.delete(
        userId,
        credit.copyWith(isDeleted: true),
      );
    }
    return _creditRemoteDataSource.upsert(
      userId,
      credit.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchCreditCard(
    String userId,
    CreditCardEntity creditCard,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _creditCardRemoteDataSource.delete(
        userId,
        creditCard.copyWith(isDeleted: true),
      );
    }
    return _creditCardRemoteDataSource.upsert(
      userId,
      creditCard.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchProfile(
    String userId,
    Profile profile,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      // Profiles currently support only upsert semantics.
      return Future<void>.value();
    }
    return _profileRemoteDataSource.upsert(userId, profile);
  }

  Future<void> _dispatchBudget(
    String userId,
    Budget budget,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _budgetRemoteDataSource.delete(
        userId,
        budget.copyWith(isDeleted: true),
      );
    }
    return _budgetRemoteDataSource.upsert(
      userId,
      budget.copyWith(isDeleted: false),
    );
  }

  Future<void> _dispatchBudgetInstance(
    String userId,
    BudgetInstance instance,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _budgetInstanceRemoteDataSource.delete(userId, instance);
    }
    return _budgetInstanceRemoteDataSource.upsert(userId, instance);
  }

  Future<void> _dispatchSavingGoal(
    String userId,
    SavingGoal goal,
    OutboxOperation operation,
  ) {
    return _savingGoalRemoteDataSource.upsert(userId, goal);
  }

  Future<void> _dispatchUpcomingPayment(
    String userId,
    UpcomingPayment payment,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _upcomingPaymentRemoteDataSource.delete(userId, payment);
    }
    return _upcomingPaymentRemoteDataSource.upsert(userId, payment);
  }

  Future<void> _dispatchPaymentReminder(
    String userId,
    PaymentReminder reminder,
    OutboxOperation operation,
  ) {
    if (operation == OutboxOperation.delete) {
      return _paymentReminderRemoteDataSource.delete(userId, reminder);
    }
    return _paymentReminderRemoteDataSource.upsert(userId, reminder);
  }

  AccountEntity _applyAccountMoney(
    AccountEntity account,
    Map<String, dynamic> payload,
  ) {
    return account.copyWith(
      balanceMinor: _readBigInt(payload['balanceMinor']),
      openingBalanceMinor: _readBigInt(payload['openingBalanceMinor']),
      currencyScale: _readInt(payload['currencyScale']),
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

  DateTime? _coerceDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }

  Future<void> _handleConnectivity(List<ConnectivityResult> results) async {
    final bool isNowOnline = results.any(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
    final bool changed = isNowOnline != _isOnline;
    _isOnline = isNowOnline;
    _updateStatus();
    if (_isOnline && changed) {
      await syncPending();
    }
  }

  void _updateStatus() {
    final SyncStatus nextStatus = kIsWeb
        ? ((_isSyncing || _isManualSyncing)
              ? SyncStatus.syncing
              : SyncStatus.upToDate)
        : (!_isOnline
              ? SyncStatus.offline
              : ((_isSyncing || _isManualSyncing)
                    ? SyncStatus.syncing
                    : SyncStatus.upToDate));
    if (nextStatus == _status) return;
    _status = nextStatus;
    if (_statusController.isClosed) return;
    _statusController.add(nextStatus);
  }

  Future<void> _recordDependencyCycle(
    List<db.OutboxEntryRow> blockedEntries,
  ) async {
    if (blockedEntries.isEmpty) {
      return;
    }
    final String blockedIds = blockedEntries
        .map((db.OutboxEntryRow entry) => entry.id)
        .join(',');
    await _syncConflictDao.upsertConflict(
      conflictKey: 'outbox_cycle:$blockedIds',
      entityType: 'outbox',
      entityId: blockedIds,
      conflictType: SyncConflictType.outboxDependencyCycle.value,
      severity: SyncConflictSeverity.blocking.value,
      status: SyncConflictStatus.pending.value,
      metadataJson: jsonEncode(<String, Object>{
        'blockedOutboxIds': blockedEntries
            .map((db.OutboxEntryRow entry) => entry.id)
            .toList(growable: false),
        'entityTypes': blockedEntries
            .map((db.OutboxEntryRow entry) => entry.entityType)
            .toList(growable: false),
      }),
    );
  }
}
