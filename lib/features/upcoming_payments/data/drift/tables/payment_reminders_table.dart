import 'package:drift/drift.dart';

@DataClassName('PaymentReminderRow')
class PaymentReminders extends Table {
  @override
  String get tableName => 'payment_reminders';

  TextColumn get id => text()();

  TextColumn get title => text()();

  RealColumn get amount => real()();

  IntColumn get whenAt => integer()();

  TextColumn get note => text().nullable()();

  BoolColumn get isDone => boolean().withDefault(const Constant<bool>(false))();

  IntColumn get lastNotifiedAt => integer().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
