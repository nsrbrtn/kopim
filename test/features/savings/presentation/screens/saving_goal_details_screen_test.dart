import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_category_breakdown.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goal_details_providers.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_state.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _FakeSavingGoalsController extends SavingGoalsController {
  _FakeSavingGoalsController(this._state);

  final SavingGoalsState _state;

  @override
  SavingGoalsState build() => _state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavingGoalDetailsScreen', () {
    testWidgets('renders goal summary and analytics data', (
      WidgetTester tester,
    ) async {
      final SavingGoal goal = SavingGoal(
        id: 'goal-1',
        userId: 'user',
        name: 'Vacation Trip',
        targetAmount: 500000,
        currentAmount: 150000,
        note: 'Save for summer holidays',
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2024, 2, 15),
        archivedAt: null,
      );
      final SavingGoalsState controllerState = SavingGoalsState(
        goals: <SavingGoal>[goal],
        isLoading: false,
        error: null,
        showArchived: false,
      );
      final SavingGoalAnalytics analytics = SavingGoalAnalytics(
        goalId: goal.id,
        totalAmount: MoneyAmount(minor: BigInt.from(120000), scale: 2),
        lastContributionAt: DateTime(2024, 2, 10),
        categoryBreakdown: <SavingGoalCategoryBreakdown>[
          SavingGoalCategoryBreakdown(
            categoryId: 'travel',
            amount: MoneyAmount(minor: BigInt.from(80000), scale: 2),
          ),
          SavingGoalCategoryBreakdown(
            categoryId: 'food',
            amount: MoneyAmount(minor: BigInt.from(40000), scale: 2),
          ),
        ],
        transactionCount: 4,
      );
      final Category travelCategory = Category(
        id: 'travel',
        name: 'Travel',
        type: 'expense',
        color: '#FF7043',
        icon: const PhosphorIconDescriptor(
          name: 'airplane-tilt',
          style: PhosphorIconStyle.regular,
        ),
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
      final Category foodCategory = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        color: '#4CAF50',
        icon: const PhosphorIconDescriptor(
          name: 'pizza',
          style: PhosphorIconStyle.regular,
        ),
        parentId: null,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            savingGoalsControllerProvider.overrideWith(
              () => _FakeSavingGoalsController(controllerState),
            ),
            savingGoalByIdProvider(goal.id).overrideWithValue(goal),
            savingGoalAnalyticsProvider(
              goal.id,
            ).overrideWith((_) => Stream<SavingGoalAnalytics>.value(analytics)),
            savingGoalCategoriesProvider.overrideWith(
              (_) => Stream<List<Category>>.value(<Category>[
                travelCategory,
                foodCategory,
              ]),
            ),
            savingGoalTransactionsProvider(goal.id).overrideWith(
              (_) => const Stream<List<TransactionEntity>>.empty(),
            ),
            savingGoalAccountsProvider(
              goal.id,
            ).overrideWith((_) => const Stream<List<AccountEntity>>.empty()),
            savingGoalForecastProvider(goal.id).overrideWithValue(
              const SavingGoalForecast(
                averageMonthlyContribution: 1200,
                estimatedCompletionDate: null,
                recommendedMonthlyContribution: 800,
              ),
            ),
            activeCurrencyCodeProvider.overrideWithValue('USD'),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SavingGoalDetailsScreen(goalId: goal.id),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final BuildContext context = tester.element(
        find.byType(SavingGoalDetailsScreen),
      );
      final AppLocalizations strings = AppLocalizations.of(context)!;

      final String transactionsLabel = strings
          .savingsGoalDetailsTransactionsCount(analytics.transactionCount);

      expect(find.text('Vacation Trip'), findsOneWidget);
      expect(find.textContaining('Save for summer holidays'), findsOneWidget);
      expect(find.text(transactionsLabel), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
