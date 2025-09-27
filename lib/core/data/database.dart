// lib/core/data/database.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';  // Для сгенерированного кода (DAO, queries, companions)

// Таблица Accounts (локальное хранилище для счетов, immutable для оффлайн-операций и sync)
class Accounts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();  // UUID как строка для sync с Firebase
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();  // ISO код, напр. 'USD'
  TextColumn get type => text().withLength(min: 1, max: 50)();  // 'savings', 'credit' и т.д.

  @override
  Set<Column> get primaryKey => <Column<Object>>{id};  // Явный primary key для UUID (без auto-increment)
}

// Таблица Transactions (локальное хранилище для транзакций, с foreign keys для связей, immutable)
class Transactions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();  // UUID для sync
  TextColumn get accountId => text().references(Accounts, #id, onDelete: KeyAction.cascade)();  // Foreign key к Accounts (cascade delete для целостности)
  TextColumn get categoryId => text().references(Categories, #id, onDelete: KeyAction.setNull).nullable()();  // Foreign key к Categories (nullable, set null on delete)
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();  // Исправлено: добавлен () для завершенияビルдера (TextColumn вместо ColumnBuilder)
  TextColumn get type => text().withLength(min: 1, max: 50)();  // 'income', 'expense' и т.д.

  @override
  Set<Column> get primaryKey => <Column<Object>>{id};  // Явный primary key для UUID
}

// Таблица Categories (локальное хранилище для категорий, immutable для оффлайн-операций и sync)
class Categories extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();  // UUID для sync
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().withLength(min: 1, max: 50)();  // 'income', 'expense' и т.д.
  TextColumn get icon => text().nullable()();  // Исправлено: добавлен () для завершенияビルдера (TextColumn вместо ColumnBuilder)
  TextColumn get color => text().nullable()();  // Исправлено: добавлен () для завершения билдера (TextColumn вместо ColumnBuilder)

  @override
  Set<Column> get primaryKey => <Column<Object>>{id};  // Явный primary key для UUID
}

// Основная БД (расширяй таблицами для других фич: budgets, recurring и т.д.)
@DriftDatabase(tables: <Type>[Accounts, Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;  // Начальная версия схемы (увеличивай при миграциях для оффлайн-миграций)

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();  // Создаёт таблицы при первом запуске (offline-first init)
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Для будущих миграций: используй drift_dev generate для auto-diff и добавь логику здесь (например, m.addColumn, m.alterTable)
      // Пример: if (from < 2) { await m.addColumn(accounts, accounts.newColumn); }
    },
  );
}

// Соединение (lazy для оффлайн, файл в app documents, типобезопасно для мультиплатформенности)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'kopim.db'));  // Имя БД для проекта
    return NativeDatabase.createInBackground(file);  // Фоновая инициализация для UI-оптимизации
  });
}