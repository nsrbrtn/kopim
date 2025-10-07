import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/widgets/home_budget_progress_card.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeBudgetProgressCard', () {
    final Budget budget = Budget(
      id: 'budget-1',
      title: 'Food',
      period: BudgetPeriod.monthly,
      startDate: DateTime(2024, 1, 1),
      amount: 500,
      scope: BudgetScope.all,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
    final BudgetInstance instance = BudgetInstance(
      id: 'instance-1',
      budgetId: 'budget-1',
      periodStart: DateTime(2024, 1, 1),
      periodEnd: DateTime(2024, 1, 31),
      amount: 500,
      spent: 200,
      status: BudgetInstanceStatus.active,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
    final BudgetProgress progress = BudgetProgress(
      budget: budget,
      instance: instance,
      spent: 200,
      remaining: 300,
      utilization: 0.4,
      isExceeded: false,
    );

    testWidgets('renders selected budget progress', (
      WidgetTester tester,
    ) async {
      final Category groceries = Category(
        id: 'cat-1',
        name: 'Groceries',
        type: 'expense',
        color: '#FF0000',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final TransactionEntity groceryTx = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        categoryId: groceries.id,
        amount: -120,
        date: DateTime(2024, 1, 10),
        type: 'expense',
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2024, 1, 10),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          budgetProgressByIdProvider(
            'budget-1',
          ).overrideWithValue(AsyncValue<BudgetProgress>.data(progress)),
          budgetCategoriesStreamProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(<Category>[groceries]),
          ),
          budgetTransactionsByIdProvider('budget-1').overrideWithValue(
            AsyncValue<List<TransactionEntity>>.data(<TransactionEntity>[
              groceryTx,
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: HomeBudgetProgressCard(
                preferences: const HomeDashboardPreferences(
                  showBudgetWidget: true,
                  budgetId: 'budget-1',
                ),
                onConfigure: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Budget overview'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(Chip), findsWidgets);
      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets(
      'invokes callback when configure button tapped for empty state',
      (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: HomeBudgetProgressCard(
                preferences: const HomeDashboardPreferences(
                  showBudgetWidget: true,
                  budgetId: null,
                ),
                onConfigure: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open settings'));
        await tester.pump();

        expect(tapped, isTrue);
      },
    );
  });
}
