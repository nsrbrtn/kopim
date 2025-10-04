import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';

class RecurringRuleDao {
  RecurringRuleDao(this._database);

  final db.AppDatabase _database;

  Stream<List<db.RecurringRuleRow>> watchAll() {
    final SimpleSelectStatement<db.$RecurringRulesTable, db.RecurringRuleRow>
    query = _database.select(_database.recurringRules);
    return query.watch();
  }

  Future<List<db.RecurringRuleRow>> getAll() {
    return _database.select(_database.recurringRules).get();
  }

  Future<db.RecurringRuleRow?> findById(String id) {
    final SimpleSelectStatement<db.$RecurringRulesTable, db.RecurringRuleRow>
    query = _database.select(_database.recurringRules)
      ..where((db.$RecurringRulesTable tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(RecurringRule rule) {
    return _database
        .into(_database.recurringRules)
        .insertOnConflictUpdate(_mapRuleToCompanion(rule));
  }

  Future<void> deleteById(String id) {
    return (_database.delete(
      _database.recurringRules,
    )..where((db.$RecurringRulesTable tbl) => tbl.id.equals(id))).go();
  }

  Future<void> toggle({
    required String id,
    required bool isActive,
    required DateTime updatedAt,
  }) {
    return (_database.update(
      _database.recurringRules,
    )..where((db.$RecurringRulesTable tbl) => tbl.id.equals(id))).write(
      db.RecurringRulesCompanion(
        isActive: Value<bool>(isActive),
        updatedAt: Value<DateTime>(updatedAt),
      ),
    );
  }

  db.RecurringRulesCompanion _mapRuleToCompanion(RecurringRule rule) {
    return db.RecurringRulesCompanion(
      id: Value<String>(rule.id),
      title: Value<String>(rule.title),
      accountId: Value<String>(rule.accountId),
      categoryId: Value<String>(rule.categoryId),
      amount: Value<double>(rule.amount),
      currency: Value<String>(rule.currency),
      startAt: Value<DateTime>(rule.startAt.toUtc()),
      timezone: Value<String>(rule.timezone),
      rrule: Value<String>(rule.rrule),
      endAt: Value<DateTime?>(rule.endAt?.toUtc()),
      notes: Value<String?>(rule.notes),
      dayOfMonth: Value<int>(rule.dayOfMonth),
      applyAtLocalHour: Value<int>(rule.applyAtLocalHour),
      applyAtLocalMinute: Value<int>(rule.applyAtLocalMinute),
      lastRunAt: Value<DateTime?>(rule.lastRunAt?.toUtc()),
      nextDueLocalDate: Value<DateTime?>(rule.nextDueLocalDate?.toUtc()),
      isActive: Value<bool>(rule.isActive),
      autoPost: Value<bool>(rule.autoPost),
      reminderMinutesBefore: Value<int?>(rule.reminderMinutesBefore),
      shortMonthPolicy: Value<String>(rule.shortMonthPolicy.value),
      createdAt: Value<DateTime>(rule.createdAt.toUtc()),
      updatedAt: Value<DateTime>(rule.updatedAt.toUtc()),
    );
  }
}
