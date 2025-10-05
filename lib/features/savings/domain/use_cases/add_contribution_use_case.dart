import '../entities/saving_goal.dart';
import '../repositories/saving_goal_repository.dart';
import '../value_objects/money.dart';

class AddContributionUseCase {
  AddContributionUseCase({
    required SavingGoalRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final SavingGoalRepository _repository;
  final DateTime Function() _clock;

  Future<SavingGoal> call({
    required String goalId,
    required Money amount,
    String? sourceAccountId,
    String? note,
  }) async {
    if (amount.minorUnits <= 0) {
      throw ArgumentError.value(
        amount.minorUnits,
        'amount',
        'Contribution amount must be greater than zero',
      );
    }
    final SavingGoal? goal = await _repository.findById(goalId);
    if (goal == null) {
      throw StateError('Saving goal not found');
    }
    if (goal.isArchived) {
      throw StateError('Cannot contribute to archived goals');
    }
    if (goal.currentAmount >= goal.targetAmount) {
      throw StateError('Goal already reached');
    }
    final DateTime now = _clock().toUtc();
    final int desiredAmount = goal.currentAmount + amount.minorUnits;
    final int cappedAmount = desiredAmount > goal.targetAmount
        ? goal.targetAmount
        : desiredAmount;
    final int appliedDelta = cappedAmount - goal.currentAmount;
    if (appliedDelta <= 0) {
      throw StateError('Contribution does not change goal progress');
    }
    final String? trimmedNote = note?.trim().isNotEmpty ?? false
        ? note!.trim()
        : null;
    final SavingGoal updatedGoal = await _repository.addContribution(
      goal: goal,
      appliedDelta: appliedDelta,
      newCurrentAmount: cappedAmount,
      contributedAt: now,
      sourceAccountId: sourceAccountId,
      contributionNote: trimmedNote,
    );
    return updatedGoal;
  }
}
