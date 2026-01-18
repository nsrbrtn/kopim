import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/outbox/outbox_payload_normalizer.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/remote/debt_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
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

class SyncService {
  SyncService({
    required OutboxDao outboxDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
    required TransactionTagRemoteDataSource transactionTagRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required DebtRemoteDataSource debtRemoteDataSource,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource,
    required SavingGoalRemoteDataSource savingGoalRemoteDataSource,
    required UpcomingPaymentRemoteDataSource upcomingPaymentRemoteDataSource,
    required PaymentReminderRemoteDataSource paymentReminderRemoteDataSource,
    required FirebaseAuth firebaseAuth,
    Connectivity? connectivity,
    OutboxPayloadNormalizer payloadNormalizer = const OutboxPayloadNormalizer(),
  }) : _outboxDao = outboxDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _tagRemoteDataSource = tagRemoteDataSource,
       _transactionTagRemoteDataSource = transactionTagRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _debtRemoteDataSource = debtRemoteDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _budgetRemoteDataSource = budgetRemoteDataSource,
       _budgetInstanceRemoteDataSource = budgetInstanceRemoteDataSource,
       _savingGoalRemoteDataSource = savingGoalRemoteDataSource,
       _upcomingPaymentRemoteDataSource = upcomingPaymentRemoteDataSource,
       _paymentReminderRemoteDataSource = paymentReminderRemoteDataSource,
       _auth = firebaseAuth,
       _connectivity = connectivity ?? Connectivity(),
       _payloadNormalizer = payloadNormalizer;

  final OutboxDao _outboxDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TagRemoteDataSource _tagRemoteDataSource;
  final TransactionTagRemoteDataSource _transactionTagRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final DebtRemoteDataSource _debtRemoteDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final BudgetInstanceRemoteDataSource _budgetInstanceRemoteDataSource;
  final SavingGoalRemoteDataSource _savingGoalRemoteDataSource;
  final UpcomingPaymentRemoteDataSource _upcomingPaymentRemoteDataSource;
  final PaymentReminderRemoteDataSource _paymentReminderRemoteDataSource;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;
  final OutboxPayloadNormalizer _payloadNormalizer;

  StreamSubscription<List<db.OutboxEntryRow>>? _outboxSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  bool _isOnline = false;
  bool _isSyncing = false;
  bool _initialized = false;
  SyncStatus _status = SyncStatus.offline;

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get status => _status;

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

  Future<void> dispose() async {
    await _outboxSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _statusController.close();
  }

  Future<void> syncPending() async {
    _updateStatus();
    if (_isSyncing || !_isOnline) return;
    final User? user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    _updateStatus();
    try {
      final List<db.OutboxEntryRow> pendingEntries = await _outboxDao
          .fetchPending(limit: 100);
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

  Future<void> _syncEntry(String userId, db.OutboxEntryRow entry) async {
    final db.OutboxEntryRow prepared = await _outboxDao.prepareForSend(entry);
    try {
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
        case 'debt':
          final DebtEntity debt = _applyDebtMoney(
            DebtEntity.fromJson(payload),
            payload,
          );
          await _dispatchDebt(userId, debt, operation);
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
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'sync_entry_failed',
      );
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
        ? (_isSyncing ? SyncStatus.syncing : SyncStatus.upToDate)
        : (!_isOnline
              ? SyncStatus.offline
              : (_isSyncing ? SyncStatus.syncing : SyncStatus.upToDate));
    if (nextStatus == _status) return;
    _status = nextStatus;
    if (_statusController.isClosed) return;
    _statusController.add(nextStatus);
  }
}
