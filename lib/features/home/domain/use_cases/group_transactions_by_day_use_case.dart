import 'package:flutter/material.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class GroupTransactionsByDayUseCase {
  const GroupTransactionsByDayUseCase();

  List<DaySection> call({
    required List<TransactionEntity> transactions,
    DateTime? reference,
  }) {
    if (transactions.isEmpty) {
      return const <DaySection>[];
    }

    final Map<DateTime, List<TransactionEntity>> grouped =
        <DateTime, List<TransactionEntity>>{};

    for (final TransactionEntity transaction in transactions) {
      final DateTime day = DateUtils.dateOnly(transaction.date);
      grouped.putIfAbsent(day, () => <TransactionEntity>[]).add(transaction);
    }

    final List<DateTime> sortedDays = grouped.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    final List<DaySection> sections = <DaySection>[];

    for (final DateTime day in sortedDays) {
      final List<TransactionEntity> sortedTransactions =
          List<TransactionEntity>.from(grouped[day]!)..sort(
            (TransactionEntity a, TransactionEntity b) =>
                b.date.compareTo(a.date),
          );

      sections.add(
        DaySection(
          date: day,
          transactions: List<TransactionEntity>.unmodifiable(
            sortedTransactions,
          ),
        ),
      );
    }

    return List<DaySection>.unmodifiable(sections);
  }
}
