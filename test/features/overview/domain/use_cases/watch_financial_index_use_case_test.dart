import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/use_cases/watch_financial_index_use_case.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  group('computeFinancialIndexSeries', () {
    test('считает текущий индекс и историю по месяцам', () {
      final DateTime reference = DateTime(2026, 2, 25);
      final DateTime createdAt = DateTime(2025, 1, 1);

      final List<AccountEntity> accounts = <AccountEntity>[
        AccountEntity(
          id: 'cash',
          name: 'Cash',
          balanceMinor: BigInt.from(120000),
          openingBalanceMinor: BigInt.from(0),
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        AccountEntity(
          id: 'credit',
          name: 'Credit',
          balanceMinor: BigInt.from(-50000),
          openingBalanceMinor: BigInt.from(0),
          currency: 'RUB',
          currencyScale: 2,
          type: 'credit_card',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ];

      final List<Budget> budgets = <Budget>[
        Budget(
          id: 'budget-1',
          title: 'Main budget',
          period: BudgetPeriod.monthly,
          startDate: DateTime(2025, 1, 1),
          amountMinor: BigInt.from(100000),
          amountScale: 2,
          scope: BudgetScope.all,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ];

      final List<SavingGoal> goals = <SavingGoal>[
        SavingGoal(
          id: 'goal-1',
          userId: 'u1',
          name: 'Reserve',
          targetAmount: 100000,
          currentAmount: 50000,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ];

      final List<TransactionEntity> transactions = <TransactionEntity>[
        _expense('e-prev-1', 'cash', 30000, DateTime(2026, 1, 5), createdAt),
        _expense('e-prev-2', 'cash', 50000, DateTime(2026, 1, 18), createdAt),
        _expense('e-cur-1', 'cash', 25000, DateTime(2026, 2, 5), createdAt),
        _expense('e-cur-2', 'cash', 35000, DateTime(2026, 2, 15), createdAt),
        _income('i-cur-1', 'cash', 100000, DateTime(2026, 2, 7), createdAt),
        for (int day = 1; day <= 10; day += 1)
          _expense(
            'discipline-$day',
            'cash',
            1000,
            DateTime(2026, 2, day),
            createdAt,
          ),
      ];

      final FinancialIndexSeries series = computeFinancialIndexSeries(
        accounts: accounts,
        transactions: transactions,
        budgets: budgets,
        savingGoals: goals,
        reference: reference,
        historyMonths: 6,
        weights: FinancialIndexWeights.standard,
        computeBudgetProgressUseCase: ComputeBudgetProgressUseCase(),
      );

      expect(series.monthly.length, 6);
      expect(series.current.totalScore, inInclusiveRange(0, 100));
      expect(series.current.status, isA<FinancialIndexStatus>());
      expect(series.current.factors.budgetScore, inInclusiveRange(0, 100));
      expect(series.current.factors.safetyScore, inInclusiveRange(0, 100));
      expect(series.current.factors.dynamicsScore, inInclusiveRange(0, 100));
      expect(series.current.factors.disciplineScore, inInclusiveRange(0, 100));
      expect(series.monthly.last.score, series.current.totalScore);

      final DateTime lastMonth = series.monthly.last.month;
      expect(lastMonth.year, 2026);
      expect(lastMonth.month, 2);
    });

    test('для пустых данных возвращает валидный нейтральный результат', () {
      final FinancialIndexSeries series = computeFinancialIndexSeries(
        accounts: const <AccountEntity>[],
        transactions: const <TransactionEntity>[],
        budgets: const <Budget>[],
        savingGoals: const <SavingGoal>[],
        reference: DateTime(2026, 2, 25),
        historyMonths: 3,
        weights: FinancialIndexWeights.standard,
        computeBudgetProgressUseCase: ComputeBudgetProgressUseCase(),
      );

      expect(series.monthly.length, 3);
      expect(series.current.totalScore, inInclusiveRange(0, 100));
      expect(series.monthly.last.score, series.current.totalScore);
    });
  });
}

TransactionEntity _expense(
  String id,
  String accountId,
  int amountMinor,
  DateTime date,
  DateTime createdAt,
) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    amountMinor: BigInt.from(-amountMinor),
    amountScale: 2,
    date: date,
    type: TransactionType.expense.storageValue,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

TransactionEntity _income(
  String id,
  String accountId,
  int amountMinor,
  DateTime date,
  DateTime createdAt,
) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    amountMinor: BigInt.from(amountMinor),
    amountScale: 2,
    date: date,
    type: TransactionType.income.storageValue,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
