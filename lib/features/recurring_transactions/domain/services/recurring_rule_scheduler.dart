import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';

class RecurringRuleScheduleResult {
  const RecurringRuleScheduleResult({
    required this.dueDates,
    required this.nextDue,
  });

  final List<DateTime> dueDates;
  final DateTime nextDue;
}

class RecurringRuleScheduler {
  const RecurringRuleScheduler();

  RecurringRuleScheduleResult resolve({
    required RecurringRule rule,
    required DateTime now,
  }) {
    final DateTime nowLocal = now.toLocal();
    final int targetDay = rule.dayOfMonth.clamp(1, 31);
    final int hour = rule.applyAtLocalHour.clamp(0, 23);
    final int minute = rule.applyAtLocalMinute.clamp(0, 59);

    DateTime nextDue = _initialDue(
      rule,
      targetDay: targetDay,
      hour: hour,
      minute: minute,
    );
    final DateTime lastRun =
        rule.lastRunAt?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);

    while (!nextDue.isAfter(lastRun)) {
      nextDue = _advanceMonth(
        nextDue,
        targetDay: targetDay,
        hour: hour,
        minute: minute,
      );
    }

    final List<DateTime> dueDates = <DateTime>[];
    DateTime cursor = nextDue;
    while (!cursor.isAfter(nowLocal)) {
      dueDates.add(cursor);
      cursor = _advanceMonth(
        cursor,
        targetDay: targetDay,
        hour: hour,
        minute: minute,
      );
    }

    return RecurringRuleScheduleResult(dueDates: dueDates, nextDue: cursor);
  }

  DateTime _initialDue(
    RecurringRule rule, {
    required int targetDay,
    required int hour,
    required int minute,
  }) {
    final DateTime? stored = rule.nextDueLocalDate?.toLocal();
    if (stored != null) {
      return DateTime(stored.year, stored.month, stored.day, hour, minute);
    }

    final DateTime startLocal = rule.startAt.toLocal();
    final DateTime candidate = _buildDueDate(
      year: startLocal.year,
      month: startLocal.month,
      targetDay: targetDay,
      hour: hour,
      minute: minute,
    );
    if (!candidate.isBefore(startLocal)) {
      return candidate;
    }
    return _advanceMonth(
      candidate,
      targetDay: targetDay,
      hour: hour,
      minute: minute,
    );
  }

  DateTime _advanceMonth(
    DateTime from, {
    required int targetDay,
    required int hour,
    required int minute,
  }) {
    final int rawMonth = from.month + 1;
    final int normalizedMonth = ((rawMonth - 1) % 12) + 1;
    final int normalizedYear = from.year + ((rawMonth - 1) ~/ 12);
    return _buildDueDate(
      year: normalizedYear,
      month: normalizedMonth,
      targetDay: targetDay,
      hour: hour,
      minute: minute,
    );
  }

  DateTime _buildDueDate({
    required int year,
    required int month,
    required int targetDay,
    required int hour,
    required int minute,
  }) {
    final DateTime base = DateTime(year, month, 1);
    final DateTime nextMonth = DateTime(base.year, base.month + 1, 1);
    final int lastDay = nextMonth.subtract(const Duration(days: 1)).day;
    final int day = targetDay > lastDay ? lastDay : targetDay;
    return DateTime(base.year, base.month, day, hour, minute);
  }
}
