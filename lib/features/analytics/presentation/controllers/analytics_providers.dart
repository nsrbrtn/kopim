import 'dart:async';

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
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
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

      final AnalyticsDateWindow window = ref.watch(analyticsDateWindowProvider);
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

enum CreditDebtOperationKind {
  principalRepayment,
  principalInflow,
  serviceExpense,
  debtTransfer,
}

@immutable
class CreditDebtOperationItem {
  const CreditDebtOperationItem({
    required this.transaction,
    required this.kind,
    this.liabilityAccountId,
  });

  final TransactionEntity transaction;
  final CreditDebtOperationKind kind;
  final String? liabilityAccountId;

  bool get isOutflow =>
      kind == CreditDebtOperationKind.principalRepayment ||
      kind == CreditDebtOperationKind.serviceExpense;

  bool get isInflow => kind == CreditDebtOperationKind.principalInflow;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CreditDebtOperationItem &&
        other.transaction == transaction &&
        other.kind == kind &&
        other.liabilityAccountId == liabilityAccountId;
  }

  @override
  int get hashCode => Object.hash(transaction, kind, liabilityAccountId);
}

@immutable
class CreditDebtOperationsOverview {
  const CreditDebtOperationsOverview({
    required this.principalRepayment,
    required this.principalInflow,
    required this.serviceExpense,
    required this.totalOutflow,
    required this.items,
  });

  final MoneyAmount principalRepayment;
  final MoneyAmount principalInflow;
  final MoneyAmount serviceExpense;
  final MoneyAmount totalOutflow;
  final List<CreditDebtOperationItem> items;

  bool get isEmpty =>
      principalRepayment.minor <= BigInt.zero &&
      principalInflow.minor <= BigInt.zero &&
      serviceExpense.minor <= BigInt.zero &&
      items.isEmpty;

  static CreditDebtOperationsOverview empty() {
    const int scale = 2;
    final MoneyAmount zero = MoneyAmount(minor: BigInt.zero, scale: scale);
    return CreditDebtOperationsOverview(
      principalRepayment: zero,
      principalInflow: zero,
      serviceExpense: zero,
      totalOutflow: zero,
      items: const <CreditDebtOperationItem>[],
    );
  }
}

final StreamProvider<CreditDebtOperationsOverview>
analyticsCreditDebtOperationsProvider =
    StreamProvider<CreditDebtOperationsOverview>((Ref ref) {
      final AnalyticsDateWindow window = ref.watch(analyticsDateWindowProvider);
      final SortedIds selectedAccountIds = ref.watch(
        analyticsSelectedAccountIdsProvider,
      );
      final TransactionRepository transactionRepository = ref.watch(
        transactionRepositoryProvider,
      );

      final Stream<List<TransactionEntity>> transferTransactionsStream =
          transactionRepository
              .watchCategoryTransactions(
                start: window.start,
                end: window.endExclusive,
                categoryIds: const <String>[],
                includeUncategorized: true,
                type: TransactionType.transfer.storageValue,
                accountIds: const <String>[],
              )
              .distinct(_listEqualsTransactions);

      final Stream<List<TransactionEntity>> serviceExpenseTransactionsStream =
          _switchLatest<List<CreditEntity>, List<TransactionEntity>>(
            ref.watch(watchCreditsUseCaseProvider).call(),
            (List<CreditEntity> credits) {
              final List<String> serviceCategoryIds = _serviceCategoryIds(
                credits,
              );
              if (serviceCategoryIds.isEmpty) {
                return Stream<List<TransactionEntity>>.value(
                  const <TransactionEntity>[],
                );
              }
              return transactionRepository.watchCategoryTransactions(
                start: window.start,
                end: window.endExclusive,
                categoryIds: serviceCategoryIds,
                includeUncategorized: false,
                type: TransactionType.expense.storageValue,
                accountIds: selectedAccountIds.ids,
              );
            },
          ).distinct(_listEqualsTransactions);

      return _combineLatest4<
            List<TransactionEntity>,
            List<TransactionEntity>,
            List<AccountEntity>,
            List<CreditEntity>,
            CreditDebtOperationsOverview
          >(
            transferTransactionsStream,
            serviceExpenseTransactionsStream,
            ref.watch(watchAccountsUseCaseProvider).call(),
            ref.watch(watchCreditsUseCaseProvider).call(),
            (
              List<TransactionEntity> transferTransactions,
              List<TransactionEntity> serviceExpenseTransactions,
              List<AccountEntity> accounts,
              List<CreditEntity> credits,
            ) {
              final List<TransactionEntity> transactions = <TransactionEntity>[
                ...transferTransactions,
                ...serviceExpenseTransactions,
              ];
              return _buildCreditDebtOperationsOverview(
                transactions: transactions,
                accounts: accounts,
                credits: credits,
                dateWindow: window,
                selectedAccountIds: selectedAccountIds,
              );
            },
          )
          .distinct(_creditDebtOverviewEquals);
    });

