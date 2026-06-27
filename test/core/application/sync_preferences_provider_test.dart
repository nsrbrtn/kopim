import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/application/sync_preferences_provider.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.dev);
  });

  test('offline-only runtime keeps online sync preference disabled', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppRuntimeConfig.configure(AppRuntimeFlavor.offlineOnly);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final bool initial = await container.read(
      onlineSyncPreferencesControllerProvider.future,
    );
    expect(initial, isFalse);

    await container
        .read(onlineSyncPreferencesControllerProvider.notifier)
        .setEnabled(true);

    expect(
      container.read(onlineSyncPreferencesControllerProvider).value,
      isFalse,
    );
  });

  test(
    'cloud-capable runtime defaults online sync preference to enabled',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      AppRuntimeConfig.configure(AppRuntimeFlavor.storeProdLocalFirst);
      FirebaseEnvironmentConfig.configure(FirebaseEnvironment.prod);

      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final bool initial = await container.read(
        onlineSyncPreferencesControllerProvider.future,
      );

      expect(initial, isTrue);
    },
  );

  test('stored preference is respected for cloud-capable runtime', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'core.online_sync.enabled': false,
    });
    AppRuntimeConfig.configure(AppRuntimeFlavor.storeProdLocalFirst);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.prod);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final bool initial = await container.read(
      onlineSyncPreferencesControllerProvider.future,
    );

    expect(initial, isFalse);
  });
}
