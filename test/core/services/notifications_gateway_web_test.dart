import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/notification_fallback_presenter.dart';
import 'package:kopim/core/services/notifications_gateway_web.dart';
import 'package:kopim/core/services/push_permission_service.dart';

class _FakePushPermissionService implements PushPermissionService {
  _FakePushPermissionService({this.initialValue = false});

  bool initialValue;
  bool ensureCalled = false;

  @override
  Future<bool> ensurePermission({bool requestIfNeeded = true}) async {
    ensureCalled = true;
    return initialValue;
  }

  @override
  bool get isSupported => true;
}

class _DummyLogger extends LoggerService {
  @override
  void logInfo(String message) {}

  @override
  void logError(String message, [Object? error]) {}
}

void main() {
  tzdata.initializeTimeZones();

  test('web gateway triggers fallback only after permission granted', () {
    fakeAsync((FakeAsync async) {
      final StreamNotificationFallbackPresenter presenter =
          StreamNotificationFallbackPresenter();
      final _FakePushPermissionService permissionService =
          _FakePushPermissionService(initialValue: false);
      final WebNotificationsGateway gateway = WebNotificationsGateway(
        logger: _DummyLogger(),
        fallbackPresenter: presenter,
        pushPermissionService: permissionService,
      );

      final List<NotificationFallbackEvent> events =
          <NotificationFallbackEvent>[];
      presenter.events.listen(events.add);

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      gateway.scheduleAt(
        id: 1,
        when: now.add(const Duration(seconds: 5)),
        title: 'Test',
        body: 'Should be delayed',
      );
      async.elapse(const Duration(seconds: 10));
      expect(events, isEmpty);

      permissionService.initialValue = true;
      async.run((_) async {
        await gateway.ensurePermission();
      });

      gateway.scheduleAt(
        id: 2,
        when: now.add(const Duration(seconds: 5)),
        title: 'Test',
        body: 'Should appear',
      );
      async.elapse(const Duration(seconds: 5));
      expect(events.length, 1);
      expect(events.single.title, 'Test');
      expect(permissionService.ensureCalled, isTrue);

      presenter.dispose();
    });
  });
}
