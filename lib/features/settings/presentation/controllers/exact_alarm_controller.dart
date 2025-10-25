import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/features/upcoming_payments/application/upcoming_notifications_controller.dart';

part 'exact_alarm_controller.g.dart';

@Riverpod(keepAlive: true)
class ExactAlarmController extends _$ExactAlarmController {
  bool _isRequesting = false;
  bool? _lastKnownValue;

  @override
  Future<bool> build() async {
    final NotificationsGateway service = ref.watch(
      notificationsGatewayProvider,
    );
    final bool canSchedule = await service.canScheduleExact();
    _lastKnownValue = canSchedule;
    return canSchedule;
  }

  Future<void> refresh() async {
    final bool? previousValue = state.asData?.value ?? _lastKnownValue;
    state = const AsyncValue<bool>.loading();
    final AsyncValue<bool> result = await AsyncValue.guard<bool>(() async {
      final NotificationsGateway service = ref.read(
        notificationsGatewayProvider,
      );
      return service.canScheduleExact();
    });
    state = result;

    final bool? currentValue = result.asData?.value;
    if (currentValue != null) {
      final bool shouldReschedule = currentValue && previousValue != true;
      _lastKnownValue = currentValue;
      if (shouldReschedule) {
        final LoggerService logger = ref.read(loggerServiceProvider);
        logger.logInfo('Точные напоминания включены, пересоздаем расписание.');
        await ref
            .read(upcomingNotificationsControllerProvider.notifier)
            .rescheduleAll();
      }
    }
  }

  Future<bool> request() async {
    if (_isRequesting) {
      return false;
    }
    _isRequesting = true;
    final NotificationsGateway service = ref.read(notificationsGatewayProvider);
    final LoggerService logger = ref.read(loggerServiceProvider);
    try {
      final bool launched = await service.openExactAlarmsSettings();
      await refresh();
      return launched;
    } catch (error, stackTrace) {
      state = AsyncValue<bool>.error(error, stackTrace);
      logger.logError(
        'Ошибка при запросе точных напоминаний: $error\n$stackTrace',
      );
      return false;
    } finally {
      _isRequesting = false;
    }
  }
}
