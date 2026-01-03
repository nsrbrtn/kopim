import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';

void main() {
  const BudgetSchedule schedule = BudgetSchedule();

  Budget buildBudget({
    required DateTime start,
    DateTime? end,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) {
    return Budget(
      id: 'budget',
      title: 'Test',
      period: period,
      startDate: start,
      endDate: end,
      amount: 1000,
      scope: BudgetScope.all,
      categories: const <String>[],
      accounts: const <String>[],
      createdAt: start,
      updatedAt: start,
    );
  }

  group('BudgetSchedule.periodFor', () {
    test('returns calendar monthly window based on reference', () {
      final DateTime initial = DateTime(2024, 1, 15, 13, 45);
      final Budget budget = buildBudget(start: initial);

      // Reference in March should give March 1 to April 1
      final ({DateTime start, DateTime end}) period = schedule.periodFor(
        budget: budget,
        reference: DateTime(2024, 3, 5),
      );

      expect(period.start, DateTime(2024, 3, 1));
      expect(period.end, DateTime(2024, 4, 1));
    });

    test('returns weekly window starting on Monday', () {
      // 2024-01-18 is Thursday
      final DateTime initial = DateTime(2024, 1, 18);
      final Budget budget = buildBudget(
        start: initial,
        period: BudgetPeriod.weekly,
      );

      // Reference 2024-01-20 (Saturday) -> should give 2024-01-15 (Monday) to 2024-01-22 (Monday)
      final ({DateTime start, DateTime end}) period = schedule.periodFor(
        budget: budget,
        reference: DateTime(2024, 1, 20),
      );

      expect(period.start, DateTime(2024, 1, 15));
      expect(period.end, DateTime(2024, 1, 22));
    });

    test('uses exact bounds for custom budgets', () {
      final DateTime start = DateTime(2024, 4, 20);
      final DateTime end = DateTime(2024, 5, 20);
      final Budget budget = buildBudget(
        start: start,
        end: end,
        period: BudgetPeriod.custom,
      );

      final ({DateTime start, DateTime end}) period = schedule.periodFor(
        budget: budget,
      );

      expect(period.start, DateTime(2024, 4, 20));
      expect(period.end, DateTime(2024, 5, 20));
    });
  });

  group('BudgetSchedule.generateUpcomingInstances', () {
    test('produces instances aligned to calendar', () {
      final Budget budget = buildBudget(start: DateTime(2024, 6, 15));
      final Iterable<BudgetInstance> instances = schedule
          .generateUpcomingInstances(
            budget: budget,
            from: DateTime(2024, 6, 15),
            count: 2,
            idBuilder: (DateTime start) =>
                'instance-${start.toIso8601String()}',
          );

      final List<BudgetInstance> list = instances.toList();
      expect(list, hasLength(2));

      // First instance should be June
      expect(list.first.periodStart, DateTime(2024, 6, 1));
      expect(list.first.periodEnd, DateTime(2024, 7, 1));

      // Second instance should be July
      expect(list.last.periodStart, DateTime(2024, 7, 1));
      expect(list.last.periodEnd, DateTime(2024, 8, 1));
    });
  });

  group('BudgetSchedule.statusFor', () {
    test('returns correct status', () {
      final DateTime start = DateTime(2024, 5, 1);
      final DateTime end = DateTime(2024, 6, 1);

      expect(
        schedule.statusFor(
          clock: DateTime(2024, 4, 30, 23, 59),
          start: start,
          end: end,
        ),
        BudgetInstanceStatus.pending,
      );

      expect(
        schedule.statusFor(
          clock: DateTime(2024, 5, 15),
          start: start,
          end: end,
        ),
        BudgetInstanceStatus.active,
      );

      expect(
        schedule.statusFor(clock: DateTime(2024, 6, 1), start: start, end: end),
        BudgetInstanceStatus.closed,
      );
    });
  });
}
