import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/data/sources/remote/credit_remote_data_source.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';

void main() {
  group('CreditRemoteDataSource', () {
    test(
      'сохраняет и читает interestCategoryId, feesCategoryId и firstPaymentDate при round-trip',
      () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final CreditRemoteDataSource dataSource = CreditRemoteDataSource(
          firestore,
        );

        final DateTime now = DateTime.utc(2026, 2, 28, 12, 0);
        final DateTime firstPaymentDate = DateTime.utc(2026, 3, 15);
        final CreditEntity entity = CreditEntity(
          id: 'credit-1',
          accountId: 'acc-credit-1',
          categoryId: 'cat-credit-main',
          interestCategoryId: 'cat-credit-interest',
          feesCategoryId: 'cat-credit-fees',
          totalAmountMinor: BigInt.from(500000),
          totalAmountScale: 2,
          interestRate: 12.0,
          termMonths: 24,
          startDate: DateTime.utc(2026, 2, 1),
          firstPaymentDate: firstPaymentDate,
          paymentDay: 15,
          createdAt: now,
          updatedAt: now,
        );

        await dataSource.upsert('user-1', entity);
        final List<CreditEntity> fetched = await dataSource.fetchAll('user-1');

        expect(fetched, hasLength(1));
        expect(fetched.first.id, entity.id);
        expect(fetched.first.interestCategoryId, entity.interestCategoryId);
        expect(fetched.first.feesCategoryId, entity.feesCategoryId);
        expect(fetched.first.firstPaymentDate, firstPaymentDate);
      },
    );
  });
}
