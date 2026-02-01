import 'dart:async';

// ignore_for_file: always_specify_types

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/home/presentation/controllers/home_transactions_filter_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:riverpod/riverpod.dart' as riverpod;

void _noop<T>(T? previous, T next) {}

Future<List<DaySection>> _readGroupedTransactions(
  riverpod.ProviderContainer container,
) async {
  final Completer<List<DaySection>> completer = Completer<List<DaySection>>();
  final riverpod.ProviderSubscription<riverpod.AsyncValue<List<DaySection>>>
  subscription = container.listen(homeGroupedTransactionsProvider, (
    riverpod.AsyncValue<List<DaySection>>? _,
    riverpod.AsyncValue<List<DaySection>> next,
  ) {
    if (next.hasValue && !completer.isCompleted) {
      completer.complete(next.value!);
    } else if (next.hasError && !completer.isCompleted) {
      completer.completeError(next.error!, next.stackTrace);
    }
  }, fireImmediately: true);
  try {
    return await completer.future;
  } finally {
    subscription.close();
  }
}

void main() {
  group('homeTransactionByIdProvider', () {
    test('возвращает транзакцию по идентификатору', () async {
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        amountMinor: BigInt.from(-4200),
        amountScale: 2,
        categoryId: 'cat-1',
        date: DateTime(2024, 10, 1, 12, 30),
        note: 'test',
        type: 'expense',
        createdAt: DateTime(2024, 10, 1),
        updatedAt: DateTime(2024, 10, 1),
      );

      final overrides = [
        homeRecentTransactionsProvider().overrideWith((
          riverpod.Ref ref, {
          int limit = kDefaultRecentTransactionsLimit,
        }) {
          return Stream<List<TransactionEntity>>.value(<TransactionEntity>[
            transaction,
          ]);
        }),
      ];
      final riverpod.ProviderContainer container = riverpod.ProviderContainer(
        overrides: overrides,
      );
      addTearDown(container.dispose);

      final riverpod.ProviderSubscription<TransactionEntity?> subscription =
          container.listen(
            homeTransactionByIdProvider('tx-1'),
            _noop,
            fireImmediately: true,
          );
      addTearDown(subscription.close);

      await container.pump();
      expect(subscription.read(), transaction);
    });

    test('возвращает null, если транзакция отсутствует', () async {
      final overrides = [
        homeRecentTransactionsProvider().overrideWith((
          riverpod.Ref ref, {
          int limit = kDefaultRecentTransactionsLimit,
        }) {
          return const Stream<List<TransactionEntity>>.empty();
        }),
      ];
      final riverpod.ProviderContainer container = riverpod.ProviderContainer(
        overrides: overrides,
      );
      addTearDown(container.dispose);

      final riverpod.ProviderSubscription<TransactionEntity?> subscription =
          container.listen(
            homeTransactionByIdProvider('missing'),
            _noop,
            fireImmediately: true,
          );
      addTearDown(subscription.close);

      await container.pump();
      expect(subscription.read(), isNull);
    });
  });

  group('homeAccountByIdProvider', () {
    test('возвращает аккаунт по идентификатору', () async {
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Checking',
        balanceMinor: BigInt.from(10000),
        currency: 'usd',
        currencyScale: 2,
        type: 'bank',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isDeleted: false,
      );

      final overrides = [
        homeAccountsProvider.overrideWith(
          (riverpod.Ref ref) =>
              Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
        ),
      ];
      final riverpod.ProviderContainer container = riverpod.ProviderContainer(
        overrides: overrides,
      );
      addTearDown(container.dispose);

      final riverpod.ProviderSubscription<AccountEntity?> subscription =
          container.listen(
            homeAccountByIdProvider('acc-1'),
            _noop,
            fireImmediately: true,
          );
      addTearDown(subscription.close);

      await container.pump();
      expect(subscription.read(), account);
    });
  });

  group('homeCategoryByIdProvider', () {
    test('возвращает категорию по идентификатору', () async {
      final Category category = Category(
        id: 'cat-1',
        name: 'Food',
        type: 'expense',
        icon: null,
        color: '#FF0000',
        parentId: null,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isDeleted: false,
      );

      final overrides = [
        homeCategoriesProvider.overrideWith(
          (riverpod.Ref ref) =>
              Stream<List<Category>>.value(<Category>[category]),
        ),
      ];
      final riverpod.ProviderContainer container = riverpod.ProviderContainer(
        overrides: overrides,
      );
      addTearDown(container.dispose);

      final riverpod.ProviderSubscription<Category?> subscription = container
          .listen(
            homeCategoryByIdProvider('cat-1'),
            _noop,
            fireImmediately: true,
          );
      addTearDown(subscription.close);

      await container.pump();
      expect(subscription.read(), category);
    });
  });

  group('homeGroupedTransactionsProvider', () {
    test('учитывает фильтр по типу транзакции', () async {
      final TransactionEntity expense = TransactionEntity(
        id: 'tx-expense',
        accountId: 'acc-1',
        categoryId: 'cat-1',
        amountMinor: BigInt.from(-10000),
        amountScale: 2,
        date: DateTime(2024, 3, 1, 10, 0),
        note: 'Expense',
        type: TransactionType.expense.storageValue,
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 1),
      );
      final TransactionEntity income = TransactionEntity(
        id: 'tx-income',
        accountId: 'acc-1',
        categoryId: 'cat-2',
        amountMinor: BigInt.from(20000),
        amountScale: 2,
        date: DateTime(2024, 3, 2, 9, 0),
        note: 'Income',
        type: TransactionType.income.storageValue,
        createdAt: DateTime(2024, 3, 2),
        updatedAt: DateTime(2024, 3, 2),
      );

      final overrides = [
        homeRecentTransactionsProvider().overrideWith((
          riverpod.Ref ref, {
          int limit = kDefaultRecentTransactionsLimit,
        }) {
          return Stream<List<TransactionEntity>>.value(<TransactionEntity>[
            expense,
            income,
          ]);
        }),
      ];

      final riverpod.ProviderContainer container = riverpod.ProviderContainer(
        overrides: overrides,
      );
      addTearDown(container.dispose);

      final List<DaySection> allSections = await _readGroupedTransactions(
        container,
      );
      final int totalAll = allSections
          .map((DaySection section) => section.items.length)
          .fold<int>(0, (int prev, int count) => prev + count);
      expect(totalAll, 2);

      container
          .read(homeTransactionsFilterControllerProvider.notifier)
          .update(HomeTransactionsFilter.income);
      container.invalidate(homeGroupedTransactionsProvider);
      final List<DaySection> incomeSections = await _readGroupedTransactions(
        container,
      );
      final int totalIncome = incomeSections
          .map((DaySection section) => section.items.length)
          .fold<int>(0, (int prev, int count) => prev + count);

      expect(totalIncome, 1);
      expect(
        incomeSections.every(
          (DaySection section) => section.items.every(
            (item) => item.maybeWhen(
              transaction: (tx) =>
                  tx.type == TransactionType.income.storageValue,
              orElse: () => false,
            ),
          ),
        ),
        isTrue,
      );
    });
  });
}
