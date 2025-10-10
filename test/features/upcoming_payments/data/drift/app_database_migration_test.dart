import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';

void main() {
  group('AppDatabase upcoming payments миграции', () {
    test('onCreate создаёт таблицы и индексы', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );

      final List<String> tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('upcoming_payments', 'payment_reminders')",
          )
          .map((drift.QueryRow row) => row.read<String>('name'))
          .get();
      expect(
        tables,
        containsAll(<String>['upcoming_payments', 'payment_reminders']),
      );

      final List<String> indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name IN ('upcoming_payments_next_notify_idx', 'upcoming_payments_next_run_idx', 'upcoming_payments_day_idx', 'payment_reminders_when_idx')",
          )
          .map((drift.QueryRow row) => row.read<String>('name'))
          .get();
      expect(
        indexes,
        containsAll(<String>[
          'upcoming_payments_next_notify_idx',
          'upcoming_payments_next_run_idx',
          'upcoming_payments_day_idx',
          'payment_reminders_when_idx',
        ]),
      );

      await database.close();
    });

    test('onUpgrade восстанавливает таблицы и индексы', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );

      await database.customStatement('DROP TABLE IF EXISTS upcoming_payments');
      await database.customStatement('DROP TABLE IF EXISTS payment_reminders');
      await database.customStatement('PRAGMA user_version = 14');

      final drift.Migrator migrator = drift.Migrator(database);
      await database.migration.onUpgrade(migrator, 14, database.schemaVersion);
      final drift.OpeningDetails details = drift.OpeningDetails(
        14,
        database.schemaVersion,
      );
      if (database.migration.beforeOpen != null) {
        await database.migration.beforeOpen!(details);
      }
      await database.customStatement(
        'PRAGMA user_version = ${database.schemaVersion}',
      );

      final List<String> tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('upcoming_payments', 'payment_reminders')",
          )
          .map((drift.QueryRow row) => row.read<String>('name'))
          .get();
      expect(
        tables,
        containsAll(<String>['upcoming_payments', 'payment_reminders']),
      );

      final List<String> indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name IN ('upcoming_payments_next_notify_idx', 'upcoming_payments_next_run_idx', 'upcoming_payments_day_idx', 'payment_reminders_when_idx')",
          )
          .map((drift.QueryRow row) => row.read<String>('name'))
          .get();
      expect(
        indexes,
        containsAll(<String>[
          'upcoming_payments_next_notify_idx',
          'upcoming_payments_next_run_idx',
          'upcoming_payments_day_idx',
          'payment_reminders_when_idx',
        ]),
      );

      final int schemaVersion = (await database
          .customSelect('PRAGMA user_version')
          .map((drift.QueryRow row) => row.read<int>('user_version'))
          .getSingle());
      expect(schemaVersion, 16);

      await database.close();
    });
  });
}
