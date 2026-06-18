import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CloudEntitlementRepository Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      sharedPreferences = await SharedPreferences.getInstance();
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    });

    test('should allow DEMO-CLOUD-KEY in dev/debug modes', () async {
      final CloudEntitlementRepositoryImpl repository =
          CloudEntitlementRepositoryImpl(
            preferences: Future<SharedPreferences>.value(sharedPreferences),
          );

      final CloudEntitlementResult result = await repository.activateKey(
        'DEMO-CLOUD-KEY',
      );
      expect(result.success, isTrue);
      expect(result.state, equals(CloudEntitlementState.active));

      final CloudEntitlementState cached = await repository.getCachedState();
      expect(cached, equals(CloudEntitlementState.active));
    });

    test('should reject invalid keys', () async {
      final CloudEntitlementRepositoryImpl repository =
          CloudEntitlementRepositoryImpl(
            preferences: Future<SharedPreferences>.value(sharedPreferences),
          );

      final CloudEntitlementResult result = await repository.activateKey(
        'INVALID-KEY',
      );
      expect(result.success, isFalse);
      expect(result.state, equals(CloudEntitlementState.invalid));
    });

    test(
      'should reject DEMO-CLOUD-KEY if in offlineOnly distribution mode',
      () async {
        AppRuntimeConfig.configure(AppRuntimeFlavor.offline);
        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
            );

        final CloudEntitlementState cached = await repository.getCachedState();
        expect(cached, equals(CloudEntitlementState.unavailable));
      },
    );
  });
}
