import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/profile/application/migration_write_guard.dart';

class GoalContributionRebuildService {
  GoalContributionRebuildService(
    this._database, {
    MigrationWriteGuard? migrationWriteGuard,
  }) : _migrationWriteGuard =
           migrationWriteGuard ?? const NoopMigrationWriteGuard();

  final db.AppDatabase _database;
  final MigrationWriteGuard _migrationWriteGuard;

  Future<void> rebuild() async {
    await _migrationWriteGuard.runBackgroundMutation(
      action: () async {
        await _database.transaction(() async {
          final List<db.SavingGoalRow> goalRows = await _database
              .select(_database.savingGoals)
              .get();
          final Set<String> validGoalIds = goalRows
              .map((db.SavingGoalRow row) => row.id)
              .toSet();

          final List<db.TransactionRow> activeTransactions =
              await (_database.select(_database.transactions)..where(
                    (db.$TransactionsTable tbl) =>
                        tbl.isDeleted.equals(false) &
                        tbl.savingGoalId.isNotNull(),
                  ))
                  .get();
          final List<db.GoalContributionRow> existingRows = await _database
              .select(_database.goalContributions)
              .get();
          final Map<String, db.GoalContributionRow> existingByTransactionId =
              <String, db.GoalContributionRow>{
                for (final db.GoalContributionRow row in existingRows)
                  row.transactionId: row,
              };

          final Set<String> activeTransactionIds = <String>{};
          for (final db.TransactionRow row in activeTransactions) {
            final String? rawGoalId = row.savingGoalId?.trim();
            if (rawGoalId == null || rawGoalId.isEmpty) {
              continue;
            }
            if (!validGoalIds.contains(rawGoalId)) {
              continue;
            }

            activeTransactionIds.add(row.id);
            final db.GoalContributionRow? existing =
                existingByTransactionId[row.id];
            final String storageAccountId =
                row.transferAccountId?.trim().isNotEmpty ?? false
                ? row.transferAccountId!.trim()
                : row.accountId;

            await _database
                .into(_database.goalContributions)
                .insertOnConflictUpdate(
                  db.GoalContributionsCompanion(
                    id: Value<String>(existing?.id ?? row.id),
                    goalId: Value<String>(rawGoalId),
                    transactionId: Value<String>(row.id),
                    storageAccountId: Value<String?>(storageAccountId),
                    amount: Value<int>(
                      BigInt.parse(row.amountMinor).abs().toInt(),
                    ),
                    createdAt: Value<DateTime>(
                      existing?.createdAt ?? row.createdAt,
                    ),
                  ),
                );
          }

          for (final db.GoalContributionRow row in existingRows) {
            if (activeTransactionIds.contains(row.transactionId)) {
              continue;
            }
            if (row.id != row.transactionId) {
              continue;
            }
            await (_database.delete(_database.goalContributions)..where(
                  (db.$GoalContributionsTable tbl) => tbl.id.equals(row.id),
                ))
                .go();
          }

          final List<db.GoalContributionRow> rebuiltRows = await _database
              .select(_database.goalContributions)
              .get();
          final Map<String, int> amountByGoalId = <String, int>{};
          for (final db.GoalContributionRow row in rebuiltRows) {
            amountByGoalId.update(
              row.goalId,
              (int current) => current + row.amount,
              ifAbsent: () => row.amount,
            );
          }

          for (final db.SavingGoalRow row in goalRows) {
            final int recalculated = (amountByGoalId[row.id] ?? 0).clamp(
              0,
              row.targetAmount,
            );
            if (recalculated == row.currentAmount) {
              continue;
            }
            await (_database.update(_database.savingGoals)
                  ..where((db.$SavingGoalsTable tbl) => tbl.id.equals(row.id)))
                .write(
                  db.SavingGoalsCompanion(
                    currentAmount: Value<int>(recalculated),
                  ),
                );
          }
        });
      },
    );
  }
}
