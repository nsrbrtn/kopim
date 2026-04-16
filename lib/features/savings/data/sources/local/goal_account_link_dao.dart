import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

class GoalAccountLinkDao {
  GoalAccountLinkDao(this._db);

  final db.AppDatabase _db;

  Future<List<String>> findAccountIdsByGoalId(String goalId) async {
    final List<db.GoalAccountLinkRow> rows =
        await (_db.select(_db.goalAccountLinks)..where(
              (db.$GoalAccountLinksTable tbl) => tbl.goalId.equals(goalId),
            ))
            .get();
    return rows
        .map((db.GoalAccountLinkRow row) => row.accountId)
        .toList(growable: false);
  }

  Future<Map<String, List<String>>> findAccountIdsByGoalIds(
    Iterable<String> goalIds,
  ) async {
    final List<String> normalized = goalIds
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalized.isEmpty) {
      return const <String, List<String>>{};
    }

    final List<db.GoalAccountLinkRow> rows =
        await (_db.select(_db.goalAccountLinks)..where(
              (db.$GoalAccountLinksTable tbl) => tbl.goalId.isIn(normalized),
            ))
            .get();
    final Map<String, List<String>> result = <String, List<String>>{};
    for (final db.GoalAccountLinkRow row in rows) {
      result.putIfAbsent(row.goalId, () => <String>[]).add(row.accountId);
    }
    return result;
  }

  Future<void> replaceLinks({
    required String goalId,
    required Iterable<String> accountIds,
    DateTime? now,
  }) async {
    final List<String> normalized = accountIds
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final DateTime timestamp = now ?? DateTime.now().toUtc();

    await _db.transaction(() async {
      await (_db.delete(_db.goalAccountLinks)..where(
            (db.$GoalAccountLinksTable tbl) => tbl.goalId.equals(goalId),
          ))
          .go();
      if (normalized.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.goalAccountLinks,
          normalized
              .map(
                (String accountId) => db.GoalAccountLinksCompanion.insert(
                  goalId: goalId,
                  accountId: accountId,
                  createdAt: Value<DateTime>(timestamp),
                ),
              )
              .toList(growable: false),
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }

  Future<void> replaceLinksByGoal({
    required Map<String, Iterable<String>> accountIdsByGoalId,
    DateTime? now,
  }) async {
    if (accountIdsByGoalId.isEmpty) {
      return;
    }

    final Map<String, List<String>> normalizedByGoalId =
        <String, List<String>>{};
    for (final MapEntry<String, Iterable<String>> entry
        in accountIdsByGoalId.entries) {
      final String goalId = entry.key.trim();
      if (goalId.isEmpty) {
        continue;
      }
      final List<String> accountIds = entry.value
          .map((String value) => value.trim())
          .where((String value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false);
      normalizedByGoalId[goalId] = accountIds;
    }
    if (normalizedByGoalId.isEmpty) {
      return;
    }

    final DateTime timestamp = now ?? DateTime.now().toUtc();
    final List<String> goalIds = normalizedByGoalId.keys.toList(
      growable: false,
    );

    await _db.transaction(() async {
      await (_db.delete(
            _db.goalAccountLinks,
          )..where((db.$GoalAccountLinksTable tbl) => tbl.goalId.isIn(goalIds)))
          .go();

      final List<db.GoalAccountLinksCompanion> rows =
          <db.GoalAccountLinksCompanion>[];
      for (final MapEntry<String, List<String>> entry
          in normalizedByGoalId.entries) {
        for (final String accountId in entry.value) {
          rows.add(
            db.GoalAccountLinksCompanion.insert(
              goalId: entry.key,
              accountId: accountId,
              createdAt: Value<DateTime>(timestamp),
            ),
          );
        }
      }
      if (rows.isEmpty) {
        return;
      }

      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.goalAccountLinks,
          rows,
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }
}
