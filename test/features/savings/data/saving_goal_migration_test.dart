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

    test(
      'from v44 creates goal_account_links and backfills contribution storage account',
      () async {
        final AppDatabase database = AppDatabase.connect(
          drift.DatabaseConnection(NativeDatabase.memory()),
        );
        final DateTime now = DateTime.utc(2026, 4, 10, 12);

        await database.customStatement('PRAGMA foreign_keys = OFF');

        await database.customStatement(
          'DROP TABLE IF EXISTS goal_contributions',
        );
        await database.customStatement('DROP TABLE IF EXISTS saving_goals');
        await database.customStatement('DROP TABLE IF EXISTS accounts');
        await database.customStatement('''
CREATE TABLE accounts (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  balance REAL NOT NULL,
  balance_minor TEXT NOT NULL DEFAULT '0',
  opening_balance REAL NOT NULL,
  opening_balance_minor TEXT NOT NULL DEFAULT '0',
  currency TEXT NOT NULL,
  currency_scale INTEGER NOT NULL DEFAULT 2,
  type TEXT NOT NULL,
  type_version INTEGER NOT NULL DEFAULT 0,
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
        await database.customStatement('''
CREATE TABLE saving_goals (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  account_id TEXT NULL REFERENCES accounts(id) ON DELETE SET NULL,
  target_date INTEGER NULL,
  target_amount INTEGER NOT NULL,
  current_amount INTEGER NOT NULL DEFAULT 0,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  archived_at INTEGER NULL
)
''');
        await database.customStatement('''
CREATE TABLE goal_contributions (
  id TEXT NOT NULL PRIMARY KEY,
  goal_id TEXT NOT NULL REFERENCES saving_goals(id) ON DELETE CASCADE,
  transaction_id TEXT NOT NULL,
  amount INTEGER NOT NULL,
  created_at INTEGER NOT NULL
)
''');

        await database.customStatement(
          '''
INSERT INTO accounts (
  id, name, balance, balance_minor, opening_balance, opening_balance_minor,
  currency, currency_scale, type, type_version, created_at, updated_at,
  is_deleted, is_primary, is_hidden
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 1)
''',
          <Object?>[
            'goal-account-1',
            'Goal account',
            250.0,
            '25000',
            250.0,
            '25000',
            'USD',
            2,
            'savings',
            0,
            now.millisecondsSinceEpoch,
            now.millisecondsSinceEpoch,
          ],
        );
        await database.customStatement(
          '''
INSERT INTO saving_goals (
  id, user_id, name, account_id, target_amount, current_amount, created_at, updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
          <Object?>[
            'goal-1',
            'user-1',
            'Emergency',
            'goal-account-1',
            100000,
            25000,
            now.millisecondsSinceEpoch,
            now.millisecondsSinceEpoch,
          ],
        );
        await database.customStatement(
          '''
INSERT INTO goal_contributions (id, goal_id, transaction_id, amount, created_at)
VALUES (?, ?, ?, ?, ?)
''',
          <Object?>[
            'contrib-1',
            'goal-1',
            'tx-1',
            25000,
            now.millisecondsSinceEpoch,
          ],
        );
        await database.customStatement('PRAGMA foreign_keys = ON');

        await database.customStatement('PRAGMA user_version = 44');
        final drift.Migrator migrator = drift.Migrator(database);
        await database.migration.onUpgrade(
          migrator,
          44,
          database.schemaVersion,
        );

        final drift.QueryRow link = await database
            .customSelect(
              'SELECT goal_id, account_id FROM goal_account_links WHERE goal_id = ?',
              variables: <drift.Variable<Object>>[
                const drift.Variable<String>('goal-1'),
              ],
            )
            .getSingle();
        expect(link.read<String>('goal_id'), 'goal-1');
        expect(link.read<String>('account_id'), 'goal-account-1');

        final drift.QueryRow contribution = await database
            .customSelect(
              '''
SELECT storage_account_id
FROM goal_contributions
WHERE id = ?
''',
              variables: <drift.Variable<Object>>[
                const drift.Variable<String>('contrib-1'),
              ],
            )
            .getSingle();
        expect(
          contribution.read<String?>('storage_account_id'),
          'goal-account-1',
        );

        await database.close();
      },
    );
  });
}
