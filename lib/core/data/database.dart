// lib/core/data/database.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get type => text().withLength(min: 1, max: 50)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().nullable()();
  TextColumn get iconStyle => text().nullable()();
  TextColumn get iconName => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get parentId => text().nullable().customConstraint(
    'REFERENCES categories(id) ON DELETE SET NULL',
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get type => text().withLength(min: 1, max: 50)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('OutboxEntryRow')
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().withLength(min: 1, max: 50)();
  TextColumn get entityId => text().withLength(min: 1, max: 50)();
  TextColumn get operation => text().withLength(min: 1, max: 20)();
  TextColumn get payload => text()();
  TextColumn get status =>
      text().withDefault(const Constant<String>('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sentAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}

@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get uid => text().withLength(min: 1, max: 64)();
  TextColumn get name => text().withLength(min: 0, max: 120).nullable()();
  TextColumn get currency => text().withLength(min: 3, max: 3).nullable()();
  TextColumn get locale => text().withLength(min: 2, max: 10).nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{uid};
}

@DataClassName('RecurringRuleRow')
class RecurringRules extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  DateTimeColumn get startAt => dateTime()();
  TextColumn get timezone => text().withLength(min: 1, max: 60)();
  TextColumn get rrule => text()();
  DateTimeColumn get endAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get dayOfMonth => integer().withDefault(const Constant<int>(1))();
  IntColumn get applyAtLocalHour =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get applyAtLocalMinute =>
      integer().withDefault(const Constant<int>(1))();
  DateTimeColumn get lastRunAt => dateTime().nullable()();
  DateTimeColumn get nextDueLocalDate => dateTime().nullable()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant<bool>(true))();
  BoolColumn get autoPost =>
      boolean().withDefault(const Constant<bool>(false))();
  IntColumn get reminderMinutesBefore => integer().nullable()();
  TextColumn get shortMonthPolicy => text()
      .withLength(min: 1, max: 32)
      .withDefault(const Constant<String>('clip_to_last_day'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('RecurringRuleExecutionRow')
class RecurringRuleExecutions extends Table {
  TextColumn get occurrenceId => text().withLength(min: 1, max: 120)();
  TextColumn get ruleId =>
      text().references(RecurringRules, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get localDate => dateTime()();
  DateTimeColumn get appliedAt => dateTime()();
  TextColumn get transactionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{occurrenceId};
}

@DataClassName('RecurringOccurrenceRow')
class RecurringOccurrences extends Table {
  TextColumn get id => text().withLength(min: 1, max: 60)();
  TextColumn get ruleId =>
      text().references(RecurringRules, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dueAt => dateTime()();
  TextColumn get status => text().withLength(min: 1, max: 16)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get postedTxId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('JobQueueRow')
class JobQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text().withLength(min: 1, max: 80)();
  TextColumn get payload => text()();
  DateTimeColumn get runAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get lastError => text().nullable()();
}

@DriftDatabase(
  tables: <Type>[
    Accounts,
    Categories,
    Transactions,
    OutboxEntries,
    Profiles,
    RecurringRules,
    RecurringOccurrences,
    RecurringRuleExecutions,
    JobQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.connect(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await m.createIndex(
        Index(
          'recurring_occurrences_rule_due_idx',
          'CREATE INDEX IF NOT EXISTS recurring_occurrences_rule_due_idx '
              'ON recurring_occurrences(rule_id, due_at)',
        ),
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(outboxEntries);
        await m.addColumn(accounts, accounts.createdAt);
        await m.addColumn(accounts, accounts.updatedAt);
        await m.addColumn(accounts, accounts.isDeleted);
        await m.addColumn(categories, categories.createdAt);
        await m.addColumn(categories, categories.updatedAt);
        await m.addColumn(categories, categories.isDeleted);
        await m.addColumn(transactions, transactions.createdAt);
        await m.addColumn(transactions, transactions.updatedAt);
        await m.addColumn(transactions, transactions.isDeleted);
      }
      if (from < 3) {
        await m.createTable(profiles);
      }
      if (from < 4) {
        await m.addColumn(categories, categories.iconStyle);
        await m.addColumn(categories, categories.iconName);
        await m.addColumn(categories, categories.parentId);
        await m.database.customStatement(
          "UPDATE categories SET icon_name = icon WHERE icon_name IS NULL AND icon IS NOT NULL AND icon != ''",
        );
        await m.database.customStatement(
          "UPDATE categories SET icon_style = 'regular' WHERE icon_name IS NOT NULL AND (icon_style IS NULL OR icon_style = '')",
        );
      }
      if (from < 5) {
        await m.createTable(recurringRules);
        await m.createTable(recurringOccurrences);
        await m.createTable(jobQueue);
        await m.createIndex(
          Index(
            'recurring_occurrences_rule_due_idx',
            'CREATE INDEX IF NOT EXISTS recurring_occurrences_rule_due_idx '
                'ON recurring_occurrences(rule_id, due_at)',
          ),
        );
      }
      if (from < 6) {
        await m.addColumn(recurringRules, recurringRules.dayOfMonth);
        await m.addColumn(recurringRules, recurringRules.applyAtLocalHour);
        await m.addColumn(recurringRules, recurringRules.applyAtLocalMinute);
        await m.addColumn(recurringRules, recurringRules.lastRunAt);
        await m.addColumn(recurringRules, recurringRules.nextDueLocalDate);
        await m.createTable(recurringRuleExecutions);
        await m.createIndex(
          Index(
            'recurring_rule_executions_rule_local_date_idx',
            'CREATE UNIQUE INDEX IF NOT EXISTS '
                'recurring_rule_executions_rule_local_date_idx '
                'ON recurring_rule_executions(rule_id, local_date)',
          ),
        );
        await m.database.customStatement(
          'UPDATE recurring_rules SET day_of_month = '
          "CAST(strftime('%d', start_at) AS INTEGER), apply_at_local_hour = 0, apply_at_local_minute = 1 "
          'WHERE day_of_month IS NULL',
        );
        await m.database.customStatement(
          'UPDATE recurring_rules SET next_due_local_date = '
          "CASE WHEN next_due_local_date IS NULL THEN datetime(strftime('%Y-%m-%d', start_at) || ' 00:01:00') ELSE next_due_local_date END",
        );
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(p.join(directory.path, 'kopim.db'));
    return NativeDatabase.createInBackground(file);
  });
}
