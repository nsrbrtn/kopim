import 'package:kopim/features/overview/domain/models/overview_behavior_progress.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class BehaviorDisciplineCalculator {
  const BehaviorDisciplineCalculator._();

  static const int windowDays = 30;
  static const int streakTargetDays = 14;

  static OverviewBehaviorProgress calculate({
    required List<TransactionEntity> transactions,
    required DateTime reference,
  }) {
    final DateTime today = _dateOnly(reference);
    final DateTime start = today.subtract(const Duration(days: windowDays - 1));
    final DateTime endExclusive = today.add(const Duration(days: 1));

    final Set<int> activeDays = <int>{};
    for (final TransactionEntity tx in transactions) {
      if (tx.isDeleted) {
        continue;
      }
      if (tx.date.isBefore(start) || !tx.date.isBefore(endExclusive)) {
        continue;
      }
      activeDays.add(_dayKey(tx.date));
    }

    final double consistencyScore = _clampDouble(
      (activeDays.length / windowDays) * 100,
      0,
      100,
    );

    int streakDays = 0;
    for (int offset = 0; offset < windowDays; offset += 1) {
      final DateTime day = today.subtract(Duration(days: offset));
      if (!activeDays.contains(_dayKey(day))) {
        break;
      }
      streakDays += 1;
    }

    final double streakScore = _clampDouble(
      (streakDays / streakTargetDays) * 100,
      0,
      100,
    );
    final int disciplineScore = (consistencyScore * 0.6 + streakScore * 0.4)
        .round()
        .clamp(0, 100);

    return OverviewBehaviorProgress(
      disciplineScore: disciplineScore,
      streakDays: streakDays,
      activeDays30d: activeDays.length,
      progress: _clampDouble(disciplineScore / 100, 0, 1),
    );
  }
}

DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

int _dayKey(DateTime dateTime) {
  final DateTime day = _dateOnly(dateTime);
  return day.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

double _clampDouble(double value, double min, double max) {
  if (value.isNaN) {
    return min;
  }
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
