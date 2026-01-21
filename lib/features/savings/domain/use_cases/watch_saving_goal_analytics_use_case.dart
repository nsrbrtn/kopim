import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kopim/core/money/money_utils.dart';
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
        return SavingGoalAnalytics(
          goalId: goalId,
          totalAmount: const MoneyAmount(minor: BigInt.zero, scale: 2),
        );
      }

      final Map<String?, MoneyAccumulator> totalsByCategory =
          <String?, MoneyAccumulator>{};
      final MoneyAccumulator totalAmount = MoneyAccumulator();
      DateTime? latest;

      for (final TransactionEntity transaction in related) {
        final MoneyAmount absolute = transaction.amountValue.abs();
        totalAmount.add(absolute);
        final String? key = transaction.categoryId;
        totalsByCategory.putIfAbsent(key, MoneyAccumulator.new).add(absolute);
        if (latest == null || transaction.date.isAfter(latest)) {
          latest = transaction.date;
        }
      }

      final List<SavingGoalCategoryBreakdown> breakdown = totalsByCategory
          .entries
          .map(
            (MapEntry<String?, MoneyAccumulator> entry) =>
                SavingGoalCategoryBreakdown(
                  categoryId: entry.key,
                  amount: MoneyAmount(
                    minor: entry.value.minor,
                    scale: entry.value.scale,
                  ),
                ),
          )
          .sorted(
            (SavingGoalCategoryBreakdown a, SavingGoalCategoryBreakdown b) =>
                b.amount.toDouble().compareTo(a.amount.toDouble()),
          )
          .toList(growable: false);

      return SavingGoalAnalytics(
        goalId: goalId,
        totalAmount: MoneyAmount(
          minor: totalAmount.minor,
          scale: totalAmount.scale,
        ),
        lastContributionAt: latest,
        categoryBreakdown: breakdown,
        transactionCount: related.length,
      );
    });
  }
}
