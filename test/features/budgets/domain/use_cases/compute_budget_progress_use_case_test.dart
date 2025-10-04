import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  final ComputeBudgetProgressUseCase useCase = ComputeBudgetProgressUseCase(
    schedule: const BudgetSchedule(),
  );

  Budget buildBudget({
    BudgetScope scope = BudgetScope.all,
    List<String> categories = const <String>[],
    List<String> accounts = const <String>[],
    double amount = 100,
    DateTime? start,
  }) {
    final DateTime startDate = start ?? DateTime.utc(2024, 1, 1, 0, 1);
    return Budget(
      id: 'budget',
      title: 'Budget',
      period: BudgetPeriod.monthly,
      startDate: startDate,
      endDate: null,
      amount: amount,
      scope: scope,
      categories: categories,
      accounts: accounts,
      createdAt: startDate,
      updatedAt: startDate,
    );
  }

  TransactionEntity tx({
    required String id,
    required double amount,
    required DateTime date,
    String accountId = 'acc',
    String? categoryId,
    String type = 'expense',
  }) {
    return TransactionEntity(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      note: null,
      type: type,
      createdAt: date,
      updatedAt: date,
    );
  }

  group('ComputeBudgetProgressUseCase', () {
    test('computes utilization and exceeded flag for overspent budget', () {
      final Budget budget = buildBudget(amount: 100);
      final List<TransactionEntity> transactions = <TransactionEntity>[
        tx(id: 't1', amount: -70, date: DateTime.utc(2024, 1, 10)),
        tx(id: 't2', amount: -50, date: DateTime.utc(2024, 1, 20)),
      ];

      final BudgetProgress progress = useCase(
        budget: budget,
        transactions: transactions,
        reference: DateTime.utc(2024, 1, 25),
      );

      expect(progress.spent, closeTo(120, 0.0001));
      expect(progress.remaining, closeTo(-20, 0.0001));
      expect(progress.utilization, closeTo(1.2, 0.0001));
      expect(progress.isExceeded, isTrue);
    });

    test('filters transactions by category scope', () {
      final Budget budget = buildBudget(
        scope: BudgetScope.byCategory,
        categories: <String>['food'],
      );
      final List<TransactionEntity> transactions = <TransactionEntity>[
        tx(
          id: 't1',
          amount: -25,
          categoryId: 'food',
          date: DateTime.utc(2024, 1, 5),
        ),
        tx(
          id: 't2',
          amount: -30,
          categoryId: 'transport',
          date: DateTime.utc(2024, 1, 6),
        ),
      ];

      final List<TransactionEntity> filtered = useCase.filterTransactions(
        budget: budget,
        transactions: transactions,
        reference: DateTime.utc(2024, 1, 10),
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.id, 't1');
    });

    test('reuses existing instance when period matches', () {
      final DateTime periodStart = DateTime.utc(2024, 2, 1, 0, 1);
      final Budget budget = buildBudget(start: periodStart);
      final BudgetInstance existing = BudgetInstance(
        id: 'instance',
        budgetId: budget.id,
        periodStart: periodStart,
        periodEnd: DateTime.utc(2024, 3, 1, 0, 1),
        amount: 80,
        spent: 10,
        status: BudgetInstanceStatus.pending,
        createdAt: periodStart,
        updatedAt: periodStart,
      );

      final TransactionEntity transaction = tx(
        id: 't1',
        amount: -40,
        date: DateTime.utc(2024, 2, 10),
      );

      final BudgetProgress progress = useCase(
        budget: budget,
        transactions: <TransactionEntity>[transaction],
        reference: DateTime.utc(2024, 2, 15),
        existingInstance: existing,
      );

      expect(progress.instance.id, existing.id);
      expect(progress.instance.spent, closeTo(40, 0.0001));
      expect(progress.instance.status, BudgetInstanceStatus.active);
    });
  });
}
