// test/features/profile/application/cloud_activation_hardening_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/sync/sync_ownership_guard.dart';
import 'package:kopim/core/services/sync/sync_metadata_repository.dart';
import 'package:kopim/features/profile/data/user_account_cleanup_repository_impl.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';

class _MockProfileAvatarRepository extends Mock
    implements ProfileAvatarRepository {}

class _MockSyncMetadataRepository extends Mock
    implements SyncMetadataRepository {}

class _FailingTransactionDatabase extends db.AppDatabase {
  _FailingTransactionDatabase(super.connection);

  @override
  Future<T> transaction<T>(
    Future<T> Function() action, {
    bool requireNew = false,
  }) {
    return Future<T>.error(Exception('SQLite reset failed'));
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(MigrationDecision.none);
  });

  group('Cloud Activation Hardening & Reset Tests', () {
    late db.AppDatabase realDb;
    late OutboxDao outboxDao;
    late _MockProfileAvatarRepository avatarRepository;
    late _MockSyncMetadataRepository metadataRepository;
    late UserAccountCleanupRepositoryImpl cleanupRepository;

    setUp(() {
      realDb = db.AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      outboxDao = OutboxDao(realDb, () => 'local-user');
      avatarRepository = _MockProfileAvatarRepository();
      metadataRepository = _MockSyncMetadataRepository();

      cleanupRepository = UserAccountCleanupRepositoryImpl(
        firestore: FakeFirebaseFirestoreInstance(),
        database: realDb,
        profileAvatarRepository: avatarRepository,
        syncMetadataRepository: metadataRepository,
      );

      when(() => metadataRepository.clear(any())).thenAnswer((_) async {});
      when(() => avatarRepository.delete(any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await realDb.close();
    });

    test(
      'SQLite reset failed inside transaction => sync metadata clear is not called (atomic order)',
      () async {
        final _FailingTransactionDatabase failingDb =
            _FailingTransactionDatabase(
              DatabaseConnection(NativeDatabase.memory()),
            );
        final UserAccountCleanupRepositoryImpl repositoryWithFailingDb =
            UserAccountCleanupRepositoryImpl(
              firestore: FakeFirebaseFirestoreInstance(),
              database: failingDb,
              profileAvatarRepository: avatarRepository,
              syncMetadataRepository: metadataRepository,
            );

        expect(
          () => repositoryWithFailingDb.deleteLocalUserData('user-123'),
          throwsA(
            isA<Exception>().having(
              (Exception e) => e.toString(),
              'message',
              contains('SQLite reset failed'),
            ),
          ),
        );

        // Проверяем, что metadataRepository.clear никогда не был вызван, так как SQLite транзакция упала
        verifyNever(() => metadataRepository.clear('user-123'));

        await failingDb.close();
      },
    );

    test(
      'successful reset completely clears database tables and outbox entries without leaving tombstones',
      () async {
        // Добавим тестовую категорию и транзакцию
        await realDb
            .into(realDb.categories)
            .insert(
              db.CategoriesCompanion.insert(
                id: 'c1',
                name: 'Food',
                type: 'expense',
                isSystem: const Value<bool>(false),
              ),
            );
        await realDb
            .into(realDb.accounts)
            .insert(
              db.AccountsCompanion.insert(
                id: 'a1',
                name: 'Main Wallet',
                balance: 1000.0,
                currency: 'USD',
                type: 'checking',
              ),
            );
        await realDb
            .into(realDb.transactions)
            .insert(
              db.TransactionsCompanion.insert(
                id: 't1',
                accountId: 'a1',
                amount: 50.0,
                date: DateTime.now(),
                type: 'expense',
              ),
            );

        // Также вставим запись в outbox
        await outboxDao.enqueue(
          entityType: 'transaction',
          entityId: 't1',
          operation: OutboxOperation.upsert,
          payload: const <String, dynamic>{'amount': 50.0},
        );

        // Убедимся, что данные есть
        final List<db.CategoryRow> categoriesBefore = await realDb
            .select(realDb.categories)
            .get();
        final List<db.TransactionRow> transactionsBefore = await realDb
            .select(realDb.transactions)
            .get();
        final int outboxCountBefore = await outboxDao.pendingCount();

        expect(categoriesBefore.length, 1);
        expect(transactionsBefore.length, 1);
        expect(outboxCountBefore, 1);

        // Выполняем сброс
        await cleanupRepository.deleteLocalUserData('user-123');

        // Проверяем состояние БД после сброса
        final List<db.CategoryRow> categoriesAfter = await realDb
            .select(realDb.categories)
            .get();
        final List<db.TransactionRow> transactionsAfter = await realDb
            .select(realDb.transactions)
            .get();
        final int outboxCountAfter = await outboxDao.pendingCount();

        expect(categoriesAfter.isEmpty, true);
        expect(transactionsAfter.isEmpty, true);
        expect(outboxCountAfter, 0);

        // Проверяем, что sync metadata была успешно очищена после транзакции
        verify(() => metadataRepository.clear('user-123')).called(1);
      },
    );

    test(
      'SyncOwnershipGuard blocks pushing outbox entries with null or local- ownerUid',
      () async {
        const SyncOwnershipGuard guard = SyncOwnershipGuard();

        // 1. null ownerUid
        expect(
          () => guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: null,
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains('Legacy OutboxEntry с пустым ownerUid заблокирована'),
            ),
          ),
        );

        // 2. local- ownerUid
        expect(
          () => guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'local-user-123',
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains(
                'Локальная OutboxEntry заблокирована от автоматической отправки',
              ),
            ),
          ),
        );

        // 3. mismatched ownerUid
        expect(
          () => guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-2',
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains('не может быть отправлена для пользователя'),
            ),
          ),
        );

        // 4. matched ownerUid passes
        await expectLater(
          guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
          ),
          completes,
        );
      },
    );

    test(
      'SyncOwnershipGuard.ensureCanStartCloudSync blocks startWithEmptyCloud decision if local data is present',
      () async {
        const SyncOwnershipGuard guard = SyncOwnershipGuard();

        expect(
          () => guard.ensureCanStartCloudSync(
            currentCloudUid: 'cloud-user-1',
            migrationDecision: MigrationDecision.startWithEmptyCloud,
            hasLocalData: true,
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains(
                'Использование облака с пустого профиля при наличии локальных данных заблокировано',
              ),
            ),
          ),
        );
      },
    );
  });
}

// Заглушка для FakeFirebaseFirestore
class FakeFirebaseFirestoreInstance extends Mock implements FirebaseFirestore {}
