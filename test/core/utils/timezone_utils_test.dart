import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kopim/core/utils/timezone_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_timezone');

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    resetCachedTimeZoneIdForTests();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('loads timezone id from platform and caches it', () async {
    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      callCount += 1;
      if (call.method == 'getLocalTimezone') {
        return 'UTC';
      }
      throw PlatformException(code: 'unimplemented', message: call.method);
    });

    final String timeZoneId = await loadCurrentTimeZoneId();
    expect(timeZoneId, 'UTC');
    expect(callCount, 1);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('core.local_time_zone_id'), 'UTC');

    final String cached = resolveCurrentTimeZoneId();
    expect(cached, 'UTC');
  });

  test('uses persisted timezone id without calling platform', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'core.local_time_zone_id': 'UTC',
    });

    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      callCount += 1;
      return 'Europe/Berlin';
    });

    final String timeZoneId = await loadCurrentTimeZoneId();
    expect(timeZoneId, 'UTC');
    expect(callCount, 0);
  });

  test('falls back to heuristic when platform timezone is invalid', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getLocalTimezone') {
        return 'Invalid/Timezone';
      }
      throw PlatformException(code: 'unimplemented', message: call.method);
    });

    final String timeZoneId = await loadCurrentTimeZoneId();
    expect(timeZoneId, isNotEmpty);
    expect(() => tz.getLocation(timeZoneId), returnsNormally);
  });
}
