import 'dart:async';

import 'package:kopim/features/profile/data/remote/user_progress_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  UserProgressRepositoryImpl({
    required TransactionDao transactionDao,
    required UserProgressRemoteDataSource remoteDataSource,
  }) : _transactionDao = transactionDao,
       _remoteDataSource = remoteDataSource;

  final TransactionDao _transactionDao;
  final UserProgressRemoteDataSource _remoteDataSource;
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
    return _remoteDataSource.fetch(uid);
  }

  @override
  Future<void> saveRemoteProgress({
    required String uid,
    required int totalTx,
    required DateTime updatedAt,
  }) {
    return _remoteDataSource.upsert(
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
