import 'package:kopim/features/profile/domain/entities/user_progress.dart';

class ProgressSnapshot {
  const ProgressSnapshot({required this.totalTx, required this.updatedAt});

  final int totalTx;
  final DateTime updatedAt;
}

abstract class UserProgressRepository {
  Stream<int> watchTransactionCount();

  Future<int> countTransactions();

  Future<ProgressSnapshot?> fetchRemoteProgress(String uid);

  Future<void> saveRemoteProgress({
    required String uid,
    required int totalTx,
    required DateTime updatedAt,
  });

  Future<void> cacheProgress(UserProgress progress);

  Stream<UserProgress?> watchCachedProgress();
}
