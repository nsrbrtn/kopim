import 'package:meta/meta.dart';

/// Сервис работы с временем и локальными датами.
@immutable
abstract class TimeService {
  /// Возвращает текущее время в миллисекундах UTC.
  int nowMs();

  /// Возвращает текущее локальное время.
  DateTime nowLocal();

  /// Преобразует время в миллисекундах UTC в локальное представление.
  DateTime toLocal(int epochMs);

  /// Преобразует локальное или UTC время в миллисекунды UTC.
  int toEpochMs(DateTime dt);

  /// Создаёт локальный объект [DateTime] для указанных параметров.
  DateTime atLocalDateTime(int year, int month, int day, int hour, int minute);

  /// Парсит строку формата `HH:mm` в количество минут от полуночи.
  int parseHhmmToMinutes(String hhmm);
}

/// Реализация [TimeService], основанная на стандартном [DateTime].
class SystemTimeService implements TimeService {
  const SystemTimeService();

  @override
  int nowMs() {
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  @override
  DateTime nowLocal() {
    return DateTime.now();
  }

  @override
  DateTime toLocal(int epochMs) {
    return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
  }

  @override
  int toEpochMs(DateTime dt) {
    return dt.toUtc().millisecondsSinceEpoch;
  }

  @override
  DateTime atLocalDateTime(int year, int month, int day, int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }

  @override
  int parseHhmmToMinutes(String hhmm) {
    final _ParsedTime parsed = _ParsedTime.parse(hhmm);
    return parsed.hour * 60 + parsed.minute;
  }
}

class _ParsedTime {
  const _ParsedTime(this.hour, this.minute);

  final int hour;
  final int minute;

  static _ParsedTime parse(String value) {
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
    return _ParsedTime(hour, minute);
  }
}
