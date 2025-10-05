import '../entities/saving_goal.dart';
import '../repositories/saving_goal_repository.dart';

class GetSavingGoalsUseCase {
  GetSavingGoalsUseCase({required SavingGoalRepository repository})
    : _repository = repository;

  final SavingGoalRepository _repository;

  Future<List<SavingGoal>> call({required bool includeArchived}) {
    return _repository.loadGoals(includeArchived: includeArchived);
  }
}
