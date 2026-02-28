import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  group('TransactionRemoteDataSource', () {
    test('сохраняет и читает groupId при round-trip', () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final TransactionRemoteDataSource dataSource =
          TransactionRemoteDataSource(firestore);

      final DateTime now = DateTime.utc(2026, 2, 28, 12, 0);
      final TransactionEntity entity = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        transferAccountId: 'acc-credit',
        categoryId: 'cat-1',
        idempotencyKey: 'idem-1',
        groupId: 'credit-group-1',
        amountMinor: BigInt.from(12345),
        amountScale: 2,
        date: now,
        note: 'Платеж по кредиту',
        type: 'transfer',
        createdAt: now,
        updatedAt: now,
      );

      await dataSource.upsert('user-1', entity);
      final List<TransactionEntity> fetched = await dataSource.fetchAll(
        'user-1',
      );

      expect(fetched, hasLength(1));
      expect(fetched.first.id, entity.id);
      expect(fetched.first.groupId, entity.groupId);
      expect(fetched.first.type, entity.type);
      expect(fetched.first.transferAccountId, entity.transferAccountId);
    });
  });
}
