import 'package:collection/collection.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';

import 'saving_goals_controller.dart';
import 'saving_goals_state.dart';

part 'saving_goal_details_providers.g.dart';

@riverpod
SavingGoal? savingGoalById(Ref ref, String goalId) {
  final List<SavingGoal> goals = ref.watch(
    savingGoalsControllerProvider.select(
      (SavingGoalsState state) => state.goals,
    ),
  );
  return goals.firstWhereOrNull((SavingGoal goal) => goal.id == goalId);
}

@riverpod
Stream<SavingGoalAnalytics> savingGoalAnalytics(Ref ref, String goalId) {
  return ref
      .watch(watchSavingGoalAnalyticsUseCaseProvider)
      .call(goalId: goalId);
}

@riverpod
Stream<List<Category>> savingGoalCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}
