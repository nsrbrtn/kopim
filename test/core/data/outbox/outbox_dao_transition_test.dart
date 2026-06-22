import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';

void main() {
  late AppDatabase database;
  late OutboxDao outboxDao;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    outboxDao = OutboxDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('OutboxDao Transition Tests', () {
    test(
      'selectLocalOnlyOutboxRows selects local- prefixed ownerUid rows',
      () async {
        // Insert one local- prefixed, one null owner, and one cloud owner outbox entry
        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-1'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>('local-user-123'),
              ),
            );

        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-2'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>(null),
              ),
            );

        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-3'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>('cloud-user-123'),
              ),
            );

        final List<OutboxEntryRow> localOnly = await outboxDao
            .selectLocalOnlyOutboxRows();
        expect(localOnly, hasLength(1));
        expect(localOnly.first.entityId, 'acc-1');
      },
    );

    test('selectNullOwnerOutboxRows selects null ownerUid rows', () async {
      await database
          .into(database.outboxEntries)
          .insert(
            const OutboxEntriesCompanion(
              entityType: Value<String>('account'),
              entityId: Value<String>('acc-1'),
              operation: Value<String>('upsert'),
              payload: Value<String>('{}'),
              status: Value<String>('pending'),
              ownerUid: Value<String?>('local-user-123'),
            ),
          );

      await database
          .into(database.outboxEntries)
          .insert(
            const OutboxEntriesCompanion(
              entityType: Value<String>('account'),
              entityId: Value<String>('acc-2'),
              operation: Value<String>('upsert'),
              payload: Value<String>('{}'),
              status: Value<String>('pending'),
              ownerUid: Value<String?>(null),
            ),
          );

      final List<OutboxEntryRow> nullOwner = await outboxDao
          .selectNullOwnerOutboxRows();
      expect(nullOwner, hasLength(1));
      expect(nullOwner.first.entityId, 'acc-2');
    });

    test(
      'assertNoDispatchableLocalOnlyOutbox throws StateError on active local/null outbox',
      () async {
        // 1. Initially empty outbox should not throw
        await expectLater(
          outboxDao.assertNoDispatchableLocalOnlyOutbox(),
          completes,
        );

        // 2. Regular cloud outbox should not throw
        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-1'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>('cloud-user-123'),
              ),
            );
        await expectLater(
          outboxDao.assertNoDispatchableLocalOnlyOutbox(),
          completes,
        );

        // 3. Local outbox with status 'pending' should throw
        final int localId = await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-2'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>('local-user-123'),
              ),
            );
        expect(
          () => outboxDao.assertNoDispatchableLocalOnlyOutbox(),
          throwsStateError,
        );

        // 4. Update status to 'completed' - should not throw
        await (database.update(
          database.outboxEntries,
        )..where(($OutboxEntriesTable tbl) => tbl.id.equals(localId))).write(
          const OutboxEntriesCompanion(status: Value<String>('completed')),
        );
        await expectLater(
          outboxDao.assertNoDispatchableLocalOnlyOutbox(),
          completes,
        );

        // 5. Add null-owner with status 'failed' - should throw
        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-3'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('failed'),
                ownerUid: Value<String?>(null),
              ),
            );
        expect(
          () => outboxDao.assertNoDispatchableLocalOnlyOutbox(),
          throwsStateError,
        );
      },
    );

    test(
      'consumeLocalOnlyOutboxAfterMigrationSuccess deletes local/null outbox rows and preserves cloud ones',
      () async {
        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-1'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>('local-user-123'),
              ),
            );

        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-2'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>(null),
              ),
            );

        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-3'),
                operation: Value<String>('upsert'),
                payload: Value<String>('{}'),
                status: Value<String>('pending'),
                ownerUid: Value<String?>('cloud-user-123'),
              ),
            );

        await outboxDao.consumeLocalOnlyOutboxAfterMigrationSuccess();

        final List<OutboxEntryRow> remaining = await database
            .select(database.outboxEntries)
            .get();
        expect(remaining, hasLength(1));
        expect(remaining.first.entityId, 'acc-3');
      },
    );
  });
}
