import '../entities/saving_goal.dart';
import '../repositories/saving_goal_repository.dart';
import '../value_objects/money.dart';

class UpdateSavingGoalUseCase {
  UpdateSavingGoalUseCase({
    required SavingGoalRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final SavingGoalRepository _repository;
  final DateTime Function() _clock;

  Future<SavingGoal> call({
    required SavingGoal goal,
    String? name,
    Money? target,
    String? note,
  }) async {
    final String updatedName = name?.trim().isNotEmpty ?? false
        ? name!.trim()
        : goal.name;
    if (updatedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty');
    }
    final int updatedTarget = target?.minorUnits ?? goal.targetAmount;
    if (updatedTarget <= 0) {
      throw ArgumentError.value(
        updatedTarget,
        'target',
        'Target amount must be greater than zero',
      );
    }
    if (goal.currentAmount > updatedTarget) {
      throw StateError('Current amount exceeds new target');
    }
    final DateTime now = _clock().toUtc();
    final SavingGoal updatedGoal = goal.copyWith(
      name: updatedName,
      targetAmount: updatedTarget,
      note: note?.trim().isNotEmpty ?? false ? note!.trim() : null,
      updatedAt: now,
    );
    await _repository.update(updatedGoal);
    return updatedGoal;
  }
}
