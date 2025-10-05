import '../entities/saving_goal.dart';

abstract class SavingGoalRepository {
  Stream<List<SavingGoal>> watchGoals({required bool includeArchived});
  Future<List<SavingGoal>> loadGoals({required bool includeArchived});
  Future<SavingGoal?> findById(String id);
  Future<SavingGoal?> findByName({
    required String userId,
    required String name,
  });
  Future<void> create(SavingGoal goal);
  Future<void> update(SavingGoal goal);
  Future<void> archive(String goalId, DateTime archivedAt);
  Future<SavingGoal> addContribution({
    required SavingGoal goal,
    required int appliedDelta,
    required int newCurrentAmount,
    required DateTime contributedAt,
    String? sourceAccountId,
    String? contributionNote,
  });
}
