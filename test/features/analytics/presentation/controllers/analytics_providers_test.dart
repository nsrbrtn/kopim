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
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:riverpod/riverpod.dart';

class _FakeAnalyticsFilterController extends AnalyticsFilterController {
  _FakeAnalyticsFilterController(this._state);

  final AnalyticsFilterState _state;

  @override
  AnalyticsFilterState build() => _state;
}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._transactionsStream);

  final Stream<List<TransactionEntity>> _transactionsStream;

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
  Future<List<TransactionEntity>> loadTransactions() {
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
          _FakeTransactionRepository(transactionsController.stream),
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
          _FakeTransactionRepository(transactionsController.stream),
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
