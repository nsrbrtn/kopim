import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

enum OutboxOperation { upsert, delete }

enum OutboxStatus { pending, sending, sent, failed }

class OutboxDao {
  OutboxDao(this._db);

  final db.AppDatabase _db;

  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required OutboxOperation operation,
    required Map<String, dynamic> payload,
  }) {
    final now = DateTime.now();
    return _db
        .into(_db.outboxEntries)
        .insert(
          db.OutboxEntriesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation.name,
            payload: jsonEncode(payload),
            status: Value(OutboxStatus.pending.name),
            attemptCount: const Value(0),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Stream<List<db.OutboxEntryRow>> watchPending({int? limit}) {
    final query = _db.select(_db.outboxEntries)
      ..where(
        (tbl) =>
            tbl.status.equals(OutboxStatus.pending.name) |
            tbl.status.equals(OutboxStatus.failed.name),
      )
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.watch();
  }

  Future<List<db.OutboxEntryRow>> fetchPending({int limit = 50}) {
    final query = _db.select(_db.outboxEntries)
      ..where(
        (tbl) =>
            tbl.status.equals(OutboxStatus.pending.name) |
            tbl.status.equals(OutboxStatus.failed.name),
      )
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)])
      ..limit(limit);
    return query.get();
  }

  Future<db.OutboxEntryRow> prepareForSend(db.OutboxEntryRow entry) async {
    final updatedEntry = entry.copyWith(
      status: OutboxStatus.sending.name,
      attemptCount: entry.attemptCount + 1,
      updatedAt: DateTime.now(),
    );
    await (_db.update(
      _db.outboxEntries,
    )..where((tbl) => tbl.id.equals(entry.id))).write(
      db.OutboxEntriesCompanion.custom(
        status: Constant(updatedEntry.status),
        attemptCount: _db.outboxEntries.attemptCount + const Constant(1),
        updatedAt: Constant(updatedEntry.updatedAt),
      ),
    );
    return updatedEntry;
  }

  Future<void> markAsSent(int id) async {
    final now = DateTime.now();
    await (_db.update(
      _db.outboxEntries,
    )..where((tbl) => tbl.id.equals(id))).write(
      db.OutboxEntriesCompanion(
        status: Value(OutboxStatus.sent.name),
        sentAt: Value(now),
        updatedAt: Value(now),
        lastError: const Value.absent(),
      ),
    );
  }

  Future<void> markAsFailed(int id, String errorMessage) async {
    await (_db.update(
      _db.outboxEntries,
    )..where((tbl) => tbl.id.equals(id))).write(
      db.OutboxEntriesCompanion(
        status: Value(OutboxStatus.failed.name),
        lastError: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> resetToPending(int id) async {
    await (_db.update(
      _db.outboxEntries,
    )..where((tbl) => tbl.id.equals(id))).write(
      db.OutboxEntriesCompanion(
        status: Value(OutboxStatus.pending.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> pruneSent({Duration retain = const Duration(days: 7)}) {
    final cutoff = DateTime.now().subtract(retain);
    return (_db.delete(_db.outboxEntries)..where(
          (tbl) =>
              tbl.status.equals(OutboxStatus.sent.name) &
              tbl.sentAt.isNotNull() &
              tbl.sentAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  Map<String, dynamic> decodePayload(db.OutboxEntryRow entry) {
    return jsonDecode(entry.payload) as Map<String, dynamic>;
  }
}
