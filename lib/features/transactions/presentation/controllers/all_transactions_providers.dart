import 'package:flutter/material.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/controllers/all_transactions_filter_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_transactions_providers.g.dart';

@riverpod
Stream<List<TransactionEntity>> allTransactionsStream(Ref ref) {
  return ref.watch(watchRecentTransactionsUseCaseProvider).call(limit: 0);
}

@riverpod
AsyncValue<List<TransactionEntity>> filteredTransactions(Ref ref) {
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    allTransactionsStreamProvider,
  );
  final AllTransactionsFilterState filters = ref.watch(
    allTransactionsFilterControllerProvider,
  );

  return transactionsAsync.whenData(
    (List<TransactionEntity> transactions) =>
        _applyFilters(transactions, filters),
  );
}

@riverpod
Stream<List<AccountEntity>> allTransactionsAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}

@riverpod
Stream<List<Category>> allTransactionsCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

List<TransactionEntity> _applyFilters(
  List<TransactionEntity> transactions,
  AllTransactionsFilterState filters,
) {
  if (!filters.hasFilters) {
    return transactions;
  }
  return transactions
      .where((TransactionEntity transaction) {
        if (filters.accountId != null &&
            transaction.accountId != filters.accountId) {
          return false;
        }
        if (filters.categoryId != null &&
            transaction.categoryId != filters.categoryId) {
          return false;
        }
        final DateTimeRange? range = filters.dateRange;
        if (range != null) {
          final DateTime start = DateUtils.dateOnly(range.start);
          final DateTime end = DateUtils.dateOnly(range.end);
          final DateTime date = DateUtils.dateOnly(transaction.date);
          if (date.isBefore(start) || date.isAfter(end)) {
            return false;
          }
        }
        return true;
      })
      .toList(growable: false);
}