CreditDebtOperationsOverview _buildCreditDebtOperationsOverview({
  required List<TransactionEntity> transactions,
  required List<AccountEntity> accounts,
  required List<CreditEntity> credits,
  required AnalyticsDateWindow dateWindow,
  required SortedIds selectedAccountIds,
}) {
  final Set<String> liabilityTypes = <String>{'credit', 'credit_card', 'debt'};
  final Set<String> liabilityAccountIds = accounts
      .where((AccountEntity account) => liabilityTypes.contains(account.type))
      .map((AccountEntity account) => account.id)
      .toSet();

  if (liabilityAccountIds.isEmpty) {
    return CreditDebtOperationsOverview.empty();
  }

  final Map<String, String> serviceCategoryToLiabilityAccount =
      <String, String>{};
  for (final CreditEntity credit in credits) {
    final String accountId = credit.accountId;
    final String? interestCategoryId = credit.interestCategoryId;
    if (interestCategoryId != null && interestCategoryId.isNotEmpty) {
      serviceCategoryToLiabilityAccount[interestCategoryId] = accountId;
    }
    final String? feesCategoryId = credit.feesCategoryId;
    if (feesCategoryId != null && feesCategoryId.isNotEmpty) {
      serviceCategoryToLiabilityAccount[feesCategoryId] = accountId;
    }
  }

  final MoneyAccumulator principalRepayment = MoneyAccumulator();
  final MoneyAccumulator principalInflow = MoneyAccumulator();
  final MoneyAccumulator serviceExpense = MoneyAccumulator();
  final List<CreditDebtOperationItem> items = <CreditDebtOperationItem>[];

  bool touchesSelectedAccounts(TransactionEntity transaction) {
    if (selectedAccountIds.isEmpty) {
      return true;
    }
    if (selectedAccountIds.set.contains(transaction.accountId)) {
      return true;
    }
    final String? transferAccountId = transaction.transferAccountId;
    if (transferAccountId == null) {
      return false;
    }
    return selectedAccountIds.set.contains(transferAccountId);
  }

  bool inDateWindow(DateTime date) {
    if (date.isBefore(dateWindow.start)) {
      return false;
    }
    return date.isBefore(dateWindow.endExclusive);
  }

  for (final TransactionEntity transaction in transactions) {
    if (!touchesSelectedAccounts(transaction) ||
        !inDateWindow(transaction.date)) {
      continue;
    }
    final MoneyAmount amount = transaction.amountValue;
    if (amount.minor <= BigInt.zero) {
      continue;
    }

    final TransactionType type = parseTransactionType(transaction.type);
    if (type == TransactionType.transfer) {
      final bool sourceIsLiability = liabilityAccountIds.contains(
        transaction.accountId,
      );
      final String? transferAccountId = transaction.transferAccountId;
      final bool targetIsLiability =
          transferAccountId != null &&
          liabilityAccountIds.contains(transferAccountId);

      if (!sourceIsLiability && targetIsLiability) {
        principalRepayment.add(amount);
        items.add(
          CreditDebtOperationItem(
            transaction: transaction,
            kind: CreditDebtOperationKind.principalRepayment,
            liabilityAccountId: transferAccountId,
          ),
        );
        continue;
      }
      if (sourceIsLiability && !targetIsLiability) {
        principalInflow.add(amount);
        items.add(
          CreditDebtOperationItem(
            transaction: transaction,
            kind: CreditDebtOperationKind.principalInflow,
            liabilityAccountId: transaction.accountId,
          ),
        );
        continue;
      }
      if (sourceIsLiability || targetIsLiability) {
        items.add(
          CreditDebtOperationItem(
            transaction: transaction,
            kind: CreditDebtOperationKind.debtTransfer,
            liabilityAccountId: sourceIsLiability
                ? transaction.accountId
                : transferAccountId,
          ),
        );
      }
      continue;
    }

    if (type == TransactionType.expense) {
      final String? categoryId = transaction.categoryId;
      if (categoryId == null) {
        continue;
      }
      final String? linkedLiabilityAccountId =
          serviceCategoryToLiabilityAccount[categoryId];
      if (linkedLiabilityAccountId == null) {
        continue;
      }
      serviceExpense.add(amount);
      items.add(
        CreditDebtOperationItem(
          transaction: transaction,
          kind: CreditDebtOperationKind.serviceExpense,
          liabilityAccountId: linkedLiabilityAccountId,
        ),
      );
    }
  }

  items.sort((CreditDebtOperationItem a, CreditDebtOperationItem b) {
    return b.transaction.date.compareTo(a.transaction.date);
  });

  final MoneyAmount principalRepaymentAmount = MoneyAmount(
    minor: principalRepayment.minor,
    scale: principalRepayment.scale,
  );
  final MoneyAmount serviceExpenseAmount = MoneyAmount(
    minor: serviceExpense.minor,
    scale: serviceExpense.scale,
  );

  final MoneyAccumulator totalOutflow = MoneyAccumulator();
  totalOutflow.add(principalRepaymentAmount);
  totalOutflow.add(serviceExpenseAmount);

  return CreditDebtOperationsOverview(
    principalRepayment: principalRepaymentAmount,
    principalInflow: MoneyAmount(
      minor: principalInflow.minor,
      scale: principalInflow.scale,
    ),
    serviceExpense: serviceExpenseAmount,
    totalOutflow: MoneyAmount(
      minor: totalOutflow.minor,
      scale: totalOutflow.scale,
    ),
    items: List<CreditDebtOperationItem>.unmodifiable(items),
  );
}

