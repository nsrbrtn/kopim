import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/savings/domain/use_cases/update_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';
import 'package:mocktail/mocktail.dart';

class _MockSavingGoalRepository extends Mock implements SavingGoalRepository {}

SavingGoal _goal() {
  final DateTime now = DateTime.utc(2024, 1, 1);
  return SavingGoal(
    id: 'goal',
    userId: 'user-1',
    name: 'Old name',
    targetAmount: 2000,
    currentAmount: 500,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _MockSavingGoalRepository repository;
  late UpdateSavingGoalUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 6, 1, 10);

  setUpAll(() {
    registerFallbackValue(_goal());
  });

  setUp(() {
    repository = _MockSavingGoalRepository();
    useCase = UpdateSavingGoalUseCase(
      repository: repository,
      clock: () => fixedNow,
    );
    when(() => repository.update(any())).thenAnswer((_) async {});
  });

  test('updates goal with trimmed fields', () async {
    final SavingGoal updated = await useCase(
      goal: _goal(),
      name: '  New name  ',
      target: Money.fromMinorUnits(2500),
      note: '  Focus on flights  ',
    );

    expect(updated.name, 'New name');
    expect(updated.targetAmount, 2500);
    expect(updated.note, 'Focus on flights');
    expect(updated.updatedAt, fixedNow);

    verify(() => repository.update(updated)).called(1);
  });

  test('throws when new target is not positive', () async {
    expect(
      () => useCase(goal: _goal(), target: Money.fromMinorUnits(0)),
      throwsArgumentError,
    );
  });

  test('throws when current amount exceeds new target', () async {
    final SavingGoal goal = _goal();
    expect(
      () => useCase(
        goal: goal,
        target: Money.fromMinorUnits(goal.currentAmount - 10),
      ),
      throwsStateError,
    );
  });
}
