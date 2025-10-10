import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notifications_service.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

part 'upcoming_notifications_controller.g.dart';

@Riverpod(keepAlive: true)
class UpcomingNotificationsController
    extends _$UpcomingNotificationsController {
  ProviderSubscription<AsyncValue<List<UpcomingPayment>>>? _paymentsSub;
  ProviderSubscription<AsyncValue<List<PaymentReminder>>>? _remindersSub;
  final Set<int> _activePaymentIds = <int>{};
  final Set<int> _activeReminderIds = <int>{};

  @override
  Future<void> build() async {
    final NotificationsService notifications = ref.read(
      notificationsServiceProvider,
    );
    final LoggerService logger = ref.read(loggerServiceProvider);
    final TimeService timeService = ref.read(timeServiceProvider);

    List<UpcomingPayment> initialPayments = const <UpcomingPayment>[];
    try {
      initialPayments = await ref.watch(watchUpcomingPaymentsProvider.future);
    } on Object catch (error, stackTrace) {
      logger.logError('Ошибка потока правил платежей: $error\n$stackTrace');
    }
    await _syncPaymentNotifications(
      notifications: notifications,
      logger: logger,
      timeService: timeService,
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
                notifications: notifications,
                logger: logger,
                timeService: timeService,
                payments: payments,
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) {
            logger.logError(
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
      logger.logError('Ошибка потока напоминаний: $error\n$stackTrace');
    }
    await _syncReminderNotifications(
      notifications: notifications,
      logger: logger,
      timeService: timeService,
      reminders: initialReminders,
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
                notifications: notifications,
                logger: logger,
                timeService: timeService,
                reminders: reminders,
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) {
            logger.logError('Ошибка потока напоминаний: $error\n$stackTrace');
          },
          loading: () {},
        );
      },
      fireImmediately: false,
    );

    ref.onDispose(() {
      _paymentsSub?.close();
      _remindersSub?.close();
      _activePaymentIds.clear();
      _activeReminderIds.clear();
    });
  }

  Future<void> _syncPaymentNotifications({
    required NotificationsService notifications,
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
    required NotificationsService notifications,
    required LoggerService logger,
    required TimeService timeService,
    required List<PaymentReminder> reminders,
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
