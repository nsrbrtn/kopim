import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';

SavingGoal _buildGoal({required int target, required int current}) {
  final DateTime now = DateTime.utc(2024, 1, 1);
  return SavingGoal(
    id: 'goal-1',
    userId: 'user-1',
    name: 'Vacation',
    targetAmount: target,
    currentAmount: current,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('GoalProgress', () {
    test('computes remaining amount and percent for partial progress', () {
      final SavingGoal goal = _buildGoal(target: 1000, current: 250);
      final GoalProgress progress = GoalProgress.fromGoal(goal);

      expect(progress.remaining.minorUnits, 750);
      expect(progress.percent, closeTo(0.25, 0.0001));
    });

    test('clamps percent when current amount exceeds target', () {
      final SavingGoal goal = _buildGoal(target: 500, current: 800);
      final GoalProgress progress = GoalProgress.fromGoal(goal);

      expect(progress.percent, 1);
      expect(progress.remaining.minorUnits, 0);
    });
  });
}
