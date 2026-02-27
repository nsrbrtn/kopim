import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

final StreamProvider<Set<DateTime>> profileActivityDaysProvider =
    StreamProvider.autoDispose<Set<DateTime>>((Ref ref) {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime windowStart = today.subtract(const Duration(days: 6));

      return ref
          .watch(transactionRepositoryProvider)
          .watchTransactions()
          .map(
            (List<TransactionEntity> transactions) =>
                resolveProfileActiveDaysForWindow(
                  transactions: transactions,
                  windowStart: windowStart,
                  windowEnd: today,
                ),
          );
    });

Set<DateTime> resolveProfileActiveDaysForWindow({
  required List<TransactionEntity> transactions,
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final DateTime normalizedWindowStart = DateTime(
    windowStart.year,
    windowStart.month,
    windowStart.day,
  );
  final DateTime normalizedWindowEnd = DateTime(
    windowEnd.year,
    windowEnd.month,
    windowEnd.day,
  );

  final Set<DateTime> activeDays = <DateTime>{};
  for (final TransactionEntity transaction in transactions) {
    final DateTime localDate = transaction.date.toLocal();
    final DateTime day = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    if (day.isBefore(normalizedWindowStart) ||
        day.isAfter(normalizedWindowEnd)) {
      continue;
    }
    activeDays.add(day);
  }
  return Set<DateTime>.unmodifiable(activeDays);
}
