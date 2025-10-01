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

@DriftDatabase(
  tables: <Type>[Accounts, Categories, Transactions, OutboxEntries, Profiles],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.connect(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
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
