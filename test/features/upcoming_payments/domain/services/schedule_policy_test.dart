import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';

void main() {
  const SchedulePolicy policy = SchedulePolicy();

  group('computeNextRunLocal', () {
    test('корректно использует последний день месяца для dayOfMonth=31', () {
      final DateTime february = DateTime(2024, 2, 10, 12);
      final DateTime april = DateTime(2024, 4, 2, 8);
      final DateTime december = DateTime(2024, 12, 20, 7);

      expect(
        policy.computeNextRunLocal(fromLocal: february, dayOfMonth: 31),
        DateTime(2024, 2, 29, 0, 1),
      );
      expect(
        policy.computeNextRunLocal(fromLocal: april, dayOfMonth: 31),
        DateTime(2024, 4, 30, 0, 1),
      );
      expect(
        policy.computeNextRunLocal(fromLocal: december, dayOfMonth: 31),
        DateTime(2024, 12, 31, 0, 1),
      );
    });

    test('возвращает следующий месяц, если целевой день уже прошёл', () {
      final DateTime now = DateTime(2024, 5, 30, 12, 30);

      expect(
        policy.computeNextRunLocal(fromLocal: now, dayOfMonth: 15),
        DateTime(2024, 6, 15, 0, 1),
      );
    });
  });

  group('computeNextNotifyLocal', () {
    final DateTime nextRun = DateTime(2024, 7, 20, 0, 1);

    test('без смещения по дням', () {
      expect(
        policy.computeNextNotifyLocal(
          nextRunLocal: nextRun,
          notifyDaysBefore: 0,
          notifyTimeHhmm: '09:30',
        ),
        DateTime(2024, 7, 20, 9, 30),
      );
    });

    test('со смещением на 1 день', () {
      expect(
        policy.computeNextNotifyLocal(
          nextRunLocal: nextRun,
          notifyDaysBefore: 1,
          notifyTimeHhmm: '08:15',
        ),
        DateTime(2024, 7, 19, 8, 15),
      );
    });

    test('со смещением на неделю', () {
      expect(
        policy.computeNextNotifyLocal(
          nextRunLocal: nextRun,
          notifyDaysBefore: 7,
          notifyTimeHhmm: '18:45',
        ),
        DateTime(2024, 7, 13, 18, 45),
      );
    });
  });
}
