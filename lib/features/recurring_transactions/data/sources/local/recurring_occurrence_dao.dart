import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';

class RecurringOccurrenceDao {
  RecurringOccurrenceDao(this._database);

  final db.AppDatabase _database;

  Stream<List<db.RecurringOccurrenceRow>> watchWindow({
    required DateTime from,
    required DateTime to,
  }) {
    final SimpleSelectStatement<
      db.$RecurringOccurrencesTable,
      db.RecurringOccurrenceRow
    >
    query = _database.select(_database.recurringOccurrences)
      ..where(
        (db.$RecurringOccurrencesTable tbl) =>
            tbl.dueAt.isBetweenValues(from.toUtc(), to.toUtc()),
      );
    return query.watch();
  }

  Stream<List<db.RecurringOccurrenceRow>> watchRule(String ruleId) {
    final SimpleSelectStatement<
      db.$RecurringOccurrencesTable,
      db.RecurringOccurrenceRow
    >
    query = _database.select(_database.recurringOccurrences)
      ..where((db.$RecurringOccurrencesTable tbl) => tbl.ruleId.equals(ruleId));
    return query.watch();
  }

  Future<List<db.RecurringOccurrenceRow>> getDueOn(DateTime date) {
    final DateTime start = DateTime.utc(date.year, date.month, date.day);
    final DateTime end = start.add(const Duration(days: 1));
    final SimpleSelectStatement<
      db.$RecurringOccurrencesTable,
      db.RecurringOccurrenceRow
    >
    query = _database.select(_database.recurringOccurrences)
      ..where(
        (db.$RecurringOccurrencesTable tbl) =>
            tbl.dueAt.isBetweenValues(start, end),
      );
    return query.get();
  }

  Future<void> replaceOccurrences(
    Iterable<RecurringOccurrence> occurrences,
  ) async {
    await _database.transaction(() async {
      final List<String> ruleIds = occurrences
          .map((RecurringOccurrence e) => e.ruleId)
          .toSet()
          .toList();
      for (final String ruleId in ruleIds) {
        await (_database.delete(_database.recurringOccurrences)..where(
              (db.$RecurringOccurrencesTable tbl) => tbl.ruleId.equals(ruleId),
            ))
            .go();
      }
      if (occurrences.isEmpty) {
        return;
      }
      await _database.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _database.recurringOccurrences,
          occurrences.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> upsertAll(Iterable<RecurringOccurrence> occurrences) async {
    if (occurrences.isEmpty) return;
    await _database.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _database.recurringOccurrences,
        occurrences.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> deleteForRule(String ruleId) {
    return (_database.delete(_database.recurringOccurrences)..where(
          (db.$RecurringOccurrencesTable tbl) => tbl.ruleId.equals(ruleId),
        ))
        .go();
  }

  Future<void> clearAll() {
    return _database.delete(_database.recurringOccurrences).go();
  }

  Future<void> updateStatus(
    String occurrenceId,
    RecurringOccurrenceStatus status, {
    String? postedTxId,
    DateTime? updatedAt,
  }) {
    return (_database.update(_database.recurringOccurrences)..where(
          (db.$RecurringOccurrencesTable tbl) => tbl.id.equals(occurrenceId),
        ))
        .write(
          db.RecurringOccurrencesCompanion(
            status: Value<String>(status.value),
            postedTxId: Value<String?>(postedTxId),
            updatedAt: Value<DateTime>(
              updatedAt?.toUtc() ?? DateTime.now().toUtc(),
            ),
          ),
        );
  }

  db.RecurringOccurrencesCompanion _mapToCompanion(
    RecurringOccurrence occurrence,
  ) {
    return db.RecurringOccurrencesCompanion(
      id: Value<String>(occurrence.id),
      ruleId: Value<String>(occurrence.ruleId),
      dueAt: Value<DateTime>(occurrence.dueAt.toUtc()),
      status: Value<String>(occurrence.status.value),
      createdAt: Value<DateTime>(occurrence.createdAt.toUtc()),
      postedTxId: Value<String?>(occurrence.postedTxId),
      updatedAt: Value<DateTime>(
        occurrence.updatedAt?.toUtc() ?? occurrence.createdAt.toUtc(),
      ),
    );
  }
}
