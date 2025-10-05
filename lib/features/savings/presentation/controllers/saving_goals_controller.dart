import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/use_cases/archive_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/get_saving_goals_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/watch_saving_goals_use_case.dart';

import 'saving_goals_state.dart';

part 'saving_goals_controller.g.dart';

@riverpod
class SavingGoalsController extends _$SavingGoalsController {
  StreamSubscription<List<SavingGoal>>? _subscription;

  @override
  SavingGoalsState build() {
    const SavingGoalsState initial = SavingGoalsState();
    state = initial;
    ref.onDispose(() async {
      await _subscription?.cancel();
    });
    _subscribe(initial.showArchived);
    return state;
  }

  void toggleShowArchived(bool value) {
    if (state.showArchived == value) {
      return;
    }
    state = state.copyWith(showArchived: value);
    _subscribe(value);
  }

  Future<void> refresh() async {
    final GetSavingGoalsUseCase loader = ref.read(
      getSavingGoalsUseCaseProvider,
    );
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<SavingGoal> items = await loader(
        includeArchived: state.showArchived,
      );
      state = state.copyWith(goals: items, isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      ref
          .read(loggerServiceProvider)
          .logError('Failed to refresh saving goals', error);
    }
  }

  void _subscribe(bool includeArchived) {
    _subscription?.cancel();
    state = state.copyWith(isLoading: true, error: null);
    final WatchSavingGoalsUseCase watch = ref.watch(
      watchSavingGoalsUseCaseProvider,
    );
    _subscription = watch(includeArchived: includeArchived).listen(
      (List<SavingGoal> goals) {
        state = state.copyWith(goals: goals, isLoading: false, error: null);
      },
      onError: (Object error, StackTrace _) {
        state = state.copyWith(isLoading: false, error: error.toString());
        ref
            .read(loggerServiceProvider)
            .logError('Saving goals stream error', error);
      },
    );
  }

  Future<void> archiveGoal(String goalId) async {
    try {
      state = state.copyWith(error: null);
      final ArchiveSavingGoalUseCase archive = ref.read(
        archiveSavingGoalUseCaseProvider,
      );
      await archive(goalId);
    } catch (error) {
      state = state.copyWith(error: error.toString());
      ref
          .read(loggerServiceProvider)
          .logError('Failed to archive saving goal', error);
      rethrow;
    }
  }
}
