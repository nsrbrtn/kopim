import 'package:drift/drift.dart' as drift show DatabaseConnection, Migrator;
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';

void main() {
  group('Database migration v50 tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'fresh database contains local_row_ownership and current_sync_state tables',
      () async {
        final List<LocalRowOwnershipRow> ownerships = await database
            .select(database.localRowOwnership)
            .get();
        expect(ownerships, isEmpty);

        final List<CurrentSyncStateRow> syncStates = await database
            .select(database.currentSyncStates)
            .get();
        expect(syncStates, hasLength(1));
        expect(syncStates.first.id, 1);
        expect(syncStates.first.currentUid, isNull);
        expect(syncStates.first.syncActive, isFalse);
        expect(syncStates.first.importInProgress, isFalse);
      },
    );

    test(
      'migration from v49 to v50 backfills existing data and registers triggers',
      () async {
        // 1. Drop new tables and triggers to simulate v49
        await database.customStatement(
          'DROP TABLE IF EXISTS local_row_ownership',
        );
        await database.customStatement(
          'DROP TABLE IF EXISTS current_sync_state',
        );
        const List<Map<String, String>> tablesAndTypes = <Map<String, String>>[
          <String, String>{'table': 'accounts', 'type': 'account'},
          <String, String>{'table': 'categories', 'type': 'category'},
          <String, String>{'table': 'tags', 'type': 'tag'},
          <String, String>{'table': 'transactions', 'type': 'transaction'},
          <String, String>{'table': 'budgets', 'type': 'budget'},
          <String, String>{
            'table': 'budget_instances',
            'type': 'budget_instance',
          },
          <String, String>{'table': 'saving_goals', 'type': 'saving_goal'},
          <String, String>{
            'table': 'upcoming_payments',
            'type': 'upcoming_payment',
          },
          <String, String>{
            'table': 'payment_reminders',
            'type': 'payment_reminder',
          },
          <String, String>{'table': 'debts', 'type': 'debt'},
          <String, String>{'table': 'credits', 'type': 'credit'},
          <String, String>{'table': 'credit_cards', 'type': 'credit_card'},
          <String, String>{
            'table': 'credit_payment_schedules',
            'type': 'credit_payment_schedule',
          },
          <String, String>{
            'table': 'credit_payment_groups',
            'type': 'credit_payment_group',
          },
        ];
        for (final Map<String, String> item in tablesAndTypes) {
          final String tableName = item['table']!;
          await database.customStatement(
            'DROP TRIGGER IF EXISTS ${tableName}_ownership_trigger',
          );
          await database.customStatement(
            'DROP TRIGGER IF EXISTS ${tableName}_ownership_delete_trigger',
          );
        }

        // 2. Insert some dummy data to simulate existing rows
        await database
            .into(database.accounts)
            .insert(
              AccountsCompanion.insert(
                id: 'acc-1',
                name: 'Checking',
                balance: 100.0,
                currency: 'USD',
                type: 'regular',
              ),
            );

        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'cat-1',
                name: 'Food',
                type: 'expense',
                isSystem: const Value<bool>(false),
              ),
            );

        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'system-cat',
                name: 'Uncategorized',
                type: 'expense',
                isSystem: const Value<bool>(true),
              ),
            );

        // 3. Run migration onUpgrade from 49 to 50
        final drift.Migrator migrator = drift.Migrator(database);
        await database.migration.onUpgrade(migrator, 49, 50);

        // 4. Verify tables exist
        final List<CurrentSyncStateRow> syncStates = await database
            .select(database.currentSyncStates)
            .get();
        expect(syncStates, hasLength(1));

        // 5. Verify existing rows are backfilled
        final List<LocalRowOwnershipRow> ownerships = await database
            .select(database.localRowOwnership)
            .get();
        expect(ownerships, hasLength(3));

        final LocalRowOwnershipRow accOwner = ownerships.firstWhere(
          (LocalRowOwnershipRow o) => o.entityId == 'acc-1',
        );
        expect(accOwner.entityType, 'account');
        expect(accOwner.ownershipState, 'localOnly');
        expect(accOwner.ownerUid, isNull);
        expect(accOwner.source, 'schema_backfill');

        final LocalRowOwnershipRow catOwner = ownerships.firstWhere(
          (LocalRowOwnershipRow o) => o.entityId == 'cat-1',
        );
        expect(catOwner.entityType, 'category');
        expect(catOwner.ownershipState, 'localOnly');
        expect(catOwner.source, 'schema_backfill');

        final LocalRowOwnershipRow systemCatOwner = ownerships.firstWhere(
          (LocalRowOwnershipRow o) => o.entityId == 'system-cat',
        );
        expect(systemCatOwner.entityType, 'category');
        expect(systemCatOwner.ownershipState, 'systemDefault');
        expect(systemCatOwner.source, 'schema_backfill');
      },
    );

    test(
      'new inserts/deletes trigger ownership projection update automatically',
      () async {
        // Setup triggers and sync state: user is logged in and sync is active
        await database.updateCurrentSyncState('cloud-uid-1', true);

        // Insert new account
        await database
            .into(database.accounts)
            .insert(
              AccountsCompanion.insert(
                id: 'new-acc',
                name: 'Savings',
                balance: 500.0,
                currency: 'USD',
                type: 'regular',
              ),
            );

        // Verify trigger automatically inserted cloudOwned row
        final LocalRowOwnershipRow? newAccOwner = await database.getOwnership(
          'account',
          'new-acc',
        );
        expect(newAccOwner, isNotNull);
        expect(newAccOwner!.ownershipState, 'cloudOwned');
        expect(newAccOwner.ownerUid, 'cloud-uid-1');
        expect(newAccOwner.source, 'local_creation');

        // Delete account
        await (database.delete(
          database.accounts,
        )..where(($AccountsTable tbl) => tbl.id.equals('new-acc'))).go();

        // Verify trigger automatically deleted ownership row
        final LocalRowOwnershipRow? deletedAccOwner = await database
            .getOwnership('account', 'new-acc');
        expect(deletedAccOwner, isNull);
      },
    );

    test('every direct-projection family gets ownership coverage', () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Wallet',
              balance: 100,
              currency: 'USD',
              type: 'cash',
            ),
          );
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-1',
              name: 'Food',
              type: 'expense',
              isSystem: const Value<bool>(false),
            ),
          );
      await database
          .into(database.tags)
          .insert(
            TagsCompanion.insert(id: 'tag-1', name: 'Urgent', color: '#FF0000'),
          );
      await database
          .into(database.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'budget-1',
              title: 'Monthly',
              period: 'month',
              startDate: DateTime.utc(2024, 1, 1),
              amount: 1000,
              scope: 'global',
            ),
          );
      await database
          .into(database.budgetInstances)
          .insert(
            BudgetInstancesCompanion.insert(
              id: 'budget-instance-1',
              budgetId: 'budget-1',
              periodStart: DateTime.utc(2024, 1, 1),
              periodEnd: DateTime.utc(2024, 1, 31),
              amount: 1000,
              spent: const Value<double>(0),
            ),
          );
      await database
          .into(database.savingGoals)
          .insert(
            SavingGoalsCompanion.insert(
              id: 'goal-1',
              userId: 'local-user-1',
              name: 'Trip',
              targetAmount: 10000,
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-1',
              accountId: 'acc-1',
              amount: 100,
              date: DateTime.utc(2024, 1, 1),
              type: 'expense',
              categoryId: const Value<String?>('cat-1'),
            ),
          );
      await database
          .into(database.upcomingPayments)
          .insert(
            UpcomingPaymentsCompanion.insert(
              id: 'up-1',
              title: 'Rent',
              accountId: 'acc-1',
              categoryId: 'cat-1',
              amount: 1200,
              dayOfMonth: 1,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await database
          .into(database.paymentReminders)
          .insert(
            PaymentRemindersCompanion.insert(
              id: 'rem-1',
              title: 'Reminder',
              amount: 10,
              whenAt: 1,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await database
          .into(database.debts)
          .insert(
            DebtsCompanion.insert(
              id: 'debt-1',
              accountId: 'acc-1',
              amount: 500,
              dueDate: DateTime.utc(2024, 2, 1),
            ),
          );
      await database
          .into(database.credits)
          .insert(
            CreditsCompanion.insert(
              id: 'credit-1',
              accountId: 'acc-1',
              totalAmount: 1000,
              interestRate: 10,
              termMonths: 12,
              startDate: DateTime.utc(2024, 1, 1),
            ),
          );
      await database
          .into(database.creditCards)
          .insert(
            CreditCardsCompanion.insert(
              id: 'card-1',
              accountId: 'acc-1',
              creditLimit: 2000,
              statementDay: 1,
              paymentDueDays: 20,
              interestRateAnnual: 12,
            ),
          );
      await database
          .into(database.creditPaymentSchedules)
          .insert(
            CreditPaymentSchedulesCompanion.insert(
              id: 'sched-1',
              creditId: 'credit-1',
              periodKey: '2024-01',
              dueDate: DateTime.utc(2024, 1, 20),
              status: 'pending',
              principalAmountMinor: '1000',
              interestAmountMinor: '100',
              totalAmountMinor: '1100',
            ),
          );
      await database
          .into(database.creditPaymentGroups)
          .insert(
            CreditPaymentGroupsCompanion.insert(
              id: 'group-1',
              creditId: 'credit-1',
              sourceAccountId: 'acc-1',
              paidAt: DateTime.utc(2024, 1, 20),
              totalOutflowMinor: '1100',
              principalPaidMinor: '1000',
              interestPaidMinor: '100',
              feesPaidMinor: '0',
            ),
          );

      final Set<String> coveredTypes =
          (await database.select(database.localRowOwnership).get())
              .map((LocalRowOwnershipRow row) => row.entityType)
              .toSet();

      expect(
        coveredTypes,
        containsAll(<String>{
          'account',
          'category',
          'tag',
          'transaction',
          'budget',
          'budget_instance',
          'saving_goal',
          'upcoming_payment',
          'payment_reminder',
          'debt',
          'credit',
          'credit_card',
          'credit_payment_schedule',
          'credit_payment_group',
        }),
      );
    });

    test(
      'inserts during import are flagged as import_restore and localOnly',
      () async {
        // 1. Set importInProgress = true
        await database
            .into(database.currentSyncStates)
            .insertOnConflictUpdate(
              const CurrentSyncStateRow(
                id: 1,
                currentUid: 'cloud-uid-1',
                syncActive: true,
                importInProgress: true,
              ),
            );

        // 2. Insert account
        await database
            .into(database.accounts)
            .insert(
              AccountsCompanion.insert(
                id: 'imported-acc',
                name: 'Imported',
                balance: 1000.0,
                currency: 'USD',
                type: 'regular',
              ),
            );

        // 3. Verify it is localOnly and import_restore, despite syncActive being true
        final LocalRowOwnershipRow? importedAccOwner = await database
            .getOwnership('account', 'imported-acc');
        expect(importedAccOwner, isNotNull);
        expect(importedAccOwner!.ownershipState, 'localOnly');
        expect(importedAccOwner.ownerUid, isNull);
        expect(importedAccOwner.source, 'import_restore');
        expect(importedAccOwner.version, 1);
      },
    );
  });
}
