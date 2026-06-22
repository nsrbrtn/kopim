import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync/sync_ownership_guard.dart';

void main() {
  late AppDatabase database;
  late SyncOwnershipGuard guard;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    guard = SyncOwnershipGuard(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('SyncOwnershipGuard Projection Tests', () {
    test('skips row-level validation if database is null', () async {
      const SyncOwnershipGuard nullDbGuard = SyncOwnershipGuard(null);
      await expectLater(
        nullDbGuard.ensureOutboxEntryCanBePushed(
          currentCloudUid: 'cloud-user-1',
          entryOwnerUid: 'cloud-user-1',
          entityType: 'account',
          entityId: 'acc-1',
          payload: '{}',
        ),
        completes,
      );
    });

    test(
      'skips row-level validation if entityType or entityId is null',
      () async {
        await expectLater(
          guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: null,
            entityId: null,
            payload: '{}',
          ),
          completes,
        );
      },
    );

    test('skips row-level validation for profile type', () async {
      await expectLater(
        guard.ensureOutboxEntryCanBePushed(
          currentCloudUid: 'cloud-user-1',
          entryOwnerUid: 'cloud-user-1',
          entityType: 'profile',
          entityId: 'profile-1',
          payload: '{}',
        ),
        completes,
      );
    });

    test(
      'throws SyncOwnershipException if no ownership projection exists for the entity',
      () async {
        expect(
          () => guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'account',
            entityId: 'acc-not-exists',
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

    test(
      'throws SyncOwnershipException if ownership projection state is not cloudOwned',
      () async {
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
          () => guard.ensureOutboxEntryCanBePushed(
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
      },
    );

    test(
      'throws SyncOwnershipException if ownerUid does not match currentCloudUid',
      () async {
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
          () => guard.ensureOutboxEntryCanBePushed(
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
              contains(
                'принадлежит cloud-user-2, а текущий пользователь cloud-user-1',
              ),
            ),
          ),
        );
      },
    );

    test(
      'completes successfully if ownership state is cloudOwned and ownerUid matches',
      () async {
        await database
            .into(database.localRowOwnership)
            .insert(
              const LocalRowOwnershipCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-1'),
                ownershipState: Value<String>('cloudOwned'),
                ownerUid: Value<String?>('cloud-user-1'),
                source: Value<String>('local_creation'),
              ),
            );

        await expectLater(
          guard.ensureOutboxEntryCanBePushed(
            currentCloudUid: 'cloud-user-1',
            entryOwnerUid: 'cloud-user-1',
            entityType: 'account',
            entityId: 'acc-1',
            payload: '{}',
          ),
          completes,
        );
      },
    );

    group('transaction_tag inheritance validation', () {
      test(
        'throws SyncOwnershipException if transaction_tag payload is missing or invalid',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-1',
              entryOwnerUid: 'cloud-user-1',
              entityType: 'transaction_tag',
              entityId: 'tag-1',
              payload: null,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('не содержит payload'),
              ),
            ),
          );

          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-1',
              entryOwnerUid: 'cloud-user-1',
              entityType: 'transaction_tag',
              entityId: 'tag-1',
              payload: 'invalid-json',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('Не удалось извлечь transactionId'),
              ),
            ),
          );

          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-1',
              entryOwnerUid: 'cloud-user-1',
              entityType: 'transaction_tag',
              entityId: 'tag-1',
              payload: '{"someKey": "value"}',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('не содержит transactionId'),
              ),
            ),
          );
        },
      );

      test(
        'validates based on parent transaction ownership projection',
        () async {
          // Parent transaction is cloudOwned by cloud-user-1
          await database
              .into(database.localRowOwnership)
              .insert(
                const LocalRowOwnershipCompanion(
                  entityType: Value<String>('transaction'),
                  entityId: Value<String>('tx-999'),
                  ownershipState: Value<String>('cloudOwned'),
                  ownerUid: Value<String?>('cloud-user-1'),
                  source: Value<String>('local_creation'),
                ),
              );

          await expectLater(
            guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-1',
              entryOwnerUid: 'cloud-user-1',
              entityType: 'transaction_tag',
              entityId: 'tag-1',
              payload: '{"transactionId": "tx-999"}',
            ),
            completes,
          );

          // Mismatched parent ownerUid should throw
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-2',
              entryOwnerUid: 'cloud-user-2',
              entityType: 'transaction_tag',
              entityId: 'tag-1',
              payload: '{"transactionId": "tx-999"}',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains(
                  'принадлежит cloud-user-1, а текущий пользователь cloud-user-2',
                ),
              ),
            ),
          );
        },
      );
    });
  });
}
