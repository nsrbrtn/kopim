import 'dart:async';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';
import 'package:kopim/features/profile/domain/usecases/recompute_user_progress_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_progress_controller.g.dart';

@riverpod
Stream<UserProgress> userProgress(Ref ref, String uid) {
  final LevelPolicy policy = ref.watch(levelPolicyProvider);
  final UserProgressRepository repository = ref.watch(
    userProgressRepositoryProvider,
  );
  final RecomputeUserProgressUseCase recompute = ref.watch(
    recomputeUserProgressUseCaseProvider,
  );

  unawaited(recompute());

  final StreamController<UserProgress> controller =
      StreamController<UserProgress>.broadcast();

  final StreamSubscription<int> countSubscription = repository
      .watchTransactionCount()
      .listen((int count) {
        final int level = policy.levelFor(count);
        final UserProgress progress = UserProgress(
          totalTx: count,
          level: level,
          title: policy.titleFor(level),
          nextThreshold: policy.nextThreshold(count),
          updatedAt: DateTime.now().toUtc(),
        );
        controller.add(progress);
        unawaited(repository.cacheProgress(progress));
      });

  final StreamSubscription<UserProgress?> cacheSubscription = repository
      .watchCachedProgress()
      .listen((UserProgress? progress) {
        if (progress != null) {
          controller.add(progress);
        }
      });

  ref.onDispose(() async {
    await countSubscription.cancel();
    await cacheSubscription.cancel();
    await controller.close();
  });

  return controller.stream;
}
