import 'package:kopim/features/profile/domain/entities/user_progress.dart';

import 'recompute_user_progress_use_case.dart';

class OnTransactionDeletedUseCase {
  OnTransactionDeletedUseCase({
    required RecomputeUserProgressUseCase recomputeUserProgressUseCase,
  }) : _recomputeUserProgressUseCase = recomputeUserProgressUseCase;

  final RecomputeUserProgressUseCase _recomputeUserProgressUseCase;

  Future<UserProgress> call() {
    return _recomputeUserProgressUseCase();
  }
}
