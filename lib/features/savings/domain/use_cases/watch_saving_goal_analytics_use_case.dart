import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_category_breakdown.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchSavingGoalAnalyticsUseCase {
  WatchSavingGoalAnalyticsUseCase({
    required TransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;

  Stream<SavingGoalAnalytics> call({required String goalId}) {
    return _transactionRepository.watchTransactions().map((
      List<TransactionEntity> transactions,
    ) {
      final Iterable<TransactionEntity> related = transactions.where(
        (TransactionEntity transaction) => transaction.savingGoalId == goalId,
      );

      if (related.isEmpty) {
        return SavingGoalAnalytics(goalId: goalId);
      }

      final Map<String?, double> totalsByCategory = <String?, double>{};
      double totalAmount = 0;
      DateTime? latest;

      for (final TransactionEntity transaction in related) {
        final double absolute = transaction.amountValue.abs().toDouble();
        totalAmount += absolute;
        final String? key = transaction.categoryId;
        totalsByCategory[key] = (totalsByCategory[key] ?? 0) + absolute;
        if (latest == null || transaction.date.isAfter(latest)) {
          latest = transaction.date;
        }
      }

      final List<SavingGoalCategoryBreakdown> breakdown = totalsByCategory
          .entries
          .map(
            (MapEntry<String?, double> entry) => SavingGoalCategoryBreakdown(
              categoryId: entry.key,
              amount: entry.value,
            ),
          )
          .sorted(
            (SavingGoalCategoryBreakdown a, SavingGoalCategoryBreakdown b) =>
                b.amount.compareTo(a.amount),
          )
          .toList(growable: false);

      return SavingGoalAnalytics(
        goalId: goalId,
        totalAmount: totalAmount,
        lastContributionAt: latest,
        categoryBreakdown: breakdown,
        transactionCount: related.length,
      );
    });
  }
}
