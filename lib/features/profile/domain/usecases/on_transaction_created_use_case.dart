import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';

import 'recompute_user_progress_use_case.dart';

class OnTransactionCreatedUseCase {
  OnTransactionCreatedUseCase({
    required RecomputeUserProgressUseCase recomputeUserProgressUseCase,
    required LevelPolicy levelPolicy,
    required AnalyticsService analyticsService,
  }) : _recomputeUserProgressUseCase = recomputeUserProgressUseCase,
       _levelPolicy = levelPolicy,
       _analyticsService = analyticsService;

  final RecomputeUserProgressUseCase _recomputeUserProgressUseCase;
  final LevelPolicy _levelPolicy;
  final AnalyticsService _analyticsService;

  Future<UserProgress> call() async {
    final UserProgress progress = await _recomputeUserProgressUseCase();
    final int previousLevel = _levelPolicy.levelFor(
      progress.totalTx > 0 ? progress.totalTx - 1 : 0,
    );
    if (progress.level > previousLevel) {
      await _analyticsService.logEvent('level_up', <String, Object?>{
        'old_level': previousLevel,
        'new_level': progress.level,
        'total_tx': progress.totalTx,
      });
    }
    return progress;
  }
}
