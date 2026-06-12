import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/savings/data/services/goal_contribution_rebuild_service.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late SavingGoalDao savingGoalDao;
  late TransactionDao transactionDao;
  late GoalContributionRebuildService service;
  late DateTime now;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    savingGoalDao = SavingGoalDao(database);
    transactionDao = TransactionDao(database);
    service = GoalContributionRebuildService(database);
    now = DateTime.utc(2024, 1, 1, 12);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'rebuild is idempotent and recalculates currentAmount from transactions',
    () async {
      await accountDao.upsert(
        AccountEntity(
          id: 'acc-source',
          name: 'Source',
          balanceMinor: BigInt.from(50_000),
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await accountDao.upsert(
        AccountEntity(
          id: 'acc-storage',
          name: 'Storage',
          balanceMinor: BigInt.zero,
          currency: 'USD',
          currencyScale: 2,
          type: 'savings',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await savingGoalDao.upsert(
        SavingGoal(
          id: 'goal-1',
          userId: 'user-1',
          name: 'Goal',
          accountId: 'acc-storage',
          targetAmount: 10_000,
          currentAmount: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await transactionDao.upsert(
        TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-source',
          transferAccountId: 'acc-storage',
          savingGoalId: 'goal-1',
          amountMinor: BigInt.from(2_500),
          amountScale: 2,
          date: now,
          type: 'transfer',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await service.rebuild();
      await service.rebuild();

      final List<db.GoalContributionRow> rows = await database
          .select(database.goalContributions)
          .get();
      final SavingGoal? goal = await savingGoalDao.findById('goal-1');

      expect(rows, hasLength(1));
      expect(rows.single.id, 'tx-1');
      expect(rows.single.transactionId, 'tx-1');
      expect(rows.single.storageAccountId, 'acc-storage');
      expect(rows.single.amount, 2_500);
      expect(goal?.currentAmount, 2_500);
    },
  );

  test(
    'rebuild removes stale generated contribution for deleted transaction',
    () async {
      await accountDao.upsert(
        AccountEntity(
          id: 'acc-source',
          name: 'Source',
          balanceMinor: BigInt.from(50_000),
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await savingGoalDao.upsert(
        SavingGoal(
          id: 'goal-1',
          userId: 'user-1',
          name: 'Goal',
          accountId: 'acc-source',
          targetAmount: 10_000,
          currentAmount: 5_000,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await transactionDao.upsert(
        TransactionEntity(
          id: 'tx-1',
          accountId: 'acc-source',
          transferAccountId: 'acc-source',
          savingGoalId: 'goal-1',
          amountMinor: BigInt.from(5_000),
          amountScale: 2,
          date: now,
          type: 'transfer',
          createdAt: now,
          updatedAt: now,
          isDeleted: true,
        ),
      );
      await database
          .into(database.goalContributions)
          .insert(
            db.GoalContributionsCompanion.insert(
              id: 'tx-1',
              goalId: 'goal-1',
              transactionId: 'tx-1',
              storageAccountId: const Value<String?>('acc-source'),
              amount: 5_000,
              createdAt: Value<DateTime>(now),
            ),
          );

      await service.rebuild();

      final List<db.GoalContributionRow> rows = await database
          .select(database.goalContributions)
          .get();
      final SavingGoal? goal = await savingGoalDao.findById('goal-1');

      expect(rows, isEmpty);
      expect(goal?.currentAmount, 0);
    },
  );
}
