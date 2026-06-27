import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';

enum OutboxOperation { upsert, delete }

enum OutboxStatus { pending, sending, sent, failed }

class OutboxDao {
  OutboxDao(
    this._db, [
    String? Function()? currentUidProvider,
    this._logger,
    MigrationWriteGuard? migrationWriteGuard,
  ]) : _currentUidProvider = currentUidProvider ?? (() => null),
       _migrationWriteGuard =
           migrationWriteGuard ?? const NoopMigrationWriteGuard();

  final db.AppDatabase _db;
  final String? Function() _currentUidProvider;
  final LoggerService? _logger;
  final MigrationWriteGuard _migrationWriteGuard;
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
    DateTime? baseRemoteUpdatedAt,
    bool? baseRemoteIsDeleted,
    int? baseRemoteTypeVersion,
  }) async {
    await _migrationWriteGuard.ensureOutboxMutationAllowed(
      entityType: entityType,
    );
    final DateTime now = DateTime.now();
    final String encodedPayload = jsonEncode(payload);
    final String? ownerUid = _currentUidProvider();

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
              baseRemoteUpdatedAt: Value<DateTime?>(baseRemoteUpdatedAt),
              baseRemoteIsDeleted: Value<bool?>(baseRemoteIsDeleted),
              baseRemoteTypeVersion: Value<int?>(baseRemoteTypeVersion),
              ownerUid: Value<String?>(ownerUid),
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
            baseRemoteTypeVersion: Value<int?>(baseRemoteTypeVersion),
            ownerUid: Value<String?>(ownerUid),
          ),
        );
  }

  Future<bool> hasPendingDeleteForEntity({
    required String entityType,
    required String entityId,
  }) async {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.entityType.equals(entityType) &
            tbl.entityId.equals(entityId) &
            tbl.operation.equals(OutboxOperation.delete.name) &
            tbl.status.isIn(<String>[
              OutboxStatus.pending.name,
              OutboxStatus.sending.name,
              OutboxStatus.failed.name,
            ]),
      );
    final List<db.OutboxEntryRow> rows = await query.get();
    return rows.isNotEmpty;
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
      (List<db.OutboxEntryRow> entries) => _buildPendingPlan(
        _filterEntriesForCurrentOwner(entries),
        limit: limit,
      ).dispatchableEntries,
    );
  }

  Future<void> deleteByEntityType(String entityType) async {
    await (_db.delete(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) => tbl.entityType.equals(entityType),
        ))
        .go();
  }

  Future<List<db.OutboxEntryRow>> fetchPending({
    int limit = 50,
    String? ownerUid,
  }) {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.status.equals(OutboxStatus.pending.name) |
            tbl.status.equals(OutboxStatus.failed.name),
      );
    return query.get().then(
      (List<db.OutboxEntryRow> entries) => _buildPendingPlan(
        _filterEntriesForOwner(entries, ownerUid: ownerUid),
        limit: limit,
      ).dispatchableEntries,
    );
  }

  Future<OutboxPendingPlan> fetchPendingPlan({
    int limit = 50,
    String? ownerUid,
  }) {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.status.equals(OutboxStatus.pending.name) |
            tbl.status.equals(OutboxStatus.failed.name),
      );
    return query.get().then(
      (List<db.OutboxEntryRow> entries) => _buildPendingPlan(
        _filterEntriesForOwner(entries, ownerUid: ownerUid),
        limit: limit,
      ),
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

  Future<void> clearByOwnerUid(String ownerUid) async {
    await (_db.delete(
          _db.outboxEntries,
        )..where((db.$OutboxEntriesTable tbl) => tbl.ownerUid.equals(ownerUid)))
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

  List<db.OutboxEntryRow> _filterEntriesForCurrentOwner(
    List<db.OutboxEntryRow> entries,
  ) {
    return _filterEntriesForOwner(entries);
  }

  List<db.OutboxEntryRow> _filterEntriesForOwner(
    List<db.OutboxEntryRow> entries, {
    String? ownerUid,
  }) {
    final String? effectiveOwnerUid = ownerUid ?? _currentUidProvider();
    if (effectiveOwnerUid == null) {
      return const <db.OutboxEntryRow>[];
    }
    return entries
        .where((db.OutboxEntryRow entry) => entry.ownerUid == effectiveOwnerUid)
        .toList(growable: false);
  }

  OutboxPendingPlan _buildPendingPlan(
    List<db.OutboxEntryRow> entries, {
    int? limit,
  }) {
    if (entries.isEmpty) {
      return const OutboxPendingPlan(
        dispatchableEntries: <db.OutboxEntryRow>[],
        blockedByDependencyCycle: <db.OutboxEntryRow>[],
      );
    }

    // 1. Предварительная сортировка по fallback-приоритету
    final List<db.OutboxEntryRow> sortedCandidates =
        List<db.OutboxEntryRow>.from(entries)
          ..sort((db.OutboxEntryRow a, db.OutboxEntryRow b) {
            final int dependencyCompare = _dependencyOrderFor(
              a.entityType,
            ).compareTo(_dependencyOrderFor(b.entityType));
            if (dependencyCompare != 0) return dependencyCompare;

            final int createdAtCompare = a.createdAt.compareTo(b.createdAt);
            if (createdAtCompare != 0) return createdAtCompare;

            return a.id.compareTo(b.id);
          });

    final int n = sortedCandidates.length;

    // 2. Построение индексов: entityType -> entityId -> list of indices in sortedCandidates
    final Map<String, Map<String, List<int>>> entityMap =
        <String, Map<String, List<int>>>{};
    for (int i = 0; i < n; i++) {
      final db.OutboxEntryRow entry = sortedCandidates[i];
      entityMap
          .putIfAbsent(entry.entityType, () => <String, List<int>>{})
          .putIfAbsent(entry.entityId, () => <int>[])
          .add(i);
    }

    // 3. Декодирование payloads и определение tombstone-статуса для каждого элемента
    final List<Map<String, dynamic>> payloads =
        List<Map<String, dynamic>>.generate(n, (int i) {
          try {
            return jsonDecode(sortedCandidates[i].payload)
                as Map<String, dynamic>;
          } catch (_) {
            return const <String, dynamic>{};
          }
        });

    final List<bool> isTombstone = List<bool>.generate(
      n,
      (int i) => _isTombstoneEntry(sortedCandidates[i], payloads[i]),
    );

    // 4. Построение графа (списки смежности и входящие степени)
    final List<List<int>> adj = List<List<int>>.generate(n, (_) => <int>[]);
    final List<int> indegree = List<int>.filled(n, 0);
    final Set<String> addedEdges = <String>{};

    void addEdge(int from, int to) {
      final String key = '$from->$to';
      if (addedEdges.add(key)) {
        adj[from].add(to);
        indegree[to]++;
      }
    }

    // а) Очередность операций над одной и той же сущностью (same entity older -> newer)
    entityMap.forEach((String entityType, Map<String, List<int>> ids) {
      ids.forEach((String entityId, List<int> indices) {
        for (int k = 0; k < indices.length - 1; k++) {
          addEdge(indices[k], indices[k + 1]);
        }
      });
    });

    // б) Зависимости родитель-ребенок на основе SyncContract
    for (int childIdx = 0; childIdx < n; childIdx++) {
      final String childType = sortedCandidates[childIdx].entityType;
      final Map<String, dynamic> childPayload = payloads[childIdx];

      final List<_ParentRef> parentRefs = _getParentReferences(
        childType,
        childPayload,
      );
      for (final _ParentRef ref in parentRefs) {
        final String parentType = ref.type;
        final String parentId = ref.id;

        final List<int>? parentIndices = entityMap[parentType]?[parentId];
        if (parentIndices == null || parentIndices.isEmpty) {
          continue;
        }

        // Проверяем, не является ли родитель missing reference placeholder'ом
        bool parentIsPlaceholder = false;
        for (final int pIdx in parentIndices) {
          if (_isMissingReferencePlaceholder(parentType, payloads[pIdx])) {
            parentIsPlaceholder = true;
            break;
          }
        }
        if (parentIsPlaceholder) {
          continue;
        }

        final SyncEntityManifestEntry? parentManifest =
            SyncContract.manifestByOutboxType[parentType];
        final SyncReferencePolicy policy =
            parentManifest?.referencePolicy ??
            SyncReferencePolicy.independentTombstone;

        for (final int parentIdx in parentIndices) {
          if (parentIdx == childIdx) continue;

          if (!isTombstone[parentIdx]) {
            // Родитель активный -> сначала родитель, потом ребенок
            addEdge(parentIdx, childIdx);
          } else {
            // Родитель удален (tombstone) -> зависит от политики родителя
            switch (policy) {
              case SyncReferencePolicy.keepReferenceAfterParentTombstone:
                // Сначала tombstone родителя, потом ребенок
                addEdge(parentIdx, childIdx);
                break;
              case SyncReferencePolicy.childMustBeInactiveBeforeParentTombstone:
                // Сначала ребенок (upsert/delete), потом tombstone родителя
                addEdge(childIdx, parentIdx);
                break;
              case SyncReferencePolicy.independentTombstone:
                break;
            }
          }
        }
      }
    }

    // 5. Алгоритм Кана (топологическая сортировка)
    final List<int> candidates = <int>[];
    for (int i = 0; i < n; i++) {
      if (indegree[i] == 0) {
        candidates.add(i);
      }
    }

    final List<db.OutboxEntryRow> result = <db.OutboxEntryRow>[];
    final Set<int> visited = <int>{};

    while (candidates.isNotEmpty) {
      final int u = candidates.removeAt(0);
      result.add(sortedCandidates[u]);
      visited.add(u);

      for (final int v in adj[u]) {
        indegree[v]--;
        if (indegree[v] == 0) {
          candidates.add(v);
        }
      }
      candidates.sort();
    }

    // 6. Обработка циклов (Graceful recovery)
    final List<db.OutboxEntryRow> blockedByCycle = <db.OutboxEntryRow>[];
    if (result.length < n) {
      const String warningMsg =
          'OutboxDao: detected a dependency cycle in outbox entries! '
          'Affected entries will stay local until repaired.';
      if (_logger != null) {
        _logger.logWarning(warningMsg);
      } else {
        // Избегаем avoid_print через developer.log
        developer.log('WARNING: $warningMsg', name: 'OutboxDao');
      }

      for (int i = 0; i < n; i++) {
        if (!visited.contains(i)) {
          blockedByCycle.add(sortedCandidates[i]);
        }
      }
    }

    final List<db.OutboxEntryRow> limitedDispatchable =
        limit == null || result.length <= limit
        ? result
        : result.take(limit).toList(growable: false);
    return OutboxPendingPlan(
      dispatchableEntries: limitedDispatchable,
      blockedByDependencyCycle: blockedByCycle,
    );
  }

  bool _isTombstoneEntry(
    db.OutboxEntryRow entry,
    Map<String, dynamic> payload,
  ) {
    if (entry.operation == 'delete') return true;
    final dynamic isDeleted = payload['isDeleted'] ?? payload['is_deleted'];
    if (isDeleted == true || isDeleted == 'true') return true;
    return false;
  }

  List<_ParentRef> _getParentReferences(
    String entityType,
    Map<String, dynamic> payload,
  ) {
    final List<_ParentRef> refs = <_ParentRef>[];
    final SyncEntityManifestEntry? entryManifest =
        SyncContract.manifestByOutboxType[entityType];
    if (entryManifest == null) return refs;

    for (final SyncReferenceDescriptor desc in entryManifest.references) {
      final dynamic val = payload[desc.fieldName];
      if (val is String && val.isNotEmpty) {
        refs.add(_ParentRef(desc.parentEntityType, val));
      }
    }
    return refs;
  }

  bool _isMissingReferencePlaceholder(
    String entityType,
    Map<String, dynamic> payload,
  ) {
    if (entityType != 'category') return false;
    final bool isSystem =
        payload['isSystem'] == true || payload['is_system'] == true;
    final bool isDeleted =
        payload['isDeleted'] == true || payload['is_deleted'] == true;
    final String name = payload['name'] as String? ?? '';
    return isSystem && isDeleted && name.startsWith('Категория недоступна');
  }

  int _dependencyOrderFor(String entityType) {
    return SyncContract.manifestByOutboxType[entityType]?.dependencyOrder ??
        1 << 20;
  }

  Future<List<db.OutboxEntryRow>> selectLocalOnlyOutboxRows() {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where((db.$OutboxEntriesTable tbl) => tbl.ownerUid.like('local-%'));
    return query.get();
  }

  Future<List<db.OutboxEntryRow>> selectNullOwnerOutboxRows() {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where((db.$OutboxEntriesTable tbl) => tbl.ownerUid.isNull());
    return query.get();
  }

  Future<void> assertNoDispatchableLocalOnlyOutbox() async {
    final SimpleSelectStatement<db.$OutboxEntriesTable, db.OutboxEntryRow>
    query = _db.select(_db.outboxEntries)
      ..where(
        (db.$OutboxEntriesTable tbl) =>
            tbl.status.isIn(<String>[
              OutboxStatus.pending.name,
              OutboxStatus.failed.name,
            ]) &
            (tbl.ownerUid.like('local-%') | tbl.ownerUid.isNull()),
      );
    final List<db.OutboxEntryRow> rows = await query.get();
    if (rows.isNotEmpty) {
      throw StateError('Found active local-only or null-owner outbox entries.');
    }
  }

  Future<void> consumeLocalOnlyOutboxAfterMigrationSuccess() async {
    await (_db.delete(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) =>
              tbl.ownerUid.like('local-%') | tbl.ownerUid.isNull(),
        ))
        .go();
  }

  Future<void> consumeMigrationOutboxEntries(
    List<(String entityType, String entityId)> targets,
  ) async {
    await _db.transaction(() async {
      for (final (String entityType, String entityId) in targets) {
        await (_db.delete(_db.outboxEntries)..where(
              (db.$OutboxEntriesTable tbl) =>
                  tbl.entityType.equals(entityType) &
                  tbl.entityId.equals(entityId) &
                  (tbl.ownerUid.like('local-%') | tbl.ownerUid.isNull()),
            ))
            .go();
      }
    });
  }

  Future<void> consumeOutboxEntriesForFreshUpload({
    required String firebaseUid,
    required String localSessionUid,
  }) async {
    await (_db.delete(_db.outboxEntries)..where(
          (db.$OutboxEntriesTable tbl) =>
              tbl.ownerUid.equals(localSessionUid) |
              tbl.ownerUid.like('local-%') |
              tbl.ownerUid.isNull(),
        ))
        .go();
  }
}

class OutboxPendingPlan {
  const OutboxPendingPlan({
    required this.dispatchableEntries,
    required this.blockedByDependencyCycle,
  });

  final List<db.OutboxEntryRow> dispatchableEntries;
  final List<db.OutboxEntryRow> blockedByDependencyCycle;

  bool get hasDependencyCycle => blockedByDependencyCycle.isNotEmpty;
}

class _ParentRef {
  const _ParentRef(this.type, this.id);
  final String type;
  final String id;
}
