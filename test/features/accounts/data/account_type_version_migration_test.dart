import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';

void main() {
  group('Account type version migration', () {
    test('from v43 adds type_version with default 0', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );

      await database.customStatement('DROP TABLE IF EXISTS accounts');
      await database.customStatement('''
CREATE TABLE accounts (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  balance REAL NOT NULL,
  balance_minor TEXT NOT NULL DEFAULT '0',
  opening_balance REAL NOT NULL DEFAULT 0,
  opening_balance_minor TEXT NOT NULL DEFAULT '0',
  currency TEXT NOT NULL,
  currency_scale INTEGER NOT NULL DEFAULT 2,
  type TEXT NOT NULL,
  color TEXT NULL,
  gradient_id TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  is_primary INTEGER NOT NULL DEFAULT 0,
  is_hidden INTEGER NOT NULL DEFAULT 0,
  icon_name TEXT NULL,
  icon_style TEXT NULL
)
''');

      await database.customStatement(
        '''
INSERT INTO accounts (
  id, name, balance, balance_minor, opening_balance, opening_balance_minor,
  currency, currency_scale, type, color, gradient_id, created_at, updated_at,
  is_deleted, is_primary, is_hidden, icon_name, icon_style
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, ?, ?, 0, 0, 0, NULL, NULL)
''',
        <Object?>[
          'acc-1',
          'Main',
          0.0,
          '0',
          0.0,
          '0',
          'RUB',
          2,
          'card',
          DateTime.utc(2026, 4, 10).millisecondsSinceEpoch,
          DateTime.utc(2026, 4, 10).millisecondsSinceEpoch,
        ],
      );

      await database.customStatement('PRAGMA user_version = 43');
      final drift.Migrator migrator = drift.Migrator(database);
      await database.migration.onUpgrade(migrator, 43, database.schemaVersion);

      final drift.QueryRow row = await database
          .customSelect(
            'SELECT type, type_version FROM accounts WHERE id = ?',
            variables: <drift.Variable<Object>>[
              const drift.Variable<String>('acc-1'),
            ],
          )
          .getSingle();

      expect(row.read<String>('type'), 'card');
      expect(row.read<int>('type_version'), 0);

      await database.close();
    });
  });
}
