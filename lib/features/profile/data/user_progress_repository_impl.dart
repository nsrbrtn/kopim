import 'dart:async';

import 'package:kopim/features/profile/data/remote/user_progress_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  UserProgressRepositoryImpl({
    required TransactionDao transactionDao,
    UserProgressRemoteDataSource? remoteDataSource,
    bool Function(String uid)? canWriteRemotely,
  }) : _transactionDao = transactionDao,
       _remoteDataSource = remoteDataSource,
       _canWriteRemotely = canWriteRemotely ?? ((String _) => true);

  final TransactionDao _transactionDao;
  final UserProgressRemoteDataSource? _remoteDataSource;
  final bool Function(String uid) _canWriteRemotely;
  final StreamController<UserProgress?> _cacheController =
      StreamController<UserProgress?>.broadcast();

  @override
  Stream<int> watchTransactionCount() {
    return _transactionDao.watchActiveCount();
  }

  @override
  Future<int> countTransactions() {
    return _transactionDao.countActiveTransactions();
  }

  @override
  Future<ProgressSnapshot?> fetchRemoteProgress(String uid) {
    final UserProgressRemoteDataSource? remoteDataSource = _remoteDataSource;
    if (remoteDataSource == null || !_canWriteRemotely(uid)) {
      return Future<ProgressSnapshot?>.value(null);
    }
    return remoteDataSource.fetch(uid);
  }

  @override
  Future<void> saveRemoteProgress({
    required String uid,
    required int totalTx,
    required DateTime updatedAt,
  }) {
    final UserProgressRemoteDataSource? remoteDataSource = _remoteDataSource;
    if (remoteDataSource == null || !_canWriteRemotely(uid)) {
      return Future<void>.value();
    }
    return remoteDataSource.upsert(
      uid: uid,
      totalTx: totalTx,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> cacheProgress(UserProgress progress) async {
    if (_cacheController.isClosed) {
      return;
    }
    _cacheController.add(progress);
  }

  @override
  Stream<UserProgress?> watchCachedProgress() {
    return _cacheController.stream;
  }

  void dispose() {
    _cacheController.close();
  }
}
