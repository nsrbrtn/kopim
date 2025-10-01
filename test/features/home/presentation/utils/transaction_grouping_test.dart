import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopim/features/home/presentation/utils/transaction_grouping.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru');
  });

  group('groupTransactionsByDay', () {
    test('groups transactions by calendar day and keeps order', () {
      final DateTime today = DateTime(2024, 9, 30, 10);
      final TransactionEntity firstToday = _transaction('1', today);
      final TransactionEntity secondToday = _transaction(
        '2',
        today.add(const Duration(hours: 2)),
      );
      final TransactionEntity previousDay = _transaction(
        '3',
        today.subtract(const Duration(days: 1)),
      );

      final List<TransactionListSection> sections = groupTransactionsByDay(
        transactions: <TransactionEntity>[firstToday, secondToday, previousDay],
        today: DateTime(today.year, today.month, today.day),
        localeName: 'ru',
        todayLabel: 'Сегодня',
      );

      expect(sections.length, 2);
      expect(sections.first.title, 'Сегодня');
      expect(sections.first.transactions, <TransactionEntity>[
        firstToday,
        secondToday,
      ]);
      expect(sections.last.transactions, <TransactionEntity>[previousDay]);
    });
  });
}

TransactionEntity _transaction(String id, DateTime date) {
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
