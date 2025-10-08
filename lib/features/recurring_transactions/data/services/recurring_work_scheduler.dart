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
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_execution_dao.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_scheduler.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/apply_recurring_rules_use_case.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

const String kRecurringTaskGenerateWindow = 'recurring_generate_window';
const String kRecurringTaskMaintainWindow = 'recurring_window_maintenance';
const String kRecurringTaskApplyRules = 'apply_recurring_rules';

@pragma('vm:entry-point')
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
        case kRecurringTaskApplyRules:
          await _applyRecurringRules(
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

  Future<void> scheduleApplyRecurringRules() async {
    final Duration initialDelay = _timeUntilNextApplyRun();
    await _workmanager.registerPeriodicTask(
      kRecurringTaskApplyRules,
      kRecurringTaskApplyRules,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    _logger.logInfo(
      'Scheduled recurring rule application in ${initialDelay.inMinutes} minutes',
    );
  }

  Duration _timeUntilNextSixAm() {
    final DateTime now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, 6);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }

  Duration _timeUntilNextApplyRun() {
    final DateTime now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, 0, 1);
    if (!next.isAfter(now)) {
      final DateTime tomorrow = now.add(const Duration(days: 1));
      next = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 1);
    }
    return next.difference(now);
  }
}

RecurringTransactionsRepository _buildRepository(AppDatabase database) {
  final RecurringRuleDao ruleDao = RecurringRuleDao(database);
  final RecurringOccurrenceDao occurrenceDao = RecurringOccurrenceDao(database);
  final RecurringRuleExecutionDao executionDao = RecurringRuleExecutionDao(
    database,
  );
  final JobQueueDao jobQueueDao = JobQueueDao(database);
  final OutboxDao outboxDao = OutboxDao(database);
  return RecurringTransactionsRepositoryImpl(
    ruleDao: ruleDao,
    occurrenceDao: occurrenceDao,
    executionDao: executionDao,
    jobQueueDao: jobQueueDao,
    database: database,
    outboxDao: outboxDao,
  );
}

Future<void> _applyRecurringRules({
  required RecurringTransactionsRepository repository,
  required AppDatabase database,
  required LoggerService logger,
}) async {
  final OutboxDao outboxDao = OutboxDao(database);
  final AccountDao accountDao = AccountDao(database);
  final TransactionDao transactionDao = TransactionDao(database);
  final SavingGoalDao savingGoalDao = SavingGoalDao(database);
  final GoalContributionDao goalContributionDao = GoalContributionDao(database);
  final AccountRepository accountRepository = AccountRepositoryImpl(
    database: database,
    accountDao: accountDao,
    outboxDao: outboxDao,
  );
  final TransactionRepository transactionRepository = TransactionRepositoryImpl(
    database: database,
    transactionDao: transactionDao,
    savingGoalDao: savingGoalDao,
    goalContributionDao: goalContributionDao,
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
  Future<String?> postTransaction(AddTransactionRequest request) async {
    lastGeneratedId = null;
    await addTransaction(request);
    return lastGeneratedId;
  }

  final ApplyRecurringRulesUseCase applyRules = ApplyRecurringRulesUseCase(
    repository: repository,
    postTransaction: postTransaction,
    scheduler: const RecurringRuleScheduler(),
    clock: () => DateTime.now(),
  );

  final ApplyRecurringRulesResult result = await applyRules();
  logger.logInfo(
    'Recurring rules applied: ${result.applied} new, ${result.skipped} skipped',
  );
}
