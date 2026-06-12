import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/sync/sync_contract.dart';

enum OutboxOperation { upsert, delete }

enum OutboxStatus { pending, sending, sent, failed }

class OutboxDao {
  OutboxDao(this._db);

  final db.AppDatabase _db;
  static const List<OutboxStatus> _compactableStatuses = <OutboxStatus>[
    OutboxStatus.pending,
    OutboxStatus.failed,
  ];

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
  }) async {
    final DateTime now = DateTime.now();
    final String encodedPayload = jsonEncode(payload);
    final db.OutboxEntryRow? compacted = await _findCompactableEntry(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
    );
    if (compacted != null) {
      await (_db.update(
            _db.outboxEntries,
          )..where((db.$OutboxEntriesTable tbl) => tbl.id.equals(compacted.id)))
          .write(
            db.OutboxEntriesCompanion(
              payload: Value<String>(encodedPayload),
              status: Value<String>(OutboxStatus.pending.name),
              attemptCount: const Value<int>(0),
              updatedAt: Value<DateTime>(now),
              sentAt: const Value<DateTime?>.absent(),
              lastError: const Value<String?>.absent(),
            ),
          );
      return compacted.id;
    }
    return _db
        .into(_db.outboxEntries)
        .insert(
          db.OutboxEntriesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation.name,
            payload: encodedPayload,
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
      );
    return query.watch().map(
      (List<db.OutboxEntryRow> entries) =>
          _sortPendingEntries(entries, limit: limit),
    );
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
      );
    return query.get().then(
      (List<db.OutboxEntryRow> entries) =>
          _sortPendingEntries(entries, limit: limit),
    );
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

  Future<int> resetStaleSendingToPending({required DateTime cutoff}) {
    return (_db.update(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) =>
              tbl.status.equals(OutboxStatus.sending.name) &
              tbl.updatedAt.isSmallerOrEqualValue(cutoff),
        ))
        .write(
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

  Future<db.OutboxEntryRow?> _findCompactableEntry({
    required String entityType,
    required String entityId,
    required OutboxOperation operation,
  }) {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.entityType.equals(entityType) &
            tbl.entityId.equals(entityId) &
            tbl.operation.equals(operation.name) &
            tbl.status.isIn(
              _compactableStatuses
                  .map((OutboxStatus status) => status.name)
                  .toList(growable: false),
            ),
      )
      ..orderBy(<OrderClauseGenerator<db.$OutboxEntriesTable>>[
        (db.$OutboxEntriesTable tbl) =>
            OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
        (db.$OutboxEntriesTable tbl) =>
            OrderingTerm(expression: tbl.id, mode: OrderingMode.desc),
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  List<db.OutboxEntryRow> _sortPendingEntries(
    List<db.OutboxEntryRow> entries, {
    int? limit,
  }) {
    final List<db.OutboxEntryRow> sorted = List<db.OutboxEntryRow>.from(entries)
      ..sort((db.OutboxEntryRow a, db.OutboxEntryRow b) {
        final int dependencyCompare = _dependencyOrderFor(
          a.entityType,
        ).compareTo(_dependencyOrderFor(b.entityType));
        if (dependencyCompare != 0) {
          return dependencyCompare;
        }
        final int createdAtCompare = a.createdAt.compareTo(b.createdAt);
        if (createdAtCompare != 0) {
          return createdAtCompare;
        }
        return a.id.compareTo(b.id);
      });
    if (limit == null || sorted.length <= limit) {
      return sorted;
    }
    return sorted.take(limit).toList(growable: false);
  }

  int _dependencyOrderFor(String entityType) {
    return SyncContract.manifestByOutboxType[entityType]?.dependencyOrder ??
        1 << 20;
  }
}
