import 'dart:async';
import 'dart:math';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/profile/domain/services/profile_sync_error_reporter.dart';

class RecomputeUserProgressUseCase {
  RecomputeUserProgressUseCase({
    required UserProgressRepository repository,
    required LevelPolicy levelPolicy,
    required AuthRepository authRepository,
    required ProfileSyncErrorReporter syncErrorReporter,
    DateTime Function()? clock,
  }) : _repository = repository,
       _levelPolicy = levelPolicy,
       _authRepository = authRepository,
       _syncErrorReporter = syncErrorReporter,
       _clock = clock ?? DateTime.now;

  final UserProgressRepository _repository;
  final LevelPolicy _levelPolicy;
  final AuthRepository _authRepository;
  final ProfileSyncErrorReporter _syncErrorReporter;
  final DateTime Function() _clock;

  Future<ProfileCommandResult<UserProgress>> call() async {
    final List<ProfileDomainEvent> events = <ProfileDomainEvent>[];
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
      unawaited(_syncRemoteProgress(user.uid, localCount, now));
    }

    return ProfileCommandResult<UserProgress>(value: progress, events: events);
  }

  Future<void> _syncRemoteProgress(
    String uid,
    int localCount,
    DateTime now,
  ) async {
    try {
      final ProgressSnapshot? remote = await _repository.fetchRemoteProgress(
        uid,
      );
      final int resolvedTotal = max(localCount, remote?.totalTx ?? 0);
      if (remote == null || remote.totalTx != resolvedTotal) {
        await _repository.saveRemoteProgress(
          uid: uid,
          totalTx: resolvedTotal,
          updatedAt: now,
        );
      }
    } catch (error, stackTrace) {
      _syncErrorReporter.reportProgressSyncError(
        uid: uid,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
