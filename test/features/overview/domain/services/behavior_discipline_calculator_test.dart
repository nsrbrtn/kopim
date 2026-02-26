import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/overview/domain/models/overview_behavior_progress.dart';
import 'package:kopim/features/overview/domain/services/behavior_discipline_calculator.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  group('BehaviorDisciplineCalculator', () {
    test('для пустой истории возвращает нулевой прогресс', () {
      final DateTime reference = DateTime(2026, 2, 25);

      final OverviewBehaviorProgress result =
          BehaviorDisciplineCalculator.calculate(
            transactions: const <TransactionEntity>[],
            reference: reference,
          );

      expect(result.activeDays30d, 0);
      expect(result.streakDays, 0);
      expect(result.disciplineScore, 0);
      expect(result.progress, 0);
    });

    test('считает score из activeDays и streak за окно 30 дней', () {
      final DateTime reference = DateTime(2026, 2, 15);
      final DateTime createdAt = DateTime(2026, 1, 1);
      final List<TransactionEntity> transactions = <TransactionEntity>[
        _expense('tx-1', 'a', DateTime(2026, 2, 15), createdAt),
        _expense('tx-2', 'a', DateTime(2026, 2, 14), createdAt),
        _expense('tx-3', 'a', DateTime(2026, 2, 13), createdAt),
        _expense('tx-4', 'a', DateTime(2026, 2, 1), createdAt),
        _expense('tx-5', 'a', DateTime(2026, 1, 20), createdAt),
      ];

      final OverviewBehaviorProgress result =
          BehaviorDisciplineCalculator.calculate(
            transactions: transactions,
            reference: reference,
          );

      expect(result.activeDays30d, 5);
      expect(result.streakDays, 3);
      expect(result.disciplineScore, 19);
      expect(result.progress, closeTo(0.19, 0.0001));
    });

    test(
      'ограничивает streakScore верхней границей и игнорирует удаленные',
      () {
        final DateTime reference = DateTime(2026, 2, 25);
        final DateTime createdAt = DateTime(2026, 1, 1);
        final List<TransactionEntity> transactions = <TransactionEntity>[
          for (int offset = 0; offset < 20; offset += 1)
            _expense(
              'tx-$offset',
              'a',
              reference.subtract(Duration(days: offset)),
              createdAt,
            ),
          _expense(
            'deleted',
            'a',
            reference.subtract(const Duration(days: 20)),
            createdAt,
            isDeleted: true,
          ),
        ];

        final OverviewBehaviorProgress result =
            BehaviorDisciplineCalculator.calculate(
              transactions: transactions,
              reference: reference,
            );

        expect(result.activeDays30d, 20);
        expect(result.streakDays, 20);
        expect(result.disciplineScore, 80);
        expect(result.progress, closeTo(0.8, 0.0001));
      },
    );
  });
}

TransactionEntity _expense(
  String id,
  String accountId,
  DateTime date,
  DateTime createdAt, {
  bool isDeleted = false,
}) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    amountMinor: BigInt.from(-1000),
    amountScale: 2,
    date: date,
    type: TransactionType.expense.storageValue,
    createdAt: createdAt,
    updatedAt: createdAt,
    isDeleted: isDeleted,
  );
}
