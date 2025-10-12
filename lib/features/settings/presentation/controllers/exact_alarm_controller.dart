import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notifications_service.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';

part 'exact_alarm_controller.g.dart';

@Riverpod(keepAlive: true)
class ExactAlarmController extends _$ExactAlarmController {
  bool _isRequesting = false;

  @override
  Future<bool> build() async {
    final NotificationsService service = ref.watch(
      notificationsServiceProvider,
    );
    return service.canScheduleExact();
  }

  Future<void> refresh() async {
    state = const AsyncValue<bool>.loading();
    state = await AsyncValue.guard<bool>(() async {
      final NotificationsService service = ref.read(
        notificationsServiceProvider,
      );
      return service.canScheduleExact();
    });
  }

  Future<void> request() async {
    if (_isRequesting) {
      return;
    }
    _isRequesting = true;
    final NotificationsService service = ref.read(notificationsServiceProvider);
    final LoggerService logger = ref.read(loggerServiceProvider);
    try {
      await service.openExactAlarmsSettings();
      await Future<void>.delayed(const Duration(seconds: 1));
      await refresh();
      final bool enabled = state.maybeWhen(
        data: (bool value) => value,
        orElse: () => false,
      );
      if (enabled) {
        logger.logInfo('Точные напоминания включены, запускаем пересоздание.');
        await ref
            .read(upcomingNotificationsControllerProvider.notifier)
            .rescheduleAll();
      }
    } catch (error, stackTrace) {
      state = AsyncValue<bool>.error(error, stackTrace);
      logger.logError(
        'Ошибка при запросе точных напоминаний: $error\n$stackTrace',
      );
    } finally {
      _isRequesting = false;
    }
  }
}
