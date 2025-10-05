import '../repositories/saving_goal_repository.dart';

class ArchiveSavingGoalUseCase {
  ArchiveSavingGoalUseCase({
    required SavingGoalRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final SavingGoalRepository _repository;
  final DateTime Function() _clock;

  Future<void> call(String goalId) {
    if (goalId.isEmpty) {
      throw ArgumentError.value(goalId, 'goalId', 'Goal id required');
    }
    return _repository.archive(goalId, _clock().toUtc());
  }
}
