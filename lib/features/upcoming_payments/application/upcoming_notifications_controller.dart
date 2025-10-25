import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/mark_reminder_done_uc.dart';
import 'package:kopim/l10n/app_localizations.dart';

part 'upcoming_notifications_controller.g.dart';

@Riverpod(keepAlive: true)
class UpcomingNotificationsController
    extends _$UpcomingNotificationsController {
  ProviderSubscription<AsyncValue<List<UpcomingPayment>>>? _paymentsSub;
  ProviderSubscription<AsyncValue<List<PaymentReminder>>>? _remindersSub;
  StreamSubscription<NotificationResponse>? _responsesSub;
  final Set<int> _activePaymentIds = <int>{};
  final Set<int> _activeReminderIds = <int>{};
  late NotificationsGateway _notifications;
  late LoggerService _logger;
  late TimeService _timeService;
  late AppLocalizations _strings;
  bool _ready = false;

  @override
  Future<void> build() async {
    _notifications = ref.read(notificationsGatewayProvider);
    _logger = ref.read(loggerServiceProvider);
    _timeService = ref.read(timeServiceProvider);
    final Locale locale = ref.watch(appLocaleProvider);
    _strings = await AppLocalizations.delegate.load(locale);

    await _responsesSub?.cancel();
    _responsesSub = _notifications.responses.listen((
      NotificationResponse response,
    ) {
      unawaited(handleNotificationResponse(response));
    });

    try {
      await _notifications.ensurePermission();
    } catch (error, stackTrace) {
      _logger.logError(
        'Не удалось запросить разрешение на уведомления: $error\n$stackTrace',
      );
    }

    List<UpcomingPayment> initialPayments = const <UpcomingPayment>[];
    try {
      initialPayments = await ref.watch(watchUpcomingPaymentsProvider.future);
    } on Object catch (error, stackTrace) {
      _logger.logError('Ошибка потока правил платежей: $error\n$stackTrace');
    }
    await _syncPaymentNotifications(
      notifications: _notifications,
      logger: _logger,
      timeService: _timeService,
      payments: initialPayments,
    );

    _paymentsSub = ref.listen<AsyncValue<List<UpcomingPayment>>>(
      watchUpcomingPaymentsProvider,
      (
        AsyncValue<List<UpcomingPayment>>? previous,
        AsyncValue<List<UpcomingPayment>> next,
      ) {
        next.when(
          data: (List<UpcomingPayment> payments) {
            unawaited(
              _syncPaymentNotifications(
                notifications: _notifications,
                logger: _logger,
                timeService: _timeService,
                payments: payments,
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) {
            _logger.logError(
              'Ошибка потока правил платежей: $error\n$stackTrace',
            );
          },
          loading: () {},
        );
      },
      fireImmediately: false,
    );

    List<PaymentReminder> initialReminders = const <PaymentReminder>[];
    try {
      initialReminders = await ref.watch(
        watchPaymentRemindersProvider(limit: null).future,
      );
    } on Object catch (error, stackTrace) {
      _logger.logError('Ошибка потока напоминаний: $error\n$stackTrace');
    }
    await _syncReminderNotifications(
      notifications: _notifications,
      logger: _logger,
      timeService: _timeService,
      reminders: initialReminders,
      markPaidLabel: _strings.upcomingPaymentsReminderMarkPaidAction,
    );

    _remindersSub = ref.listen<AsyncValue<List<PaymentReminder>>>(
      watchPaymentRemindersProvider(limit: null),
      (
        AsyncValue<List<PaymentReminder>>? previous,
        AsyncValue<List<PaymentReminder>> next,
      ) {
        next.when(
          data: (List<PaymentReminder> reminders) {
            unawaited(
              _syncReminderNotifications(
                notifications: _notifications,
                logger: _logger,
                timeService: _timeService,
                reminders: reminders,
                markPaidLabel: _strings.upcomingPaymentsReminderMarkPaidAction,
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) {
            _logger.logError('Ошибка потока напоминаний: $error\n$stackTrace');
          },
          loading: () {},
        );
      },
      fireImmediately: false,
    );

    ref.onDispose(() {
      _paymentsSub?.close();
      _remindersSub?.close();
      unawaited(_responsesSub?.cancel());
      _responsesSub = null;
      _activePaymentIds.clear();
      _activeReminderIds.clear();
      _ready = false;
    });

    _ready = true;
  }

  Future<void> rescheduleAll() async {
    if (!_ready) {
      return;
    }
    try {
      final List<UpcomingPayment> payments = await ref.read(
        watchUpcomingPaymentsProvider.future,
      );
      await _syncPaymentNotifications(
        notifications: _notifications,
        logger: _logger,
        timeService: _timeService,
        payments: payments,
      );

      final List<PaymentReminder> reminders = await ref.read(
        watchPaymentRemindersProvider(limit: null).future,
      );
      await _syncReminderNotifications(
        notifications: _notifications,
        logger: _logger,
        timeService: _timeService,
        reminders: reminders,
        markPaidLabel: _strings.upcomingPaymentsReminderMarkPaidAction,
      );
      _logger.logInfo('Пересоздали напоминания с учётом точных алармов');
    } on Object catch (error, stackTrace) {
      _logger.logError(
        'Не удалось пересоздать напоминания: $error\n$stackTrace',
      );
    }
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    if (response.actionId != NotificationsGateway.actionMarkReminderPaid) {
      return;
    }
    final String? payload = response.payload;
    if (payload == null || !payload.startsWith('reminder:')) {
      return;
    }
    final String reminderId = payload.substring('reminder:'.length);
    if (reminderId.isEmpty) {
      return;
    }
    try {
      final MarkReminderDoneUC markDone = ref.read(markReminderDoneUCProvider);
      await markDone(MarkReminderDoneInput(id: reminderId, isDone: true));
      _logger.logInfo(
        'Reminder $reminderId marked as done from notification action',
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'Failed to mark reminder done from notification action: '
        '$error\n$stackTrace',
      );
    }
  }

  Future<void> _syncPaymentNotifications({
    required NotificationsGateway notifications,
    required LoggerService logger,
    required TimeService timeService,
    required List<UpcomingPayment> payments,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final Set<int> currentIds = <int>{};
    for (final UpcomingPayment payment in payments) {
      final int notificationId = _hashId('rule_${payment.id}');
      currentIds.add(notificationId);
      final tz.TZDateTime? when = _resolvePaymentWhen(
        payment: payment,
        timeService: timeService,
        now: now,
      );
      if (when == null) {
        await notifications.cancel(notificationId);
        continue;
      }
      await notifications.scheduleAt(
        id: notificationId,
        when: when,
        title: payment.title,
        body: _buildPaymentBody(payment),
        payload: 'rule:${payment.id}',
      );
    }

    for (final int id in _activePaymentIds.difference(currentIds)) {
      await notifications.cancel(id);
    }

    _activePaymentIds
      ..clear()
      ..addAll(currentIds);
  }

  Future<void> _syncReminderNotifications({
    required NotificationsGateway notifications,
    required LoggerService logger,
    required TimeService timeService,
    required List<PaymentReminder> reminders,
    required String markPaidLabel,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final Set<int> currentIds = <int>{};
    for (final PaymentReminder reminder in reminders) {
      if (reminder.isDone) {
        final int id = _hashId('rem_${reminder.id}');
        await notifications.cancel(id);
        continue;
      }
      final int notificationId = _hashId('rem_${reminder.id}');
      currentIds.add(notificationId);
      final tz.TZDateTime? when = _resolveReminderWhen(
        reminder: reminder,
        timeService: timeService,
        now: now,
      );
      if (when == null) {
        await notifications.cancel(notificationId);
        continue;
      }
      await notifications.scheduleAt(
        id: notificationId,
        when: when,
        title: reminder.title,
        body: _buildReminderBody(reminder),
        payload: 'reminder:${reminder.id}',
        androidActions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            NotificationsGateway.actionMarkReminderPaid,
            markPaidLabel,
          ),
        ],
      );
    }

    for (final int id in _activeReminderIds.difference(currentIds)) {
      await notifications.cancel(id);
    }

    _activeReminderIds
      ..clear()
      ..addAll(currentIds);
  }

  tz.TZDateTime? _resolvePaymentWhen({
    required UpcomingPayment payment,
    required TimeService timeService,
    required tz.TZDateTime now,
  }) {
    final int? targetMs = payment.nextNotifyAtMs ?? payment.nextRunAtMs;
    if (targetMs == null) {
      return null;
    }
    final DateTime local = timeService.toLocal(targetMs);
    final tz.TZDateTime when = tz.TZDateTime.from(local, tz.local);
    if (!when.isAfter(now)) {
      return null;
    }
    return when;
  }

  tz.TZDateTime? _resolveReminderWhen({
    required PaymentReminder reminder,
    required TimeService timeService,
    required tz.TZDateTime now,
  }) {
    final DateTime local = timeService.toLocal(reminder.whenAtMs);
    final tz.TZDateTime when = tz.TZDateTime.from(local, tz.local);
    if (!when.isAfter(now)) {
      return null;
    }
    return when;
  }

  String _buildPaymentBody(UpcomingPayment payment) {
    final String amount = payment.amount.toStringAsFixed(2);
    if (payment.note == null || payment.note!.isEmpty) {
      return 'Сумма к списанию: $amount';
    }
    return 'Сумма к списанию: $amount\n${payment.note!}';
  }

  String _buildReminderBody(PaymentReminder reminder) {
    final String amount = reminder.amount.toStringAsFixed(2);
    if (reminder.note == null || reminder.note!.isEmpty) {
      return 'Напоминание на сумму $amount';
    }
    return 'Напоминание на сумму $amount\n${reminder.note!}';
  }

  int _hashId(String value) => value.hashCode & 0x7fffffff;
}
