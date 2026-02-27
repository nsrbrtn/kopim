import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/features/profile/presentation/controllers/profile_activity_days_provider.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  group('resolveProfileActiveDaysForWindow', () {
    test('возвращает только уникальные даты внутри окна', () {
      final DateTime windowEnd = DateTime(2026, 2, 27);
      final DateTime windowStart = DateTime(2026, 2, 21);
      final List<TransactionEntity> transactions = <TransactionEntity>[
        _tx(id: '1', date: DateTime(2026, 2, 27, 9)),
        _tx(id: '2', date: DateTime(2026, 2, 27, 18)),
        _tx(id: '3', date: DateTime(2026, 2, 24, 12)),
      ];

      final Set<DateTime> result = resolveProfileActiveDaysForWindow(
        transactions: transactions,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(
        result,
        equals(<DateTime>{DateTime(2026, 2, 27), DateTime(2026, 2, 24)}),
      );
    });

    test('игнорирует даты вне окна активности', () {
      final DateTime windowEnd = DateTime(2026, 2, 27);
      final DateTime windowStart = DateTime(2026, 2, 21);
      final List<TransactionEntity> transactions = <TransactionEntity>[
        _tx(id: 'old', date: DateTime(2026, 2, 20, 23, 59)),
        _tx(id: 'in', date: DateTime(2026, 2, 21, 0, 1)),
        _tx(id: 'future', date: DateTime(2026, 2, 28, 0, 1)),
      ];

      final Set<DateTime> result = resolveProfileActiveDaysForWindow(
        transactions: transactions,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(result, equals(<DateTime>{DateTime(2026, 2, 21)}));
    });
  });
}

TransactionEntity _tx({required String id, required DateTime date}) {
  return TransactionEntity(
    id: id,
    accountId: 'acc-1',
    date: date,
    type: 'expense',
    createdAt: DateTime(2026, 2, 27),
    updatedAt: DateTime(2026, 2, 27),
  );
}
