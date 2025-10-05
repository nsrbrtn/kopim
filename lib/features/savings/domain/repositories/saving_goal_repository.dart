import '../entities/saving_goal.dart';

abstract class SavingGoalRepository {
  Stream<List<SavingGoal>> watchGoals({required bool includeArchived});
  Future<List<SavingGoal>> loadGoals({required bool includeArchived});
  Future<SavingGoal?> findById(String id);
  Future<void> create(SavingGoal goal);
  Future<void> update(SavingGoal goal);
  Future<void> archive(String goalId, DateTime archivedAt);
  Future<void> addContribution({
    required SavingGoal updatedGoal,
    required int contributionAmount,
    String? sourceAccountId,
    String? contributionNote,
  });
}
