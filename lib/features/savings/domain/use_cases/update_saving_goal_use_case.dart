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
    List<String>? storageAccountIds,
    String? note,
    DateTime? targetDate,
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
    final List<String>? normalizedStorageAccountIds = storageAccountIds
        ?.map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final DateTime now = _clock().toUtc();
    final List<String> resolvedStorageAccountIds =
        normalizedStorageAccountIds ?? goal.storageAccountIds;
    final String? primaryStorageAccountId = resolvedStorageAccountIds.isEmpty
        ? goal.accountId
        : resolvedStorageAccountIds.first;
    final SavingGoal updatedGoal = goal.copyWith(
      name: updatedName,
      accountId: primaryStorageAccountId,
      storageAccountIds: resolvedStorageAccountIds,
      targetAmount: updatedTarget,
      targetDate: targetDate == null
          ? goal.targetDate
          : DateTime.utc(targetDate.year, targetDate.month, targetDate.day),
      note: note?.trim().isNotEmpty ?? false ? note!.trim() : null,
      updatedAt: now,
    );
    await _repository.update(updatedGoal);
    return updatedGoal;
  }
}
