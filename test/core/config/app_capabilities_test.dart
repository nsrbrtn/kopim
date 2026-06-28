import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';

void main() {
  tearDown(() {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.dev);
  });

  test('offlineOnly runtime disables Firebase and AI capabilities', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.offlineOnly);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.canInitializeFirebase, isFalse);
    expect(capabilities.canUseFirebaseAuth, isFalse);
    expect(capabilities.canUseFirestore, isFalse);
    expect(capabilities.canUseAiTransport, isFalse);
    expect(capabilities.firebaseEnvironment, isNull);
  });

  test('dev runtime uses dev Firebase environment', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.dev);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.firebaseEnvironment, FirebaseEnvironment.dev);
  });

  test('storeProdLocalFirst runtime uses prod Firebase environment', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.storeProdLocalFirst);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.prod);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.firebaseEnvironment, FirebaseEnvironment.prod);
    expect(capabilities.canRunCloudSync, isTrue);
    expect(capabilities.canRegisterInApp, isFalse);
    expect(capabilities.canShowPaymentOrPurchaseUi, isFalse);
    expect(capabilities.canActivatePromoOrLicenseInApp, isFalse);
    expect(capabilities.allowsLocalOnlyUsage, isTrue);
    expect(
      capabilities.expiredEntitlementMode,
      ExpiredEntitlementMode.localWritableSyncPaused,
    );
  });

  test('webProdCloudOnly runtime keeps cloud capabilities and web gating', () {
    AppRuntimeConfig.configure(AppRuntimeFlavor.webProdCloudOnly);
    FirebaseEnvironmentConfig.configure(FirebaseEnvironment.prod);

    final AppCapabilities capabilities = AppCapabilities.fromRuntime();

    expect(capabilities.firebaseEnvironment, FirebaseEnvironment.prod);
    expect(capabilities.canRunCloudSync, isTrue);
    expect(capabilities.canRegisterInApp, isTrue);
    expect(capabilities.canShowPaymentOrPurchaseUi, isTrue);
    expect(capabilities.canActivatePromoOrLicenseInApp, isFalse);
    expect(capabilities.requiresEntitlementBeforeWebApp, isTrue);
    expect(capabilities.allowsLocalOnlyUsage, isFalse);
    expect(
      capabilities.expiredEntitlementMode,
      ExpiredEntitlementMode.readOnly,
    );
  });
}
