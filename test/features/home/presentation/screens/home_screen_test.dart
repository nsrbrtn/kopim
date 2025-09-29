import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('Home providers', () {
    late StreamController<List<AccountEntity>> accountsController;
    late StreamController<List<TransactionEntity>> transactionsController;
    late ProviderContainer container;

    setUp(() {
      accountsController = StreamController<List<AccountEntity>>();
      transactionsController = StreamController<List<TransactionEntity>>();

      container = ProviderContainer(
        overrides: <Override>[
          watchAccountsUseCaseProvider.overrideWithValue(
            WatchAccountsUseCase(
              _InMemoryAccountRepository(accountsController.stream),
            ),
          ),
          watchRecentTransactionsUseCaseProvider.overrideWithValue(
            WatchRecentTransactionsUseCase(
              _InMemoryTransactionRepository(transactionsController.stream),
            ),
          ),
        ],
      );
    });

    tearDown(() async {
      await accountsController.close();
      await transactionsController.close();
      container.dispose();
    });

    test('homeAccountsProvider exposes the account stream', () async {
      final List<AccountEntity> expectedAccounts = <AccountEntity>[
        _account('1'),
        _account('2'),
      ];

      final Future<List<AccountEntity>> result =
          container.read(homeAccountsProvider.stream).first;

      accountsController.add(expectedAccounts);

      expect(await result, expectedAccounts);
    });

    test('homeRecentTransactionsProvider forwards the limit to the use case',
        () async {
      final List<TransactionEntity> expectedTransactions =
          <TransactionEntity>[_transaction('1'), _transaction('2')];
      final _RecordingWatchRecentTransactionsUseCase recordingUseCase =
          _RecordingWatchRecentTransactionsUseCase(
        transactionsController.stream,
      );

      final ProviderContainer scopedContainer = ProviderContainer(
        parent: container,
        overrides: <Override>[
          watchRecentTransactionsUseCaseProvider.overrideWithValue(
            recordingUseCase,
          ),
        ],
      );

      addTearDown(scopedContainer.dispose);

      final Future<List<TransactionEntity>> result = scopedContainer
          .read(homeRecentTransactionsProvider(limit: 7).stream)
          .first;

      transactionsController.add(expectedTransactions);

      expect(await result, expectedTransactions);
      expect(recordingUseCase.lastLimit, 7);
    });
  });
}

AccountEntity _account(String id) {
  final DateTime now = DateTime.now();
  return AccountEntity(
    id: id,
    name: 'Account $id',
    balance: 0,
    currency: 'USD',
    type: 'cash',
    createdAt: now,
    updatedAt: now,
  );
}

TransactionEntity _transaction(String id) {
  final DateTime now = DateTime.now();
  return TransactionEntity(
    id: id,
    accountId: 'acc',
    categoryId: 'cat',
    amount: 10,
    date: now,
    note: null,
    type: 'expense',
    createdAt: now,
    updatedAt: now,
  );
}

class _InMemoryAccountRepository implements AccountRepository {
  _InMemoryAccountRepository(this._stream);

  final Stream<List<AccountEntity>> _stream;

  @override
  Future<AccountEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> loadAccounts() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(AccountEntity account) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() => _stream;
}

class _InMemoryTransactionRepository implements TransactionRepository {
  _InMemoryTransactionRepository(this._stream);

  final Stream<List<TransactionEntity>> _stream;

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _stream;
}

class _RecordingWatchRecentTransactionsUseCase
    extends WatchRecentTransactionsUseCase {
  _RecordingWatchRecentTransactionsUseCase(this._stream)
      : lastLimit = null,
        super(_DummyTransactionRepository());

  final Stream<List<TransactionEntity>> _stream;
  int? lastLimit;

  @override
  Stream<List<TransactionEntity>> call({int limit = 5}) {
    lastLimit = limit;
    return _stream;
  }
}

class _DummyTransactionRepository implements TransactionRepository {
  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> loadTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    throw UnimplementedError();
  }
}
