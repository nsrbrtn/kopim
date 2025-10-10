import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart';

@DataClassName('UpcomingPaymentRow')
class UpcomingPayments extends Table {
  @override
  String get tableName => 'upcoming_payments';

  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();

  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();

  RealColumn get amount => real()();

  IntColumn get dayOfMonth => integer()();

  IntColumn get notifyDaysBefore =>
      integer().withDefault(const Constant<int>(1))();

  TextColumn get notifyTimeHhmm => text()
      .withLength(min: 5, max: 5)
      .withDefault(const Constant<String>('12:00'))();

  TextColumn get note => text().nullable()();

  BoolColumn get autoPost =>
      boolean().withDefault(const Constant<bool>(false))();

  BoolColumn get isActive =>
      boolean().withDefault(const Constant<bool>(true))();

  IntColumn get nextRunAt => integer().nullable()();

  IntColumn get nextNotifyAt => integer().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
