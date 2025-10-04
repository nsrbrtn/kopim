import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/recurring_transactions/data/repositories/recurring_transactions_repository_impl.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/job_queue_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_occurrence_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_execution_dao.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/apply_recurring_rules_use_case.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase database;
  late RecurringTransactionsRepository repository;

  setUp(() async {
    database = AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    repository = RecurringTransactionsRepositoryImpl(
      ruleDao: RecurringRuleDao(database),
      occurrenceDao: RecurringOccurrenceDao(database),
      executionDao: RecurringRuleExecutionDao(database),
      jobQueueDao: JobQueueDao(database),
      database: database,
    );

    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'acc1',
            name: 'Primary',
            balance: 1000,
            currency: 'USD',
            type: 'cash',
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat1',
            name: 'Subscriptions',
            type: 'expense',
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'applies and advances recurring rules exactly once per window',
    () async {
      final DateTime created = DateTime.utc(2024, 1, 1);
      final RecurringRule rule = RecurringRule(
        id: 'rule1',
        title: 'Monthly subscription',
        accountId: 'acc1',
        categoryId: 'cat1',
        amount: 50,
        currency: 'USD',
        startAt: DateTime(2024, 1, 31, 0, 1),
        timezone: 'Europe/Helsinki',
        rrule: 'FREQ=MONTHLY',
        notes: 'Test rule',
        autoPost: true,
        dayOfMonth: 31,
        applyAtLocalHour: 0,
        applyAtLocalMinute: 1,
        lastRunAt: DateTime(2024, 1, 31, 0, 1),
        nextDueLocalDate: DateTime(2024, 1, 31, 0, 1),
        createdAt: created,
        updatedAt: created,
      );
      await repository.upsertRule(rule);

      final OutboxDao outboxDao = OutboxDao(database);
      final AccountDao accountDao = AccountDao(database);
      final TransactionDao transactionDao = TransactionDao(database);
      final AccountRepository accountRepository = AccountRepositoryImpl(
        database: database,
        accountDao: accountDao,
        outboxDao: outboxDao,
      );
      final TransactionRepository transactionRepository =
          TransactionRepositoryImpl(
            database: database,
            transactionDao: transactionDao,
            outboxDao: outboxDao,
          );

      String? lastId;
      final AddTransactionUseCase addTransaction = AddTransactionUseCase(
        transactionRepository: transactionRepository,
        accountRepository: accountRepository,
        idGenerator: () {
          final String generated = const Uuid().v4();
          lastId = generated;
          return generated;
        },
        clock: () => DateTime(2024, 2, 29, 0, 1).toUtc(),
      );

      Future<String?> postTransaction(AddTransactionRequest request) async {
        lastId = null;
        await addTransaction(request);
        return lastId;
      }

      final ApplyRecurringRulesUseCase useCase = ApplyRecurringRulesUseCase(
        repository: repository,
        postTransaction: postTransaction,
        clock: () => DateTime(2024, 2, 29, 0, 1),
      );

      final ApplyRecurringRulesResult result = await useCase();

      expect(result.applied, 1);
      expect(result.skipped, 0);

      final List<TransactionRow> transactions = await database
          .select(database.transactions)
          .get();
      expect(transactions, hasLength(1));
      expect(lastId, isNotNull);
      expect(transactions.first.id, lastId);
      expect(
        transactions.first.date.toUtc(),
        DateTime(2024, 2, 29, 0, 1).toUtc(),
      );
      expect(transactions.first.note, 'Автоплатеж "Monthly subscription"');
      expect(transactions.first.categoryId, 'cat1');

      final AccountRow account = await database
          .select(database.accounts)
          .getSingle();
      expect(account.balance, closeTo(950, 0.0001));

      final RecurringRule? updated = await repository.getRuleById('rule1');
      expect(updated, isNotNull);
      expect(updated!.lastRunAt, DateTime(2024, 2, 29, 0, 1));
      expect(updated.nextDueLocalDate, DateTime(2024, 3, 31, 0, 1));

      final String occurrenceId = sha1
          .convert(utf8.encode('rule12024-02-29'))
          .toString();
      bool executed = false;
      final bool duplicate = await repository.applyRuleOccurrence(
        rule: updated,
        occurrenceId: occurrenceId,
        occurrenceLocalDate: DateTime(2024, 2, 29, 0, 1),
        postTransaction: () async {
          executed = true;
          return null;
        },
      );
      expect(duplicate, isFalse);
      expect(executed, isFalse);

      final ApplyRecurringRulesResult secondResult = await useCase();
      expect(secondResult.applied, 0);
      expect(secondResult.skipped, 0);
      final List<TransactionRow> transactionsAfterSecondRun = await database
          .select(database.transactions)
          .get();
      expect(transactionsAfterSecondRun, hasLength(1));
    },
  );

  test('reminder mode rules не создают транзакции', () async {
    final DateTime created = DateTime.utc(2024, 1, 1);
    final RecurringRule rule = RecurringRule(
      id: 'rule-reminder',
      title: 'Напоминание об аренде',
      accountId: 'acc1',
      categoryId: 'cat1',
      amount: 800,
      currency: 'USD',
      startAt: DateTime(2024, 3, 1, 0, 1),
      timezone: 'Europe/Helsinki',
      rrule: 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=1',
      notes: null,
      dayOfMonth: 1,
      applyAtLocalHour: 0,
      applyAtLocalMinute: 1,
      lastRunAt: null,
      nextDueLocalDate: DateTime(2024, 3, 1, 0, 1),
      isActive: true,
      autoPost: false,
      reminderMinutesBefore: null,
      shortMonthPolicy: RecurringRuleShortMonthPolicy.clipToLastDay,
      createdAt: created,
      updatedAt: created,
    );
    await repository.upsertRule(rule);

    final ApplyRecurringRulesUseCase useCase = ApplyRecurringRulesUseCase(
      repository: repository,
      postTransaction: (_) async {
        fail('Не должно создаваться транзакций для режима напоминания');
      },
      clock: () => DateTime(2024, 3, 1, 8, 0),
    );

    final ApplyRecurringRulesResult result = await useCase();

    expect(result.applied, 0);
    expect(result.skipped, 0);

    final List<TransactionRow> transactions = await database
        .select(database.transactions)
        .get();
    expect(transactions, isEmpty);
  });
}
