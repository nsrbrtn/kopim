import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_details_providers.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  const String accountId = 'acc-1';
  final DateTime now = DateTime.utc(2024, 6, 1);

  TransactionEntity transaction(
    String id, {
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? categoryId,
  }) {
    return TransactionEntity(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      note: null,
      type: type.storageValue,
      createdAt: date,
      updatedAt: date,
    );
  }

  group('filteredAccountTransactionsProvider', () {
    test('applies type, category and date filters', () async {
      final List<TransactionEntity> transactions = <TransactionEntity>[
        transaction(
          't1',
          type: TransactionType.income,
          amount: 120,
          date: now,
          categoryId: 'cat-1',
        ),
        transaction(
          't2',
          type: TransactionType.expense,
          amount: 80,
          date: now.subtract(const Duration(days: 5)),
          categoryId: 'cat-2',
        ),
        transaction(
          't3',
          type: TransactionType.income,
          amount: 75,
          date: now.subtract(const Duration(days: 45)),
          categoryId: 'cat-1',
        ),
      ];

      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          accountTransactionsProvider.overrideWith((Ref ref, String id) {
            expect(id, accountId);
            return Stream<List<TransactionEntity>>.value(transactions);
          }),
        ],
      );
      addTearDown(container.dispose);

      final DateTimeRange range = DateTimeRange(
        start: now.subtract(const Duration(days: 10)),
        end: now,
      );

      final AccountTransactionsFilterController controller = container.read(
        accountTransactionsFilterControllerProvider(accountId).notifier,
      );
      controller
        ..setType(TransactionType.income)
        ..setCategory('cat-1')
        ..setDateRange(range);

      final Completer<List<TransactionEntity>> completer =
          Completer<List<TransactionEntity>>();
      final ProviderSubscription<AsyncValue<List<TransactionEntity>>> listener =
          container.listen(filteredAccountTransactionsProvider(accountId), (
            AsyncValue<List<TransactionEntity>>? previous,
            AsyncValue<List<TransactionEntity>> next,
          ) {
            next.whenData((List<TransactionEntity> data) {
              if (!completer.isCompleted) {
                completer.complete(data);
              }
            });
          }, fireImmediately: true);
      addTearDown(listener.close);

      final List<TransactionEntity> result = await completer.future;

      expect(result, <TransactionEntity>[transactions.first]);
    });
  });

  group('accountTransactionSummaryProvider', () {
    test('aggregates income and expenses', () async {
      final List<TransactionEntity> transactions = <TransactionEntity>[
        transaction('t1', type: TransactionType.income, amount: 200, date: now),
        transaction('t2', type: TransactionType.expense, amount: 50, date: now),
        transaction('t3', type: TransactionType.expense, amount: 30, date: now),
      ];

      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          accountTransactionsProvider.overrideWith((Ref ref, String id) {
            expect(id, accountId);
            return Stream<List<TransactionEntity>>.value(transactions);
          }),
        ],
      );
      addTearDown(container.dispose);

      final Completer<AccountTransactionSummary> completer =
          Completer<AccountTransactionSummary>();
      final ProviderSubscription<AsyncValue<AccountTransactionSummary>>
      listener = container
          .listen(accountTransactionSummaryProvider(accountId), (
            AsyncValue<AccountTransactionSummary>? previous,
            AsyncValue<AccountTransactionSummary> next,
          ) {
            next.whenData((AccountTransactionSummary summary) {
              if (!completer.isCompleted) {
                completer.complete(summary);
              }
            });
          }, fireImmediately: true);
      addTearDown(listener.close);

      final AccountTransactionSummary summary = await completer.future;

      expect(summary.totalIncome, 200);
      expect(summary.totalExpense, 80);
      expect(summary.net, 120);
    });
  });
}
