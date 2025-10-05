import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class SyncService {
  SyncService({
    required OutboxDao outboxDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource,
    required SavingGoalRemoteDataSource savingGoalRemoteDataSource,
    FirebaseAuth? firebaseAuth,
    Connectivity? connectivity,
  }) : _outboxDao = outboxDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _budgetRemoteDataSource = budgetRemoteDataSource,
       _budgetInstanceRemoteDataSource = budgetInstanceRemoteDataSource,
       _savingGoalRemoteDataSource = savingGoalRemoteDataSource,
       _auth = firebaseAuth ?? FirebaseAuth.instance,
       _connectivity = connectivity ?? Connectivity();

  final OutboxDao _outboxDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final BudgetInstanceRemoteDataSource _budgetInstanceRemoteDataSource;
  final SavingGoalRemoteDataSource _savingGoalRemoteDataSource;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;

  StreamSubscription<List<db.OutboxEntryRow>>? _outboxSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = false;
  bool _isSyncing = false;
  bool _initialized = false;

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
  }

  Future<void> syncPending() async {
    if (_isSyncing || !_isOnline) return;
    final User? user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
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
    }
  }

  Future<void> _syncEntry(String userId, db.OutboxEntryRow entry) async {
    final db.OutboxEntryRow prepared = await _outboxDao.prepareForSend(entry);
    try {
      final Map<String, dynamic> payload = _outboxDao.decodePayload(prepared);
      final OutboxOperation operation = OutboxOperation.values.byName(
        prepared.operation,
      );

      switch (prepared.entityType) {
        case 'account':
          final AccountEntity account = AccountEntity.fromJson(payload);
          await _dispatchAccount(userId, account, operation);
          break;
        case 'category':
          final Category category = Category.fromJson(payload);
          await _dispatchCategory(userId, category, operation);
          break;
        case 'transaction':
          final TransactionEntity transaction = TransactionEntity.fromJson(
            payload,
          );
          await _dispatchTransaction(userId, transaction, operation);
          break;
        case 'profile':
          final Profile profile = Profile.fromJson(payload);
          await _dispatchProfile(userId, profile, operation);
          break;
        case 'budget':
          final Budget budget = Budget.fromJson(payload);
          await _dispatchBudget(userId, budget, operation);
          break;
        case 'budget_instance':
          final BudgetInstance instance = BudgetInstance.fromJson(payload);
          await _dispatchBudgetInstance(userId, instance, operation);
          break;
        case 'saving_goal':
          final SavingGoal goal = SavingGoal.fromJson(payload);
          await _dispatchSavingGoal(userId, goal, operation);
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

  Future<void> _handleConnectivity(List<ConnectivityResult> results) async {
    final bool isNowOnline = results.any(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
    final bool changed = isNowOnline != _isOnline;
    _isOnline = isNowOnline;
    if (_isOnline && changed) {
      await syncPending();
    }
  }
}
