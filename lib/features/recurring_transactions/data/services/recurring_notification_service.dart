import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class RecurringNotificationService {
  RecurringNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const int _maxNotifications = 3;
  static const int _notificationBaseId = 4100;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> ensurePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation == null) {
      return false;
    }
    final bool? granted = await androidImplementation
        .requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> refreshNotifications({
    required Iterable<RecurringOccurrence> occurrences,
    required Map<String, RecurringRule> rules,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    final bool permissionGranted = await ensurePermissions();
    if (!permissionGranted) {
      return;
    }

    for (int i = 0; i < _maxNotifications; i++) {
      await _plugin.cancel(_notificationBaseId + i);
    }

    final DateTime now = DateTime.now().toUtc();
    final List<RecurringOccurrence> upcoming =
        occurrences
            .where(
              (RecurringOccurrence occurrence) =>
                  occurrence.status == RecurringOccurrenceStatus.scheduled &&
                  occurrence.dueAt.isAfter(now),
            )
            .toList()
          ..sort(
            (RecurringOccurrence a, RecurringOccurrence b) =>
                a.dueAt.compareTo(b.dueAt),
          );

    for (
      int index = 0;
      index < upcoming.length && index < _maxNotifications;
      index++
    ) {
      final RecurringOccurrence occurrence = upcoming[index];
      final RecurringRule? rule = rules[occurrence.ruleId];
      if (rule == null) {
        continue;
      }
      final tz.Location location = tz.getLocation(rule.timezone);
      final Duration reminderOffset = Duration(
        minutes: rule.reminderMinutesBefore ?? 0,
      );
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        occurrence.dueAt,
        location,
      ).subtract(reminderOffset);
      if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
        continue;
      }
      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_reminders',
          'Напоминания о платежах',
          channelDescription: 'Напоминания о платежах',
          category: AndroidNotificationCategory.reminder,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        _notificationBaseId + index,
        rule.title,
        _buildBody(rule),
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: occurrence.id,
        matchDateTimeComponents: null,
      );
    }
  }

  String _buildBody(RecurringRule rule) {
    final String amount = rule.amount.toStringAsFixed(2);
    return 'Списание $amount ${rule.currency} по счёту ${rule.accountId}';
  }
}
