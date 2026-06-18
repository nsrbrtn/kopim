import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/data/remote/user_progress_remote_data_source.dart';
import 'package:kopim/features/profile/data/user_progress_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionDao extends Mock implements TransactionDao {}

class _MockUserProgressRemoteDataSource extends Mock
    implements UserProgressRemoteDataSource {}

void main() {
  late _MockTransactionDao transactionDao;
  late _MockUserProgressRemoteDataSource remoteDataSource;

  setUp(() {
    transactionDao = _MockTransactionDao();
    remoteDataSource = _MockUserProgressRemoteDataSource();
  });

  test(
    'does not write remote progress when remote writes are blocked',
    () async {
      final UserProgressRepositoryImpl repository = UserProgressRepositoryImpl(
        transactionDao: transactionDao,
        remoteDataSource: remoteDataSource,
        canWriteRemotely: (_) => false,
      );

      await repository.saveRemoteProgress(
        uid: 'cloud-user-1',
        totalTx: 10,
        updatedAt: DateTime.utc(2024, 6, 12),
      );

      verifyNever(
        () => remoteDataSource.upsert(
          uid: any(named: 'uid'),
          totalTx: any(named: 'totalTx'),
          updatedAt: any(named: 'updatedAt'),
        ),
      );
    },
  );

  test('writes remote progress when remote writes are allowed', () async {
    when(
      () => remoteDataSource.upsert(
        uid: any(named: 'uid'),
        totalTx: any(named: 'totalTx'),
        updatedAt: any(named: 'updatedAt'),
      ),
    ).thenAnswer((_) async {});
    final UserProgressRepositoryImpl repository = UserProgressRepositoryImpl(
      transactionDao: transactionDao,
      remoteDataSource: remoteDataSource,
      canWriteRemotely: (String uid) => uid == 'cloud-user-1',
    );

    await repository.saveRemoteProgress(
      uid: 'cloud-user-1',
      totalTx: 10,
      updatedAt: DateTime.utc(2024, 6, 12),
    );

    verify(
      () => remoteDataSource.upsert(
        uid: 'cloud-user-1',
        totalTx: 10,
        updatedAt: DateTime.utc(2024, 6, 12),
      ),
    ).called(1);
  });
}
