import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

SavingGoal mapSavingGoalStorageAccounts(
  SavingGoal goal,
  List<String>? storageAccountIds,
) {
  final List<String> resolved = (storageAccountIds ?? goal.storageAccountIds)
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);

  final String? primaryAccountId;
  if (goal.accountId != null &&
      goal.accountId!.isNotEmpty &&
      resolved.contains(goal.accountId)) {
    primaryAccountId = goal.accountId;
  } else if (resolved.isNotEmpty) {
    primaryAccountId = resolved.first;
  } else {
    primaryAccountId = (goal.accountId != null && goal.accountId!.isNotEmpty)
        ? goal.accountId
        : null;
  }

  return goal.copyWith(
    accountId: primaryAccountId,
    storageAccountIds: resolved,
  );
}
