// ignore_for_file: always_specify_types

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart' as riverpod;
import 'package:uuid/uuid.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:kopim/features/budgets/presentation/controllers/budget_form_controller.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';

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
  final List<Category> categories = <Category>[
    Category(
      id: 'food',
      name: 'Food',
      type: 'expense',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Category(
      id: 'groceries',
      name: 'Groceries',
      type: 'expense',
      parentId: 'food',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Category(
      id: 'restaurants',
      name: 'Restaurants',
      type: 'expense',
      parentId: 'food',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  test('selecting parent category also selects descendants', () {
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

    controller.toggleCategory(categories.first, categories);

    final BudgetFormState state = container.read(
      budgetFormControllerProvider(params: params),
    );

    expect(state.categoryIds.toSet(), <String>{
      'food',
      'groceries',
      'restaurants',
    });
  });

  test('submit saves budget with expanded category scope', () async {
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
    controller.toggleCategory(categories.first, categories);
    controller.setCategoryAmount('food', '10000');
    controller.setCategoryAmount('groceries', '2000');
    controller.setCategoryAmount('restaurants', '1000');

    final bool result = await controller.submit(categories);
    expect(result, isTrue);
    expect(repository.savedBudgets, hasLength(1));
    final Budget saved = repository.savedBudgets.single;
    expect(saved.amountValue.toDouble(), closeTo(10000, 0.0001));
    expect(saved.categoryAllocations, hasLength(3));
    expect(saved.categories.toSet(), <String>{
      'food',
      'groceries',
      'restaurants',
    });
  });

  test('submit fails when category scope has no categories', () async {
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

    final bool result = await controller.submit(categories);
    expect(result, isFalse);
    final BudgetFormState state = container.read(
      budgetFormControllerProvider(params: params),
    );
    expect(state.errorMessage, 'invalid_category_amount');
    expect(repository.savedBudgets, isEmpty);
  });

  test('submit fails when child limits exceed parent limit', () async {
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

    controller.setTitle('Broken category budget');
    controller.setScope(BudgetScope.byCategory);
    controller.toggleCategory(categories.first, categories);
    controller.setCategoryAmount('food', '100');
    controller.setCategoryAmount('groceries', '60');
    controller.setCategoryAmount('restaurants', '50');

    final bool result = await controller.submit(categories);

    expect(result, isFalse);
    final BudgetFormState state = container.read(
      budgetFormControllerProvider(params: params),
    );
    expect(state.errorMessage, 'invalid_category_amount');
    expect(repository.savedBudgets, isEmpty);
  });

  test(
    'submit allows child categories without explicit limit under parent',
    () async {
      final _RecordingBudgetRepository repository =
          _RecordingBudgetRepository();
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

      controller.setTitle('Food budget');
      controller.setScope(BudgetScope.byCategory);
      controller.toggleCategory(categories.first, categories);
      controller.setCategoryAmount('food', '10000');

      final bool result = await controller.submit(categories);

      expect(result, isTrue);
      expect(repository.savedBudgets, hasLength(1));
      final Budget saved = repository.savedBudgets.single;
      expect(saved.amountValue.toDouble(), closeTo(10000, 0.0001));
      expect(saved.categoryAllocations, hasLength(1));
      expect(saved.categoryAllocations.single.categoryId, 'food');
    },
  );

  test(
    'submit fails when top-level selected category has no covering limit',
    () async {
      final _RecordingBudgetRepository repository =
          _RecordingBudgetRepository();
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

      controller.setTitle('Groceries only');
      controller.setScope(BudgetScope.byCategory);
      controller.toggleCategory(categories[1], categories);

      final bool result = await controller.submit(categories);

      expect(result, isFalse);
      final BudgetFormState state = container.read(
        budgetFormControllerProvider(params: params),
      );
      expect(state.errorMessage, 'invalid_category_amount');
    },
  );
}
