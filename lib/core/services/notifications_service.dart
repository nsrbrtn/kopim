import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/utils/timezone_utils.dart';

class NotificationsService {
  NotificationsService({
    FlutterLocalNotificationsPlugin? plugin,
    LoggerService? logger,
    ExactAlarmPermissionService? exactAlarmPermissionService,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _logger = logger ?? LoggerService(),
       _exactAlarmPermissionService =
           exactAlarmPermissionService ?? ExactAlarmPermissionService();

  static const String _channelId = 'payments_due';
  static const String _channelName = 'Предстоящие платежи';
  static const String _channelDescription =
      'Уведомления о предстоящих и повторяющихся платежах';
  static const String actionMarkReminderPaid = 'mark_reminder_paid';

  final FlutterLocalNotificationsPlugin _plugin;
  final LoggerService _logger;
  final ExactAlarmPermissionService _exactAlarmPermissionService;
  final StreamController<NotificationResponse> _responsesController =
      StreamController<NotificationResponse>.broadcast();

  bool _initialized = false;
  bool? _permissionGranted;

  Stream<NotificationResponse> get responses => _responsesController.stream;

  Future<void> initialize() async {
    await _ensureInitialized();
  }

  Future<void> ensurePermission() async {
    await _resolvePermission(requestIfNeeded: true);
  }

  Future<bool> canScheduleExact() async {
    return _exactAlarmPermissionService.canScheduleExactAlarms();
  }

  Future<void> openExactAlarmsSettings() async {
    await _exactAlarmPermissionService.openExactAlarmsSettings();
  }

  Future<void> scheduleAt({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
    String? payload,
    List<AndroidNotificationAction>? androidActions,
  }) async {
    await _ensureInitialized();
    final bool hasPermission = await _resolvePermission(
      requestIfNeeded: false,
      forceRefresh: true,
    );
    if (!hasPermission) {
      _logger.logInfo(
        'Notifications permission denied, skip scheduling id=$id',
      );
      return;
    }

    final tz.TZDateTime now = tz.TZDateTime.now(when.location);
    if (!when.isAfter(now)) {
      _logger.logInfo(
        'Skip scheduling id=$id because time ${when.toIso8601String()} is not in the future',
      );
      return;
    }

    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      final bool exactEnabled = await canScheduleExact();
      androidScheduleMode = exactEnabled
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact;
      if (!exactEnabled) {
        _logger.logInfo('exact alarm unavailable, id=$id fallback to inexact');
      }
    }

    try {
      final NotificationDetails details = _buildNotificationDetails(
        androidActions: androidActions,
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: androidScheduleMode,
        payload: payload,
        matchDateTimeComponents: null,
      );
      _logger.logInfo('scheduled id=$id at ${when.toIso8601String()}');
    } catch (error) {
      _logger.logError('Failed to schedule notification id=$id', error);
    }
  }

  Future<void> cancel(int id) async {
    await _ensureInitialized();
    try {
      await _plugin.cancel(id);
      _logger.logInfo('cancelled id=$id');
    } catch (error) {
      _logger.logError('Failed to cancel notification id=$id', error);
    }
  }

  Future<void> cancelAll() async {
    await _ensureInitialized();
    try {
      await _plugin.cancelAll();
      _logger.logInfo('cancelled all notifications');
    } catch (error) {
      _logger.logError('Failed to cancel all notifications', error);
    }
  }

  void dispose() {
    if (!_responsesController.isClosed) {
      _responsesController.close();
    }
  }

  Future<void> showTestNotification() async {
    await _ensureInitialized();
    final bool hasPermission = await _resolvePermission(
      requestIfNeeded: true,
      forceRefresh: true,
    );
    if (!hasPermission) {
      _logger.logInfo('Test notification skipped: permission denied');
      return;
    }

    final bool allowExact = !Platform.isAndroid || await canScheduleExact();
    if (!allowExact && Platform.isAndroid) {
      try {
        await _plugin.show(
          0x54E57,
          'Проверка уведомлений',
          'Тестовое напоминание отправлено из настроек',
          _buildNotificationDetails(),
          payload: 'test',
        );
        _logger.logInfo('Test notification shown immediately (fallback)');
      } catch (error) {
        _logger.logError('Failed to show fallback test notification', error);
      }
      return;
    }
    final tz.TZDateTime when = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 5));
    await scheduleAt(
      id: 0x54E57,
      when: when,
      title: 'Проверка уведомлений',
      body: 'Тестовое напоминание отправлено из настроек',
      payload: 'test',
    );
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final String timeZoneId = resolveCurrentTimeZoneId();
    tz.setLocalLocation(tz.getLocation(timeZoneId));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (!_responsesController.isClosed) {
          _responsesController.add(response);
        }
      },
    );

    final NotificationAppLaunchDetails? launchDetails = await _plugin
        .getNotificationAppLaunchDetails();
    final NotificationResponse? initialResponse =
        launchDetails?.notificationResponse;
    if (initialResponse != null && !_responsesController.isClosed) {
      _responsesController.add(initialResponse);
    }

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );
      await androidImplementation.createNotificationChannel(channel);
    }
    _initialized = true;
    _logger.logInfo('Notifications initialized with tz=$timeZoneId');
  }

  Future<bool> _resolvePermission({
    required bool requestIfNeeded,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _permissionGranted != null) {
      return _permissionGranted!;
    }
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      _permissionGranted = true;
      return true;
    }

    bool granted = true;
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation == null) {
        _permissionGranted = false;
        return false;
      }
      final bool? current = await androidImplementation
          .areNotificationsEnabled();
      granted = current ?? false;
      if (!granted && requestIfNeeded) {
        final bool? requested = await androidImplementation
            .requestNotificationsPermission();
        granted = requested ?? false;
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      if (requestIfNeeded) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final MacOSFlutterLocalNotificationsPlugin? macImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        bool anyGranted = false;
        if (iosImplementation != null) {
          final bool? result = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          anyGranted = anyGranted || (result ?? false);
        }
        if (macImplementation != null) {
          final bool? result = await macImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          anyGranted = anyGranted || (result ?? false);
        }
        granted = anyGranted || granted;
      } else {
        granted = _permissionGranted ?? true;
      }
    }

    _permissionGranted = granted;
    _logger.logInfo('permission: ${granted ? 'granted' : 'denied'}');
    return granted;
  }

  NotificationDetails _buildNotificationDetails({
    List<AndroidNotificationAction>? androidActions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        actions: androidActions,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
  }
}
