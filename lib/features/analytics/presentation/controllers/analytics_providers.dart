import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/material.dart' show DateTimeRange, DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsFilter analyticsFilters(Ref ref) {
  final AnalyticsFilterState state = ref.watch(
    analyticsFilterControllerProvider,
  );
  return state.toDomain();
}

@riverpod
Stream<AnalyticsOverview> analyticsFilteredStats(
  Ref ref, {
  int topCategoriesLimit = 5,
}) {
  final AnalyticsFilter filters = ref.watch(analyticsFiltersProvider);
  return ref
      .watch(watchMonthlyAnalyticsUseCaseProvider)
      .call(topCategoriesLimit: topCategoriesLimit, filter: filters);
}

@riverpod
Stream<List<Category>> analyticsCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
Stream<List<AccountEntity>> analyticsAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}

@immutable
class AnalyticsCategoryTransactionsFilter {
  AnalyticsCategoryTransactionsFilter({
    required Iterable<String> categoryIds,
    required this.includeUncategorized,
    required this.type,
  }) : categoryIds = List<String>.unmodifiable(
         (categoryIds.toSet().toList()..sort()),
       );

  final List<String> categoryIds;
  final bool includeUncategorized;
  final TransactionType type;

  bool matchesCategory(String? categoryId) {
    if (categoryId == null) {
      return includeUncategorized;
    }
    return categoryIds.contains(categoryId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AnalyticsCategoryTransactionsFilter &&
        listEquals(other.categoryIds, categoryIds) &&
        other.includeUncategorized == includeUncategorized &&
        other.type == type;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(categoryIds), includeUncategorized, type);
}

final StreamProviderFamily<
  List<TransactionEntity>,
  AnalyticsCategoryTransactionsFilter
>
analyticsCategoryTransactionsProvider =
    StreamProvider.family<
      List<TransactionEntity>,
      AnalyticsCategoryTransactionsFilter
    >((Ref ref, AnalyticsCategoryTransactionsFilter filter) {
      if (filter.categoryIds.isEmpty && !filter.includeUncategorized) {
        return Stream<List<TransactionEntity>>.value(
          const <TransactionEntity>[],
        );
      }

      final AnalyticsFilterState state = ref.watch(
        analyticsFilterControllerProvider,
      );
      final DateTimeRange range = state.dateRange;
      final DateTime start = DateUtils.dateOnly(range.start);
      final DateTime end = DateUtils.dateOnly(range.end);

      return ref.watch(transactionRepositoryProvider).watchTransactions().map((
        List<TransactionEntity> transactions,
      ) {
        final List<TransactionEntity> filtered =
            transactions
                .where((TransactionEntity transaction) {
                  final DateTime date = DateUtils.dateOnly(transaction.date);
                  if (date.isBefore(start) || date.isAfter(end)) {
                    return false;
                  }
                  if (state.accountIds.isNotEmpty &&
                      !state.accountIds.contains(transaction.accountId)) {
                    return false;
                  }
                  if (transaction.type != filter.type.storageValue) {
                    return false;
                  }
                  if (!filter.matchesCategory(transaction.categoryId)) {
                    return false;
                  }
                  return true;
                })
                .toList(growable: false)
              ..sort(
                (TransactionEntity a, TransactionEntity b) =>
                    b.date.compareTo(a.date),
              );
        return filtered;
      });
    });

@riverpod
Stream<List<MonthlyBalanceData>> monthlyBalanceData(Ref ref) {
  final Set<String> selectedAccountIds = ref.watch(
    analyticsFilterControllerProvider.select(
      (AnalyticsFilterState s) => s.accountIds,
    ),
  );
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    analyticsAccountsProvider,
  );

  final List<AccountEntity> accounts =
      accountsAsync.value ?? const <AccountEntity>[];

