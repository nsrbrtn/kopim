import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/database/database_factory.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/core/services/firebase_initializer.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/repositories/payment_reminders_repository_impl.dart';
import 'package:kopim/features/upcoming_payments/data/drift/repositories/upcoming_payments_repository_impl.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/recalc_upcoming_payment_uc.dart';
import 'package:kopim/l10n/app_localizations.dart';

const String kUpcomingPaymentsPeriodicTask = 'upcoming_apply_rules';
const String kUpcomingPaymentsOneOffTask = 'upcoming_apply_rules_once';

bool _isMobilePlatform() {
  if (kIsWeb) {
    return false;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    default:
      return false;
  }
}

@pragma('vm:entry-point')
Future<bool> runUpcomingPaymentsBackgroundTask(
  String task, {
  AppDatabase? database,
  NotificationsGateway? notifications,
  LoggerService? logger,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final LoggerService effectiveLogger = logger ?? LoggerService();
  await ensureFirebaseInitialized(logger: effectiveLogger);
  final AppDatabase effectiveDatabase = database ?? constructDb();
  final NotificationsGateway effectiveNotifications =
      notifications ??
      createNotificationsGateway(
        plugin: FlutterLocalNotificationsPlugin(),
        logger: effectiveLogger,
        exactAlarmPermissionService: ExactAlarmPermissionService(),
        fallbackPresenter: const NullNotificationFallbackPresenter(),
      );
  final bool ownsDatabase = database == null;
  final bool ownsNotifications = notifications == null;
  bool success = true;
  try {
    final String markPaidLabel = await _resolveReminderMarkPaidLabel();
    await _executeUpcomingPaymentsWorkflow(
      database: effectiveDatabase,
      notifications: effectiveNotifications,
      logger: effectiveLogger,
      markPaidActionLabel: markPaidLabel,
    );
  } catch (error, stackTrace) {
    success = false;
    effectiveLogger.logError(
      'Upcoming payments task failed: $error\n$stackTrace',
    );
  } finally {
    if (ownsNotifications) {
      effectiveNotifications.dispose();
    }
    if (ownsDatabase) {
      await effectiveDatabase.close();
    }
  }
  return success;
}

class UpcomingPaymentsWorkScheduler {
  UpcomingPaymentsWorkScheduler({
    required Workmanager workmanager,
    required LoggerService logger,
  }) : _workmanager = workmanager,
       _logger = logger;

  final Workmanager _workmanager;
  final LoggerService _logger;

  Future<void> scheduleDailyCatchUp() async {
    if (!_isMobilePlatform()) {
      return;
    }
    await _workmanager.registerPeriodicTask(
      kUpcomingPaymentsPeriodicTask,
      kUpcomingPaymentsPeriodicTask,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 1),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    _logger.logInfo('Scheduled upcoming payments daily catch-up');
  }

  Future<void> triggerOneOffCatchUp() async {
    if (!_isMobilePlatform()) {
      return;
    }
    final String id =
        '${kUpcomingPaymentsOneOffTask}_${DateTime.now().millisecondsSinceEpoch}';
    await _workmanager.registerOneOffTask(
      id,
      kUpcomingPaymentsOneOffTask,
      initialDelay: Duration.zero,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    _logger.logInfo('Enqueued upcoming payments catch-up task: $id');
  }
}

Future<void> _executeUpcomingPaymentsWorkflow({
  required AppDatabase database,
  required NotificationsGateway notifications,
  required LoggerService logger,
  required String markPaidActionLabel,
}) async {
  final UpcomingPaymentsDao upcomingDao = UpcomingPaymentsDao(database);
  final PaymentRemindersDao remindersDao = PaymentRemindersDao(database);
  final UpcomingPaymentsRepository upcomingRepository =
      UpcomingPaymentsRepositoryImpl(dao: upcomingDao);
  final PaymentRemindersRepository remindersRepository =
      PaymentRemindersRepositoryImpl(dao: remindersDao);

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
  final AddTransactionUseCase addTransaction = AddTransactionUseCase(
    transactionRepository: transactionRepository,
    accountRepository: accountRepository,
  );
  final ProfileEventRecorder eventRecorder = ProfileEventRecorder(
    analyticsService: const AnalyticsService(),
    loggerService: logger,
  );

  const SystemTimeService timeService = SystemTimeService();
  const SchedulePolicy policy = SchedulePolicy();
  final RecalcUpcomingPaymentUC recalcUseCase = RecalcUpcomingPaymentUC(
    repo: upcomingRepository,
    time: timeService,
    policy: policy,
  );

  final List<UpcomingPayment> payments = await upcomingDao.getAll();
  for (final UpcomingPayment payment in payments) {
    await _handleUpcomingPayment(
      payment: payment,
      addTransaction: addTransaction,
      eventRecorder: eventRecorder,
      notifications: notifications,
      recalcUseCase: recalcUseCase,
      timeService: timeService,
      logger: logger,
    );
  }

  final List<PaymentReminder> reminders = await remindersDao.getAll();
  logger.logInfo('Processing ${reminders.length} active reminders');
  int skippedDone = 0;
  for (final PaymentReminder reminder in reminders) {
    if (reminder.isDone) {
      skippedDone++;
      continue;
    }
    await _handleReminder(
      reminder: reminder,
      notifications: notifications,
      remindersRepository: remindersRepository,
      timeService: timeService,
      logger: logger,
      markPaidActionLabel: markPaidActionLabel,
    );
  }
  if (skippedDone > 0) {
    logger.logInfo('Skipped $skippedDone done reminders');
  }
}

Future<void> _handleUpcomingPayment({
  required UpcomingPayment payment,
  required AddTransactionUseCase addTransaction,
  required ProfileEventRecorder eventRecorder,
  required NotificationsGateway notifications,
  required RecalcUpcomingPaymentUC recalcUseCase,
  required TimeService timeService,
  required LoggerService logger,
}) async {
  final int notificationId = _hashId('rule_${payment.id}');
  UpcomingPayment current = payment;
  final int nowMs = timeService.nowMs();

  if (current.nextRunAtMs == null || current.nextRunAtMs! <= nowMs) {
    final int? dueMs = current.nextRunAtMs;
    if (dueMs != null && current.autoPost) {
      final DateTime dueLocal = timeService.toLocal(dueMs);
      final TransactionType type = current.amount >= 0
          ? TransactionType.expense
          : TransactionType.income;
      final AddTransactionRequest request = AddTransactionRequest(
        accountId: current.accountId,
        categoryId: current.categoryId,
        amount: current.amount.abs(),
        date: dueLocal.toUtc(),
        note: current.note?.isNotEmpty == true
            ? current.note
            : 'Автоплатёж "${current.title}"',
        type: type,
      );
      try {
        final TransactionCommandResult<TransactionEntity> result =
            await addTransaction(request);
        await eventRecorder.record(result.profileEvents);
        logger.logInfo('Автоплатёж ${current.id} обработан транзакцией');
      } catch (error) {
        logger.logError('Ошибка автоплатежа ${current.id}: $error');
      }
    }
    final UpcomingPayment? recalculated = await recalcUseCase(
      RecalcUpcomingPaymentRequest.entity(current),
    );
    if (recalculated != null) {
      current = recalculated;
    }
  }

  await notifications.cancel(notificationId);

  final tz.TZDateTime? when = _buildPaymentScheduleTime(
    payment: current,
    timeService: timeService,
  );
  if (when == null) {
    return;
  }
  await notifications.scheduleAt(
    id: notificationId,
    when: when,
    title: current.title,
    body: _paymentBody(current),
    payload: 'rule:${current.id}',
  );
  logger.logInfo('scheduled id=$notificationId for rule ${current.id}');
}

Future<String> _resolveReminderMarkPaidLabel() async {
  try {
    final Locale deviceLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    final Locale resolved = _resolveSupportedLocale(deviceLocale);
    final AppLocalizations strings = await AppLocalizations.delegate.load(
      resolved,
    );
    return strings.upcomingPaymentsReminderMarkPaidAction;
  } catch (_) {
    return 'Оплачено';
  }
}

Locale _resolveSupportedLocale(Locale locale) {
  for (final Locale supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == locale.languageCode) {
      return supported;
    }
  }
  return const Locale('ru');
}

Future<void> _handleReminder({
  required PaymentReminder reminder,
  required NotificationsGateway notifications,
  required PaymentRemindersRepository remindersRepository,
  required TimeService timeService,
  required LoggerService logger,
  required String markPaidActionLabel,
}) async {
  PaymentReminder current = reminder;
  final int notificationId = _hashId('rem_${current.id}');
  await notifications.cancel(notificationId);
  if (current.isDone) {
    return;
  }

  if (current.lastNotifiedAtMs != null &&
      current.lastNotifiedAtMs! > current.whenAtMs) {
    final int nowMs = timeService.nowMs();
    current = current.copyWith(lastNotifiedAtMs: null, updatedAtMs: nowMs);
    await remindersRepository.upsert(current);
    logger.logInfo(
      'Reset lastNotifiedAt for reminder ${current.id} due to past reschedule',
    );
  }

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  final tz.TZDateTime scheduled = tz.TZDateTime.from(
    timeService.toLocal(current.whenAtMs),
    tz.local,
  );
  if (scheduled.isAfter(now)) {
    await notifications.scheduleAt(
      id: notificationId,
      when: scheduled,
      title: current.title,
      body: _reminderBody(current),
      payload: 'reminder:${current.id}',
      androidActions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationsGateway.actionMarkReminderPaid,
          markPaidActionLabel,
        ),
      ],
    );
    logger.logInfo('scheduled id=$notificationId for reminder ${current.id}');
    return;
  }
  if (current.lastNotifiedAtMs != null &&
      current.lastNotifiedAtMs! >= current.whenAtMs) {
    logger.logInfo('Reminder ${current.id} already notified');
    return;
  }
  final tz.TZDateTime catchUpTime = tz.TZDateTime.now(
    tz.local,
  ).add(const Duration(minutes: 1));
  await notifications.scheduleAt(
    id: notificationId,
    when: catchUpTime,
    title: current.title,
    body: _reminderBody(current),
    payload: 'reminder:${current.id}',
    androidActions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        NotificationsGateway.actionMarkReminderPaid,
        markPaidActionLabel,
      ),
    ],
  );
  final int nowMs = timeService.nowMs();
  final PaymentReminder updated = current.copyWith(
    lastNotifiedAtMs: nowMs,
    updatedAtMs: nowMs,
  );
  await remindersRepository.upsert(updated);
  logger.logInfo('Reminder ${current.id} catch-up scheduled');
}

int _hashId(String value) => value.hashCode & 0x7fffffff;

tz.TZDateTime? _buildPaymentScheduleTime({
  required UpcomingPayment payment,
  required TimeService timeService,
}) {
  final int? notifyMs = payment.nextNotifyAtMs ?? payment.nextRunAtMs;
  if (notifyMs == null) {
    return null;
  }
  final DateTime local = timeService.toLocal(notifyMs);
  final tz.TZDateTime when = tz.TZDateTime.from(local, tz.local);
  if (!when.isAfter(tz.TZDateTime.now(tz.local))) {
    return null;
  }
  return when;
}

String _paymentBody(UpcomingPayment payment) {
  final String amount = payment.amount.toStringAsFixed(2);
  if (payment.note == null || payment.note!.isEmpty) {
    return 'Сумма к списанию: $amount';
  }
  return 'Сумма к списанию: $amount\n${payment.note!}';
}

String _reminderBody(PaymentReminder reminder) {
  final String amount = reminder.amount.toStringAsFixed(2);
  if (reminder.note == null || reminder.note!.isEmpty) {
    return 'Напоминание на сумму $amount';
  }
  return 'Напоминание на сумму $amount\n${reminder.note!}';
}
