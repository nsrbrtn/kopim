import 'dart:isolate';

import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:rrule/rrule.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class RecurringRuleEngine {
  RecurringRuleEngine({int? windowMonthsForward})
    : _windowMonthsForward = windowMonthsForward ?? 6;

  final int _windowMonthsForward;

  Future<List<RecurringOccurrence>> generateOccurrences({
    required RecurringRule rule,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    return Isolate.run(() {
      _ensureTimeZonesInitialized();
      return _generateOccurrences(
        rule: rule,
        windowStart: windowStart,
        windowEnd: windowEnd,
        windowMonthsForward: _windowMonthsForward,
      );
    });
  }
}

bool _tzInitialized = false;

void _ensureTimeZonesInitialized() {
  if (!_tzInitialized) {
    tzdata.initializeTimeZones();
    _tzInitialized = true;
  }
}

List<RecurringOccurrence> _generateOccurrences({
  required RecurringRule rule,
  required DateTime windowStart,
  required DateTime windowEnd,
  required int windowMonthsForward,
}) {
  final tz.Location location = tz.getLocation(rule.timezone);
  final tz.TZDateTime start = tz.TZDateTime.from(rule.startAt, location);

  final String rruleString = rule.rrule.trim().startsWith('RRULE:')
      ? rule.rrule.trim()
      : 'RRULE:${rule.rrule.trim()}';
  final RecurrenceRule recurrenceRule = RecurrenceRule.fromString(rruleString);

  final tz.TZDateTime localWindowStart = tz.TZDateTime.from(
    windowStart,
    location,
  );
  final tz.TZDateTime localWindowEnd = tz.TZDateTime.from(windowEnd, location);

  final Set<String> seenIds = <String>{};
  final List<RecurringOccurrence> occurrences = <RecurringOccurrence>[];
  final DateTime startFloating = _toFloatingUtc(start);
  final DateTime afterFloatingCandidate = _toFloatingUtc(
    localWindowStart,
  ).subtract(const Duration(seconds: 1));
  final DateTime afterFloating = afterFloatingCandidate.isBefore(startFloating)
      ? startFloating
      : afterFloatingCandidate;
  final DateTime beforeFloating = _toFloatingUtc(
    localWindowEnd,
  ).add(const Duration(seconds: 1));

  final Iterable<DateTime> generated = recurrenceRule.getInstances(
    start: startFloating,
    after: afterFloating,
    includeAfter: true,
    before: beforeFloating,
    includeBefore: true,
  );

  for (final DateTime occurrence in generated) {
    final tz.TZDateTime instance = tz.TZDateTime(
      location,
      occurrence.year,
      occurrence.month,
      occurrence.day,
      occurrence.hour,
      occurrence.minute,
      occurrence.second,
      occurrence.millisecond,
      occurrence.microsecond,
    );
    if (_isOutsideRule(instance, rule, localWindowStart, localWindowEnd)) {
      continue;
    }
    final String occurrenceId = _occurrenceId(rule.id, instance);
    if (seenIds.add(occurrenceId)) {
      occurrences.add(
        RecurringOccurrence(
          id: occurrenceId,
          ruleId: rule.id,
          dueAt: _asUtcDateTime(instance),
          createdAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  if (rule.shortMonthPolicy == RecurringRuleShortMonthPolicy.clipToLastDay &&
      recurrenceRule.frequency == Frequency.monthly) {
    final Set<int> targetDays = recurrenceRule.byMonthDays.isNotEmpty
        ? recurrenceRule.byMonthDays.toSet()
        : <int>{start.day};
    if (targetDays.isNotEmpty) {
      tz.TZDateTime cursor = tz.TZDateTime(
        location,
        localWindowStart.year,
        localWindowStart.month,
      );
      final tz.TZDateTime limit = tz.TZDateTime(
        location,
        localWindowEnd.year,
        localWindowEnd.month,
      );
      while (!cursor.isAfter(limit)) {
        for (final int day in targetDays) {
          final int lastDayOfMonth = DateTime(
            cursor.year,
            cursor.month + 1,
            0,
          ).day;
          final int resolvedDay = day > lastDayOfMonth ? lastDayOfMonth : day;
          final tz.TZDateTime candidate = tz.TZDateTime(
            location,
            cursor.year,
            cursor.month,
            resolvedDay,
            start.hour,
            start.minute,
            start.second,
            start.millisecond,
            start.microsecond,
          );
          if (_isOutsideRule(
            candidate,
            rule,
            localWindowStart,
            localWindowEnd,
          )) {
            continue;
          }
          final String occurrenceId = _occurrenceId(rule.id, candidate);
          if (seenIds.add(occurrenceId)) {
            occurrences.add(
              RecurringOccurrence(
                id: occurrenceId,
                ruleId: rule.id,
                dueAt: _asUtcDateTime(candidate),
                createdAt: DateTime.now().toUtc(),
              ),
            );
          }
        }
        cursor = tz.TZDateTime(location, cursor.year, cursor.month + 1);
      }
    }
  }

  occurrences.sort(
    (RecurringOccurrence a, RecurringOccurrence b) =>
        a.dueAt.compareTo(b.dueAt),
  );
  return occurrences;
}

bool _isOutsideRule(
  tz.TZDateTime instance,
  RecurringRule rule,
  tz.TZDateTime windowStart,
  tz.TZDateTime windowEnd,
) {
  if (instance.isBefore(windowStart)) {
    return true;
  }
  if (instance.isAfter(windowEnd)) {
    return true;
  }
  if (rule.endAt != null) {
    final DateTime endAtUtc = rule.endAt!.toUtc();
    if (instance.toUtc().isAfter(endAtUtc)) {
      return true;
    }
  }
  return false;
}

String _occurrenceId(String ruleId, tz.TZDateTime dueAt) {
  return '$ruleId-${dueAt.toUtc().toIso8601String()}';
}

DateTime _asUtcDateTime(tz.TZDateTime value) {
  return DateTime.fromMillisecondsSinceEpoch(
    value.millisecondsSinceEpoch,
    isUtc: true,
  );
}

DateTime _toFloatingUtc(tz.TZDateTime value) {
  return DateTime.utc(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}
