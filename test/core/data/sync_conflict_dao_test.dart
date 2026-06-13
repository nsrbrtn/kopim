import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/services/sync/sync_conflict_types.dart';

void main() {
  late AppDatabase database;
  late SyncConflictDao dao;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    dao = SyncConflictDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('SyncConflictDao tests', () {
    test('upsertConflict creates new record', () async {
      const String key =
          'transaction:txn-1:missingOptionalReference:category:cat-1';
      await dao.upsertConflict(
        conflictKey: key,
        entityType: 'transaction',
        entityId: 'txn-1',
        conflictType: SyncConflictType.missingOptionalReference.value,
        severity: SyncConflictSeverity.warning.value,
        status: SyncConflictStatus.pending.value,
        localPayloadJson: '{"id": "txn-1"}',
        metadataJson: '{"missingId": "cat-1"}',
      );

      final SyncConflictRow? conflict = await dao.getConflictByKey(key);
      expect(conflict, isNotNull);
      expect(conflict!.conflictKey, key);
      expect(conflict.entityType, 'transaction');
      expect(conflict.entityId, 'txn-1');
      expect(
        conflict.conflictType,
        SyncConflictType.missingOptionalReference.value,
      );
      expect(conflict.severity, SyncConflictSeverity.warning.value);
      expect(conflict.status, SyncConflictStatus.pending.value);
      expect(conflict.localPayloadJson, '{"id": "txn-1"}');
      expect(conflict.metadataJson, '{"missingId": "cat-1"}');
      expect(conflict.createdAt, isNotNull);
      expect(conflict.updatedAt, isNotNull);
      expect(conflict.resolvedAt, isNull);
      expect(conflict.resolution, isNull);
    });

    test(
      'repeated upsertConflict with same conflictKey does not create duplicate and updates pending fields',
      () async {
        const String key =
            'transaction:txn-1:missingOptionalReference:category:cat-1';

        // Первый upsert
        await dao.upsertConflict(
          conflictKey: key,
          entityType: 'transaction',
          entityId: 'txn-1',
          conflictType: SyncConflictType.missingOptionalReference.value,
          severity: SyncConflictSeverity.warning.value,
          status: SyncConflictStatus.pending.value,
          localPayloadJson: '{"id": "txn-1", "note": "Old"}',
        );

        final DateTime? firstUpdatedAt = (await dao.getConflictByKey(
          key,
        ))?.updatedAt;

        // Небольшая задержка, чтобы updatedAt отличался (в SQLite хранение идет в секундах)
        await Future<void>.delayed(const Duration(seconds: 1));

        // Второй upsert
        await dao.upsertConflict(
          conflictKey: key,
          entityType: 'transaction',
          entityId: 'txn-1',
          conflictType: SyncConflictType.missingOptionalReference.value,
          severity: SyncConflictSeverity.warning.value,
          status: SyncConflictStatus.pending.value,
          localPayloadJson: '{"id": "txn-1", "note": "New"}',
        );

        final List<SyncConflictRow> allConflicts = await database
            .select(database.syncConflicts)
            .get();
        expect(allConflicts, hasLength(1));

        final SyncConflictRow conflict = allConflicts.first;
        expect(conflict.localPayloadJson, '{"id": "txn-1", "note": "New"}');
        expect(conflict.updatedAt.isAfter(firstUpdatedAt!), isTrue);
      },
    );

    test('watchPendingConflicts returns only pending conflicts', () async {
      const String key1 = 'conflict-1';
      const String key2 = 'conflict-2';

      await dao.upsertConflict(
        conflictKey: key1,
        entityType: 'transaction',
        entityId: 'txn-1',
        conflictType: SyncConflictType.missingOptionalReference.value,
        severity: SyncConflictSeverity.warning.value,
        status: SyncConflictStatus.pending.value,
      );

      await dao.upsertConflict(
        conflictKey: key2,
        entityType: 'transaction',
        entityId: 'txn-2',
        conflictType: SyncConflictType.missingOptionalReference.value,
        severity: SyncConflictSeverity.warning.value,
        status: SyncConflictStatus.resolved.value,
      );

      final List<SyncConflictRow> pending = await dao.getPendingConflicts();
      expect(pending, hasLength(1));
      expect(pending.first.conflictKey, key1);

      final List<SyncConflictRow> watched = await dao
          .watchPendingConflicts()
          .first;
      expect(watched, hasLength(1));
      expect(watched.first.conflictKey, key1);
    });

    test('markResolved changes status, resolvedAt, and resolution', () async {
      const String key = 'conflict-1';
      await dao.upsertConflict(
        conflictKey: key,
        entityType: 'transaction',
        entityId: 'txn-1',
        conflictType: SyncConflictType.missingOptionalReference.value,
        severity: SyncConflictSeverity.warning.value,
        status: SyncConflictStatus.pending.value,
      );

      await dao.markResolved(key, 'category_created');

      final SyncConflictRow? conflict = await dao.getConflictByKey(key);
      expect(conflict, isNotNull);
      expect(conflict!.status, SyncConflictStatus.resolved.value);
      expect(conflict.resolvedAt, isNotNull);
      expect(conflict.resolution, 'category_created');
    });

    test('markIgnored changes status to ignored and sets resolvedAt', () async {
      const String key = 'conflict-1';
      await dao.upsertConflict(
        conflictKey: key,
        entityType: 'transaction',
        entityId: 'txn-1',
        conflictType: SyncConflictType.missingOptionalReference.value,
        severity: SyncConflictSeverity.warning.value,
        status: SyncConflictStatus.pending.value,
      );

      await dao.markIgnored(key);

      final SyncConflictRow? conflict = await dao.getConflictByKey(key);
      expect(conflict, isNotNull);
      expect(conflict!.status, SyncConflictStatus.ignored.value);
      expect(conflict.resolvedAt, isNotNull);
    });

    test(
      'deleteResolvedOlderThan deletes old non-pending but keeps pending',
      () async {
        const String keyPending = 'conflict-pending';
        const String keyOldResolved = 'conflict-old-resolved';
        const String keyNewResolved = 'conflict-new-resolved';

        // Вставляем pending
        await dao.upsertConflict(
          conflictKey: keyPending,
          entityType: 'transaction',
          entityId: 'txn-1',
          conflictType: SyncConflictType.missingOptionalReference.value,
          severity: SyncConflictSeverity.warning.value,
          status: SyncConflictStatus.pending.value,
        );

        // Вставляем resolved (он сейчас свежий)
        await dao.upsertConflict(
          conflictKey: keyNewResolved,
          entityType: 'transaction',
          entityId: 'txn-2',
          conflictType: SyncConflictType.missingOptionalReference.value,
          severity: SyncConflictSeverity.warning.value,
          status: SyncConflictStatus.resolved.value,
        );
        await dao.markResolved(keyNewResolved, 'fixed');

        // Имитируем старый resolved (вставим напрямую со старым updatedAt)
        final DateTime oldDate = DateTime.now().subtract(
          const Duration(days: 10),
        );
        await database
            .into(database.syncConflicts)
            .insert(
              SyncConflictsCompanion.insert(
                conflictKey: keyOldResolved,
                entityType: 'transaction',
                entityId: 'txn-3',
                conflictType: SyncConflictType.missingOptionalReference.value,
                severity: SyncConflictSeverity.warning.value,
                status: SyncConflictStatus.resolved.value,
                createdAt: Value<DateTime>(oldDate),
                updatedAt: Value<DateTime>(oldDate),
                resolvedAt: Value<DateTime?>(oldDate),
                resolution: const Value<String?>('fixed'),
              ),
            );

        // Удаляем те, что старше 5 дней
        final int deletedCount = await dao.deleteResolvedOlderThan(
          const Duration(days: 5),
        );
        expect(deletedCount, 1);

        final List<SyncConflictRow> remaining = await database
            .select(database.syncConflicts)
            .get();
        expect(remaining, hasLength(2));

        final List<String> remainingKeys = remaining
            .map((SyncConflictRow e) => e.conflictKey)
            .toList();
        expect(remainingKeys, contains(keyPending));
        expect(remainingKeys, contains(keyNewResolved));
        expect(remainingKeys, isNot(contains(keyOldResolved)));
      },
    );
  });
}
