import 'package:flutter/foundation.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

@immutable
class OverviewGoalFocus {
  const OverviewGoalFocus({
    required this.goal,
    required this.progress,
    required this.percent,
    required this.remainingAmount,
  });

  final SavingGoal goal;
  final double progress;
  final int percent;
  final int remainingAmount;

  bool get isReached => remainingAmount <= 0;
}
