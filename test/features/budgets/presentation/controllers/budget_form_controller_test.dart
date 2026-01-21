// ignore_for_file: always_specify_types

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart' as riverpod;
import 'package:uuid/uuid.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:kopim/features/budgets/presentation/controllers/budget_form_controller.dart';

class _RecordingBudgetRepository implements BudgetRepository {
  final List<Budget> savedBudgets = <Budget>[];

  @override
  Future<void> upsert(Budget budget) async {
    savedBudgets.add(budget);
  }

  @override
  Stream<List<Budget>> watchBudgets() => const Stream<List<Budget>>.empty();

  @override
  Future<List<Budget>> loadBudgets() async => savedBudgets;

  @override
  Future<Budget?> findById(String id) async {
    try {
      return savedBudgets.firstWhere((Budget b) => b.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> softDelete(String id) async {}

  @override
  Stream<List<BudgetInstance>> watchInstances(String budgetId) =>
      const Stream<List<BudgetInstance>>.empty();

  @override
  Future<List<BudgetInstance>> loadInstances(String budgetId) async =>
      const <BudgetInstance>[];

  @override
  Future<void> upsertInstance(BudgetInstance instance) async {}

  @override
  Future<void> deleteInstance(String id) async {}
}

void main() {
  test('recalculates total when category allocations change', () {
    final riverpod.ProviderContainer container = riverpod.ProviderContainer(
      overrides: [
        saveBudgetUseCaseProvider.overrideWithValue(
          SaveBudgetUseCase(repository: _RecordingBudgetRepository()),
        ),
        uuidGeneratorProvider.overrideWithValue(const Uuid()),
      ],
    );
    addTearDown(container.dispose);

    const BudgetFormParams params = BudgetFormParams();
    final BudgetFormController controller = container.read(
      budgetFormControllerProvider(params: params).notifier,
    );

    controller.setScope(BudgetScope.byCategory);
    controller.toggleCategory('food');
    controller.updateCategoryAmount('food', '200.5');
    controller.toggleCategory('travel');
    controller.updateCategoryAmount('travel', '100');

    final BudgetFormState state = container.read(
      budgetFormControllerProvider(params: params),
    );

    expect(state.amountText, '300.50');
  });

  test('submit saves budget with category allocations', () async {
    final _RecordingBudgetRepository repository = _RecordingBudgetRepository();
    final riverpod.ProviderContainer container = riverpod.ProviderContainer(
      overrides: [
        saveBudgetUseCaseProvider.overrideWithValue(
          SaveBudgetUseCase(repository: repository),
        ),
        uuidGeneratorProvider.overrideWithValue(const Uuid()),
      ],
    );
    addTearDown(container.dispose);

    const BudgetFormParams params = BudgetFormParams();
    final BudgetFormController controller = container.read(
      budgetFormControllerProvider(params: params).notifier,
    );

    controller.setTitle('Monthly essentials');
    controller.setScope(BudgetScope.byCategory);
    controller.toggleCategory('groceries');
    controller.updateCategoryAmount('groceries', '20000');
    controller.toggleCategory('transport');
    controller.updateCategoryAmount('transport', '5000');

    final bool result = await controller.submit();
    expect(result, isTrue);
    expect(repository.savedBudgets, hasLength(1));
    final Budget saved = repository.savedBudgets.single;
    expect(saved.amountValue.toDouble(), closeTo(25000, 0.0001));
    expect(saved.categoryAllocations, hasLength(2));
    expect(
      saved.categoryAllocations
          .firstWhere(
            (BudgetCategoryAllocation allocation) =>
                allocation.categoryId == 'groceries',
          )
          .limitValue
          .toDouble(),
      closeTo(20000, 0.0001),
    );
    expect(
      saved.categoryAllocations
          .firstWhere(
            (BudgetCategoryAllocation allocation) =>
                allocation.categoryId == 'transport',
          )
          .limitValue
          .toDouble(),
      closeTo(5000, 0.0001),
    );
  });

  test('submit fails when category allocations are invalid', () async {
    final _RecordingBudgetRepository repository = _RecordingBudgetRepository();
    final riverpod.ProviderContainer container = riverpod.ProviderContainer(
      overrides: [
        saveBudgetUseCaseProvider.overrideWithValue(
          SaveBudgetUseCase(repository: repository),
        ),
        uuidGeneratorProvider.overrideWithValue(const Uuid()),
      ],
    );
    addTearDown(container.dispose);

    const BudgetFormParams params = BudgetFormParams();
    final BudgetFormController controller = container.read(
      budgetFormControllerProvider(params: params).notifier,
    );

    controller.setTitle('Invalid budget');
    controller.setScope(BudgetScope.byCategory);
    controller.toggleCategory('groceries');
    controller.updateCategoryAmount('groceries', '0');

    final bool result = await controller.submit();
    expect(result, isFalse);
    final BudgetFormState state = container.read(
      budgetFormControllerProvider(params: params),
    );
    expect(state.errorMessage, 'invalid_category_amount');
    expect(repository.savedBudgets, isEmpty);
  });
}
