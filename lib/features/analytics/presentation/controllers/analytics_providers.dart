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
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
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

final Provider<SortedIds> analyticsSelectedAccountIdsProvider =
    Provider<SortedIds>((Ref ref) {
      return ref.watch(
        analyticsFilterControllerProvider.select(
          (AnalyticsFilterState state) => SortedIds(state.accountIds),
        ),
      );
    });

final Provider<SortedIds> analyticsRelevantCashAccountIdsProvider =
    Provider<SortedIds>((Ref ref) {
      final SortedIds selected = ref.watch(analyticsSelectedAccountIdsProvider);
      final List<AccountEntity> accounts = ref.watch(
        analyticsAccountsProvider.select(
          (AsyncValue<List<AccountEntity>> value) =>
              value.value ?? const <AccountEntity>[],
        ),
      );
      final Iterable<AccountEntity> cashAccounts = accounts.where(
        (AccountEntity account) => isCashAccountType(account.type),
      );
      final Iterable<AccountEntity> filtered = selected.isEmpty
          ? cashAccounts
          : cashAccounts.where(
              (AccountEntity account) => selected.set.contains(account.id),
            );
      return SortedIds(
        filtered.map((AccountEntity account) => account.id).toSet(),
      );
    });

@immutable
class MonthlyCashflowWindow {
  const MonthlyCashflowWindow({
    required this.months,
    required this.monthIndexByKey,
    required this.start,
    required this.end,
    required this.nowInclusive,
  });

  final List<DateTime> months;
  final Map<int, int> monthIndexByKey;
  final DateTime start;
  final DateTime end;
  final DateTime nowInclusive;
}

@immutable
class MonthlyBalanceWindow {
  const MonthlyBalanceWindow({
    required this.months,
    required this.monthIndexByKey,
    required this.start,
    required this.end,
  });

  final List<DateTime> months;
  final Map<int, int> monthIndexByKey;
  final DateTime start;
  final DateTime end;
}

final Provider<MonthlyBalanceWindow> analyticsMonthlyBalanceWindowProvider =
    Provider<MonthlyBalanceWindow>((Ref ref) {
      final DateTime now = DateTime.now();
      final DateTime currentMonth = DateTime(now.year, now.month);
      final DateTime start = DateTime(
        currentMonth.year,
        currentMonth.month - 5,
      );
      final DateTime end = DateTime(currentMonth.year, currentMonth.month + 1);
      final List<DateTime> months = List<DateTime>.generate(
        6,
        (int index) =>
            DateTime(currentMonth.year, currentMonth.month - (5 - index)),
        growable: false,
      );
      final Map<int, int> monthIndexByKey = <int, int>{
        for (int i = 0; i < months.length; i++) _monthKey(months[i]): i,
      };
      return MonthlyBalanceWindow(
        months: months,
        monthIndexByKey: monthIndexByKey,
        start: start,
        end: end,
      );
    });

final Provider<MonthlyCashflowWindow> analyticsMonthlyCashflowWindowProvider =
    Provider<MonthlyCashflowWindow>((Ref ref) {
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
      final DateTime start = months.first;
      final DateTime end = DateTime(currentMonth.year, currentMonth.month + 1);
      final DateTime nowInclusive = now.add(const Duration(microseconds: 1));
      return MonthlyCashflowWindow(
        months: months,
        monthIndexByKey: monthIndexByKey,
        start: start,
        end: end,
        nowInclusive: nowInclusive,
      );
    });

@riverpod
Stream<AnalyticsOverview> analyticsFilteredStats(
  Ref ref, {
  int topCategoriesLimit = 5,
}) {
  final AnalyticsFilter filters = ref.watch(analyticsFiltersProvider);
  return ref
      .watch(watchMonthlyAnalyticsUseCaseProvider)
      .call(topCategoriesLimit: topCategoriesLimit, filter: filters)
      .distinct();
}

@riverpod
Stream<List<Category>> analyticsCategories(Ref ref) {
  return ref
      .watch(watchCategoriesUseCaseProvider)
      .call()
      .distinct(_listEqualsCategories);
}

@riverpod
Stream<List<AccountEntity>> analyticsAccounts(Ref ref) {
  return ref
      .watch(watchAccountsUseCaseProvider)
      .call()
      .distinct(_listEqualsAccounts);
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

@immutable
class AnalyticsDateWindow {
  const AnalyticsDateWindow({required this.start, required this.endExclusive});

  final DateTime start;
  final DateTime endExclusive;
}

final Provider<AnalyticsDateWindow> analyticsDateWindowProvider =
    Provider<AnalyticsDateWindow>((Ref ref) {
      final DateTimeRange range = ref.watch(
        analyticsFilterControllerProvider.select(
          (AnalyticsFilterState state) => state.dateRange,
        ),
      );
      final DateTime start = DateUtils.dateOnly(range.start);
      final DateTime endExclusive = DateUtils.dateOnly(
        range.end,
      ).add(const Duration(days: 1));
      return AnalyticsDateWindow(start: start, endExclusive: endExclusive);
    });

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

      final AnalyticsDateWindow window = ref.watch(
        analyticsDateWindowProvider,
      );
      final List<String> sortedAccountIds = ref
          .watch(analyticsSelectedAccountIdsProvider)
          .ids;

      return ref
          .watch(transactionRepositoryProvider)
          .watchCategoryTransactions(
            start: window.start,
            end: window.endExclusive,
            categoryIds: filter.categoryIds,
            includeUncategorized: filter.includeUncategorized,
            type: filter.type.storageValue,
            accountIds: sortedAccountIds,
          )
          .distinct(_listEqualsTransactions);
    });

