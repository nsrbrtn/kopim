import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync/sync_ownership_guard.dart';

void main() {
  group('SyncOwnershipGuard Tests', () {
    const SyncOwnershipGuard guard = SyncOwnershipGuard();

    tearDown(() {
      // Возвращаем в дефолтное состояние после каждого теста
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    });

    group('ensureCanStartCloudSync', () {
      test(
        'should throw SyncOwnershipException if offlineOnly distribution',
        () async {
          AppRuntimeConfig.configure(AppRuntimeFlavor.offlineOnly);

          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.none,
              hasLocalData: false,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('disabled in offline-only build'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is none',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.none,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('обнаружены локальные данные'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is stayLocalOnly',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.stayLocalOnly,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('обнаружены локальные данные'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is migrateLocalToCloud',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.migrateLocalToCloud,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains(
                  'Перенос локальных данных в облако временно недоступен',
                ),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is startWithEmptyCloud',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
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

      test('should complete successfully if hasLocalData is false', () async {
        await expectLater(
          guard.ensureCanStartCloudSync(
            currentCloudUid: 'cloud-user-123',
            migrationDecision: MigrationDecision.none,
            hasLocalData: false,
          ),
          completes,
        );
      });
    });

    group('ensureOutboxEntryCanBePushed', () {
      test(
        'should throw SyncOwnershipException if offlineOnly distribution',
        () async {
          AppRuntimeConfig.configure(AppRuntimeFlavor.offlineOnly);

          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'cloud-user-123',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('disabled in offline-only build'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if entryOwnerUid is null',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
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
        },
      );

      test(
        'should throw SyncOwnershipException if entryOwnerUid starts with local-',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'local-profile-abc',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('Локальная OutboxEntry заблокирована'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if entryOwnerUid does not match currentCloudUid',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'cloud-user-999',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('не может быть отправлена для пользователя'),
              ),
            ),
          );
        },
      );

      test(
        'should complete successfully if entryOwnerUid matches currentCloudUid',
        () async {
          await expectLater(
            guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'cloud-user-123',
            ),
            completes,
          );
        },
      );
    });

    group('projection-backed dispatch blocking', () {
      late AppDatabase database;
      late SyncOwnershipGuard dbGuard;

      setUp(() {
        database = AppDatabase.connect(
          DatabaseConnection(NativeDatabase.memory()),
        );
        dbGuard = SyncOwnershipGuard(database);
      });

      tearDown(() async {
        await database.close();
      });

      test(
        'missing projection blocks dispatch for currentUid outbox',
        () async {
          expect(
            () => dbGuard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-1',
              entryOwnerUid: 'cloud-user-1',
              entityType: 'account',
              entityId: 'acc-1',
              payload: '{}',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('отсутствует запись владения'),
              ),
            ),
          );
        },
      );

      test('localOnly ownership blocks currentUid outbox dispatch', () async {
        await database
            .into(database.localRowOwnership)
            .insert(
              const LocalRowOwnershipCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-1'),
                ownershipState: Value<String>('localOnly'),
                ownerUid: Value<String?>(null),
                source: Value<String>('local_creation'),
              ),
            );

        expect(
          () => dbGuard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'account',
            entityId: 'acc-1',
            payload: '{}',
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains('имеет статус localOnly, а не cloudOwned'),
            ),
          ),
        );
      });

      test('cloudOwned foreign UID stays blocked', () async {
        await database
            .into(database.localRowOwnership)
            .insert(
              const LocalRowOwnershipCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-1'),
                ownershipState: Value<String>('cloudOwned'),
                ownerUid: Value<String?>('cloud-user-2'),
                source: Value<String>('local_creation'),
              ),
            );

        expect(
          () => dbGuard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'account',
            entityId: 'acc-1',
            payload: '{}',
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains('принадлежит cloud-user-2'),
            ),
          ),
        );
      });

      test('transaction_tag inherits transaction ownership', () async {
        await database
            .into(database.localRowOwnership)
            .insert(
              const LocalRowOwnershipCompanion(
                entityType: Value<String>('transaction'),
                entityId: Value<String>('tx-1'),
                ownershipState: Value<String>('cloudOwned'),
                ownerUid: Value<String?>('cloud-user-1'),
                source: Value<String>('local_creation'),
              ),
            );

        await expectLater(
          dbGuard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'transaction_tag',
            entityId: 'tx-1:tag-1',
            payload: '{"transactionId":"tx-1"}',
          ),
          completes,
        );

        expect(
          () => dbGuard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'transaction_tag',
            entityId: 'tx-1:tag-1',
            payload: '{"tagId":"tag-1"}',
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains('transaction_tag не содержит transactionId'),
            ),
          ),
        );
      });

      test('goal_account_link inherits saving_goal ownership', () async {
        await database
            .into(database.localRowOwnership)
            .insert(
              const LocalRowOwnershipCompanion(
                entityType: Value<String>('saving_goal'),
                entityId: Value<String>('goal-1'),
                ownershipState: Value<String>('cloudOwned'),
                ownerUid: Value<String?>('cloud-user-1'),
                source: Value<String>('local_creation'),
              ),
            );

        await expectLater(
          dbGuard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'goal_account_link',
            entityId: 'goal-1:acc-1',
            payload: '{"goalId":"goal-1","accountId":"acc-1"}',
          ),
          completes,
        );

        expect(
          () => dbGuard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'goal_account_link',
            entityId: 'goal-1:acc-1',
            payload: '{"accountId":"acc-1"}',
          ),
          throwsA(
            isA<SyncOwnershipException>().having(
              (SyncOwnershipException e) => e.message,
              'message',
              contains('goal_account_link не содержит goalId'),
            ),
          ),
        );
      });
    });
  });
}