bool _creditDebtOverviewEquals(
  CreditDebtOperationsOverview previous,
  CreditDebtOperationsOverview next,
) {
  return previous.principalRepayment == next.principalRepayment &&
      previous.principalInflow == next.principalInflow &&
      previous.serviceExpense == next.serviceExpense &&
      previous.totalOutflow == next.totalOutflow &&
      listEquals(previous.items, next.items);
}

int _monthKey(DateTime monthStart) => monthStart.year * 100 + monthStart.month;

List<String> _serviceCategoryIds(List<CreditEntity> credits) {
  final Set<String> unique = <String>{};
  for (final CreditEntity credit in credits) {
    final String? interestCategoryId = credit.interestCategoryId;
    if (interestCategoryId != null && interestCategoryId.isNotEmpty) {
      unique.add(interestCategoryId);
    }
    final String? feesCategoryId = credit.feesCategoryId;
    if (feesCategoryId != null && feesCategoryId.isNotEmpty) {
      unique.add(feesCategoryId);
    }
  }
  final List<String> sorted = unique.toList(growable: false)..sort();
  return sorted;
}

Stream<T> _combineLatest4<A, B, C, D, T>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  Stream<D> d,
  T Function(A, B, C, D) mapper,
) {
  late StreamController<T> controller;
  A? lastA;
  B? lastB;
  C? lastC;
  D? lastD;
  bool hasA = false;
  bool hasB = false;
  bool hasC = false;
  bool hasD = false;

  void emitIfReady() {
    if (hasA && hasB && hasC && hasD) {
      controller.add(mapper(lastA as A, lastB as B, lastC as C, lastD as D));
    }
  }

  controller = StreamController<T>(
    onListen: () {
      int doneCount = 0;
      void handleDone() {
        doneCount += 1;
        if (doneCount >= 4 && !controller.isClosed) {
          controller.close();
        }
      }

      final StreamSubscription<A> subA = a.listen(
        (A value) {
          lastA = value;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: handleDone,
      );
      final StreamSubscription<B> subB = b.listen(
        (B value) {
          lastB = value;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: handleDone,
      );
      final StreamSubscription<C> subC = c.listen(
        (C value) {
          lastC = value;
          hasC = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: handleDone,
      );
      final StreamSubscription<D> subD = d.listen(
        (D value) {
          lastD = value;
          hasD = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: handleDone,
      );
      controller.onCancel = () async {
        await subA.cancel();
        await subB.cancel();
        await subC.cancel();
        await subD.cancel();
      };
    },
  );

  return controller.stream;
}

Stream<R> _switchLatest<T, R>(Stream<T> source, Stream<R> Function(T) mapper) {
  late StreamController<R> controller;
  StreamSubscription<T>? outerSub;
  StreamSubscription<R>? innerSub;
  bool sourceDone = false;

  Future<void> maybeClose() async {
    if (sourceDone && innerSub == null && !controller.isClosed) {
      await controller.close();
    }
  }

  controller = StreamController<R>(
    onListen: () {
      outerSub = source.listen(
        (T value) async {
          await innerSub?.cancel();
          innerSub = mapper(value).listen(
            controller.add,
            onError: controller.addError,
            onDone: () async {
              innerSub = null;
              await maybeClose();
            },
          );
        },
        onError: controller.addError,
        onDone: () async {
          sourceDone = true;
          await maybeClose();
        },
      );
    },
    onCancel: () async {
      await innerSub?.cancel();
      await outerSub?.cancel();
    },
  );

  return controller.stream;
}

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
