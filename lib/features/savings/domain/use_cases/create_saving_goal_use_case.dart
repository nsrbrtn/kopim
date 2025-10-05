import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

import '../entities/saving_goal.dart';
import '../repositories/saving_goal_repository.dart';
import '../value_objects/money.dart';

class CreateSavingGoalUseCase {
  CreateSavingGoalUseCase({
    required SavingGoalRepository repository,
    required AuthRepository authRepository,
    required Uuid uuidGenerator,
    DateTime Function()? clock,
  }) : _repository = repository,
       _authRepository = authRepository,
       _uuid = uuidGenerator,
       _clock = clock ?? DateTime.now;

  final SavingGoalRepository _repository;
  final AuthRepository _authRepository;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<SavingGoal> call({
    required String name,
    required Money target,
    String? note,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty');
    }
    if (target.minorUnits <= 0) {
      throw ArgumentError.value(
        target.minorUnits,
        'target',
        'Target amount must be greater than zero',
      );
    }
    final String? userId = _authRepository.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('Authenticated user required to create saving goal');
    }
    final SavingGoal? existing = await _repository.findByName(
      userId: userId,
      name: trimmedName,
    );
    if (existing != null) {
      throw StateError('Saving goal name already exists');
    }
    final DateTime now = _clock().toUtc();
    final SavingGoal goal = SavingGoal(
      id: _uuid.v4(),
      userId: userId,
      name: trimmedName,
      targetAmount: target.minorUnits,
      currentAmount: 0,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _repository.create(goal);
    return goal;
  }
}
