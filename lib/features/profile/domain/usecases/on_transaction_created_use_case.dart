import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';

import 'recompute_user_progress_use_case.dart';

class OnTransactionCreatedUseCase {
  OnTransactionCreatedUseCase({
    required RecomputeUserProgressUseCase recomputeUserProgressUseCase,
    required LevelPolicy levelPolicy,
  }) : _recomputeUserProgressUseCase = recomputeUserProgressUseCase,
       _levelPolicy = levelPolicy;

  final RecomputeUserProgressUseCase _recomputeUserProgressUseCase;
  final LevelPolicy _levelPolicy;

  Future<ProfileCommandResult<UserProgress>> call() async {
    final ProfileCommandResult<UserProgress> progressResult =
        await _recomputeUserProgressUseCase();
    final UserProgress progress = progressResult.value;
    final List<ProfileDomainEvent> events = List<ProfileDomainEvent>.from(
      progressResult.events,
    );
    final int previousLevel = _levelPolicy.levelFor(
      progress.totalTx > 0 ? progress.totalTx - 1 : 0,
    );
    if (progress.level > previousLevel) {
      events.add(
        ProfileDomainEvent.levelIncreased(
          previousLevel: previousLevel,
          newLevel: progress.level,
          totalTransactions: progress.totalTx,
        ),
      );
    }
    return ProfileCommandResult<UserProgress>(value: progress, events: events);
  }
}
