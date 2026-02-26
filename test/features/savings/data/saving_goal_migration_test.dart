import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';

void main() {
  group('Saving goals migration', () {
    test('from v39 adds account_id and backfills goal account', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );
      final DateTime now = DateTime.utc(2026, 2, 26, 12);
      final int nowMs = now.millisecondsSinceEpoch;

      await database.customStatement('DROP TABLE IF EXISTS saving_goals');
      await database.customStatement('''
CREATE TABLE saving_goals (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  target_amount INTEGER NOT NULL,
  current_amount INTEGER NOT NULL DEFAULT 0,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  archived_at INTEGER NULL
)
''');

      await database.customStatement(
        '''
INSERT INTO saving_goals (
  id, user_id, name, target_amount, current_amount, note, created_at, updated_at, archived_at
) VALUES (?, ?, ?, ?, ?, NULL, ?, ?, NULL)
''',
        <Object?>[
          'goal-legacy-1',
          'user-1',
          'Emergency',
          100000,
          25000,
          nowMs,
          nowMs,
        ],
      );
      await database.customStatement(
        '''
INSERT INTO accounts (
  id, name, balance, balance_minor, opening_balance, opening_balance_minor,
  currency, currency_scale, type, color, gradient_id, created_at, updated_at,
  is_deleted, is_primary, is_hidden, icon_name, icon_style
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, ?, ?, 0, 1, 0, NULL, NULL)
''',
        <Object?>[
          'acc-seed',
          'Main',
          1000.0,
          '100000',
          1000.0,
          '100000',
          'USD',
          2,
          'checking',
          nowMs,
          nowMs,
        ],
      );

      await database.customStatement('PRAGMA user_version = 39');
      final drift.Migrator migrator = drift.Migrator(database);
      await database.migration.onUpgrade(migrator, 39, database.schemaVersion);

      final drift.QueryRow migratedGoal = await database
          .customSelect(
            'SELECT account_id, current_amount FROM saving_goals WHERE id = ?',
            variables: <drift.Variable<Object>>[
              const drift.Variable<String>('goal-legacy-1'),
            ],
          )
          .getSingle();
      final String goalAccountId = migratedGoal.read<String>('account_id');
      expect(goalAccountId, isNotEmpty);

      final drift.QueryRow goalAccount = await database
          .customSelect(
            '''
SELECT id, type, is_hidden, balance_minor, opening_balance_minor
FROM accounts
WHERE id = ?
''',
            variables: <drift.Variable<Object>>[
              drift.Variable<String>(goalAccountId),
            ],
          )
          .getSingle();
      expect(goalAccount.read<String>('id'), goalAccountId);
      expect(goalAccount.read<String>('type'), 'savings');
      expect(goalAccount.read<bool>('is_hidden'), isTrue);
      expect(goalAccount.read<String>('balance_minor'), '25000');
      expect(goalAccount.read<String>('opening_balance_minor'), '25000');

      await database.close();
    });
  });
}
