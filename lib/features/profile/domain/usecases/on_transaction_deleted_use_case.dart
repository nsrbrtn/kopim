import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';

import 'recompute_user_progress_use_case.dart';

class OnTransactionDeletedUseCase {
  OnTransactionDeletedUseCase({
    required RecomputeUserProgressUseCase recomputeUserProgressUseCase,
  }) : _recomputeUserProgressUseCase = recomputeUserProgressUseCase;

  final RecomputeUserProgressUseCase _recomputeUserProgressUseCase;

  Future<ProfileCommandResult<UserProgress>> call() {
    return _recomputeUserProgressUseCase();
  }
}
