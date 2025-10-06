import 'dart:math';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';

class RecomputeUserProgressUseCase {
  RecomputeUserProgressUseCase({
    required UserProgressRepository repository,
    required LevelPolicy levelPolicy,
    required AuthRepository authRepository,
    required LoggerService loggerService,
    DateTime Function()? clock,
  }) : _repository = repository,
       _levelPolicy = levelPolicy,
       _authRepository = authRepository,
       _logger = loggerService,
       _clock = clock ?? DateTime.now;

  final UserProgressRepository _repository;
  final LevelPolicy _levelPolicy;
  final AuthRepository _authRepository;
  final LoggerService _logger;
  final DateTime Function() _clock;

  Future<UserProgress> call() async {
    final int localCount = await _repository.countTransactions();
    final DateTime now = _clock().toUtc();

    final UserProgress progress = UserProgress(
      totalTx: localCount,
      level: _levelPolicy.levelFor(localCount),
      title: _levelPolicy.titleFor(_levelPolicy.levelFor(localCount)),
      nextThreshold: _levelPolicy.nextThreshold(localCount),
      updatedAt: now,
    );

    await _repository.cacheProgress(progress);

    final AuthUser? user = _authRepository.currentUser;
    if (user != null && !user.isAnonymous) {
      try {
        final ProgressSnapshot? remote = await _repository.fetchRemoteProgress(
          user.uid,
        );
        final int resolvedTotal = max(localCount, remote?.totalTx ?? 0);
        if (remote == null || remote.totalTx != resolvedTotal) {
          await _repository.saveRemoteProgress(
            uid: user.uid,
            totalTx: resolvedTotal,
            updatedAt: now,
          );
        }
      } catch (error, stackTrace) {
        _logger.logError('Failed to sync progress for ${user.uid}', error);
        _logger.logError('Progress sync stack: $stackTrace');
      }
    }

    return progress;
  }
}
