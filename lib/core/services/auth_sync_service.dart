import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
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
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class AuthSyncService {
  AuthSyncService({
    required AppDatabase database,
    required OutboxDao outboxDao,
    required AccountDao accountDao,
    required CategoryDao categoryDao,
    required TransactionDao transactionDao,
    required BudgetDao budgetDao,
    required BudgetInstanceDao budgetInstanceDao,
    required SavingGoalDao savingGoalDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required BudgetRemoteDataSource budgetRemoteDataSource,
    required BudgetInstanceRemoteDataSource budgetInstanceRemoteDataSource,
    required SavingGoalRemoteDataSource savingGoalRemoteDataSource,
    required ProfileDao profileDao,
    required ProfileRemoteDataSource profileRemoteDataSource,
    required FirebaseFirestore firestore,
    required LoggerService loggerService,
    required AnalyticsService analyticsService,
  }) : _database = database,
       _outboxDao = outboxDao,
       _accountDao = accountDao,
       _categoryDao = categoryDao,
       _transactionDao = transactionDao,
       _budgetDao = budgetDao,
       _budgetInstanceDao = budgetInstanceDao,
       _savingGoalDao = savingGoalDao,
       _profileDao = profileDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _budgetRemoteDataSource = budgetRemoteDataSource,
       _budgetInstanceRemoteDataSource = budgetInstanceRemoteDataSource,
       _savingGoalRemoteDataSource = savingGoalRemoteDataSource,
       _profileRemoteDataSource = profileRemoteDataSource,
       _firestore = firestore,
       _logger = loggerService,
       _analyticsService = analyticsService;

  static const int _outboxBatchSize = 500;

  final AppDatabase _database;
  final OutboxDao _outboxDao;
  final AccountDao _accountDao;
  final CategoryDao _categoryDao;
  final TransactionDao _transactionDao;
  final BudgetDao _budgetDao;
  final BudgetInstanceDao _budgetInstanceDao;
  final SavingGoalDao _savingGoalDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final BudgetRemoteDataSource _budgetRemoteDataSource;
  final BudgetInstanceRemoteDataSource _budgetInstanceRemoteDataSource;
  final SavingGoalRemoteDataSource _savingGoalRemoteDataSource;
  final ProfileDao _profileDao;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final FirebaseFirestore _firestore;
  final LoggerService _logger;
  final AnalyticsService _analyticsService;

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
    try {
      preparedEntries = await _preparePendingEntries();
      await _applyOutboxToFirestore(user.uid, preparedEntries);
      final _RemoteSnapshot remoteSnapshot = await _fetchRemoteSnapshot(
        user.uid,
      );
      await _persistMergedState(
        remoteSnapshot: remoteSnapshot,
        processedEntries: preparedEntries,
        userId: user.uid,
      );
      await _analyticsService.logEvent('auth_sync_success', <String, dynamic>{
        ...syncContext,
        'pendingEntries': preparedEntries.length,
        'remoteAccounts': remoteSnapshot.accounts.length,
        'remoteCategories': remoteSnapshot.categories.length,
        'remoteTransactions': remoteSnapshot.transactions.length,
        'remoteBudgets': remoteSnapshot.budgets.length,
        'remoteBudgetInstances': remoteSnapshot.budgetInstances.length,
        'remoteSavingGoals': remoteSnapshot.savingGoals.length,
      });
      _logger.logInfo(
        'AuthSyncService: login sync completed for ${user.uid}. '
        'Accounts: ${remoteSnapshot.accounts.length}, '
        'Categories: ${remoteSnapshot.categories.length}, '
        'Transactions: ${remoteSnapshot.transactions.length}, '
        'Budgets: ${remoteSnapshot.budgets.length}, '
        'Savings goals: ${remoteSnapshot.savingGoals.length}.',
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'AuthSyncService: synchronization failed for ${user.uid}',
        error,
      );
      _analyticsService.reportError(error, stackTrace);
      await _outboxDao.resetAllToPending(
        preparedEntries.map((OutboxEntryRow entry) => entry.id),
      );
      throw const AuthFailure(
        code: 'sync-failed',
        message: 'Failed to synchronize data. Please try again later.',
      );
    } finally {
      _inProgress = false;
    }
  }

  Future<List<db.OutboxEntryRow>> _preparePendingEntries() async {
    return _database.transaction(() async {
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

  Future<void> _applyOutboxToFirestore(
    String userId,
    List<db.OutboxEntryRow> entries,
  ) async {
    if (entries.isEmpty) return;

    await _firestore.runTransaction((Transaction transaction) async {
      for (final OutboxEntryRow entry in entries) {
        final Map<String, dynamic> payload = _outboxDao.decodePayload(entry);
        final OutboxOperation operation = OutboxOperation.values.byName(
          entry.operation,
        );
        switch (entry.entityType) {
          case 'account':
            final AccountEntity account = AccountEntity.fromJson(payload);
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
          case 'transaction':
            final TransactionEntity transactionEntity =
                TransactionEntity.fromJson(payload);
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
            final Budget budget = Budget.fromJson(payload);
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
            final BudgetInstance instance = BudgetInstance.fromJson(payload);
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
            _savingGoalRemoteDataSource.upsertInTransaction(
              transaction,
              userId,
              goal,
            );
            break;
          default:
            throw UnsupportedError(
              'Unsupported outbox entity type ${entry.entityType}',
            );
        }
      }
    });
  }

  Future<_RemoteSnapshot> _fetchRemoteSnapshot(String userId) async {
    final List<List<Object>> results = await Future.wait(<Future<List<Object>>>[
      _accountRemoteDataSource.fetchAll(userId),
      _categoryRemoteDataSource.fetchAll(userId),
      _transactionRemoteDataSource.fetchAll(userId),
      _budgetRemoteDataSource.fetchAll(userId),
      _budgetInstanceRemoteDataSource.fetchAll(userId),
      _savingGoalRemoteDataSource.fetchAll(userId),
    ]);
    final Profile? profile = await _profileRemoteDataSource.fetch(userId);
    return _RemoteSnapshot(
      accounts: results[0] as List<AccountEntity>,
      categories: results[1] as List<Category>,
      transactions: results[2] as List<TransactionEntity>,
      budgets: results[3] as List<Budget>,
      budgetInstances: results[4] as List<BudgetInstance>,
      savingGoals: results[5] as List<SavingGoal>,
      profile: profile,
    );
  }

  Future<void> _persistMergedState({
    required _RemoteSnapshot remoteSnapshot,
    required List<db.OutboxEntryRow> processedEntries,
    required String userId,
  }) async {
    final List<int> processedIds = processedEntries
        .map((OutboxEntryRow entry) => entry.id)
        .toList();
    await _database.transaction(() async {
      if (processedIds.isNotEmpty) {
        await _outboxDao.markBatchAsSent(processedIds);
        await _outboxDao.clearSent();
      }

      final List<AccountEntity> localAccounts = await _accountDao
          .getAllAccounts();
      final List<Category> localCategories = await _categoryDao
          .getAllCategories();
      final List<TransactionEntity> localTransactions = await _transactionDao
          .getAllTransactions();
      final List<Budget> localBudgets = await _budgetDao.getAllBudgets();
      final List<BudgetInstance> localBudgetInstances = await _budgetInstanceDao
          .getAllInstances();
      final List<SavingGoal> localSavingGoals = await _savingGoalDao.getGoals(
        includeArchived: true,
      );

      final List<AccountEntity> mergedAccounts = _mergeEntities<AccountEntity>(
        local: localAccounts,
        remote: remoteSnapshot.accounts,
        getId: (AccountEntity entity) => entity.id,
        getUpdatedAt: (AccountEntity entity) => entity.updatedAt,
      );
      final List<Category> mergedCategories = _mergeEntities<Category>(
        local: localCategories,
        remote: remoteSnapshot.categories,
        getId: (Category entity) => entity.id,
        getUpdatedAt: (Category entity) => entity.updatedAt,
      );
      final List<TransactionEntity> mergedTransactions =
          _mergeEntities<TransactionEntity>(
            local: localTransactions,
            remote: remoteSnapshot.transactions,
            getId: (TransactionEntity entity) => entity.id,
            getUpdatedAt: (TransactionEntity entity) => entity.updatedAt,
          );
      final List<Budget> mergedBudgets = _mergeEntities<Budget>(
        local: localBudgets,
        remote: remoteSnapshot.budgets,
        getId: (Budget entity) => entity.id,
        getUpdatedAt: (Budget entity) => entity.updatedAt,
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

      await _accountDao.upsertAll(mergedAccounts);
      await _categoryDao.upsertAll(mergedCategories);
      await _transactionDao.upsertAll(mergedTransactions);
      await _budgetDao.upsertAll(mergedBudgets);
      await _budgetInstanceDao.upsertAll(mergedBudgetInstances);
      await _savingGoalDao.upsertAll(mergedSavingGoals);

      final Profile? profile = _mergeProfile(
        await _profileDao.getProfile(userId),
        remoteSnapshot.profile,
      );
      if (profile != null) {
        await _profileDao.upsertInTransaction(profile);
      }
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
}

class _RemoteSnapshot {
  _RemoteSnapshot({
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.budgets,
    required this.budgetInstances,
    required this.savingGoals,
    required this.profile,
  });

  final List<AccountEntity> accounts;
  final List<Category> categories;
  final List<TransactionEntity> transactions;
  final List<Budget> budgets;
  final List<BudgetInstance> budgetInstances;
  final List<SavingGoal> savingGoals;
  final Profile? profile;
}
