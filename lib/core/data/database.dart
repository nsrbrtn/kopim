// lib/core/data/database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';  // Для сгенерированного кода (DAO, queries)

// Таблица Accounts (локальное хранилище для счетов, immutable для оффлайн-операций и sync)
class Accounts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();  // UUID как строка для sync с Firebase
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();  // ISO код, напр. 'USD'
  TextColumn get type => text().withLength(min: 1, max: 50)();  // 'savings', 'credit' и т.д.
}

// Основная БД (расширяй таблицами для других фич: transactions, categories и т.д.)
@DriftDatabase(tables: <Type>[Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;  // Начальная версия схемы (увеличивай при миграциях для оффлайн-миграций)

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();  // Создаёт таблицы при первом запуске (offline-first init)
    },
    // Добавь миграции позже, напр. onUpgrade для добавления колонок с сохранением данных
  );
}

// Соединение (lazy для оффлайн, файл в app documents, типобезопасно для мультиплатформенности)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();  // Тип добавлен для linter
    final File file = File(p.join(dbFolder.path, 'kopim.db'));  // Имя БД для проекта, тип добавлен
    return NativeDatabase.createInBackground(file);  // Фоновая инициализация для UI-оптимизации
  });
}