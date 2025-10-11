import 'dart:math';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';

class RecomputeUserProgressUseCase {
  RecomputeUserProgressUseCase({
    required UserProgressRepository repository,
    required LevelPolicy levelPolicy,
    required AuthRepository authRepository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _levelPolicy = levelPolicy,
       _authRepository = authRepository,
       _clock = clock ?? DateTime.now;

  final UserProgressRepository _repository;
  final LevelPolicy _levelPolicy;
  final AuthRepository _authRepository;
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
        events.add(
          ProfileDomainEvent.progressSyncFailed(
            uid: user.uid,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }

    return ProfileCommandResult<UserProgress>(value: progress, events: events);
  }
}
