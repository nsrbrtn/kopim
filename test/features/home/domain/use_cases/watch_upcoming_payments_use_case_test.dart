import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/home/domain/models/upcoming_payment.dart';
import 'package:kopim/features/home/domain/use_cases/watch_upcoming_payments_use_case.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';

void main() {
  group('WatchUpcomingPaymentsUseCase.mapToUpcomingPayments', () {
    test('filters by status and rule activity, sorts by due date', () {
      final List<RecurringOccurrence> occurrences = <RecurringOccurrence>[
        RecurringOccurrence(
          id: 'o1',
          ruleId: 'r1',
          dueAt: DateTime.utc(2024, 10, 20),
          status: RecurringOccurrenceStatus.scheduled,
          createdAt: DateTime.utc(2024, 9, 1),
        ),
        RecurringOccurrence(
          id: 'o2',
          ruleId: 'r1',
          dueAt: DateTime.utc(2024, 10, 18),
          status: RecurringOccurrenceStatus.scheduled,
          createdAt: DateTime.utc(2024, 9, 1),
        ),
        RecurringOccurrence(
          id: 'o3',
          ruleId: 'r2',
          dueAt: DateTime.utc(2024, 10, 17),
          status: RecurringOccurrenceStatus.posted,
          createdAt: DateTime.utc(2024, 9, 1),
        ),
      ];

      final List<RecurringRule> rules = <RecurringRule>[
        RecurringRule(
          id: 'r1',
          title: 'Rent',
          accountId: 'acc-1',
          categoryId: 'cat-1',
          amount: 800,
          currency: 'usd',
          startAt: DateTime.utc(2024, 1, 1),
          timezone: 'UTC',
          rrule: 'FREQ=MONTHLY',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
        ),
        RecurringRule(
          id: 'r2',
          title: 'Gym',
          accountId: 'acc-1',
          categoryId: 'cat-2',
          amount: 50,
          currency: 'usd',
          startAt: DateTime.utc(2024, 1, 1),
          timezone: 'UTC',
          rrule: 'FREQ=MONTHLY',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
          isActive: false,
        ),
      ];

      final List<UpcomingPayment> payments =
          WatchUpcomingPaymentsUseCase.mapToUpcomingPayments(
            occurrences: occurrences,
            rules: rules,
          );

      expect(payments, hasLength(2));
      expect(payments.first.dueDate.isBefore(payments.last.dueDate), isTrue);
      expect(
        payments.every((UpcomingPayment payment) => payment.ruleId == 'r1'),
        isTrue,
      );
    });

    test('maps income amounts preserving sign', () {
      final List<RecurringOccurrence> occurrences = <RecurringOccurrence>[
        RecurringOccurrence(
          id: 'o1',
          ruleId: 'r-income',
          dueAt: DateTime.utc(2024, 11, 1),
          status: RecurringOccurrenceStatus.scheduled,
          createdAt: DateTime.utc(2024, 9, 1),
        ),
      ];

      final List<RecurringRule> rules = <RecurringRule>[
        RecurringRule(
          id: 'r-income',
          title: 'Salary',
          accountId: 'acc-2',
          categoryId: 'cat-income',
          amount: -2500,
          currency: 'eur',
          startAt: DateTime.utc(2024, 1, 1),
          timezone: 'UTC',
          rrule: 'FREQ=MONTHLY',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
        ),
      ];

      final List<UpcomingPayment> payments =
          WatchUpcomingPaymentsUseCase.mapToUpcomingPayments(
            occurrences: occurrences,
            rules: rules,
          );

      expect(payments, hasLength(1));
      expect(payments.single.amount, -2500);
      expect(payments.single.currency, 'eur');
      expect(payments.single.isExpense, isFalse);
    });
  });
}
