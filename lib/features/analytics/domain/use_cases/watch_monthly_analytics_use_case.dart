import 'dart:math' as math;

import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchMonthlyAnalyticsUseCase {
  WatchMonthlyAnalyticsUseCase({
    required TransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;

  Stream<AnalyticsOverview> call({
    DateTime? reference,
    int topCategoriesLimit = 5,
  }) {
    return _transactionRepository.watchTransactions().map((
      List<TransactionEntity> transactions,
    ) {
      if (transactions.isEmpty) {
        return const AnalyticsOverview(
          totalIncome: 0,
          totalExpense: 0,
          netBalance: 0,
          topExpenseCategories: <AnalyticsCategoryBreakdown>[],
        );
      }

      final DateTime now = reference ?? DateTime.now();
      final DateTime monthStart = DateTime(now.year, now.month);
      final DateTime monthEnd = DateTime(now.year, now.month + 1);

      double totalIncome = 0;
      double totalExpense = 0;
      final Map<String?, double> expenseByCategory = <String?, double>{};

      for (final TransactionEntity transaction in transactions) {
        if (transaction.date.isBefore(monthStart) ||
            !transaction.date.isBefore(monthEnd)) {
          continue;
        }

        final double amount = transaction.amount.abs();
        if (transaction.type == TransactionType.income.storageValue) {
          totalIncome += amount;
        } else if (transaction.type == TransactionType.expense.storageValue) {
          totalExpense += amount;
          final String? categoryKey = transaction.categoryId;
          expenseByCategory[categoryKey] =
              (expenseByCategory[categoryKey] ?? 0) + amount;
        }
      }

      final List<MapEntry<String?, double>> sortedExpenses =
          expenseByCategory.entries.toList()
            ..sort((MapEntry<String?, double> a, MapEntry<String?, double> b) {
              return b.value.compareTo(a.value);
            });

      final int effectiveLimit = topCategoriesLimit <= 0
          ? sortedExpenses.length
          : math.min(topCategoriesLimit, sortedExpenses.length);

      final Iterable<AnalyticsCategoryBreakdown> topExpenses = sortedExpenses
          .take(effectiveLimit)
          .map((MapEntry<String?, double> entry) {
            return AnalyticsCategoryBreakdown(
              categoryId: entry.key,
              amount: entry.value,
            );
          });

      return AnalyticsOverview(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netBalance: totalIncome - totalExpense,
        topExpenseCategories: List<AnalyticsCategoryBreakdown>.unmodifiable(
          topExpenses,
        ),
      );
    });
  }
}
