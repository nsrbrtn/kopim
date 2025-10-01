import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/usecases/watch_recent_transactions_use_case_impl.dart';

void main() {
  group('WatchRecentTransactionsUseCaseImpl', () {
    late StreamController<List<TransactionEntity>> controller;
    late _FakeTransactionRepository repository;
    late WatchRecentTransactionsUseCaseImpl useCase;

    setUp(() {
      controller = StreamController<List<TransactionEntity>>();
      repository = _FakeTransactionRepository(controller.stream);
      useCase = WatchRecentTransactionsUseCaseImpl(repository: repository);
    });

    tearDown(() async {
      await controller.close();
    });

    test(
      'returns most recent transactions limited to requested size',
      () async {
        final List<TransactionEntity> seedTransactions =
            List<TransactionEntity>.generate(
              60,
              (int index) => TransactionEntity(
                id: 't$index',
                accountId: 'a1',
                categoryId: 'c$index',
                amount: 10.0 + index,
                date: DateTime(2024, 1, 1).add(Duration(days: index)),
                note: 'note $index',
                type: index.isEven ? 'income' : 'expense',
                createdAt: DateTime(2024, 1, 1),
                updatedAt: DateTime(2024, 1, 1),
              ),
            );

        final List<List<TransactionEntity>> emissions =
            <List<TransactionEntity>>[];
        final StreamSubscription<List<TransactionEntity>> subscription =
            useCase(limit: 50).listen(emissions.add);

        controller.add(seedTransactions);
        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(1));
        final List<TransactionEntity> result = emissions.first;
        expect(result, hasLength(50));
        expect(result.first.id, 't59');
        expect(result.last.id, 't10');
        expect(result.first.date.isAfter(result.last.date), isTrue);

        await subscription.cancel();
      },
    );
  });
}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._stream);

  final Stream<List<TransactionEntity>> _stream;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _stream;

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
