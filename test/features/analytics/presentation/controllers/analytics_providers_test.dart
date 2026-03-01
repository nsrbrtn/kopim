import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/watch_credits_use_case.dart';
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

      final List<MoneyAccumulator> endByMonth = List<MoneyAccumulator>.generate(
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
        }

        endByMonth[i].add(
          MoneyAmount(minor: running.minor, scale: running.scale),
        );
      }

      final List<MonthlyBalanceTotals> result = <MonthlyBalanceTotals>[];
      for (int i = 0; i < months.length; i++) {
        final MoneyAccumulator acc = endByMonth[i];
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
    bool accountMatches(TransactionEntity transaction) {
      if (accountIds.isEmpty) {
        return true;
      }
      if (accountIds.contains(transaction.accountId)) {
        return true;
      }
      final String? transferAccountId = transaction.transferAccountId;
      if (transferAccountId == null) {
        return false;
      }
      return accountIds.contains(transferAccountId);
    }

    return _transactionsStream.map((List<TransactionEntity> transactions) {
      return transactions
          .where((TransactionEntity transaction) {
            if (transaction.type != type) {
              return false;
            }
            if (transaction.date.isBefore(start) ||
                !transaction.date.isBefore(end)) {
              return false;
            }
            if (!accountMatches(transaction)) {
              return false;
            }
            if (type == TransactionType.transfer.storageValue) {
              return true;
            }
            final String? categoryId = transaction.categoryId;
            if (categoryId == null) {
              return includeUncategorized;
            }
            return categoryIds.contains(categoryId);
          })
          .toList(growable: false);
    });
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
  Future<TransactionEntity?> findByIdempotencyKey(String idempotencyKey) {
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

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
}

class _StaticAccountRepository implements AccountRepository {
  _StaticAccountRepository(this._accounts);

  final List<AccountEntity> _accounts;

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    return Stream<List<AccountEntity>>.value(_accounts);
  }

  @override
  Future<List<AccountEntity>> loadAccounts() async => _accounts;

  @override
  Future<AccountEntity?> findById(String id) async {
    for (final AccountEntity account in _accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(AccountEntity account) async {}

  @override
  Future<void> softDelete(String id) async {}
}

class _StaticCreditRepository implements CreditRepository {
  _StaticCreditRepository(this._credits);

  final List<CreditEntity> _credits;

  @override
  Future<void> addCredit(CreditEntity credit) async {}

  @override
  Future<void> addPaymentGroup(CreditPaymentGroupEntity group) async {}

  @override
  Future<bool> addPaymentGroupIfAbsent(CreditPaymentGroupEntity group) async {
    return true;
  }

  @override
  Future<void> addSchedule(List<CreditPaymentScheduleEntity> schedule) async {}

  @override
  Future<void> deleteCredit(String id) async {}

  @override
  Future<CreditEntity?> getCreditByAccountId(String accountId) async {
    for (final CreditEntity credit in _credits) {
      if (credit.accountId == accountId) {
        return credit;
      }
    }
    return null;
  }

  @override
  Future<CreditEntity?> getCreditByCategoryId(String categoryId) async {
    for (final CreditEntity credit in _credits) {
      if (credit.categoryId == categoryId) {
        return credit;
      }
    }
    return null;
  }

  @override
  Future<List<CreditEntity>> getCredits() async => _credits;

  @override
  Future<List<CreditPaymentGroupEntity>> getPaymentGroups(
    String creditId,
  ) async {
    return const <CreditPaymentGroupEntity>[];
  }

  @override
  Future<CreditPaymentGroupEntity?> findPaymentGroupByIdempotencyKey({
    required String creditId,
    required String idempotencyKey,
  }) async {
    return null;
  }

  @override
  Future<List<CreditPaymentScheduleEntity>> getSchedule(String creditId) async {
    return const <CreditPaymentScheduleEntity>[];
  }

  @override
  Future<void> updateCredit(CreditEntity credit) async {}

  @override
  Future<void> updateScheduleItem(CreditPaymentScheduleEntity item) async {}

  @override
  Stream<List<CreditEntity>> watchCredits() async* {
    yield _credits;
    await Completer<void>().future;
  }

  @override
  Stream<List<CreditPaymentScheduleEntity>> watchSchedule(String creditId) {
    return const Stream<List<CreditPaymentScheduleEntity>>.empty();
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
                if (value.isNotEmpty && !completer.isCompleted) {
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
      MoneyAmount(minor: BigInt.from(10000), scale: 2),
    );
  });

  test(
    'monthlyBalanceData обновляется после новой транзакции в выбранном месяце',
    () async {
      final DateTime now = DateTime.now();
      final DateTime incomeDate = now.subtract(const Duration(hours: 2));
      final DateTime expenseDate = now.subtract(const Duration(hours: 1));

      final TransactionEntity income = TransactionEntity(
        id: 'tx-income',
        accountId: 'acc-a',
        amountMinor: BigInt.from(5000),
        amountScale: 2,
        date: incomeDate,
        type: TransactionType.income.storageValue,
        createdAt: incomeDate,
        updatedAt: incomeDate,
      );
      final TransactionEntity expense = TransactionEntity(
        id: 'tx-expense',
        accountId: 'acc-a',
        amountMinor: BigInt.from(3000),
        amountScale: 2,
        date: expenseDate,
        type: TransactionType.expense.storageValue,
        createdAt: expenseDate,
        updatedAt: expenseDate,
      );

      late final StreamController<List<TransactionEntity>>
      transactionsController;
      transactionsController =
          StreamController<List<TransactionEntity>>.broadcast(
            onListen: () {
              transactionsController.add(<TransactionEntity>[income]);
              Future<void>.microtask(() {
                transactionsController.add(<TransactionEntity>[
                  income,
                  expense,
                ]);
              });
            },
          );

      late final StreamController<List<AccountEntity>> accountsController;
      accountsController = StreamController<List<AccountEntity>>.broadcast(
        onListen: () {
          accountsController.add(<AccountEntity>[
            AccountEntity(
              id: 'acc-a',
              name: 'Main',
              balanceMinor: BigInt.zero,
              openingBalanceMinor: BigInt.from(10000),
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
                'acc-a': MoneyAmount(minor: BigInt.from(10000), scale: 2),
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

      final List<List<MonthlyBalanceData>> snapshots =
          <List<MonthlyBalanceData>>[];
      final Completer<void> loadedTwoSnapshots = Completer<void>();
      final ProviderSubscription<AsyncValue<List<MonthlyBalanceData>>> sub =
          container.listen<AsyncValue<List<MonthlyBalanceData>>>(
            monthlyBalanceDataProvider,
            (
              AsyncValue<List<MonthlyBalanceData>>? prev,
              AsyncValue<List<MonthlyBalanceData>> next,
            ) {
              next.whenData((List<MonthlyBalanceData> value) {
                if (value.isEmpty) {
                  return;
                }
                snapshots.add(value);
                if (snapshots.length >= 2 && !loadedTwoSnapshots.isCompleted) {
                  loadedTwoSnapshots.complete();
                }
              });
            },
            fireImmediately: true,
          );
      addTearDown(sub.close);

      await loadedTwoSnapshots.future;

      final MoneyAmount firstBalance = snapshots[0].last.totalBalance;
      final MoneyAmount secondBalance = snapshots[1].last.totalBalance;
      expect(firstBalance, MoneyAmount(minor: BigInt.from(15000), scale: 2));
      expect(secondBalance, MoneyAmount(minor: BigInt.from(12000), scale: 2));
    },
  );

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

  test(
    'monthlyCashflowData обновляется при добавлении транзакции позже текущего времени в тот же день',
    () async {
      final DateTime now = DateTime.now();
      final DateTime todayEnd = DateUtils.dateOnly(
        now,
      ).add(const Duration(days: 1, microseconds: -1));
      final DateTime createdAt = now.subtract(const Duration(minutes: 1));

      final StreamController<List<TransactionEntity>> transactionsController =
          StreamController<List<TransactionEntity>>.broadcast();
      addTearDown(transactionsController.close);

      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          transactionRepositoryProvider.overrideWithValue(
            _FakeTransactionRepository(
              transactionsController.stream,
              openingBalances: <String, MoneyAmount>{
                'acc-a': MoneyAmount(minor: BigInt.from(0), scale: 2),
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

      final Completer<void> updated = Completer<void>();
      final ProviderSubscription<AsyncValue<List<MonthlyCashflowData>>> sub =
          container.listen<AsyncValue<List<MonthlyCashflowData>>>(
            monthlyCashflowDataProvider,
            (
              AsyncValue<List<MonthlyCashflowData>>? prev,
              AsyncValue<List<MonthlyCashflowData>> next,
            ) {
              next.whenData((List<MonthlyCashflowData> value) {
                if (value.isEmpty || updated.isCompleted) {
                  return;
                }
                final MonthlyCashflowData current = value.last;
                if (current.income >= 10.0) {
                  updated.complete();
                }
              });
            },
            fireImmediately: true,
          );
      addTearDown(sub.close);

      transactionsController.add(const <TransactionEntity>[]);
      await Future<void>.delayed(Duration.zero);

      transactionsController.add(<TransactionEntity>[
        TransactionEntity(
          id: 'tx-future-today',
          accountId: 'acc-a',
          amountMinor: BigInt.from(1000),
          amountScale: 2,
          date: todayEnd,
          type: TransactionType.income.storageValue,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ]);

      await expectLater(
        updated.future.timeout(const Duration(seconds: 2)),
        completes,
      );
    },
  );

  test(
    'credit payment учитывается как outflow при custom:credit типе счета',
    () async {
      final DateTime now = DateTime.now();
      final DateTime txDate = now.subtract(const Duration(hours: 2));
      final DateTime rangeStart = DateUtils.dateOnly(now);
      final DateTime rangeEnd = rangeStart;

      final TransactionEntity payment = TransactionEntity(
        id: 'payment-1',
        accountId: 'cash-1',
        transferAccountId: 'credit-1',
        amountMinor: BigInt.from(5000),
        amountScale: 2,
        date: txDate,
        type: TransactionType.transfer.storageValue,
        createdAt: txDate,
        updatedAt: txDate,
      );

      final _FakeTransactionRepository transactionRepository =
          _FakeTransactionRepository(
            Stream<List<TransactionEntity>>.value(<TransactionEntity>[payment]),
            openingBalances: <String, MoneyAmount>{
              'cash-1': MoneyAmount(minor: BigInt.zero, scale: 2),
              'credit-1': MoneyAmount(minor: BigInt.zero, scale: 2),
            },
          );

      final _StaticAccountRepository accountRepository =
          _StaticAccountRepository(<AccountEntity>[
            AccountEntity(
              id: 'cash-1',
              name: 'Cash',
              balanceMinor: BigInt.zero,
              openingBalanceMinor: BigInt.zero,
              currency: 'USD',
              currencyScale: 2,
              type: 'checking',
              createdAt: now,
              updatedAt: now,
            ),
            AccountEntity(
              id: 'credit-1',
              name: 'Loan',
              balanceMinor: BigInt.zero,
              openingBalanceMinor: BigInt.zero,
              currency: 'USD',
              currencyScale: 2,
              type: 'custom:credit',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      final _StaticCreditRepository creditRepository = _StaticCreditRepository(
        const <CreditEntity>[],
      );

      final ProviderContainer container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(
            transactionRepository,
          ),
          watchAccountsUseCaseProvider.overrideWithValue(
            WatchAccountsUseCase(accountRepository),
          ),
          watchCreditsUseCaseProvider.overrideWithValue(
            WatchCreditsUseCase(creditRepository),
          ),
          analyticsFilterControllerProvider.overrideWith(
            () => _FakeAnalyticsFilterController(
              AnalyticsFilterState(
                dateRange: DateTimeRange(start: rangeStart, end: rangeEnd),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final CreditDebtOperationsOverview overview = await container.read(
        analyticsCreditDebtOperationsProvider.future,
      );

      expect(overview.principalRepayment.toDouble(), closeTo(50.0, 0.001));
      expect(overview.totalOutflow.toDouble(), closeTo(50.0, 0.001));
      expect(overview.items, hasLength(1));
      expect(
        overview.items.single.kind,
        CreditDebtOperationKind.principalRepayment,
      );
    },
    skip:
        'Требуется отдельная стабилизация switchLatest для синхронных/долгоживущих stream-кейсов.',
  );
}
