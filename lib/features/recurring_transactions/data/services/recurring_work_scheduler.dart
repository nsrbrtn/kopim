import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/recurring_transactions/data/repositories/recurring_transactions_repository_impl.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_notification_service.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_window_service.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/job_queue_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_occurrence_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

const String kRecurringTaskGenerateWindow = 'recurring_generate_window';
const String kRecurringTaskMaintainWindow = 'recurring_window_maintenance';
const String kRecurringTaskPostDueOccurrences =
    'recurring_post_due_occurrences';

void recurringWorkDispatcher() {
  Workmanager().executeTask((
    String task,
    Map<String, dynamic>? inputData,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    final LoggerService logger = LoggerService();
    final AppDatabase database = AppDatabase();
    final RecurringTransactionsRepository repository = _buildRepository(
      database,
    );
    final RecurringNotificationService notificationService =
        RecurringNotificationService(FlutterLocalNotificationsPlugin());
    final RecurringWindowService windowService = RecurringWindowService(
      repository: repository,
      engine: RecurringRuleEngine(),
      notificationService: notificationService,
    );
    bool success = true;
    try {
      switch (task) {
        case kRecurringTaskGenerateWindow:
        case kRecurringTaskMaintainWindow:
          await windowService.rebuildWindow();
          break;
        case kRecurringTaskPostDueOccurrences:
          await _postDueOccurrences(
            repository: repository,
            database: database,
            logger: logger,
          );
          break;
        default:
          logger.logInfo('Unhandled WorkManager task: $task');
      }
    } catch (error, stackTrace) {
      success = false;
      logger.logError('Recurring task failed: $error\n$stackTrace');
    }
    await database.close();
    return success;
  });
}

class RecurringWorkScheduler {
  RecurringWorkScheduler({
    required Workmanager workmanager,
    required LoggerService logger,
  }) : _workmanager = workmanager,
       _logger = logger;

  final Workmanager _workmanager;
  final LoggerService _logger;

  Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _workmanager.initialize(recurringWorkDispatcher);
    }
  }

  Future<void> scheduleDailyWindowGeneration() async {
    final Duration initialDelay = _timeUntilNextSixAm();
    await _workmanager.registerOneOffTask(
      kRecurringTaskGenerateWindow,
      kRecurringTaskGenerateWindow,
      initialDelay: initialDelay,
      constraints: Constraints(networkType: NetworkType.notRequired),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
    );
    _logger.logInfo(
      'Scheduled window generation in ${initialDelay.inMinutes} minutes',
    );
  }

  Future<void> scheduleMaintenance() async {
    await _workmanager.registerPeriodicTask(
      kRecurringTaskMaintainWindow,
      kRecurringTaskMaintainWindow,
      frequency: const Duration(hours: 24),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    _logger.logInfo('Scheduled recurring window maintenance');
  }

  Future<void> scheduleDuePostings() async {
    await _workmanager.registerPeriodicTask(
      kRecurringTaskPostDueOccurrences,
      kRecurringTaskPostDueOccurrences,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 1),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    _logger.logInfo('Scheduled daily auto-posting job');
  }

  Duration _timeUntilNextSixAm() {
    final DateTime now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, 6);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }
}

RecurringTransactionsRepository _buildRepository(AppDatabase database) {
  final RecurringRuleDao ruleDao = RecurringRuleDao(database);
  final RecurringOccurrenceDao occurrenceDao = RecurringOccurrenceDao(database);
  final JobQueueDao jobQueueDao = JobQueueDao(database);
  return RecurringTransactionsRepositoryImpl(
    ruleDao: ruleDao,
    occurrenceDao: occurrenceDao,
    jobQueueDao: jobQueueDao,
    database: database,
  );
}

Future<void> _postDueOccurrences({
  required RecurringTransactionsRepository repository,
  required AppDatabase database,
  required LoggerService logger,
}) async {
  final DateTime today = DateTime.now();
  final List<RecurringOccurrence> dueOccurrences = await repository
      .getDueOccurrences(today);
  if (dueOccurrences.isEmpty) {
    return;
  }
  final OutboxDao outboxDao = OutboxDao(database);
  final AccountDao accountDao = AccountDao(database);
  final TransactionDao transactionDao = TransactionDao(database);
  final AccountRepository accountRepository = AccountRepositoryImpl(
    database: database,
    accountDao: accountDao,
    outboxDao: outboxDao,
  );
  final TransactionRepository transactionRepository = TransactionRepositoryImpl(
    database: database,
    transactionDao: transactionDao,
    outboxDao: outboxDao,
  );
  String? lastGeneratedId;
  final AddTransactionUseCase addTransaction = AddTransactionUseCase(
    transactionRepository: transactionRepository,
    accountRepository: accountRepository,
    idGenerator: () {
      final String generated = const Uuid().v4();
      lastGeneratedId = generated;
      return generated;
    },
    clock: () => DateTime.now().toUtc(),
  );
  for (final RecurringOccurrence occurrence in dueOccurrences) {
    final RecurringRule? rule = await repository.getRuleById(occurrence.ruleId);
    if (rule == null || !rule.autoPost) {
      continue;
    }
    final TransactionType type = rule.amount >= 0
        ? TransactionType.expense
        : TransactionType.income;
    final AddTransactionRequest request = AddTransactionRequest(
      accountId: rule.accountId,
      amount: rule.amount.abs(),
      date: occurrence.dueAt,
      note: rule.notes,
      type: type,
    );
    try {
      lastGeneratedId = null;
      await addTransaction(request);
      await repository.updateOccurrenceStatus(
        occurrence.id,
        RecurringOccurrenceStatus.posted,
        postedTxId: lastGeneratedId,
      );
    } catch (error, stackTrace) {
      logger.logError(
        'Failed to auto-post occurrence ${occurrence.id}: $error\n$stackTrace',
      );
      await repository.updateOccurrenceStatus(
        occurrence.id,
        RecurringOccurrenceStatus.failed,
      );
    }
  }
}
