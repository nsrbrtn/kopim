import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_grouping.freezed.dart';

@freezed
abstract class TransactionListSection with _$TransactionListSection {
  const factory TransactionListSection({
    required String title,
    required List<TransactionEntity> transactions,
  }) = _TransactionListSection;
}

List<TransactionListSection> groupTransactionsByDay({
  required List<TransactionEntity> transactions,
  required DateTime today,
  required String localeName,
  required String todayLabel,
}) {
  if (transactions.isEmpty) {
    return const <TransactionListSection>[];
  }

  final Map<DateTime, List<TransactionEntity>> grouped =
      <DateTime, List<TransactionEntity>>{};

  for (final TransactionEntity transaction in transactions) {
    final DateTime date = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    grouped.putIfAbsent(date, () => <TransactionEntity>[]).add(transaction);
  }

  final List<DateTime> sortedDates = grouped.keys.toList()
    ..sort((DateTime a, DateTime b) => b.compareTo(a));

  final List<TransactionListSection> sections = <TransactionListSection>[];
  final DateTime normalizedToday = DateTime(today.year, today.month, today.day);
  final DateFormat dateFormat = DateFormat.MMMMd(localeName);

  for (final DateTime date in sortedDates) {
    final String title = date == normalizedToday
        ? todayLabel
        : toBeginningOfSentenceCase(dateFormat.format(date)) ??
              dateFormat.format(date);
    sections.add(
      TransactionListSection(
        title: title,
        transactions: List<TransactionEntity>.unmodifiable(grouped[date]!),
      ),
    );
  }

  return List<TransactionListSection>.unmodifiable(sections);
}
