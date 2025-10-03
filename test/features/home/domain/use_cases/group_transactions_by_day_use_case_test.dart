import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  const GroupTransactionsByDayUseCase useCase = GroupTransactionsByDayUseCase();

  TransactionEntity buildTransaction(String id, DateTime date) {
    return TransactionEntity(
      id: id,
      accountId: 'account',
      categoryId: null,
      amount: 10,
      date: date,
      note: null,
      type: 'expense',
      createdAt: date,
      updatedAt: date,
    );
  }

  test('groups transactions by calendar day in descending order', () {
    final DateTime reference = DateTime(2024, 9, 30, 10);
    final TransactionEntity firstOfDay = buildTransaction('1', reference);
    final TransactionEntity laterSameDay = buildTransaction(
      '2',
      reference.add(const Duration(hours: 3)),
    );
    final TransactionEntity previousDay = buildTransaction(
      '3',
      reference.subtract(const Duration(days: 1, hours: 1)),
    );

    final List<DaySection> sections = useCase(
      transactions: <TransactionEntity>[previousDay, firstOfDay, laterSameDay],
      reference: reference,
    );

    expect(sections, hasLength(2));
    expect(sections.first.date, DateTime(2024, 9, 30));
    expect(
      sections.first.transactions.map((TransactionEntity e) => e.id),
      <String>['2', '1'],
    );
    expect(sections.last.date, DateTime(2024, 9, 29));
    expect(
      sections.last.transactions.map((TransactionEntity e) => e.id),
      <String>['3'],
    );
  });

  test('returns an empty list when there are no transactions', () {
    final List<DaySection> sections = useCase(
      transactions: const <TransactionEntity>[],
      reference: DateTime(2024),
    );

    expect(sections, isEmpty);
  });
}
