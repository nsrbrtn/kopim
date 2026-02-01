import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
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

enum AccountDetailsPeriod { month, quarter, year }

@freezed
abstract class AccountTransactionSummary with _$AccountTransactionSummary {
  const factory AccountTransactionSummary({
    required MoneyAmount totalIncome,
    required MoneyAmount totalExpense,
  }) = _AccountTransactionSummary;

  const AccountTransactionSummary._();

  MoneyAmount get net {
    final MoneyAccumulator accumulator = MoneyAccumulator();
    accumulator.add(totalIncome);
    accumulator.subtract(totalExpense);
    return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
  }
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
class AccountDetailsPeriodController extends _$AccountDetailsPeriodController {
  @override
  AccountDetailsPeriod build(String accountId) {
    return AccountDetailsPeriod.month;
  }

  void set(AccountDetailsPeriod period) {
    state = period;
  }
}

@riverpod
DateTimeRange accountDetailsPeriodRange(Ref ref, String accountId) {
  final AccountDetailsPeriod period = ref.watch(
    accountDetailsPeriodControllerProvider(accountId),
  );
  return _resolvePeriodRange(DateTime.now(), period);
}

@riverpod
Stream<List<TransactionCategoryTotals>> accountTopCategoryTotals(
  Ref ref, {
  required String accountId,
  required DateTime start,
  required DateTime end,
}) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchAnalyticsCategoryTotals(
        start: start,
        end: end.add(const Duration(days: 1)),
        accountId: accountId,
      );
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
  final DateTimeRange range = ref.watch(
    accountDetailsPeriodRangeProvider(accountId),
  );
  return ref
      .watch(accountTransactionsProvider(accountId))
      .whenData(
        (List<TransactionEntity> transactions) =>
            _computeSummary(transactions, range: range),
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
  final DateTimeRange range = ref.watch(
    accountDetailsPeriodRangeProvider(accountId),
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
      final DateTime endInclusive = range.end.add(const Duration(days: 1));
      final bool matchesDate =
          !_isBefore(transaction.date, range.start) &&
          transaction.date.isBefore(endInclusive);
      return matchesType && matchesDate;
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
  List<TransactionEntity> transactions, {
  DateTimeRange? range,
}) {
  final MoneyAccumulator income = MoneyAccumulator();
  final MoneyAccumulator expense = MoneyAccumulator();
  final DateTime? start = range?.start;
  final DateTime? endInclusive = range?.end.add(const Duration(days: 1));
  for (final TransactionEntity transaction in transactions) {
    if (start != null && endInclusive != null) {
      if (transaction.date.isBefore(start) ||
          !transaction.date.isBefore(endInclusive)) {
        continue;
      }
    }
    if (transaction.type == TransactionType.income.storageValue) {
      income.add(transaction.amountValue.abs());
    } else if (transaction.type == TransactionType.expense.storageValue) {
      expense.add(transaction.amountValue.abs());
    }
  }
  return AccountTransactionSummary(
    totalIncome: MoneyAmount(minor: income.minor, scale: income.scale),
    totalExpense: MoneyAmount(minor: expense.minor, scale: expense.scale),
  );
}

DateTimeRange _resolvePeriodRange(DateTime now, AccountDetailsPeriod period) {
  final DateTime date = DateTime(now.year, now.month, now.day);
  switch (period) {
    case AccountDetailsPeriod.month:
      return DateTimeRange(
        start: DateTime(date.year, date.month, 1),
        end: date,
      );
    case AccountDetailsPeriod.quarter:
      final int quarterStartMonth = ((date.month - 1) ~/ 3) * 3 + 1;
      return DateTimeRange(
        start: DateTime(date.year, quarterStartMonth, 1),
        end: date,
      );
    case AccountDetailsPeriod.year:
      return DateTimeRange(start: DateTime(date.year, 1, 1), end: date);
  }
}