  return ref.watch(transactionRepositoryProvider).watchTransactions().map((
    List<TransactionEntity> transactions,
  ) {
    final DateTime now = DateTime.now();
    final List<MonthlyBalanceData> result = <MonthlyBalanceData>[];

    // Фильтруем счета
    final List<AccountEntity> relevantAccounts = accounts.where((
      AccountEntity account,
    ) {
      if (!isCashAccountType(account.type)) {
        return false;
      }
      if (selectedAccountIds.isEmpty) {
        return true;
      }
      return selectedAccountIds.contains(account.id);
    }).toList();
    final Set<String> relevantAccountIds = relevantAccounts
        .map((AccountEntity account) => account.id)
        .toSet();

    // Начальный баланс (текущий)
    final MoneyAccumulator currentBalance = MoneyAccumulator();
    for (final AccountEntity account in relevantAccounts) {
      final MoneyAmount amount = resolveMoneyAmount(
        amount: account.balance,
        minor: account.balanceMinor,
        scale: account.currencyScale,
      );
      currentBalance.add(amount);
    }

    // Сортируем транзакции по дате (от новых к старым)
    // Предполагаем, что репозиторий может возвращать не сортированные
    final List<TransactionEntity> sortedTransactions =
        transactions.where((TransactionEntity t) {
          return relevantAccountIds.contains(t.accountId);
        }).toList()..sort(
          (TransactionEntity a, TransactionEntity b) =>
              b.date.compareTo(a.date),
        );

    int txIndex = 0;
    final MoneyAccumulator runningBalance = MoneyAccumulator();
    runningBalance.add(
      MoneyAmount(minor: currentBalance.minor, scale: currentBalance.scale),
    );

    // Генерируем данные за последние 6 месяцев (от текущего назад)
    for (int i = 0; i < 6; i++) {
      // Для текущего месяца берем now как конец диапазона, чтобы не учитывать будущие транзакции (если они есть)
      // Но для алгоритма "отката" нам нужно просто знать границы месяца.
      // Если есть транзакции в будущем (позже now), их нужно откатить до начала обработки.

      final DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final DateTime monthEnd = DateTime(
        monthDate.year,
        monthDate.month + 1,
        0,
        23,
        59,
        59,
      );
      final DateTime monthStart = DateTime(
        monthDate.year,
        monthDate.month,
        1,
        0,
        0,
        0,
      );

      // 1. Откатываем транзакции, которые произошли ПОЗЖЕ конца этого месяца
      while (txIndex < sortedTransactions.length &&
          sortedTransactions[txIndex].date.isAfter(monthEnd)) {
        final TransactionEntity t = sortedTransactions[txIndex];
        final MoneyAmount amount = _resolveTransactionAmount(t);
        if (t.type == TransactionType.income.storageValue) {
          runningBalance.subtract(amount);
        } else if (t.type == TransactionType.expense.storageValue) {
          runningBalance.add(amount);
        }
        txIndex++;
      }

      // Теперь runningBalance соответствует балансу на конец месяца (monthEnd)
      double maxBalanceInMonth = runningBalance.toDouble();

      // 2. Проходим по транзакциям ВНУТРИ месяца, отслеживая макс. баланс
      while (txIndex < sortedTransactions.length &&
          sortedTransactions[txIndex].date.isAfter(
            monthStart.subtract(const Duration(microseconds: 1)),
          )) {
        // runningBalance здесь - это баланс ПОСЛЕ транзакции t
        final double runningValue = runningBalance.toDouble();
        if (runningValue > maxBalanceInMonth) {
          maxBalanceInMonth = runningValue;
        }

        final TransactionEntity t = sortedTransactions[txIndex];
        final MoneyAmount amount = _resolveTransactionAmount(t);
        // Откатываем транзакцию
        if (t.type == TransactionType.income.storageValue) {
          runningBalance.subtract(amount);
        } else if (t.type == TransactionType.expense.storageValue) {
          runningBalance.add(amount);
        }

        // runningBalance теперь - это баланс ДО транзакции t
        // Проверяем его тоже, так как это могло быть пиковое значение до списания
        final double updatedValue = runningBalance.toDouble();
        if (updatedValue > maxBalanceInMonth) {
          maxBalanceInMonth = updatedValue;
        }

        txIndex++;
      }

      // После цикла runningBalance соответствует балансу на начало месяца
      final double closingValue = runningBalance.toDouble();
      if (closingValue > maxBalanceInMonth) {
        maxBalanceInMonth = closingValue;
      }

      // Добавляем в начало списка, чтобы порядок был хронологический (если нужно)
      // Но исходный код добавлял через .add в цикле 5..0, то есть от старого к новому.
      // Здесь мы идем 0..5 (от нового к старому).
      // Значит, результат будет [Текущий, -1 мес, -2 мес...].
      // Если график ожидает хронологический порядок, нужно будет развернуть.
      result.add(
        MonthlyBalanceData(month: monthDate, totalBalance: maxBalanceInMonth),
      );
    }

    return result.reversed.toList();
  });
}

