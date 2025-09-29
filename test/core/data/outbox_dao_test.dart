import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
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
}
