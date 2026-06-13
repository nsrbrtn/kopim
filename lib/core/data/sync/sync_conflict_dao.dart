// lib/core/data/sync/sync_conflict_dao.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

class SyncConflictDao {
  SyncConflictDao(this._db);

  final db.AppDatabase _db;

  /// Наблюдение за активными конфликтами
  Stream<List<db.SyncConflictRow>> watchPendingConflicts() {
    return (_db.select(_db.syncConflicts)
          ..where((db.$SyncConflictsTable tbl) => tbl.status.equals('pending')))
        .watch();
  }

  /// Получение списка активных конфликтов
  Future<List<db.SyncConflictRow>> getPendingConflicts() {
    return (_db.select(_db.syncConflicts)
          ..where((db.$SyncConflictsTable tbl) => tbl.status.equals('pending')))
        .get();
  }

  /// Получение конфликта по уникальному ключу
  Future<db.SyncConflictRow?> getConflictByKey(String conflictKey) {
    return (_db.select(_db.syncConflicts)..where(
          (db.$SyncConflictsTable tbl) => tbl.conflictKey.equals(conflictKey),
        ))
        .getSingleOrNull();
  }

  /// Добавление или обновление конфликта
  Future<void> upsertConflict({
    required String conflictKey,
    required String entityType,
    required String entityId,
    required String conflictType,
    required String severity,
    required String status,
    String? localPayloadJson,
    String? remotePayloadJson,
    String? metadataJson,
  }) async {
    final DateTime now = DateTime.now();
    final db.SyncConflictRow? existing = await getConflictByKey(conflictKey);

    if (existing != null) {
      final bool isPending = status == 'pending';
      await (_db.update(_db.syncConflicts)..where(
            (db.$SyncConflictsTable tbl) => tbl.conflictKey.equals(conflictKey),
          ))
          .write(
            db.SyncConflictsCompanion(
              status: Value<String>(status),
              updatedAt: Value<DateTime>(now),
              localPayloadJson: Value<String?>(localPayloadJson),
              remotePayloadJson: Value<String?>(remotePayloadJson),
              metadataJson: Value<String?>(metadataJson),
              resolvedAt: isPending
                  ? const Value<DateTime?>(null)
                  : const Value<DateTime?>.absent(),
              resolution: isPending
                  ? const Value<String?>(null)
                  : const Value<String?>.absent(),
              entityType: Value<String>(entityType),
              entityId: Value<String>(entityId),
              conflictType: Value<String>(conflictType),
              severity: Value<String>(severity),
            ),
          );
    } else {
      await _db
          .into(_db.syncConflicts)
          .insert(
            db.SyncConflictsCompanion.insert(
              conflictKey: conflictKey,
              entityType: entityType,
              entityId: entityId,
              conflictType: conflictType,
              severity: severity,
              status: status,
              localPayloadJson: Value<String?>(localPayloadJson),
              remotePayloadJson: Value<String?>(remotePayloadJson),
              metadataJson: Value<String?>(metadataJson),
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );
    }
  }

  /// Пометка конфликта как решенного
  Future<void> markResolved(String conflictKey, String resolution) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.syncConflicts)..where(
          (db.$SyncConflictsTable tbl) => tbl.conflictKey.equals(conflictKey),
        ))
        .write(
          db.SyncConflictsCompanion(
            status: const Value<String>('resolved'),
            resolvedAt: Value<DateTime?>(now),
            resolution: Value<String?>(resolution),
            updatedAt: Value<DateTime>(now),
          ),
        );
  }

  /// Пометка конфликта как игнорируемого
  Future<void> markIgnored(String conflictKey) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.syncConflicts)..where(
          (db.$SyncConflictsTable tbl) => tbl.conflictKey.equals(conflictKey),
        ))
        .write(
          db.SyncConflictsCompanion(
            status: const Value<String>('ignored'),
            resolvedAt: Value<DateTime?>(now),
            updatedAt: Value<DateTime>(now),
          ),
        );
  }

  /// Удаление решенных/игнорируемых конфликтов старше определенного времени
  Future<int> deleteResolvedOlderThan(Duration retainWindow) async {
    final DateTime threshold = DateTime.now().subtract(retainWindow);
    return (_db.delete(_db.syncConflicts)..where(
          (db.$SyncConflictsTable tbl) =>
              tbl.status.equals('pending').not() &
              tbl.updatedAt.isSmallerThanValue(threshold),
        ))
        .go();
  }

  /// Автоматическое разрешение pending-конфликтов missingOptionalReference для восстановленных ID
  Future<void> resolvePendingMissingReferences(
    String entityType,
    List<String> restoredIds,
  ) async {
    if (restoredIds.isEmpty) return;

    final List<db.SyncConflictRow> pending = await getPendingConflicts();
    for (final db.SyncConflictRow conflict in pending) {
      if (conflict.conflictType == 'missingOptionalReference' &&
          conflict.metadataJson != null) {
        try {
          final Map<String, dynamic> meta =
              jsonDecode(conflict.metadataJson!) as Map<String, dynamic>;
          if (meta['missingEntityType'] == entityType) {
            final String? missingId = meta['missingEntityId'] as String?;
            if (missingId != null && restoredIds.contains(missingId)) {
              await markResolved(conflict.conflictKey, 'referenceRestored');
            }
          }
        } catch (_) {
          // Игнорируем ошибки парсинга метаданных
        }
      }
    }
  }
}
