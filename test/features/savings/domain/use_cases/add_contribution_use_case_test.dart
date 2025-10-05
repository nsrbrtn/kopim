import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/savings/domain/use_cases/add_contribution_use_case.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockSavingGoalRepository extends Mock implements SavingGoalRepository {}

class _MockAddTransactionUseCase extends Mock
    implements AddTransactionUseCase {}

SavingGoal _buildGoal({
  int current = 0,
  int target = 1000,
  DateTime? archivedAt,
}) {
  final DateTime now = DateTime.utc(2024, 1, 1);
  return SavingGoal(
    id: 'goal-1',
    userId: 'user-1',
    name: 'Vacation',
    targetAmount: target,
    currentAmount: current,
    createdAt: now,
    updatedAt: now,
    archivedAt: archivedAt,
  );
}

AddTransactionRequest _dummyRequest() => AddTransactionRequest(
  accountId: 'acc',
  amount: 1,
  date: DateTime.utc(2024),
);

void main() {
  late _MockSavingGoalRepository repository;
  late _MockAddTransactionUseCase addTransactionUseCase;
  late AddContributionUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 7, 1, 9);

  setUpAll(() {
    registerFallbackValue(_buildGoal());
    registerFallbackValue(_dummyRequest());
  });

  setUp(() {
    repository = _MockSavingGoalRepository();
    addTransactionUseCase = _MockAddTransactionUseCase();
    useCase = AddContributionUseCase(
      repository: repository,
      addTransactionUseCase: addTransactionUseCase,
      clock: () => fixedNow,
    );
    when(() => addTransactionUseCase(any())).thenAnswer((_) async {});
    when(
      () => repository.addContribution(
        updatedGoal: any(named: 'updatedGoal'),
        contributionAmount: any(named: 'contributionAmount'),
        sourceAccountId: any(named: 'sourceAccountId'),
        contributionNote: any(named: 'contributionNote'),
      ),
    ).thenAnswer((_) async {});
  });

  test('adds contribution, caps at target and posts transaction', () async {
    when(
      () => repository.findById('goal-1'),
    ).thenAnswer((_) async => _buildGoal(current: 800, target: 1000));

    final SavingGoal updated = await useCase(
      goalId: 'goal-1',
      amount: Money.fromMinorUnits(300),
      sourceAccountId: 'acc-1',
      note: '  Keep going  ',
    );

    expect(updated.currentAmount, 1000);
    expect(updated.updatedAt, fixedNow);

    final VerificationResult repoCall = verify(
      () => repository.addContribution(
        updatedGoal: captureAny(named: 'updatedGoal'),
        contributionAmount: 200,
        sourceAccountId: 'acc-1',
        contributionNote: 'Keep going',
      ),
    );
    repoCall.called(1);
    final SavingGoal persisted = repoCall.captured.single as SavingGoal;
    expect(persisted.currentAmount, 1000);
    expect(persisted.updatedAt, fixedNow);

    final VerificationResult txCall = verify(
      () => addTransactionUseCase(captureAny()),
    );
    txCall.called(1);
    final AddTransactionRequest request =
        txCall.captured.single as AddTransactionRequest;
    expect(request.accountId, 'acc-1');
    expect(request.categoryId, AddContributionUseCase.savingsCategoryId);
    expect(request.amount, Money.fromMinorUnits(300).toDouble());
    expect(request.note, 'Savings: Vacation — Keep going');
    expect(request.type, TransactionType.expense);
  });

  test('skips transaction when source account not provided', () async {
    when(
      () => repository.findById('goal-1'),
    ).thenAnswer((_) async => _buildGoal(current: 200, target: 500));

    final SavingGoal updated = await useCase(
      goalId: 'goal-1',
      amount: Money.fromMinorUnits(200),
    );

    expect(updated.currentAmount, 400);
    verifyNever(() => addTransactionUseCase(any()));
    verify(
      () => repository.addContribution(
        updatedGoal: any(named: 'updatedGoal'),
        contributionAmount: 200,
        sourceAccountId: null,
        contributionNote: null,
      ),
    ).called(1);
  });

  test('throws when goal is archived', () async {
    when(
      () => repository.findById('goal-1'),
    ).thenAnswer((_) async => _buildGoal(archivedAt: DateTime.utc(2024, 1, 2)));

    expect(
      () => useCase(goalId: 'goal-1', amount: Money.fromMinorUnits(100)),
      throwsStateError,
    );
  });

  test('throws when goal already reached its target', () async {
    when(
      () => repository.findById('goal-1'),
    ).thenAnswer((_) async => _buildGoal(current: 1000, target: 1000));

    expect(
      () => useCase(goalId: 'goal-1', amount: Money.fromMinorUnits(100)),
      throwsStateError,
    );
  });

  test('throws when goal cannot be found', () async {
    when(() => repository.findById('missing')).thenAnswer((_) async => null);

    expect(
      () => useCase(goalId: 'missing', amount: Money.fromMinorUnits(50)),
      throwsStateError,
    );
  });

  test('throws when contribution amount is not positive', () async {
    expect(
      () => useCase(goalId: 'goal-1', amount: Money.fromMinorUnits(0)),
      throwsArgumentError,
    );
  });
}
