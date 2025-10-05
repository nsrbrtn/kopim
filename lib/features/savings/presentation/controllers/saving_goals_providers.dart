import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

import 'saving_goals_controller.dart';
import 'saving_goals_state.dart';

part 'saving_goals_providers.g.dart';

@riverpod
List<SavingGoal> goalsStream(Ref ref) {
  return ref.watch(
    savingGoalsControllerProvider.select(
      (SavingGoalsState value) => value.goals,
    ),
  );
}
