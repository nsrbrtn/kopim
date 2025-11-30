import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';

class BudgetSchedule {
  const BudgetSchedule();

  ({DateTime start, DateTime end}) periodFor({
    required Budget budget,
    DateTime? reference,
  }) {
    final DateTime ref = _normalizeStart(reference ?? DateTime.now());
    final DateTime initialStart = _normalizeStart(budget.startDate);
    if (!budget.period.isRecurring) {
      final DateTime? rawEnd = budget.endDate;
      DateTime normalizedEnd = rawEnd != null
          ? _normalizeStart(rawEnd)
          : initialStart.add(const Duration(days: 1));
      if (!normalizedEnd.isAfter(initialStart)) {
        normalizedEnd = initialStart.add(const Duration(days: 1));
      }
      return (start: initialStart, end: normalizedEnd);
    }

    DateTime start = initialStart;
    DateTime end = _advance(budget.period, start);
    final DateTime? cutoff =
        budget.endDate != null ? _normalizeStart(budget.endDate!) : null;

    while (!ref.isBefore(end)) {
      final DateTime nextStart = end;
      if (cutoff != null && !nextStart.isBefore(cutoff)) {
        break;
      }
      start = nextStart;
      end = _advance(budget.period, start);
    }

    return (start: start, end: end);
  }

  BudgetInstance buildInstance({
    required Budget budget,
    required String instanceId,
    DateTime? reference,
    DateTime? now,
  }) {
    final ({DateTime start, DateTime end}) period = periodFor(
      budget: budget,
      reference: reference,
    );
    final DateTime clock = now ?? DateTime.now();
    final BudgetInstanceStatus status = statusFor(
      clock: clock,
      start: period.start,
      end: period.end,
    );
    return BudgetInstance(
      id: instanceId,
      budgetId: budget.id,
      periodStart: period.start,
      periodEnd: period.end,
      amount: budget.amount,
      status: status,
      createdAt: clock,
      updatedAt: clock,
    );
  }

  Iterable<BudgetInstance> generateUpcomingInstances({
    required Budget budget,
    required String Function(DateTime start) idBuilder,
    DateTime? from,
    int count = 1,
  }) sync* {
    final DateTime reference = from ?? DateTime.now();
    final ({DateTime start, DateTime end}) period = periodFor(
      budget: budget,
      reference: reference,
    );
    DateTime cursor = period.start;
    for (int i = 0; i < count; i++) {
      final DateTime instanceStart = i == 0 ? period.start : cursor;
      final DateTime instanceEnd = budget.period.isRecurring
          ? (i == 0 ? period.end : _advance(budget.period, instanceStart))
          : period.end;
      final BudgetInstanceStatus status = statusFor(
        clock: reference,
        start: instanceStart,
        end: instanceEnd,
      );
      yield BudgetInstance(
        id: idBuilder(instanceStart),
        budgetId: budget.id,
        periodStart: instanceStart,
        periodEnd: instanceEnd,
        amount: budget.amount,
        status: status,
        createdAt: reference,
        updatedAt: reference,
      );
      cursor = instanceEnd;
      if (!budget.period.isRecurring) {
        break;
      }
    }
  }

  DateTime _advance(BudgetPeriod period, DateTime start) {
    final DateTime normalized = _normalizeStart(start);
    switch (period) {
      case BudgetPeriod.monthly:
        final DateTime firstOfNextMonth = DateTime(
          normalized.year,
          normalized.month + 1,
          1,
        );
        final int lastDayOfNextMonth = DateTime(
          firstOfNextMonth.year,
          firstOfNextMonth.month + 1,
          0,
        ).day;
        final int resolvedDay = normalized.day > lastDayOfNextMonth
            ? lastDayOfNextMonth
            : normalized.day;
        return DateTime(
          firstOfNextMonth.year,
          firstOfNextMonth.month,
          resolvedDay,
        );
      case BudgetPeriod.weekly:
        return normalized.add(const Duration(days: 7));
      case BudgetPeriod.custom:
        return normalized;
    }
  }

  DateTime _normalizeStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  BudgetInstanceStatus statusFor({
    required DateTime clock,
    required DateTime start,
    required DateTime end,
  }) {
    if (clock.isBefore(start)) {
      return BudgetInstanceStatus.pending;
    }
    if (!clock.isBefore(end)) {
      return BudgetInstanceStatus.closed;
    }
    return BudgetInstanceStatus.active;
  }
}