final StreamProvider<List<MonthlyCashflowData>>
monthlyCashflowDataProvider = StreamProvider<List<MonthlyCashflowData>>((
  Ref ref,
) {
  final Set<String> selectedAccountIds = ref.watch(
    analyticsFilterControllerProvider.select(
      (AnalyticsFilterState s) => s.accountIds,
    ),
  );

  final DateTime now = DateTime.now();
  final DateTime currentMonth = DateTime(now.year, now.month);

  final List<DateTime> months = List<DateTime>.generate(
    12,
    (int index) =>
        DateTime(currentMonth.year, currentMonth.month - (11 - index)),
    growable: false,
  );
  final Map<int, int> monthIndexByKey = <int, int>{
    for (int i = 0; i < months.length; i++) _monthKey(months[i]): i,
  };

  return ref.watch(transactionRepositoryProvider).watchTransactions().map((
    List<TransactionEntity> transactions,
  ) {
    final List<MoneyAccumulator> incomes = List<MoneyAccumulator>.generate(
      12,
      (_) => MoneyAccumulator(),
    );
    final List<MoneyAccumulator> expenses = List<MoneyAccumulator>.generate(
      12,
      (_) => MoneyAccumulator(),
    );
    final DateTime nowInclusive = now.add(const Duration(microseconds: 1));

    for (final TransactionEntity transaction in transactions) {
      if (selectedAccountIds.isNotEmpty &&
          !selectedAccountIds.contains(transaction.accountId)) {
        continue;
      }

      final DateTime monthStart = DateTime(
        transaction.date.year,
        transaction.date.month,
      );
      final int? index = monthIndexByKey[_monthKey(monthStart)];
      if (index == null) {
        continue;
      }

      // Для текущего месяца показываем данные "на сегодня", без будущих транзакций.
      if (monthStart == currentMonth &&
          transaction.date.isAfter(nowInclusive)) {
        continue;
      }

      final MoneyAmount amount = _resolveTransactionAmount(transaction);
      if (transaction.type == TransactionType.income.storageValue) {
        incomes[index].add(amount);
      } else if (transaction.type == TransactionType.expense.storageValue) {
        expenses[index].add(amount);
      }
    }

    return List<MonthlyCashflowData>.generate(
      12,
      (int index) => MonthlyCashflowData(
        month: months[index],
        income: incomes[index].toDouble(),
        expense: expenses[index].toDouble(),
      ),
      growable: false,
    );
  });
});

int _monthKey(DateTime monthStart) => monthStart.year * 100 + monthStart.month;

MoneyAmount _resolveTransactionAmount(TransactionEntity transaction) {
  return resolveMoneyAmount(
    amount: transaction.amount,
    minor: transaction.amountMinor,
    scale: transaction.amountScale,
    useAbs: true,
  );
}
