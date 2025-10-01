import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/watch_recent_transactions_use_case.dart';

void main() {
  group('WatchRecentTransactionsUseCase', () {
    late StreamController<List<TransactionEntity>> controller;
    late WatchRecentTransactionsUseCase useCase;

    setUp(() {
      controller = StreamController<List<TransactionEntity>>();
      useCase = WatchRecentTransactionsUseCase(
        _InMemoryTransactionRepository(controller.stream),
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test('sorts by date descending and applies the provided limit', () async {
      final DateTime base = DateTime.utc(2024, 1, 1);
      final List<TransactionEntity> unsorted = <TransactionEntity>[
        _transaction('b', base.add(const Duration(days: 2))),
        _transaction('a', base.add(const Duration(days: 5))),
        _transaction('c', base),
      ];

      final Future<List<TransactionEntity>> result = useCase
          .call(limit: 2)
          .first;

      controller.add(unsorted);

      expect(await result, <TransactionEntity>[unsorted[1], unsorted[0]]);
    });

    test('returns all transactions when limit is zero or negative', () async {
      final DateTime base = DateTime.utc(2024, 1, 1);
      final List<TransactionEntity> unsorted = <TransactionEntity>[
        _transaction('1', base),
        _transaction('2', base.add(const Duration(days: 3))),
        _transaction('3', base.add(const Duration(days: 1))),
      ];

      final Future<List<TransactionEntity>> result = useCase
          .call(limit: 0)
          .first;

      controller.add(unsorted);

      expect(await result, <TransactionEntity>[
        unsorted[1],
        unsorted[2],
        unsorted[0],
      ]);
    });
  });
}

TransactionEntity _transaction(String id, DateTime date) {
  return TransactionEntity(
    id: id,
    accountId: 'acc',
    categoryId: 'cat',
    amount: 10,
    date: date,
    note: null,
    type: 'expense',
    createdAt: date,
    updatedAt: date,
  );
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
