import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:riverpod/riverpod.dart';

class _FakeAnalyticsFilterController extends AnalyticsFilterController {
  _FakeAnalyticsFilterController(this._state);

  final AnalyticsFilterState _state;

  @override
  AnalyticsFilterState build() => _state;
}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(
    this._transactionsStream, {
    required Map<String, MoneyAmount> openingBalances,
  }) : _openingBalances = openingBalances;

  final Stream<List<TransactionEntity>> _transactionsStream;
  final Map<String, MoneyAmount> _openingBalances;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _transactionsStream;

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) {
    return _transactionsStream;
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) {
    return Stream<List<TransactionCategoryTotals>>.value(
      const <TransactionCategoryTotals>[],
    );
  }

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) {
    return _transactionsStream.map((List<TransactionEntity> transactions) {
      final List<DateTime> months = _monthStarts(start, end);
      final Map<int, int> monthIndexByKey = <int, int>{
        for (int i = 0; i < months.length; i++) _monthKey(months[i]): i,
      };
      final List<MoneyAccumulator> incomes = List<MoneyAccumulator>.generate(
        months.length,
        (_) => MoneyAccumulator(),
      );
      final List<MoneyAccumulator> expenses = List<MoneyAccumulator>.generate(
        months.length,
        (_) => MoneyAccumulator(),
      );
      for (final TransactionEntity tx in transactions) {
        if (tx.date.isBefore(start) || !tx.date.isBefore(end)) {
          continue;
        }
        if (tx.date.isAfter(nowInclusive)) {
          continue;
        }
        final MoneyAmount? delta = _resolveTransactionDelta(
          transaction: tx,
          accountIds: accountIds,
        );
        if (delta == null) {
          continue;
        }
        final int key = _monthKey(DateTime(tx.date.year, tx.date.month));
        final int? index = monthIndexByKey[key];
        if (index == null) {
          continue;
        }
        if (delta.minor > BigInt.zero) {
          incomes[index].add(delta);
        } else if (delta.minor < BigInt.zero) {
          expenses[index].add(
            MoneyAmount(minor: -delta.minor, scale: delta.scale),
          );
        }
      }

      return List<MonthlyCashflowTotals>.generate(
        months.length,
        (int index) => MonthlyCashflowTotals(
          month: months[index],
          income: MoneyAmount(
            minor: incomes[index].minor,
            scale: incomes[index].scale,
          ),
          expense: MoneyAmount(
            minor: expenses[index].minor,
            scale: expenses[index].scale,
          ),
        ),
        growable: false,
      );
    });
  }

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) {
    return _transactionsStream.map((List<TransactionEntity> transactions) {
      final List<DateTime> months = _monthStarts(start, end);
      final List<MoneyAmount> opening = _openingBalancesFor(accountIds);
      final MoneyAccumulator openingSum = MoneyAccumulator();
      for (final MoneyAmount amount in opening) {
        openingSum.add(amount);
      }

      final List<TransactionEntity> sorted = transactions.toList()
        ..sort(
          (TransactionEntity a, TransactionEntity b) =>
              a.date.compareTo(b.date),
        );

      final List<MoneyAccumulator> maxByMonth = List<MoneyAccumulator>.generate(
        months.length,
        (_) => MoneyAccumulator(),
      );

      for (int i = 0; i < months.length; i++) {
        final DateTime monthStart = months[i];
        final DateTime monthEnd = DateTime(
          monthStart.year,
          monthStart.month + 1,
        );

        final MoneyAccumulator running = MoneyAccumulator();
        running.add(
          MoneyAmount(minor: openingSum.minor, scale: openingSum.scale),
        );
        for (final TransactionEntity tx in sorted) {
          if (!tx.date.isBefore(monthStart)) {
            break;
          }
          final MoneyAmount? delta = _resolveTransactionDelta(
            transaction: tx,
            accountIds: accountIds,
          );
          if (delta != null) {
            running.add(delta);
          }
        }

        MoneyAmount maxBalance = MoneyAmount(
          minor: running.minor,
          scale: running.scale,
        );
        for (final TransactionEntity tx in sorted) {
          if (tx.date.isBefore(monthStart) || !tx.date.isBefore(monthEnd)) {
            continue;
          }
          final MoneyAmount? delta = _resolveTransactionDelta(
            transaction: tx,
            accountIds: accountIds,
          );
          if (delta == null) {
            continue;
          }
          running.add(delta);
          final MoneyAmount current = MoneyAmount(
            minor: running.minor,
            scale: running.scale,
          );
          maxBalance = maxMoneyAmount(maxBalance, current);
        }

        maxByMonth[i].add(maxBalance);
      }

      final List<MonthlyBalanceTotals> result = <MonthlyBalanceTotals>[];
      for (int i = 0; i < months.length; i++) {
        final MoneyAccumulator acc = maxByMonth[i];
        result.add(
          MonthlyBalanceTotals(
            month: months[i],
            maxBalance: MoneyAmount(minor: acc.minor, scale: acc.scale),
          ),
        );
      }
      return result;
    });
  }

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<BudgetExpenseTotals>>.empty();

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) {
    return const Stream<List<TransactionEntity>>.empty();
  }

  List<MoneyAmount> _openingBalancesFor(List<String> accountIds) {
    if (accountIds.isEmpty) {
      return _openingBalances.values.toList(growable: false);
    }
    return accountIds
        .map((String id) => _openingBalances[id] ?? _zero())
        .toList(growable: false);
  }

  MoneyAmount _zero() => MoneyAmount(minor: BigInt.zero, scale: 2);

  MoneyAmount? _resolveTransactionDelta({
    required TransactionEntity transaction,
    required List<String> accountIds,
  }) {
    final bool allAccounts = accountIds.isEmpty;
    bool isSelected(String id) => allAccounts ? true : accountIds.contains(id);
    final TransactionType type = parseTransactionType(transaction.type);
    final MoneyAmount amount = transaction.amountValue.abs();

    if (type.isTransfer) {
      final String? targetId = transaction.transferAccountId;
      if (targetId == null || targetId == transaction.accountId) {
        return null;
      }
      final bool sourceSelected = isSelected(transaction.accountId);
      final bool targetSelected = isSelected(targetId);
      if (sourceSelected == targetSelected) {
        return null;
      }
      if (targetSelected) {
        return amount;
      }
      return MoneyAmount(minor: -amount.minor, scale: amount.scale);
    }

    if (!isSelected(transaction.accountId)) {
      return null;
    }
    if (type.isIncome) {
      return amount;
    }
    if (type.isExpense) {
      return MoneyAmount(minor: -amount.minor, scale: amount.scale);
    }
    return null;
  }

  List<DateTime> _monthStarts(DateTime start, DateTime end) {
    final List<DateTime> months = <DateTime>[];
    DateTime current = DateTime(start.year, start.month);
    final DateTime limit = DateTime(end.year, end.month);
    while (current.isBefore(limit)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return months;
  }

  int _monthKey(DateTime monthStart) {
    return monthStart.year * 100 + monthStart.month;
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('monthlyBalanceData учитывает перевод для выбранного счета', () async {
    final DateTime now = DateTime.now();
    final DateTime transactionDate = now.subtract(const Duration(hours: 1));

    final TransactionEntity transfer = TransactionEntity(
      id: 'tx-1',
      accountId: 'acc-a',
      transferAccountId: 'acc-b',
      amountMinor: BigInt.from(1000),
      amountScale: 2,
      date: transactionDate,
      type: TransactionType.transfer.storageValue,
      createdAt: transactionDate,
      updatedAt: transactionDate,
    );

    late final StreamController<List<TransactionEntity>> transactionsController;
    late final StreamController<List<AccountEntity>> accountsController;
    transactionsController =
        StreamController<List<TransactionEntity>>.broadcast(
          onListen: () {
            transactionsController.add(<TransactionEntity>[transfer]);
          },
        );
    accountsController = StreamController<List<AccountEntity>>.broadcast(
      onListen: () {
        accountsController.add(<AccountEntity>[
          AccountEntity(
            id: 'acc-a',
            name: 'Main',
            balanceMinor: BigInt.from(10000),
            openingBalanceMinor: BigInt.from(11000),
            currencyScale: 2,
            currency: 'USD',
            type: 'checking',
            createdAt: now,
            updatedAt: now,
          ),
          AccountEntity(
            id: 'acc-b',
            name: 'Spare',
            balanceMinor: BigInt.from(5000),
            openingBalanceMinor: BigInt.from(5000),
            currencyScale: 2,
            currency: 'USD',
            type: 'checking',
            createdAt: now,
            updatedAt: now,
          ),
        ]);
      },
    );
    addTearDown(transactionsController.close);
    addTearDown(accountsController.close);

    final ProviderContainer container = ProviderContainer(
      // ignore: always_specify_types, the Override type is internal to riverpod
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          _FakeTransactionRepository(
            transactionsController.stream,
            openingBalances: <String, MoneyAmount>{
              'acc-a': MoneyAmount(minor: BigInt.from(11000), scale: 2),
              'acc-b': MoneyAmount(minor: BigInt.from(5000), scale: 2),
            },
          ),
        ),
        analyticsAccountsProvider.overrideWith(
          (Ref ref) => accountsController.stream,
        ),
        analyticsFilterControllerProvider.overrideWith(
          () => _FakeAnalyticsFilterController(
            AnalyticsFilterState(
              dateRange: DateTimeRange(start: now, end: now),
              accountIds: const <String>{'acc-a'},
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final Completer<List<MonthlyBalanceData>> completer =
        Completer<List<MonthlyBalanceData>>();
    final ProviderSubscription<AsyncValue<List<MonthlyBalanceData>>> sub =
        container.listen<AsyncValue<List<MonthlyBalanceData>>>(
          monthlyBalanceDataProvider,
          (
            AsyncValue<List<MonthlyBalanceData>>? prev,
            AsyncValue<List<MonthlyBalanceData>> next,
          ) {
            next.when(
              data: (List<MonthlyBalanceData> value) {
                if (!completer.isCompleted) {
                  completer.complete(value);
                }
              },
              error: (Object error, StackTrace stackTrace) {
                if (!completer.isCompleted) {
                  completer.completeError(error, stackTrace);
                }
              },
              loading: () {},
            );
          },
          fireImmediately: true,
        );
    addTearDown(sub.close);

    final List<MonthlyBalanceData> data = await completer.future;

    expect(data, isNotEmpty);
    final MonthlyBalanceData current = data.last;
    expect(
      current.totalBalance,
      MoneyAmount(minor: BigInt.from(11000), scale: 2),
    );
  });

  test('monthlyCashflowData учитывает переводы для выбранного счета', () async {
    final DateTime now = DateTime.now();
    final DateTime transactionDate = now.subtract(const Duration(hours: 1));

    final List<TransactionEntity> transactions = <TransactionEntity>[
      TransactionEntity(
        id: 'tx-out',
        accountId: 'acc-a',
        transferAccountId: 'acc-b',
        amountMinor: BigInt.from(1000),
        amountScale: 2,
        date: transactionDate,
        type: TransactionType.transfer.storageValue,
        createdAt: transactionDate,
        updatedAt: transactionDate,
      ),
      TransactionEntity(
        id: 'tx-in',
        accountId: 'acc-b',
        transferAccountId: 'acc-a',
        amountMinor: BigInt.from(2500),
        amountScale: 2,
        date: transactionDate,
        type: TransactionType.transfer.storageValue,
        createdAt: transactionDate,
        updatedAt: transactionDate,
      ),
    ];

    late final StreamController<List<TransactionEntity>> transactionsController;
    transactionsController =
        StreamController<List<TransactionEntity>>.broadcast(
          onListen: () {
            transactionsController.add(transactions);
          },
        );
    addTearDown(transactionsController.close);

    final ProviderContainer container = ProviderContainer(
      // ignore: always_specify_types, the Override type is internal to riverpod
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          _FakeTransactionRepository(
            transactionsController.stream,
            openingBalances: <String, MoneyAmount>{
              'acc-a': MoneyAmount(minor: BigInt.from(0), scale: 2),
              'acc-b': MoneyAmount(minor: BigInt.from(0), scale: 2),
            },
          ),
        ),
        analyticsFilterControllerProvider.overrideWith(
          () => _FakeAnalyticsFilterController(
            AnalyticsFilterState(
              dateRange: DateTimeRange(start: now, end: now),
              accountIds: const <String>{'acc-a'},
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final Completer<List<MonthlyCashflowData>> completer =
        Completer<List<MonthlyCashflowData>>();
    final ProviderSubscription<AsyncValue<List<MonthlyCashflowData>>> sub =
        container.listen<AsyncValue<List<MonthlyCashflowData>>>(
          monthlyCashflowDataProvider,
          (
            AsyncValue<List<MonthlyCashflowData>>? prev,
            AsyncValue<List<MonthlyCashflowData>> next,
          ) {
            next.when(
              data: (List<MonthlyCashflowData> value) {
                if (!completer.isCompleted) {
                  completer.complete(value);
                }
              },
              error: (Object error, StackTrace stackTrace) {
                if (!completer.isCompleted) {
                  completer.completeError(error, stackTrace);
                }
              },
              loading: () {},
            );
          },
          fireImmediately: true,
        );
    addTearDown(sub.close);

    final List<MonthlyCashflowData> data = await completer.future;

    expect(data, isNotEmpty);
    final MonthlyCashflowData current = data.last;
    expect(current.income, closeTo(25.0, 0.001));
    expect(current.expense, closeTo(10.0, 0.001));
  });
}
