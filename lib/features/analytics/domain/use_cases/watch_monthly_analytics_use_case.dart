import 'dart:math' as math;

import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
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
    AnalyticsFilter? filter,
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
          topIncomeCategories: <AnalyticsCategoryBreakdown>[],
        );
      }

      final AnalyticsFilter effectiveFilter =
          filter ?? AnalyticsFilter.monthly(reference: reference);
      final DateTime start = effectiveFilter.start;
      final DateTime end = effectiveFilter.end;

      double totalIncome = 0;
      double totalExpense = 0;
      final Map<String?, double> expenseByCategory = <String?, double>{};
      final Map<String?, double> incomeByCategory = <String?, double>{};

      for (final TransactionEntity transaction in transactions) {
        if (transaction.date.isBefore(start) ||
            !transaction.date.isBefore(end)) {
          continue;
        }

        if (effectiveFilter.accountId != null &&
            transaction.accountId != effectiveFilter.accountId) {
          continue;
        }

        if (effectiveFilter.categoryId != null &&
            transaction.categoryId != effectiveFilter.categoryId) {
          continue;
        }

        final double amount = transaction.amount.abs();
        if (transaction.type == TransactionType.income.storageValue) {
          totalIncome += amount;
          final String? categoryKey = transaction.categoryId;
          incomeByCategory[categoryKey] =
              (incomeByCategory[categoryKey] ?? 0) + amount;
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

      final int expenseLimit = topCategoriesLimit <= 0
          ? sortedExpenses.length
          : math.min(topCategoriesLimit, sortedExpenses.length);

      final Iterable<AnalyticsCategoryBreakdown> topExpenses = sortedExpenses
          .take(expenseLimit)
          .map((MapEntry<String?, double> entry) {
            return AnalyticsCategoryBreakdown(
              categoryId: entry.key,
              amount: entry.value,
            );
          });

      final List<MapEntry<String?, double>> sortedIncomes =
          incomeByCategory.entries.toList()
            ..sort((MapEntry<String?, double> a, MapEntry<String?, double> b) {
              return b.value.compareTo(a.value);
            });

      final int incomeLimit = topCategoriesLimit <= 0
          ? sortedIncomes.length
          : math.min(topCategoriesLimit, sortedIncomes.length);

      final Iterable<AnalyticsCategoryBreakdown> topIncomes = sortedIncomes
          .take(incomeLimit)
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
        topIncomeCategories: List<AnalyticsCategoryBreakdown>.unmodifiable(
          topIncomes,
        ),
      );
    });
  }
}