@riverpod
Stream<List<MonthlyBalanceData>> monthlyBalanceData(Ref ref) {
  final SortedIds relevantAccountIds = ref.watch(
    analyticsRelevantCashAccountIdsProvider,
  );
  final MonthlyBalanceWindow window = ref.watch(
    analyticsMonthlyBalanceWindowProvider,
  );

  if (relevantAccountIds.isEmpty) {
    return Stream<List<MonthlyBalanceData>>.value(const <MonthlyBalanceData>[]);
  }

  return ref
      .watch(transactionRepositoryProvider)
      .watchMonthlyBalanceTotals(
        start: window.start,
        end: window.end,
        accountIds: relevantAccountIds.ids,
      )
      .map((List<MonthlyBalanceTotals> rows) {
        final List<MoneyAccumulator> balances = List<MoneyAccumulator>.generate(
          6,
          (_) => MoneyAccumulator(),
        );
        for (final MonthlyBalanceTotals row in rows) {
          final int key = _monthKey(row.month);
          final int? index = window.monthIndexByKey[key];
          if (index == null) {
            continue;
          }
          balances[index].add(row.maxBalance);
        }
        return List<MonthlyBalanceData>.generate(6, (int index) {
          final MoneyAccumulator accumulator = balances[index];
          return MonthlyBalanceData(
            month: window.months[index],
            totalBalance: MoneyAmount(
              minor: accumulator.minor,
              scale: accumulator.scale,
            ),
          );
        }, growable: false);
      })
      .distinct(_listEqualsMonthlyBalance);
}

final StreamProvider<List<MonthlyCashflowData>> monthlyCashflowDataProvider =
    StreamProvider<List<MonthlyCashflowData>>((Ref ref) {
      final SortedIds selectedAccountIds = ref.watch(
        analyticsSelectedAccountIdsProvider,
      );
      final MonthlyCashflowWindow window = ref.watch(
        analyticsMonthlyCashflowWindowProvider,
      );

      return ref
          .watch(transactionRepositoryProvider)
          .watchMonthlyCashflowTotals(
            start: window.start,
            end: window.end,
            nowInclusive: window.nowInclusive,
            accountIds: selectedAccountIds.ids,
          )
          .map((List<MonthlyCashflowTotals> rows) {
            final List<MoneyAccumulator> incomes =
                List<MoneyAccumulator>.generate(12, (_) => MoneyAccumulator());
            final List<MoneyAccumulator> expenses =
                List<MoneyAccumulator>.generate(12, (_) => MoneyAccumulator());
            for (final MonthlyCashflowTotals row in rows) {
              final int key = _monthKey(row.month);
              final int? index = window.monthIndexByKey[key];
              if (index == null) {
                continue;
              }
              final MoneyAmount income = row.income;
              final MoneyAmount expense = row.expense;
              if (income.minor > BigInt.zero) {
                incomes[index].add(income);
              }
              if (expense.minor > BigInt.zero) {
                expenses[index].add(expense);
              }
            }
            return List<MonthlyCashflowData>.generate(
              12,
              (int index) => MonthlyCashflowData(
                month: window.months[index],
                income: incomes[index].toDouble(),
                expense: expenses[index].toDouble(),
              ),
              growable: false,
            );
          })
          .distinct(_listEqualsMonthlyCashflow);
    });

int _monthKey(DateTime monthStart) => monthStart.year * 100 + monthStart.month;

bool _listEqualsAccounts(
  List<AccountEntity> first,
  List<AccountEntity> second,
) {
  return listEquals(first, second);
}

bool _listEqualsCategories(List<Category> first, List<Category> second) {
  return listEquals(first, second);
}

bool _listEqualsTransactions(
  List<TransactionEntity> first,
  List<TransactionEntity> second,
) {
  return listEquals(first, second);
}

bool _listEqualsMonthlyBalance(
  List<MonthlyBalanceData> first,
  List<MonthlyBalanceData> second,
) {
  return listEquals(first, second);
}

bool _listEqualsMonthlyCashflow(
  List<MonthlyCashflowData> first,
  List<MonthlyCashflowData> second,
) {
  if (first.length != second.length) {
    return false;
  }
  for (int i = 0; i < first.length; i++) {
    final MonthlyCashflowData a = first[i];
    final MonthlyCashflowData b = second[i];
    if (a.month != b.month || a.income != b.income || a.expense != b.expense) {
      return false;
    }
  }
  return true;
}

List<String> _sortedIds(Set<String> values) {
  final List<String> list = values.toList(growable: false);
  final List<String> mutable = List<String>.from(list)..sort();
  return List<String>.unmodifiable(mutable);
}

@immutable
class SortedIds {
  SortedIds(Set<String> values)
    : ids = _sortedIds(values),
      set = Set<String>.unmodifiable(values);

  final List<String> ids;
  final Set<String> set;

  bool get isEmpty => ids.isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SortedIds && listEquals(other.ids, ids);
  }

  @override
  int get hashCode => Object.hashAll(ids);
}
