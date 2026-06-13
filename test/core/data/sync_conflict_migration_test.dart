import 'package:drift/drift.dart'
    as drift
    show DatabaseConnection, QueryRow, Migrator;
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';

void main() {
  group('Sync conflicts database migration tests', () {
    test('fresh database contains sync_conflicts table', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );

      // Проверим, что мы можем получить доступ к таблице и сделать запрос в нее
      final List<SyncConflictRow> conflicts = await database
          .select(database.syncConflicts)
          .get();
      expect(conflicts, isEmpty);

      await database.close();
    });

    test('migration from v46 to v47 creates sync_conflicts table', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );

      // При открытии базы данных через AppDatabase Drift уже создаст все таблицы схемы 47.
      // Чтобы имитировать миграцию с v46 до v47:
      // 1. Вставим тестовые данные в outbox_entries (эта таблица уже существует).
      await database
          .into(database.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              entityType: 'transaction',
              entityId: 'txn-1',
              operation: 'upsert',
              payload: '{}',
              createdAt: Value<DateTime>(DateTime.utc(2026, 4, 10)),
              updatedAt: Value<DateTime>(DateTime.utc(2026, 4, 10)),
            ),
          );

      // 2. Удалим таблицу sync_conflicts, чтобы сымитировать её отсутствие в v46.
      await database.customStatement('DROP TABLE IF EXISTS sync_conflicts');

      // Проверим, что таблицы sync_conflicts действительно нет
      final drift.QueryRow? tableCheckBefore = await database
          .customSelect(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'sync_conflicts' LIMIT 1",
          )
          .getSingleOrNull();
      expect(tableCheckBefore, isNull);

      // 3. Выполним миграцию onUpgrade с 46 до 47
      final drift.Migrator migrator = drift.Migrator(database);
      await database.migration.onUpgrade(migrator, 46, 47);

      // 4. Проверим, что таблица sync_conflicts создана
      final drift.QueryRow? tableCheckAfter = await database
          .customSelect(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'sync_conflicts' LIMIT 1",
          )
          .getSingleOrNull();
      expect(tableCheckAfter, isNotNull);

      // 5. Проверим, что существующие данные в outbox_entries на месте
      final List<OutboxEntryRow> outbox = await database
          .select(database.outboxEntries)
          .get();
      expect(outbox, hasLength(1));
      expect(outbox.first.entityId, 'txn-1');

      await database.close();
    });
  });
}
