import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  final RecurringRuleEngine engine = RecurringRuleEngine();

  RecurringRule buildRule({
    required String id,
    required String rrule,
    required DateTime startAt,
    RecurringRuleShortMonthPolicy shortMonthPolicy =
        RecurringRuleShortMonthPolicy.clipToLastDay,
    DateTime? endAt,
    String timezone = 'UTC',
    bool autoPost = false,
  }) {
    final DateTime now = DateTime.now().toUtc();
    return RecurringRule(
      id: id,
      title: 'Rule $id',
      accountId: 'acc',
      categoryId: 'cat',
      amount: 100,
      currency: 'USD',
      startAt: startAt,
      timezone: timezone,
      rrule: rrule,
      endAt: endAt,
      notes: null,
      isActive: true,
      autoPost: autoPost,
      reminderMinutesBefore: 0,
      shortMonthPolicy: shortMonthPolicy,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('RecurringRuleEngine', () {
    test('clips short months when policy is clipToLastDay', () async {
      final RecurringRule rule = buildRule(
        id: 'clip',
        rrule: 'FREQ=MONTHLY;BYMONTHDAY=31',
        startAt: DateTime.utc(2024, 1, 31, 10),
      );
      final List<RecurringOccurrence> occurrences = await engine
          .generateOccurrences(
            rule: rule,
            windowStart: DateTime.utc(2024, 1, 1),
            windowEnd: DateTime.utc(2024, 4, 30, 23, 59),
          );
      final List<DateTime> dates = occurrences
          .map((RecurringOccurrence e) => e.dueAt)
          .toList();
      expect(
        dates,
        containsAll(<DateTime>[
          DateTime.utc(2024, 1, 31, 10),
          DateTime.utc(2024, 2, 29, 10),
          DateTime.utc(2024, 3, 31, 10),
          DateTime.utc(2024, 4, 30, 10),
        ]),
      );
    });

    test('skips short months when policy is skipMonth', () async {
      final RecurringRule rule = buildRule(
        id: 'skip',
        rrule: 'FREQ=MONTHLY;BYMONTHDAY=31',
        startAt: DateTime.utc(2024, 1, 31, 8),
        shortMonthPolicy: RecurringRuleShortMonthPolicy.skipMonth,
      );
      final List<RecurringOccurrence> occurrences = await engine
          .generateOccurrences(
            rule: rule,
            windowStart: DateTime.utc(2024, 1, 1),
            windowEnd: DateTime.utc(2024, 4, 30, 23, 59),
          );
      final List<DateTime> dates = occurrences
          .map((RecurringOccurrence e) => e.dueAt)
          .toList();
      expect(dates, contains(DateTime.utc(2024, 1, 31, 8)));
      expect(dates, isNot(contains(DateTime.utc(2024, 2, 29, 8))));
      expect(dates, contains(DateTime.utc(2024, 3, 31, 8)));
      expect(dates, isNot(contains(DateTime.utc(2024, 4, 30, 8))));
    });

    test('preserves local time across DST transitions', () async {
      final RecurringRule rule = buildRule(
        id: 'dst',
        rrule: 'FREQ=WEEKLY',
        startAt: DateTime.utc(2024, 3, 1, 12),
        timezone: 'America/New_York',
      );
      final List<RecurringOccurrence> occurrences = await engine
          .generateOccurrences(
            rule: rule,
            windowStart: DateTime.utc(2024, 3, 1),
            windowEnd: DateTime.utc(2024, 3, 31),
          );
      expect(occurrences, isNotEmpty);
      final tz.Location location = tz.getLocation('America/New_York');
      for (final RecurringOccurrence occurrence in occurrences.take(3)) {
        final tz.TZDateTime local = tz.TZDateTime.from(
          occurrence.dueAt,
          location,
        );
        expect(local.hour, 7); // 12:00 UTC == 7 AM EST/EDT
      }
    });

    test('stops generating after endAt', () async {
      final RecurringRule rule = buildRule(
        id: 'end',
        rrule: 'FREQ=MONTHLY;BYMONTHDAY=15',
        startAt: DateTime.utc(2024, 1, 15, 9),
        endAt: DateTime.utc(2024, 2, 16),
      );
      final List<RecurringOccurrence> occurrences = await engine
          .generateOccurrences(
            rule: rule,
            windowStart: DateTime.utc(2024, 1, 1),
            windowEnd: DateTime.utc(2024, 4, 1),
          );
      expect(occurrences.length, 2);
      expect(
        occurrences.map((RecurringOccurrence e) => e.dueAt).toList(),
        containsAll(<DateTime>[
          DateTime.utc(2024, 1, 15, 9),
          DateTime.utc(2024, 2, 15, 9),
        ]),
      );
    });
  });
}
