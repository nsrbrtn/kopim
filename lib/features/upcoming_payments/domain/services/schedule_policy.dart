class SchedulePolicy {
  const SchedulePolicy();

  /// Возвращает дату следующего автопроведения в локальной зоне времени.
  DateTime computeNextRunLocal({
    required DateTime fromLocal,
    required int dayOfMonth,
  }) {
    final DateTime candidate = _candidateForMonth(
      fromLocal.year,
      fromLocal.month,
      dayOfMonth: dayOfMonth,
    );
    if (!candidate.isBefore(fromLocal)) {
      return candidate;
    }
    final DateTime nextMonth = DateTime(fromLocal.year, fromLocal.month + 1);
    return _candidateForMonth(
      nextMonth.year,
      nextMonth.month,
      dayOfMonth: dayOfMonth,
    );
  }

  /// Возвращает дату и время уведомления с учётом смещения по дням.
  DateTime computeNextNotifyLocal({
    required DateTime nextRunLocal,
    required int notifyDaysBefore,
    required String notifyTimeHhmm,
  }) {
    final (_TimeParts time) = _parseHhmm(notifyTimeHhmm);
    final DateTime baseDate = nextRunLocal.subtract(
      Duration(days: notifyDaysBefore),
    );
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
  }

  /// Возвращает количество дней в месяце.
  int lastDayOfMonth(int year, int month) {
    final DateTime firstOfNextMonth = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    final DateTime lastDay = firstOfNextMonth.subtract(const Duration(days: 1));
    return lastDay.day;
  }

  DateTime _candidateForMonth(int year, int month, {required int dayOfMonth}) {
    final int lastDay = lastDayOfMonth(year, month);
    final int targetDay = dayOfMonth > lastDay ? lastDay : dayOfMonth;
    return DateTime(year, month, targetDay, 0, 1);
  }

  _TimeParts _parseHhmm(String value) {
    if (value.length != 5 || value[2] != ':') {
      throw FormatException('Ожидается формат HH:mm', value);
    }
    final int hour = int.parse(value.substring(0, 2));
    final int minute = int.parse(value.substring(3, 5));
    if (hour < 0 || hour > 23) {
      throw FormatException('Часы вне диапазона 0-23', value);
    }
    if (minute < 0 || minute > 59) {
      throw FormatException('Минуты вне диапазона 0-59', value);
    }
    return _TimeParts(hour: hour, minute: minute);
  }
}

class _TimeParts {
  const _TimeParts({required this.hour, required this.minute});

  final int hour;
  final int minute;
}
