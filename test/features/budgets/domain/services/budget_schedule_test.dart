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
    test('returns normalized monthly window based on reference', () {
      final DateTime initial = DateTime.utc(2024, 1, 15, 13, 45);
      final Budget budget = buildBudget(start: initial);
      final ({DateTime start, DateTime end}) period = schedule.periodFor(
        budget: budget,
        reference: DateTime.utc(2024, 3, 5),
      );

      expect(
        period.start.isAtSameMomentAs(DateTime.utc(2024, 2, 15, 0, 1)),
        isTrue,
      );
      expect(
        period.end.isAtSameMomentAs(DateTime.utc(2024, 3, 15, 0, 1)),
        isTrue,
      );
    });

    test('uses normalized bounds for custom budgets with invalid end', () {
      final DateTime start = DateTime.utc(2024, 4, 20, 18);
      final Budget budget = buildBudget(
        start: start,
        end: DateTime.utc(2024, 4, 19),
        period: BudgetPeriod.custom,
      );

      final ({DateTime start, DateTime end}) period = schedule.periodFor(
        budget: budget,
      );

      expect(
        period.start.isAtSameMomentAs(DateTime.utc(2024, 4, 20, 0, 1)),
        isTrue,
      );
      expect(
        period.end.isAtSameMomentAs(DateTime.utc(2024, 4, 21, 0, 1)),
        isTrue,
      );
    });
  });

  group('BudgetSchedule.generateUpcomingInstances', () {
    test('produces instances aligned to 00:01 and sequential periods', () {
      final Budget budget = buildBudget(start: DateTime.utc(2024, 6, 30, 12));
      final Iterable<BudgetInstance> instances = schedule
          .generateUpcomingInstances(
            budget: budget,
            from: DateTime.utc(2024, 6, 30, 12),
            count: 2,
            idBuilder: (DateTime start) =>
                'instance-${start.toIso8601String()}',
          );

      final List<BudgetInstance> list = instances.toList();
      expect(list, hasLength(2));
      expect(
        list.first.periodStart.isAtSameMomentAs(
          DateTime.utc(2024, 6, 30, 0, 1),
        ),
        isTrue,
      );
      expect(
        list.first.periodEnd.isAtSameMomentAs(DateTime.utc(2024, 7, 30, 0, 1)),
        isTrue,
      );
      expect(list.first.status, BudgetInstanceStatus.active);
      expect(
        list.last.periodStart.isAtSameMomentAs(DateTime.utc(2024, 7, 30, 0, 1)),
        isTrue,
      );
      expect(
        list.last.periodEnd.isAtSameMomentAs(DateTime.utc(2024, 8, 30, 0, 1)),
        isTrue,
      );
    });
  });

  group('BudgetSchedule.statusFor', () {
    test('returns pending before start and active within window', () {
      final DateTime start = DateTime.utc(2024, 5, 1, 0, 1);
      final DateTime end = DateTime.utc(2024, 6, 1, 0, 1);

      expect(
        schedule.statusFor(
          clock: DateTime.utc(2024, 4, 30, 23, 59),
          start: start,
          end: end,
        ),
        BudgetInstanceStatus.pending,
      );

      expect(
        schedule.statusFor(
          clock: DateTime.utc(2024, 5, 15),
          start: start,
          end: end,
        ),
        BudgetInstanceStatus.active,
      );

      expect(
        schedule.statusFor(
          clock: DateTime.utc(2024, 6, 1, 0, 1),
          start: start,
          end: end,
        ),
        BudgetInstanceStatus.closed,
      );
    });
  });
}
