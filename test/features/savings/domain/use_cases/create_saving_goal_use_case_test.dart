import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/savings/domain/use_cases/create_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockSavingGoalRepository extends Mock implements SavingGoalRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

SavingGoal _dummyGoal() {
  final DateTime now = DateTime.utc(2024, 1, 1);
  return SavingGoal(
    id: 'dummy',
    userId: 'user',
    name: 'Sample',
    targetAmount: 100,
    currentAmount: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _MockSavingGoalRepository repository;
  late _MockAuthRepository authRepository;
  late CreateSavingGoalUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 4, 5, 12);

  setUpAll(() {
    registerFallbackValue(_dummyGoal());
  });

  setUp(() {
    repository = _MockSavingGoalRepository();
    authRepository = _MockAuthRepository();
    useCase = CreateSavingGoalUseCase(
      repository: repository,
      authRepository: authRepository,
      uuidGenerator: const Uuid(),
      clock: () => fixedNow,
    );
    when(() => repository.create(any())).thenAnswer((_) async {});
    when(
      () => repository.findByName(
        userId: any(named: 'userId'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => authRepository.currentUser,
    ).thenReturn(const AuthUser(uid: 'user-1'));
  });

  test(
    'creates goal with trimmed values and delegates to repository',
    () async {
      final SavingGoal result = await useCase(
        name: '  Vacation  ',
        target: Money.fromMinorUnits(5000),
        note: '  Beach house  ',
      );

      expect(result.name, 'Vacation');
      expect(result.note, 'Beach house');
      expect(result.targetAmount, 5000);
      expect(result.createdAt, fixedNow);
      expect(result.updatedAt, fixedNow);

      final VerificationResult verification = verify(
        () => repository.create(captureAny()),
      );
      verification.called(1);
      final SavingGoal persisted = verification.captured.single as SavingGoal;
      expect(persisted.userId, 'user-1');
      expect(persisted.name, 'Vacation');
      expect(persisted.note, 'Beach house');
    },
  );

  test('throws when goal with same name exists for user', () async {
    final SavingGoal existing = _dummyGoal();
    when(
      () => repository.findByName(userId: 'user-1', name: 'Vacation'),
    ).thenAnswer((_) async => existing);

    expect(
      () => useCase(name: 'Vacation', target: Money.fromMinorUnits(2000)),
      throwsStateError,
    );
    verifyNever(() => repository.create(any()));
  });

  test('throws when target amount is not positive', () async {
    expect(
      () => useCase(name: 'Trip', target: Money.fromMinorUnits(0)),
      throwsArgumentError,
    );
  });

  test('throws when no authenticated user available', () async {
    when(() => authRepository.currentUser).thenReturn(null);

    expect(
      () => useCase(name: 'Trip', target: Money.fromMinorUnits(1000)),
      throwsStateError,
    );
  });
}
