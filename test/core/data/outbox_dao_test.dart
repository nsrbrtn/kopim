import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/profile/data/migration_freeze_state_repository.dart';

void main() {
  late AppDatabase database;
  late OutboxDao outboxDao;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    outboxDao = OutboxDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('enqueue stores pending entry with payload snapshot', () async {
    final int id = await outboxDao.enqueue(
      entityType: 'account',
      entityId: 'acc-1',
      operation: OutboxOperation.upsert,
      payload: <String, dynamic>{'id': 'acc-1', 'name': 'Main'},
    );

    final List<OutboxEntryRow> entries = await outboxDao.fetchPending();
    expect(entries, hasLength(1));
    final OutboxEntryRow entry = entries.single;
    expect(entry.id, id);
    expect(entry.status, OutboxStatus.pending.name);
    expect(entry.attemptCount, 0);
    final Map<String, dynamic> payload =
        jsonDecode(entry.payload) as Map<String, dynamic>;
    expect(payload['id'], 'acc-1');
  });

  test(
    'enqueue blocks covered entities while migration freeze is active',
    () async {
      final SharedPrefsMigrationFreezeStateRepository stateRepository =
          SharedPrefsMigrationFreezeStateRepository();
      final SharedPrefsMigrationWriteGuard guard =
          SharedPrefsMigrationWriteGuard(
            database: database,
            stateRepository: stateRepository,
          );
      outboxDao = OutboxDao(database, null, null, guard);
      await guard.activateFreeze(
        uid: 'cloud-user-1',
        phase: 'upload_in_progress',
      );

      await expectLater(
        outboxDao.enqueue(
          entityType: 'account',
          entityId: 'acc-1',
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{'id': 'acc-1'},
        ),
        throwsA(isA<MigrationFreezeActive>()),
      );
    },
  );

  test('prepareForSend increments attempt count and updates status', () async {
    final int id = await outboxDao.enqueue(
      entityType: 'transaction',
      entityId: 'txn-1',
      operation: OutboxOperation.upsert,
      payload: <String, dynamic>{'id': 'txn-1'},
    );

    final OutboxEntryRow entry = (await outboxDao.fetchPending()).single;
    final OutboxEntryRow prepared = await outboxDao.prepareForSend(entry);

    expect(prepared.status, OutboxStatus.sending.name);
    expect(prepared.attemptCount, 1);

    await outboxDao.markAsFailed(prepared.id, 'network-error');
    final OutboxEntryRow afterFail = (await outboxDao.fetchPending())
        .singleWhere((OutboxEntryRow element) => element.id == id);
    expect(afterFail.status, OutboxStatus.failed.name);
    expect(afterFail.lastError, 'network-error');

    await outboxDao.markAsSent(prepared.id);
    final List<OutboxEntryRow> sentEntries = await database
        .select(database.outboxEntries)
        .get();
    final OutboxEntryRow sent = sentEntries.singleWhere(
      (OutboxEntryRow element) => element.id == id,
    );
    expect(sent.status, OutboxStatus.sent.name);
    expect(sent.sentAt, isNotNull);
  });

  test(
    'enqueue coalesces repeated unsent operations for the same entity',
    () async {
      final int firstId = await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'acc-1', 'name': 'Old'},
      );

      final int secondId = await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'acc-1', 'name': 'New'},
      );

      expect(secondId, firstId);

      final List<OutboxEntryRow> entries = await outboxDao.fetchPending();
      expect(entries, hasLength(1));
      expect(outboxDao.decodePayload(entries.single)['name'], 'New');
      expect(entries.single.status, OutboxStatus.pending.name);
    },
  );

  test(
    'fetchPending orders entities by sync dependency order before createdAt',
    () async {
      await outboxDao.enqueue(
        entityType: 'transaction',
        entityId: 'tx-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'tx-1'},
      );
      await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'acc-1'},
      );
      await outboxDao.enqueue(
        entityType: 'saving_goal',
        entityId: 'goal-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'goal-1'},
      );
      await outboxDao.enqueue(
        entityType: 'credit_payment_schedule',
        entityId: 'schedule-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'schedule-1'},
      );
      await outboxDao.enqueue(
        entityType: 'credit_payment_group',
        entityId: 'group-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'group-1'},
      );

      final List<OutboxEntryRow> entries = await outboxDao.fetchPending(
        limit: 10,
      );

      expect(
        entries.map((OutboxEntryRow entry) => entry.entityType).toList(),
        <String>[
          'account',
          'saving_goal',
          'credit_payment_schedule',
          'credit_payment_group',
          'transaction',
        ],
      );
    },
  );

  test(
    'resetStaleSendingToPending recovers only stale sending entries',
    () async {
      final int staleId = await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-stale',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'acc-stale'},
      );
      final int freshId = await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-fresh',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'acc-fresh'},
      );

      final DateTime now = DateTime.now();
      await (database.update(
        database.outboxEntries,
      )..where((OutboxEntries tbl) => tbl.id.equals(staleId))).write(
        OutboxEntriesCompanion(
          status: Value<String>(OutboxStatus.sending.name),
          updatedAt: Value<DateTime>(now.subtract(const Duration(minutes: 10))),
        ),
      );
      await (database.update(
        database.outboxEntries,
      )..where((OutboxEntries tbl) => tbl.id.equals(freshId))).write(
        OutboxEntriesCompanion(
          status: Value<String>(OutboxStatus.sending.name),
          updatedAt: Value<DateTime>(now.subtract(const Duration(minutes: 1))),
        ),
      );

      final int resetCount = await outboxDao.resetStaleSendingToPending(
        cutoff: now.subtract(const Duration(minutes: 5)),
      );

      expect(resetCount, 1);

      final List<OutboxEntryRow> rows = await database
          .select(database.outboxEntries)
          .get();
      final OutboxEntryRow stale = rows.singleWhere(
        (OutboxEntryRow row) => row.id == staleId,
      );
      final OutboxEntryRow fresh = rows.singleWhere(
        (OutboxEntryRow row) => row.id == freshId,
      );
      expect(stale.status, OutboxStatus.pending.name);
      expect(fresh.status, OutboxStatus.sending.name);
    },
  );

  test(
    'pruneSent keeps fresh sent entries until retain window passes',
    () async {
      final int id = await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-sent',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'acc-sent'},
      );
      await outboxDao.markAsSent(id);

      await outboxDao.pruneSent(retain: const Duration(days: 7));

      final List<OutboxEntryRow> rowsAfterFreshPrune = await database
          .select(database.outboxEntries)
          .get();
      expect(rowsAfterFreshPrune, hasLength(1));

      await (database.update(
        database.outboxEntries,
      )..where((OutboxEntries tbl) => tbl.id.equals(id))).write(
        OutboxEntriesCompanion(
          sentAt: Value<DateTime>(
            DateTime.now().subtract(const Duration(days: 8)),
          ),
        ),
      );

      await outboxDao.pruneSent(retain: const Duration(days: 7));

      final List<OutboxEntryRow> rowsAfterExpiredPrune = await database
          .select(database.outboxEntries)
          .get();
      expect(rowsAfterExpiredPrune, isEmpty);
    },
  );

  group('OutboxDao - Topological Sort (TASK-003)', () {
    test('1. Same entity operation order (chronological)', () async {
      final int id1 = await outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-a',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'cat-a', 'name': 'Category A'},
      );

      final int id2 = await outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-a',
        operation: OutboxOperation.delete,
        payload: <String, dynamic>{'id': 'cat-a', 'isDeleted': true},
      );

      final List<OutboxEntryRow> sorted = await outboxDao.fetchPending();
      expect(sorted, hasLength(2));
      expect(sorted[0].id, id1);
      expect(sorted[1].id, id2);
    });

    test('2. Parent upsert before child delete', () async {
      final int txId = await outboxDao.enqueue(
        entityType: 'transaction',
        entityId: 'tx-1',
        operation: OutboxOperation.delete,
        payload: <String, dynamic>{
          'id': 'tx-1',
          'categoryId': 'cat-a',
          'isDeleted': true,
        },
      );

      final DateTime now = DateTime.now();
      await (database.update(
        database.outboxEntries,
      )..where((OutboxEntries tbl) => tbl.id.equals(txId))).write(
        OutboxEntriesCompanion(
          createdAt: Value<DateTime>(now.subtract(const Duration(minutes: 10))),
        ),
      );

      final int catId = await outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-a',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'cat-a', 'name': 'Category A'},
      );

      await (database.update(database.outboxEntries)
            ..where((OutboxEntries tbl) => tbl.id.equals(catId)))
          .write(OutboxEntriesCompanion(createdAt: Value<DateTime>(now)));

      final List<OutboxEntryRow> sorted = await outboxDao.fetchPending();
      final int txIdx = sorted.indexWhere((OutboxEntryRow e) => e.id == txId);
      final int catIdx = sorted.indexWhere((OutboxEntryRow e) => e.id == catId);

      // Даже при том, что транзакция создана раньше, родитель должен идти ПЕРЕД дочерним элементом
      expect(catIdx, lessThan(txIdx));
    });

    test('3. Multi-level dependency (Upsert & Cascade Delete)', () async {
      final int creditId = await outboxDao.enqueue(
        entityType: 'credit',
        entityId: 'credit-1',
        operation: OutboxOperation.delete,
        payload: <String, dynamic>{'id': 'credit-1', 'isDeleted': true},
      );

      final int groupId = await outboxDao.enqueue(
        entityType: 'credit_payment_group',
        entityId: 'group-1',
        operation: OutboxOperation.delete,
        payload: <String, dynamic>{
          'id': 'group-1',
          'creditId': 'credit-1',
          'isDeleted': true,
        },
      );

      final int scheduleId = await outboxDao.enqueue(
        entityType: 'credit_payment_schedule',
        entityId: 'schedule-1',
        operation: OutboxOperation.delete,
        payload: <String, dynamic>{
          'id': 'schedule-1',
          'creditId': 'credit-1',
          'isDeleted': true,
        },
      );

      final List<OutboxEntryRow> sorted = await outboxDao.fetchPending();
      final int creditIdx = sorted.indexWhere(
        (OutboxEntryRow e) => e.id == creditId,
      );
      final int groupIdx = sorted.indexWhere(
        (OutboxEntryRow e) => e.id == groupId,
      );
      final int scheduleIdx = sorted.indexWhere(
        (OutboxEntryRow e) => e.id == scheduleId,
      );

      // Из-за политики childMustBeInactiveBeforeParentTombstone дети должны быть удалены ПЕРЕД родителем
      expect(groupIdx, lessThan(creditIdx));
      expect(scheduleIdx, lessThan(creditIdx));
    });

    test('4. Missing-reference placeholder invariant', () async {
      final int childId = await outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-b',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{'id': 'cat-b', 'parentId': 'cat-missing-1'},
      );

      final DateTime now = DateTime.now();
      await (database.update(
        database.outboxEntries,
      )..where((OutboxEntries tbl) => tbl.id.equals(childId))).write(
        OutboxEntriesCompanion(
          createdAt: Value<DateTime>(now.subtract(const Duration(minutes: 10))),
        ),
      );

      final int parentId = await outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-missing-1',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{
          'id': 'cat-missing-1',
          'name': 'Категория недоступна (cat-missing-1)',
          'isSystem': true,
          'isDeleted': true,
        },
      );

      await (database.update(database.outboxEntries)
            ..where((OutboxEntries tbl) => tbl.id.equals(parentId)))
          .write(OutboxEntriesCompanion(createdAt: Value<DateTime>(now)));

      final List<OutboxEntryRow> sorted = await outboxDao.fetchPending();
      final int childIdx = sorted.indexWhere(
        (OutboxEntryRow e) => e.id == childId,
      );
      final int parentIdx = sorted.indexWhere(
        (OutboxEntryRow e) => e.id == parentId,
      );

      // Из-за плейсхолдера ребро зависимости не строится, и дочерняя категория идет ПЕРВОЙ по createdAt
      expect(childIdx, lessThan(parentIdx));
    });

    test(
      '5. Dependency cycle leaves affected entries blocked locally',
      () async {
        final int catAId = await outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-a',
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{'id': 'cat-a', 'parentId': 'cat-b'},
        );

        final int catBId = await outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-b',
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{'id': 'cat-b', 'parentId': 'cat-a'},
        );

        final OutboxPendingPlan plan = await outboxDao.fetchPendingPlan();

        expect(plan.dispatchableEntries, isEmpty);
        expect(plan.hasDependencyCycle, isTrue);
        expect(
          plan.blockedByDependencyCycle.map((OutboxEntryRow e) => e.id).toSet(),
          <int>{catAId, catBId},
        );
      },
    );

    test(
      '6. local-only and null-owner outbox rows stay blocked until explicit success cleanup',
      () async {
        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-local'),
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
                entityId: Value<String>('acc-null'),
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

        final List<OutboxEntryRow> beforeCleanup = await database
            .select(database.outboxEntries)
            .get();
        expect(beforeCleanup, hasLength(2));
      },
    );

    test(
      '7. consumeLocalOnlyOutboxAfterMigrationSuccess deletes only local/null outbox rows',
      () async {
        await database
            .into(database.outboxEntries)
            .insert(
              const OutboxEntriesCompanion(
                entityType: Value<String>('account'),
                entityId: Value<String>('acc-local'),
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
                entityId: Value<String>('acc-null'),
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
                entityId: Value<String>('acc-cloud'),
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
        expect(remaining.single.entityId, 'acc-cloud');
      },
    );
  });
}
