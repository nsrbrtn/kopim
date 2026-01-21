import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

void main() {
  late db.AppDatabase database;
  late AccountRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    repository = AccountRepositoryImpl(
      database: database,
      accountDao: AccountDao(database),
      outboxDao: OutboxDao(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  AccountEntity buildAccount({bool isDeleted = false, bool isPrimary = false}) {
    final DateTime now = DateTime.utc(2024, 1, 1);
    return AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balanceMinor: BigInt.zero,
      currency: 'USD',
      currencyScale: 2,
      type: 'checking',
      createdAt: now,
      updatedAt: now,
      isDeleted: isDeleted,
      isPrimary: isPrimary,
    );
  }

  test('upsert persists account locally and enqueues outbox entry', () async {
    final AccountEntity account = buildAccount();

    await repository.upsert(account);

    final List<db.AccountRow> rows = await database
        .select(database.accounts)
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.name, 'Main');
    expect(rows.single.isDeleted, isFalse);
    expect(rows.single.isPrimary, isFalse);

    final List<db.OutboxEntryRow> outboxRows = await database
        .select(database.outboxEntries)
        .get();
    expect(outboxRows, hasLength(1));
    final db.OutboxEntryRow outbox = outboxRows.single;
    expect(outbox.entityType, 'account');
    expect(outbox.operation, OutboxOperation.upsert.name);
    final Map<String, dynamic> payload =
        jsonDecode(outbox.payload) as Map<String, dynamic>;
    expect(payload['id'], 'acc-1');
    expect(payload['isDeleted'], false);
    expect(payload['isPrimary'], false);
  });

  test('upsert primary account resets previous primary flags', () async {
    final AccountEntity primaryAccount = buildAccount(isPrimary: true);
    await repository.upsert(primaryAccount);

    final AccountEntity secondAccount = primaryAccount.copyWith(
      id: 'acc-2',
      name: 'Savings',
      isPrimary: true,
    );
    await repository.upsert(secondAccount);

    final List<db.AccountRow> rows = await database
        .select(database.accounts)
        .get();
    expect(rows, hasLength(2));
    final db.AccountRow first = rows.firstWhere(
      (db.AccountRow row) => row.id == 'acc-1',
    );
    final db.AccountRow second = rows.firstWhere(
      (db.AccountRow row) => row.id == 'acc-2',
    );
    expect(first.isPrimary, isFalse);
    expect(second.isPrimary, isTrue);
  });

  test('softDelete marks record and enqueues delete event', () async {
    final AccountEntity account = buildAccount();
    await repository.upsert(account);

    await repository.softDelete(account.id);

    final db.AccountRow stored = await database
        .select(database.accounts)
        .getSingle();
    expect(stored.isDeleted, isTrue);

    final List<db.OutboxEntryRow> outboxRows = await database
        .select(database.outboxEntries)
        .get();
    expect(outboxRows.length, 2);
    final db.OutboxEntryRow deleteEntry = outboxRows.last;
    expect(deleteEntry.operation, OutboxOperation.delete.name);
    final Map<String, dynamic> payload =
        jsonDecode(deleteEntry.payload) as Map<String, dynamic>;
    expect(payload['isDeleted'], true);
  });
}
