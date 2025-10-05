import 'package:equatable/equatable.dart';

import '../entities/saving_goal.dart';
import 'money.dart';

class GoalProgress extends Equatable {
  const GoalProgress({
    required this.goal,
    required this.percent,
    required this.remaining,
  });

  factory GoalProgress.fromGoal(SavingGoal goal) {
    final Money remaining = Money.fromMinorUnits(
      (goal.targetAmount - goal.currentAmount).clamp(0, goal.targetAmount),
    );
    final double percent = goal.targetAmount == 0
        ? 0
        : (goal.currentAmount / goal.targetAmount).clamp(0, 1);
    return GoalProgress(goal: goal, percent: percent, remaining: remaining);
  }

  final SavingGoal goal;
  final double percent;
  final Money remaining;

  @override
  List<Object?> get props => <Object?>[goal, percent, remaining];
}
