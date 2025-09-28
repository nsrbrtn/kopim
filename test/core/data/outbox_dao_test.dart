import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart' as m;
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
    final id = await outboxDao.enqueue(
      entityType: 'account',
      entityId: 'acc-1',
      operation: OutboxOperation.upsert,
      payload: {'id': 'acc-1', 'name': 'Main'},
    );

    final entries = await outboxDao.fetchPending();
    expect(entries, hasLength(1));
    final entry = entries.single;
    expect(entry.id, id);
    expect(entry.status, OutboxStatus.pending.name);
    expect(entry.attemptCount, 0);
    expect(jsonDecode(entry.payload)['id'], 'acc-1');
  });

  test('prepareForSend increments attempt count and updates status', () async {
    final id = await outboxDao.enqueue(
      entityType: 'transaction',
      entityId: 'txn-1',
      operation: OutboxOperation.upsert,
      payload: {'id': 'txn-1'},
    );

    final entry = (await outboxDao.fetchPending()).single;
    final prepared = await outboxDao.prepareForSend(entry);

    expect(prepared.status, OutboxStatus.sending.name);
    expect(prepared.attemptCount, 1);

    await outboxDao.markAsFailed(prepared.id, 'network-error');
    final afterFail = (await outboxDao.fetchPending()).singleWhere(
      (element) => element.id == id,
    );
    expect(afterFail.status, OutboxStatus.failed.name);
    expect(afterFail.lastError, 'network-error');

    await outboxDao.markAsSent(prepared.id);
    final sentEntries = await database.select(database.outboxEntries).get();
    final sent = sentEntries.singleWhere((element) => element.id == id);
    expect(sent.status, OutboxStatus.sent.name);
    expect(sent.sentAt, m.isNotNull);
  });
}
