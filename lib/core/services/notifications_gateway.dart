import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';
import 'package:kopim/core/services/push_permission_service.dart';

import 'notifications_gateway_mobile.dart'
    if (dart.library.js) 'notifications_gateway_web.dart'
    as implementation;

/// Контракт работы с платформенными уведомлениями и фолбэками.
abstract class NotificationsGateway {
  const NotificationsGateway();

  static const String channelId = 'payments_due';
  static const String channelName = 'Предстоящие платежи';
  static const String channelDescription =
      'Уведомления о предстоящих и повторяющихся платежах';
  static const String actionMarkReminderPaid = 'mark_reminder_paid';

  Stream<NotificationResponse> get responses;

  Future<void> initialize();

  Future<void> ensurePermission();

  Future<bool> canScheduleExact();

  Future<bool> openExactAlarmsSettings();

  Future<void> scheduleAt({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
    String? payload,
    List<AndroidNotificationAction>? androidActions,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  void dispose();

  Future<void> showTestNotification();
}

NotificationsGateway createNotificationsGateway({
  FlutterLocalNotificationsPlugin? plugin,
  LoggerService? logger,
  ExactAlarmPermissionService? exactAlarmPermissionService,
  NotificationFallbackPresenter? fallbackPresenter,
  PushPermissionService? pushPermissionService,
}) {
  return implementation.createNotificationsGateway(
    plugin: plugin,
    logger: logger,
    exactAlarmPermissionService: exactAlarmPermissionService,
    fallbackPresenter: fallbackPresenter,
    pushPermissionService: pushPermissionService,
  );
}
