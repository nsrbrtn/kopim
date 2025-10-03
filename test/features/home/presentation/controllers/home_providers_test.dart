import 'dart:async';

// ignore_for_file: always_specify_types

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:riverpod/riverpod.dart' as riverpod;

void _noop<T>(T? previous, T next) {}

void main() {
  group('homeTransactionByIdProvider', () {
    test('возвращает транзакцию по идентификатору', () async {
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        amount: -42,
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
        balance: 100,
        currency: 'usd',
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
}
