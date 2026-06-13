import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_diagnostics_service.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  late AppDatabase database;
  late OutboxDao outboxDao;
  late LocalSyncIntegrityDiagnosticsService service;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    outboxDao = OutboxDao(database);
    service = LocalSyncIntegrityDiagnosticsService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'detects orphan transaction references and broken credit group links',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Main',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
            ),
          );
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-2',
              name: 'Broken',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-1',
              accountId: 'acc-1',
              amount: 10,
              amountMinor: const Value<String>('1000'),
              amountScale: const Value<int>(2),
              date: DateTime.utc(2024, 1, 1),
              type: TransactionType.transfer.storageValue,
            ),
          );

      await database.customStatement('PRAGMA foreign_keys = OFF');
      await (database.update(
        database.transactions,
      )..where((Transactions tbl) => tbl.id.equals('tx-1'))).write(
        const TransactionsCompanion(
          accountId: Value<String>('missing-account'),
          categoryId: Value<String>('missing-category'),
          savingGoalId: Value<String>('missing-goal'),
          groupId: Value<String>('missing-group'),
        ),
      );
      await database
          .into(database.transactionTags)
          .insert(
            TransactionTagsCompanion.insert(
              transactionId: 'missing-tx',
              tagId: 'missing-tag',
            ),
          );
      await database.customStatement('PRAGMA foreign_keys = ON');

      final LocalSyncIntegrityReport report = await service.run();

      expect(
        report.countByType(
          LocalSyncIntegrityIssueType.orphanTransactionAccount,
        ),
        1,
      );
      expect(
        report.countByType(LocalSyncIntegrityIssueType.invalidTransferLink),
        1,
      );
      expect(
        report.countByType(
          LocalSyncIntegrityIssueType.orphanTransactionCategory,
        ),
        1,
      );
      expect(
        report.countByType(LocalSyncIntegrityIssueType.invalidSavingGoalLink),
        1,
      );
      expect(
        report.countByType(LocalSyncIntegrityIssueType.invalidCreditGroupLink),
        1,
      );
      expect(
        report.countByType(
          LocalSyncIntegrityIssueType.orphanTransactionTagLink,
        ),
        1,
      );
    },
  );

  test(
    'detects saving goal mismatch, invalid money field and outbox anomalies',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Reserve',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
            ),
          );
      await database
          .into(database.savingGoals)
          .insert(
            SavingGoalsCompanion.insert(
              id: 'goal-1',
              userId: 'user-1',
              name: 'Trip',
              targetAmount: 1000,
              currentAmount: const Value<int>(500),
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-goal',
              accountId: 'acc-1',
              amount: 2,
              amountMinor: const Value<String>('200'),
              amountScale: const Value<int>(2),
              date: DateTime.utc(2024, 1, 2),
              type: TransactionType.expense.storageValue,
            ),
          );
      await (database.update(
        database.transactions,
      )..where((Transactions tbl) => tbl.id.equals('tx-goal'))).write(
        const TransactionsCompanion(amountMinor: Value<String>('oops')),
      );
      await database
          .into(database.goalContributions)
          .insert(
            GoalContributionsCompanion.insert(
              id: 'gc-1',
              goalId: 'goal-1',
              transactionId: 'tx-goal',
              amount: 200,
            ),
          );
      await (database.update(database.accounts)
            ..where((Accounts tbl) => tbl.id.equals('acc-1')))
          .write(const AccountsCompanion(balanceMinor: Value<String>('999')));

      final int outboxId = await outboxDao.enqueue(
        entityType: 'mystery',
        entityId: 'entity-1',
        operation: OutboxOperation.upsert,
        payload: const <String, dynamic>{'id': 'entity-1'},
      );
      await (database.update(
        database.outboxEntries,
      )..where((OutboxEntries tbl) => tbl.id.equals(outboxId))).write(
        OutboxEntriesCompanion(
          status: Value<String>(OutboxStatus.sending.name),
          updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 10, 12)),
        ),
      );

      final LocalSyncIntegrityReport report = await service.run(
        now: DateTime.utc(2024, 1, 10, 12, 10),
      );

      expect(
        report.countByType(
          LocalSyncIntegrityIssueType.savingGoalMissingStorageAccount,
        ),
        1,
      );
      expect(
        report.countByType(
          LocalSyncIntegrityIssueType.savingGoalCurrentAmountMismatch,
        ),
        1,
      );
      expect(
        report.countByType(LocalSyncIntegrityIssueType.invalidMoneyField),
        1,
      );
      expect(
        report.countByType(LocalSyncIntegrityIssueType.accountBalanceMismatch),
        1,
      );
      expect(
        report.countByType(
          LocalSyncIntegrityIssueType.unsupportedOutboxEntityType,
        ),
        1,
      );
      expect(
        report.countByType(LocalSyncIntegrityIssueType.staleSendingOutbox),
        1,
      );
    },
  );

  test('detects invalid credit payment schedule references', () async {
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'acc-1',
            name: 'Card',
            balance: 0,
            currency: 'RUB',
            type: 'cash',
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat-1',
            name: 'Loan',
            type: 'expense',
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
            categoryId: const Value<String>('cat-1'),
          ),
        );
    await database
        .into(database.creditPaymentSchedules)
        .insert(
          CreditPaymentSchedulesCompanion.insert(
            id: 'schedule-1',
            creditId: 'credit-1',
            periodKey: '2024-01',
            dueDate: DateTime.utc(2024, 2, 1),
            status: 'planned',
            principalAmountMinor: '500',
            interestAmountMinor: '50',
            totalAmountMinor: '550',
          ),
        );

    await database.customStatement('PRAGMA foreign_keys = OFF');
    await (database.update(database.creditPaymentSchedules)
          ..where((CreditPaymentSchedules tbl) => tbl.id.equals('schedule-1')))
        .write(
          const CreditPaymentSchedulesCompanion(
            creditId: Value<String>('missing-credit'),
          ),
        );
    await database.customStatement('PRAGMA foreign_keys = ON');

    final LocalSyncIntegrityReport report = await service.run();

    expect(
      report.countByType(LocalSyncIntegrityIssueType.invalidCreditSchedule),
      1,
    );
  });

  test(
    'detects orphan liability account without active domain entity',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-orphan-credit',
              name: 'Orphan credit',
              balance: -1000,
              currency: 'RUB',
              type: 'credit',
            ),
          );

      final LocalSyncIntegrityReport report = await service.run();

      expect(
        report.countByType(LocalSyncIntegrityIssueType.orphanLiabilityAccount),
        1,
      );
    },
  );

  test('formats developer-facing integrity report summary', () {
    const LocalSyncIntegrityReportFormatter formatter =
        LocalSyncIntegrityReportFormatter();
    final LocalSyncIntegrityReport report = LocalSyncIntegrityReport(
      generatedAt: DateTime.utc(2024, 1, 1),
      issues: const <LocalSyncIntegrityIssue>[
        LocalSyncIntegrityIssue(
          type: LocalSyncIntegrityIssueType.accountBalanceMismatch,
          entityType: 'account',
          entityId: 'acc-1',
          message: 'balance mismatch',
        ),
        LocalSyncIntegrityIssue(
          type: LocalSyncIntegrityIssueType.accountBalanceMismatch,
          entityType: 'account',
          entityId: 'acc-2',
          message: 'balance mismatch',
        ),
        LocalSyncIntegrityIssue(
          type: LocalSyncIntegrityIssueType.staleSendingOutbox,
          entityType: 'outbox',
          entityId: '42',
          message: 'stale sending',
        ),
      ],
    );

    final String text = formatter.format(report);

    expect(text, contains('Issues: 3'));
    expect(text, contains('accountBalanceMismatch: 2'));
    expect(text, contains('outbox:42 - stale sending'));
  });
}
