import '../entities/saving_goal.dart';
import '../repositories/saving_goal_repository.dart';

class WatchSavingGoalsUseCase {
  WatchSavingGoalsUseCase({required SavingGoalRepository repository})
    : _repository = repository;

  final SavingGoalRepository _repository;

  Stream<List<SavingGoal>> call({required bool includeArchived}) {
    return _repository.watchGoals(includeArchived: includeArchived);
  }
}
