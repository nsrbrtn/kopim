import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class SyncService {
  SyncService({
    required OutboxDao outboxDao,
    required AccountRemoteDataSource accountRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    FirebaseAuth? firebaseAuth,
    Connectivity? connectivity,
  }) : _outboxDao = outboxDao,
       _accountRemoteDataSource = accountRemoteDataSource,
       _categoryRemoteDataSource = categoryRemoteDataSource,
       _transactionRemoteDataSource = transactionRemoteDataSource,
       _auth = firebaseAuth ?? FirebaseAuth.instance,
       _connectivity = connectivity ?? Connectivity();

  final OutboxDao _outboxDao;
  final AccountRemoteDataSource _accountRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
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
    _outboxSubscription = _outboxDao.watchPending().listen((entries) {
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
    final user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    try {
      final pendingEntries = await _outboxDao.fetchPending(limit: 100);
      if (pendingEntries.isEmpty) return;

      for (final entry in pendingEntries) {
        await _syncEntry(user.uid, entry);
      }

      await _outboxDao.pruneSent();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncEntry(String userId, db.OutboxEntryRow entry) async {
    final prepared = await _outboxDao.prepareForSend(entry);
    try {
      final payload = _outboxDao.decodePayload(prepared);
      final operation = OutboxOperation.values.byName(prepared.operation);

      switch (prepared.entityType) {
        case 'account':
          final account = AccountEntity.fromJson(payload);
          await _dispatchAccount(userId, account, operation);
          break;
        case 'category':
          final category = Category.fromJson(payload);
          await _dispatchCategory(userId, category, operation);
          break;
        case 'transaction':
          final transaction = TransactionEntity.fromJson(payload);
          await _dispatchTransaction(userId, transaction, operation);
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

  Future<void> _handleConnectivity(List<ConnectivityResult> results) async {
    final isNowOnline = results.any(
      (result) => result != ConnectivityResult.none,
    );
    final changed = isNowOnline != _isOnline;
    _isOnline = isNowOnline;
    if (_isOnline && changed) {
      await syncPending();
    }
  }
}
