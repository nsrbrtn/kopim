import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';
import 'package:kopim/core/services/push_permission_service.dart';

import 'notifications_gateway.dart';

NotificationsGateway createNotificationsGateway({
  FlutterLocalNotificationsPlugin? plugin,
  LoggerService? logger,
  ExactAlarmPermissionService? exactAlarmPermissionService,
  NotificationFallbackPresenter? fallbackPresenter,
  PushPermissionService? pushPermissionService,
}) {
  return WebNotificationsGateway(
    logger: logger ?? LoggerService(),
    fallbackPresenter:
        fallbackPresenter ?? const NullNotificationFallbackPresenter(),
    pushPermissionService:
        pushPermissionService ?? createPushPermissionService(),
  );
}

class WebNotificationsGateway implements NotificationsGateway {
  WebNotificationsGateway({
    required LoggerService logger,
    required NotificationFallbackPresenter fallbackPresenter,
    required PushPermissionService pushPermissionService,
  }) : _logger = logger,
       _fallbackPresenter = fallbackPresenter,
       _pushPermissionService = pushPermissionService,
       _responsesController =
           StreamController<NotificationResponse>.broadcast();

  final LoggerService _logger;
  final NotificationFallbackPresenter _fallbackPresenter;
  final PushPermissionService _pushPermissionService;
  final StreamController<NotificationResponse> _responsesController;
  final Map<int, Timer> _timers = <int, Timer>{};
  bool _permissionGranted = false;
  bool _initialized = false;

  @override
  Stream<NotificationResponse> get responses => _responsesController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _permissionGranted = await _pushPermissionService.ensurePermission();
    _initialized = true;
    _logger.logInfo(
      'Web notifications initialized (granted=$_permissionGranted)',
    );
  }

  @override
  Future<void> ensurePermission() async {
    _permissionGranted = await _pushPermissionService.ensurePermission();
    _logger.logInfo('Web notifications permission: $_permissionGranted');
  }

  @override
  Future<bool> canScheduleExact() async => false;

  @override
  Future<bool> openExactAlarmsSettings() async => false;

  @override
  Future<void> scheduleAt({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
    String? payload,
    List<AndroidNotificationAction>? androidActions,
  }) async {
    final bool allowed = await _pushPermissionService.ensurePermission(
      requestIfNeeded: false,
    );
    _permissionGranted = allowed;
    if (!_permissionGranted) {
      _logger.logInfo('Web notifications skip id=$id: permission not granted');
      return;
    }
    _timers.remove(id)?.cancel();
    final DateTime now = DateTime.now();
    Duration delay = when.toLocal().difference(now);
    if (delay.isNegative) {
      delay = Duration.zero;
    }
    if (delay == Duration.zero) {
      _fallbackPresenter.show(
        NotificationFallbackEvent(title: title, body: body),
      );
      _logger.logInfo('Web fallback notification triggered id=$id immediately');
      return;
    }
    _timers[id] = Timer(delay, () {
      _fallbackPresenter.show(
        NotificationFallbackEvent(title: title, body: body),
      );
      _timers.remove(id);
      _logger.logInfo(
        'Web fallback notification triggered id=$id delay=${delay.inSeconds}s',
      );
    });
  }

  @override
  Future<void> cancel(int id) async {
    _timers.remove(id)?.cancel();
    _logger.logInfo('Web notifications cancelled timer id=$id');
  }

  @override
  Future<void> cancelAll() async {
    for (final Timer timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _logger.logInfo('Web notifications cleared all timers');
  }

  @override
  void dispose() {
    for (final Timer timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _responsesController.close();
  }

  @override
  Future<void> showTestNotification() async {
    await ensurePermission();
    if (!_permissionGranted) {
      return;
    }
    await scheduleAt(
      id: 0x54E57,
      when: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
      title: 'Проверка уведомлений (Web)',
      body: 'Уведомление появится внутри приложения',
      payload: 'test',
    );
  }
}
