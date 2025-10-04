import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_scheduler.dart';

RecurringRule buildRule({
  required DateTime startAt,
  DateTime? nextDue,
  DateTime? lastRunAt,
  int dayOfMonth = 31,
}) {
  final DateTime created = DateTime.utc(2024, 1, 1);
  return RecurringRule(
    id: 'rule-1',
    title: 'Test',
    accountId: 'acc-1',
    categoryId: 'cat-1',
    amount: 100,
    currency: 'USD',
    startAt: startAt,
    timezone: 'Europe/Helsinki',
    rrule: 'FREQ=MONTHLY',
    notes: 'Test',
    dayOfMonth: dayOfMonth,
    applyAtLocalHour: 0,
    applyAtLocalMinute: 1,
    lastRunAt: lastRunAt,
    nextDueLocalDate: nextDue,
    autoPost: true,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  const RecurringRuleScheduler scheduler = RecurringRuleScheduler();

  test('clips to February 28 on non-leap year', () {
    final RecurringRule rule = buildRule(
      startAt: DateTime(2023, 1, 31, 0, 1),
      nextDue: DateTime(2023, 1, 31, 0, 1),
      lastRunAt: DateTime(2023, 1, 31, 0, 1),
    );
    final RecurringRuleScheduleResult result = scheduler.resolve(
      rule: rule,
      now: DateTime(2023, 2, 28, 0, 1),
    );

    expect(result.dueDates, hasLength(1));
    expect(result.dueDates.first, DateTime(2023, 2, 28, 0, 1));
    expect(result.nextDue, DateTime(2023, 3, 31, 0, 1));
  });

  test('clips to February 29 on leap year', () {
    final RecurringRule rule = buildRule(
      startAt: DateTime(2024, 1, 31, 0, 1),
      nextDue: DateTime(2024, 1, 31, 0, 1),
      lastRunAt: DateTime(2024, 1, 31, 0, 1),
    );
    final RecurringRuleScheduleResult result = scheduler.resolve(
      rule: rule,
      now: DateTime(2024, 2, 29, 0, 1),
    );

    expect(result.dueDates.first, DateTime(2024, 2, 29, 0, 1));
    expect(result.nextDue, DateTime(2024, 3, 31, 0, 1));
  });

  test('always schedules at 00:01 local time', () {
    final RecurringRule rule = buildRule(
      startAt: DateTime(2024, 5, 15, 0, 1),
      nextDue: DateTime(2024, 5, 15, 0, 1),
      lastRunAt: DateTime(2024, 5, 15, 0, 1),
      dayOfMonth: 15,
    );
    final RecurringRuleScheduleResult result = scheduler.resolve(
      rule: rule,
      now: DateTime(2024, 6, 20, 12, 0),
    );

    expect(result.dueDates, contains(DateTime(2024, 6, 15, 0, 1)));
    expect(result.nextDue, DateTime(2024, 7, 15, 0, 1));
  });

  test('skips occurrences at or before last run timestamp', () {
    final RecurringRule rule = buildRule(
      startAt: DateTime(2024, 1, 15, 0, 1),
      nextDue: DateTime(2024, 4, 15, 0, 1),
      lastRunAt: DateTime(2024, 4, 15, 0, 1),
      dayOfMonth: 15,
    );

    final RecurringRuleScheduleResult result = scheduler.resolve(
      rule: rule,
      now: DateTime(2024, 6, 5, 12, 0),
    );

    expect(result.dueDates, equals(<DateTime>[DateTime(2024, 5, 15, 0, 1)]));
    expect(result.nextDue, DateTime(2024, 6, 15, 0, 1));
  });

  test('returns today as due when anchor is in the past', () {
    final RecurringRule rule = buildRule(
      startAt: DateTime(2024, 1, 20, 0, 1),
      nextDue: DateTime(2024, 3, 20, 0, 1),
      lastRunAt: DateTime(2024, 2, 20, 0, 1),
      dayOfMonth: 20,
    );

    final RecurringRuleScheduleResult result = scheduler.resolve(
      rule: rule,
      now: DateTime(2024, 3, 20, 15, 30),
    );

    expect(result.dueDates, contains(DateTime(2024, 3, 20, 0, 1)));
    expect(result.nextDue, DateTime(2024, 4, 20, 0, 1));
  });
}
