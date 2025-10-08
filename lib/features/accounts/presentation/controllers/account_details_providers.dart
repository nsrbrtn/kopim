import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_details_providers.freezed.dart';
part 'account_details_providers.g.dart';

@freezed
abstract class AccountTransactionsFilter with _$AccountTransactionsFilter {
  const factory AccountTransactionsFilter({
    DateTimeRange? dateRange,
    TransactionType? type,
    String? categoryId,
  }) = _AccountTransactionsFilter;

  const AccountTransactionsFilter._();

  bool get hasActiveFilters =>
      dateRange != null || type != null || categoryId != null;
}

@freezed
abstract class AccountTransactionSummary with _$AccountTransactionSummary {
  const factory AccountTransactionSummary({
    required double totalIncome,
    required double totalExpense,
  }) = _AccountTransactionSummary;

  const AccountTransactionSummary._();

  double get net => totalIncome - totalExpense;
}

@riverpod
Stream<AccountEntity?> accountDetails(Ref ref, String accountId) {
  return ref
      .watch(watchAccountsUseCaseProvider)
      .call()
      .map((List<AccountEntity> accounts) => _findAccount(accounts, accountId));
}

@riverpod
Stream<List<TransactionEntity>> accountTransactions(Ref ref, String accountId) {
  return ref
      .watch(watchAccountTransactionsUseCaseProvider)
      .call(accountId: accountId);
}

@riverpod
Stream<List<Category>> accountCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
AsyncValue<AccountTransactionSummary> accountTransactionSummary(
  Ref ref,
  String accountId,
) {
  return ref
      .watch(accountTransactionsProvider(accountId))
      .whenData(
        (List<TransactionEntity> transactions) => _computeSummary(transactions),
      );
}

@riverpod
class AccountTransactionsFilterController
    extends _$AccountTransactionsFilterController {
  @override
  AccountTransactionsFilter build(String accountId) {
    return const AccountTransactionsFilter();
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void setType(TransactionType? type) {
    state = state.copyWith(type: type);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void clear() {
    state = const AccountTransactionsFilter();
  }
}

@riverpod
AsyncValue<List<TransactionEntity>> filteredAccountTransactions(
  Ref ref,
  String accountId,
) {
  final AccountTransactionsFilter filter = ref.watch(
    accountTransactionsFilterControllerProvider(accountId),
  );
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    accountTransactionsProvider(accountId),
  );

  return transactionsAsync.whenData((List<TransactionEntity> transactions) {
    final Iterable<TransactionEntity> filtered = transactions.where((
      TransactionEntity transaction,
    ) {
      final bool matchesType =
          filter.type == null || transaction.type == filter.type!.storageValue;
      final bool matchesCategory =
          filter.categoryId == null ||
          transaction.categoryId == filter.categoryId;
      final bool matchesDate;
      if (filter.dateRange == null) {
        matchesDate = true;
      } else {
        final DateTimeRange range = filter.dateRange!;
        final DateTime endInclusive = range.end.add(const Duration(days: 1));
        matchesDate =
            !_isBefore(transaction.date, range.start) &&
            transaction.date.isBefore(endInclusive);
      }
      return matchesType && matchesCategory && matchesDate;
    });
    return List<TransactionEntity>.unmodifiable(filtered.toList());
  });
}

bool _isBefore(DateTime value, DateTime reference) {
  return value.isBefore(reference);
}

AccountEntity? _findAccount(List<AccountEntity> accounts, String id) {
  for (final AccountEntity account in accounts) {
    if (account.id == id) {
      return account;
    }
  }
  return null;
}

AccountTransactionSummary _computeSummary(
  List<TransactionEntity> transactions,
) {
  double income = 0;
  double expense = 0;
  for (final TransactionEntity transaction in transactions) {
    if (transaction.type == TransactionType.income.storageValue) {
      income += transaction.amount.abs();
    } else if (transaction.type == TransactionType.expense.storageValue) {
      expense += transaction.amount.abs();
    }
  }
  return AccountTransactionSummary(totalIncome: income, totalExpense: expense);
}
