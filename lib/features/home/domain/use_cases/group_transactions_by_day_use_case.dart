import 'package:flutter/material.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';

class GroupTransactionsByDayUseCase {
  const GroupTransactionsByDayUseCase();

  List<DaySection> call({
    required List<TransactionEntity> transactions,
    DateTime? reference,
  }) {
    if (transactions.isEmpty) {
      return const <DaySection>[];
    }

    // 1. Group by day
    final Map<DateTime, List<TransactionEntity>> byDay =
        <DateTime, List<TransactionEntity>>{};
    for (final TransactionEntity tx in transactions) {
      final DateTime day = DateUtils.dateOnly(tx.date);
      byDay.putIfAbsent(day, () => <TransactionEntity>[]).add(tx);
    }

    final List<DateTime> sortedDays = byDay.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    final List<DaySection> sections = <DaySection>[];

    for (final DateTime day in sortedDays) {
      final List<TransactionEntity> dayTransactions = byDay[day]!;

      // 2. Within the day, group by groupId
      final List<FeedItem> items = <FeedItem>[];
      final Map<String, List<TransactionEntity>> groups =
          <String, List<TransactionEntity>>{};
      final List<TransactionEntity> standalones = <TransactionEntity>[];

      for (final TransactionEntity tx in dayTransactions) {
        if (tx.groupId != null && tx.groupId!.isNotEmpty) {
          groups.putIfAbsent(tx.groupId!, () => <TransactionEntity>[]).add(tx);
        } else {
          standalones.add(tx);
        }
      }

      // Add groups as FeedItems
      for (final MapEntry<String, List<TransactionEntity>> entry
          in groups.entries) {
        final String groupId = entry.key;
        final List<TransactionEntity> txs = entry.value;

        // Calculate total outflow (simplified: sum of all transaction amounts in group)
        // In real app we might want to distinguish income/expense in group,
        // but for credit payments they are usually outflows from source account.

        final TransactionEntity firstTx = txs.first;
        BigInt totalMinor = BigInt.zero;
        for (final TransactionEntity tx in txs) {
          totalMinor += tx.amountMinor ?? BigInt.zero;
        }

        items.add(
          FeedItem.groupedCreditPayment(
            groupId: groupId,
            creditId: '', // To be filled or handled by UI
            transactions: txs,
            totalOutflow: Money.fromMinor(
              totalMinor,
              currency: 'XXX',
              scale: firstTx.amountScale ?? 2,
            ),
            date: firstTx.date,
            note: txs
                .map((TransactionEntity e) => e.note)
                .where((String? n) => n != null && n.isNotEmpty)
                .join('; '),
          ),
        );
      }

      // Add standalones
      for (final TransactionEntity tx in standalones) {
        items.add(FeedItem.transaction(tx));
      }

      items.sort((FeedItem a, FeedItem b) {
        final DateTime dateA = a.when(
          transaction: (TransactionEntity tx) => tx.date,
          groupedCreditPayment:
              (
                String groupId,
                String creditId,
                List<TransactionEntity> transactions,
                Money totalOutflow,
                DateTime date,
                String? note,
              ) =>
                  date,
        );
        final DateTime dateB = b.when(
          transaction: (TransactionEntity tx) => tx.date,
          groupedCreditPayment:
              (
                String groupId,
                String creditId,
                List<TransactionEntity> transactions,
                Money totalOutflow,
                DateTime date,
                String? note,
              ) =>
                  date,
        );
        return dateB.compareTo(dateA);
      });

      sections.add(DaySection(date: day, items: items));
    }

    return sections;
  }
}
