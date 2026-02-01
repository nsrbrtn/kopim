import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

enum OutboxOperation { upsert, delete }

enum OutboxStatus { pending, sending, sent, failed }

class OutboxDao {
  OutboxDao(this._db);

  final db.AppDatabase _db;

  Future<int> pendingCount() {
    final Expression<int> query = _db.outboxEntries.id.count();
    final JoinedSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    expression = _db.selectOnly(_db.outboxEntries)
      ..where(
        (_db.outboxEntries.status.equals(OutboxStatus.pending.name)) |
            (_db.outboxEntries.status.equals(OutboxStatus.failed.name)) |
            (_db.outboxEntries.status.equals(OutboxStatus.sending.name)),
      )
      ..addColumns(<Expression<Object>>[query]);
    return expression
        .map((TypedResult row) => row.read(query) ?? 0)
        .getSingle();
  }

  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required OutboxOperation operation,
    required Map<String, dynamic> payload,
  }) {
    final DateTime now = DateTime.now();
    return _db
        .into(_db.outboxEntries)
        .insert(
          db.OutboxEntriesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation.name,
            payload: jsonEncode(payload),
            status: Value<String>(OutboxStatus.pending.name),
            attemptCount: const Value<int>(0),
            createdAt: Value<DateTime>(now),
            updatedAt: Value<DateTime>(now),
          ),
        );
  }

  Stream<List<db.OutboxEntryRow>> watchPending({int? limit}) {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.status.equals(OutboxStatus.pending.name) |
            tbl.status.equals(OutboxStatus.failed.name),
      )
      ..orderBy(<OrderClauseGenerator<db.$OutboxEntriesTable>>[
        (db.$OutboxEntriesTable tbl) => OrderingTerm(expression: tbl.createdAt),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.watch();
  }

  Future<void> deleteByEntityType(String entityType) async {
    await (_db.delete(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) => tbl.entityType.equals(entityType),
        ))
        .go();
  }

  Future<List<db.OutboxEntryRow>> fetchPending({int limit = 50}) {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.status.equals(OutboxStatus.pending.name) |
            tbl.status.equals(OutboxStatus.failed.name),
      )
      ..orderBy(<OrderClauseGenerator<db.$OutboxEntriesTable>>[
        (db.$OutboxEntriesTable tbl) => OrderingTerm(expression: tbl.createdAt),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<db.OutboxEntryRow> prepareForSend(db.OutboxEntryRow entry) async {
    final db.OutboxEntryRow updatedEntry = entry.copyWith(
      status: OutboxStatus.sending.name,
      attemptCount: entry.attemptCount + 1,
      updatedAt: DateTime.now(),
    );
    await (_db.update(
      _db.outboxEntries,
    )..where((db.$OutboxEntriesTable tbl) => tbl.id.equals(entry.id))).write(
      db.OutboxEntriesCompanion.custom(
        status: Constant<String>(updatedEntry.status),
        attemptCount: _db.outboxEntries.attemptCount + const Constant<int>(1),
        updatedAt: Constant<DateTime>(updatedEntry.updatedAt),
      ),
    );
    return updatedEntry;
  }

  Future<void> markAsSent(int id) async {
    final DateTime now = DateTime.now();
    await (_db.update(
      _db.outboxEntries,
    )..where((db.$OutboxEntriesTable tbl) => tbl.id.equals(id))).write(
      db.OutboxEntriesCompanion(
        status: Value<String>(OutboxStatus.sent.name),
        sentAt: Value<DateTime>(now),
        updatedAt: Value<DateTime>(now),
        lastError: const Value<String>.absent(),
      ),
    );
  }

  Future<void> markBatchAsSent(Iterable<int> ids) async {
    if (ids.isEmpty) return;
    final DateTime now = DateTime.now();
    await (_db.update(
      _db.outboxEntries,
    )..where((db.$OutboxEntriesTable tbl) => tbl.id.isIn(ids.toList()))).write(
      db.OutboxEntriesCompanion(
        status: Value<String>(OutboxStatus.sent.name),
        sentAt: Value<DateTime>(now),
        updatedAt: Value<DateTime>(now),
        lastError: const Value<String>.absent(),
      ),
    );
  }

  Future<void> markAsFailed(int id, String errorMessage) async {
    await (_db.update(
      _db.outboxEntries,
    )..where((db.$OutboxEntriesTable tbl) => tbl.id.equals(id))).write(
      db.OutboxEntriesCompanion(
        status: Value<String>(OutboxStatus.failed.name),
        lastError: Value<String>(errorMessage),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> resetToPending(int id) async {
    await (_db.update(
      _db.outboxEntries,
    )..where((db.$OutboxEntriesTable tbl) => tbl.id.equals(id))).write(
      db.OutboxEntriesCompanion(
        status: Value<String>(OutboxStatus.pending.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> resetAllToPending(Iterable<int> ids) async {
    if (ids.isEmpty) return;
    await (_db.update(
      _db.outboxEntries,
    )..where((db.$OutboxEntriesTable tbl) => tbl.id.isIn(ids.toList()))).write(
      db.OutboxEntriesCompanion(
        status: Value<String>(OutboxStatus.pending.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> pruneSent({Duration retain = const Duration(days: 7)}) {
    final DateTime cutoff = DateTime.now().subtract(retain);
    return (_db.delete(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) =>
              tbl.status.equals(OutboxStatus.sent.name) &
              tbl.sentAt.isNotNull() &
              tbl.sentAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  Future<void> clearSent() async {
    await (_db.delete(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) =>
              tbl.status.equals(OutboxStatus.sent.name),
        ))
        .go();
  }

  Map<String, dynamic> decodePayload(db.OutboxEntryRow entry) {
    return jsonDecode(entry.payload) as Map<String, dynamic>;
  }
}
