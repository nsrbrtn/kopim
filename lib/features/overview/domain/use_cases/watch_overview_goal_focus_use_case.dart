import 'package:kopim/features/overview/domain/models/overview_goal_focus.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';

class WatchOverviewGoalFocusUseCase {
  WatchOverviewGoalFocusUseCase({
    required SavingGoalRepository savingGoalRepository,
  }) : _savingGoalRepository = savingGoalRepository;

  final SavingGoalRepository _savingGoalRepository;

  Stream<OverviewGoalFocus?> call() {
    return _savingGoalRepository.watchGoals(includeArchived: false).map((
      List<SavingGoal> goals,
    ) {
      if (goals.isEmpty) {
        return null;
      }
      final List<SavingGoal> active = goals
          .where((SavingGoal goal) => goal.targetAmount > 0)
          .toList(growable: false);
      if (active.isEmpty) {
        return null;
      }
      active.sort((SavingGoal a, SavingGoal b) {
        final int aRemaining = (a.targetAmount - a.currentAmount).clamp(
          0,
          a.targetAmount,
        );
        final int bRemaining = (b.targetAmount - b.currentAmount).clamp(
          0,
          b.targetAmount,
        );
        final int byRemaining = aRemaining.compareTo(bRemaining);
        if (byRemaining != 0) {
          return byRemaining;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
      final SavingGoal goal = active.first;
      final int remaining = (goal.targetAmount - goal.currentAmount).clamp(
        0,
        goal.targetAmount,
      );
      final double progress = goal.targetAmount <= 0
          ? 0
          : (goal.currentAmount / goal.targetAmount).clamp(0, 1);
      final int percent = (progress * 100).round().clamp(0, 100);
      return OverviewGoalFocus(
        goal: goal,
        progress: progress,
        percent: percent,
        remainingAmount: remaining,
      );
    });
  }
}
