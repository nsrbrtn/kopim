import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/repositories/budget_repository.dart';
import 'package:kopim/features/budgets/domain/use_cases/delete_budget_use_case.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;
import 'package:uuid/uuid.dart';

class _FakeBudgetRepository implements BudgetRepository {
  @override
  Future<Budget?> findById(String id) async => null;

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> deleteInstance(String id) async {}

  @override
  Future<List<BudgetInstance>> loadInstances(String budgetId) async =>
      const <BudgetInstance>[];

  @override
  Future<List<Budget>> loadBudgets() async => const <Budget>[];

  @override
  Future<void> upsert(Budget budget) async {}

  @override
  Future<void> upsertInstance(BudgetInstance instance) async {}

  @override
  Stream<List<BudgetInstance>> watchInstances(String budgetId) =>
      const Stream<List<BudgetInstance>>.empty();

  @override
  Stream<List<Budget>> watchBudgets() => const Stream<List<Budget>>.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  ];

  Widget buildTestApp({
    Budget? initialBudget,
    List<Override> overrides = const <Override>[],
  }) {
    final _FakeBudgetRepository repository = _FakeBudgetRepository();
    return ProviderScope(
      overrides: <Override>[
        saveBudgetUseCaseProvider.overrideWithValue(
          SaveBudgetUseCase(repository: repository),
        ),
        deleteBudgetUseCaseProvider.overrideWithValue(
          DeleteBudgetUseCase(repository: repository),
        ),
        uuidGeneratorProvider.overrideWithValue(const Uuid()),
        budgetCategoriesStreamProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(categories),
        ),
        budgetAccountsStreamProvider.overrideWith(
          (Ref ref) =>
              Stream<List<AccountEntity>>.value(const <AccountEntity>[]),
        ),
        ...overrides,
      ],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BudgetFormScreen(initialBudget: initialBudget),
      ),
    );
  }

  testWidgets('create screen shows category tree and category limits section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Название бюджета'), findsOneWidget);
    expect(find.text('Период'), findsOneWidget);
    expect(find.text('Область'), findsOneWidget);
    expect(find.text('Категории'), findsOneWidget);
    expect(find.text('Лимиты по категориям'), findsNothing);
    expect(find.text('Удалить'), findsNothing);

    final double titleY = tester.getTopLeft(find.text('Название бюджета')).dy;
    final double periodY = tester.getTopLeft(find.text('Период')).dy;
    final double scopeY = tester.getTopLeft(find.text('Область')).dy;
    final double categoriesY = tester.getTopLeft(find.text('Категории')).dy;

    expect(titleY, lessThan(periodY));
    expect(periodY, lessThan(scopeY));
    expect(scopeY, lessThan(categoriesY));
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pump();

    expect(find.text('Лимиты по категориям'), findsOneWidget);
    final double limitsY = tester
        .getTopLeft(find.text('Лимиты по категориям'))
        .dy;
    expect(categoriesY, lessThan(limitsY));
  });

  testWidgets('edit screen shows delete button', (WidgetTester tester) async {
    final Budget budget = Budget(
      id: 'budget-1',
      title: 'Food budget',
      period: BudgetPeriod.monthly,
      startDate: DateTime(2024, 1, 1),
      amountMinor: BigInt.from(50000),
      amountScale: 2,
      scope: BudgetScope.byCategory,
      categories: const <String>['food'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    await tester.pumpWidget(buildTestApp(initialBudget: budget));
    await tester.pump();

    expect(find.text('Удалить'), findsOneWidget);
  });
}
