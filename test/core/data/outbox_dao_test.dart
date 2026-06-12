import 'dart:convert';

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
}
