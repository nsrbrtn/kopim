import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goal_details_providers.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_state.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class _FakeSavingGoalsController extends SavingGoalsController {
  _FakeSavingGoalsController(this._state);

  final SavingGoalsState _state;

  @override
  SavingGoalsState build() => _state;
}

void main() {
  group('savingGoalForecastProvider', () {
    test(
      'не завышает рекомендацию выше остатка цели, если до даты меньше месяца',
      () {
        final DateTime now = DateTime.now();
        final SavingGoal goal = SavingGoal(
          id: 'goal-1',
          userId: 'user-1',
          name: 'Тестовая копилка',
          targetAmount: 1000000,
          currentAmount: 0,
          targetDate: now.add(const Duration(days: 14)),
          createdAt: now,
          updatedAt: now,
        );

        final ProviderContainer container = ProviderContainer(
          overrides: <Override>[
            savingGoalsControllerProvider.overrideWith(
              () => _FakeSavingGoalsController(
                SavingGoalsState(
                  goals: <SavingGoal>[goal],
                  isLoading: false,
                  error: null,
                  showArchived: false,
                ),
              ),
            ),
            savingGoalTransactionsProvider(goal.id).overrideWith(
              (_) => Stream<List<TransactionEntity>>.value(
                const <TransactionEntity>[],
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final SavingGoalForecast? forecast = container.read(
          savingGoalForecastProvider(goal.id),
        );

        expect(forecast, isNotNull);
        expect(forecast!.recommendedMonthlyContribution, 10000);
      },
    );

    test('делит остаток по месяцам, если до даты больше месяца', () {
      final DateTime now = DateTime.now();
      final SavingGoal goal = SavingGoal(
        id: 'goal-2',
        userId: 'user-1',
        name: 'Отпуск',
        targetAmount: 1200000,
        currentAmount: 0,
        targetDate: now.add(const Duration(days: 61)),
        createdAt: now,
        updatedAt: now,
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          savingGoalsControllerProvider.overrideWith(
            () => _FakeSavingGoalsController(
              SavingGoalsState(
                goals: <SavingGoal>[goal],
                isLoading: false,
                error: null,
                showArchived: false,
              ),
            ),
          ),
          savingGoalTransactionsProvider(goal.id).overrideWith(
            (_) => Stream<List<TransactionEntity>>.value(
              const <TransactionEntity>[],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final SavingGoalForecast? forecast = container.read(
        savingGoalForecastProvider(goal.id),
      );

      expect(forecast, isNotNull);
      expect(forecast!.recommendedMonthlyContribution, closeTo(6088, 0.1));
    });
  });
}
