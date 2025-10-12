import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/exact_alarm_permission_service.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/exact_alarm_permission_controller.dart';
import 'package:riverpod/riverpod.dart' as rp;

void main() {
  group('ExactAlarmPermissionController', () {
    test('build resolves permission status from service', () async {
      final _FakeExactAlarmPermissionService fakeService =
          _FakeExactAlarmPermissionService(
            canScheduleResponses: Queue<bool>.from(<bool>[true]),
            openResult: true,
          );
      final rp.ProviderContainer container = rp.ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          exactAlarmPermissionServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final bool granted = await container.read(
        exactAlarmPermissionControllerProvider.future,
      );

      expect(granted, isTrue);
      expect(fakeService.canScheduleInvocations, 1);
    });

    test('openSettings refreshes permission value', () async {
      final _FakeExactAlarmPermissionService fakeService =
          _FakeExactAlarmPermissionService(
            canScheduleResponses: Queue<bool>.from(<bool>[false, true]),
            openResult: true,
          );
      final rp.ProviderContainer container = rp.ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          exactAlarmPermissionServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final ExactAlarmPermissionController controller = container.read(
        exactAlarmPermissionControllerProvider.notifier,
      );
      final bool initial = await container.read(
        exactAlarmPermissionControllerProvider.future,
      );
      expect(initial, isFalse);

      await controller.openSettings();

      final rp.AsyncValue<bool> updated = container.read(
        exactAlarmPermissionControllerProvider,
      );
      expect(updated, const rp.AsyncValue<bool>.data(true));
      expect(fakeService.openInvocations, 1);
      expect(fakeService.canScheduleInvocations, 2);
    });
  });
}

class _FakeExactAlarmPermissionService extends ExactAlarmPermissionService {
  _FakeExactAlarmPermissionService({
    required this.canScheduleResponses,
    required this.openResult,
  }) : super(channel: const MethodChannelStub());

  final Queue<bool> canScheduleResponses;
  final bool openResult;
  int canScheduleInvocations = 0;
  int openInvocations = 0;

  @override
  Future<bool> canScheduleExactAlarms() async {
    canScheduleInvocations++;
    return canScheduleResponses.removeFirst();
  }

  @override
  Future<bool> openExactAlarmsSettings() async {
    openInvocations++;
    return openResult;
  }
}

class MethodChannelStub extends MethodChannel {
  const MethodChannelStub() : super('stub');
}
