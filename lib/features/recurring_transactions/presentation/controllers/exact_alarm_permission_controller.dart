import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/exact_alarm_permission_service.dart';

part 'exact_alarm_permission_controller.g.dart';

@Riverpod(keepAlive: true)
class ExactAlarmPermissionController extends _$ExactAlarmPermissionController {
  late final ExactAlarmPermissionService _service;

  @override
  FutureOr<bool> build() async {
    _service = ref.watch(exactAlarmPermissionServiceProvider);
    return _service.canScheduleExactAlarms();
  }

  Future<void> refresh() async {
    await _updateStateFromService();
  }

  Future<void> openSettings() async {
    final bool started = await _service.openExactAlarmsSettings();
    if (!started) {
      return;
    }
    // Give the system time to update the permission state after returning.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!ref.mounted) {
      return;
    }
    await _updateStateFromService();
  }

  Future<void> _updateStateFromService() async {
    if (!ref.mounted) {
      return;
    }
    try {
      final bool granted = await _service.canScheduleExactAlarms();
      if (!ref.mounted) {
        return;
      }
      state = AsyncValue<bool>.data(granted);
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return;
      }
      state = AsyncValue<bool>.error(error, stackTrace);
    }
  }
}
