import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/services/exact_alarm_permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel missingChannel = MethodChannel('kopim/tests/missing');

  group('ExactAlarmPermissionService', () {
    test('возвращает false, если платформенный канал недоступен', () async {
      final ExactAlarmPermissionService service = ExactAlarmPermissionService(
        channel: missingChannel,
        isAndroidOverride: true,
      );

      expect(await service.canScheduleExactAlarms(), isFalse);
      expect(await service.openExactAlarmsSettings(), isFalse);
    });

    test('возвращает значения, полученные с платформенного канала', () async {
      const MethodChannel channel = MethodChannel('kopim/tests/exact');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            switch (call.method) {
              case 'canScheduleExactAlarms':
                return true;
              case 'openExactAlarmsSettings':
                return true;
            }
            return null;
          });

      final ExactAlarmPermissionService service = ExactAlarmPermissionService(
        channel: channel,
        isAndroidOverride: true,
      );

      expect(await service.canScheduleExactAlarms(), isTrue);
      expect(await service.openExactAlarmsSettings(), isTrue);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
