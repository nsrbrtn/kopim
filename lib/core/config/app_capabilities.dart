import 'package:flutter/foundation.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:riverpod/riverpod.dart';

class AppCapabilities {
  const AppCapabilities({
    required this.canInitializeFirebase,
    required this.canUseFirebaseAuth,
    required this.canUseFirestore,
    required this.canUseRemoteConfig,
    required this.canRunCloudSync,
    required this.canUseAiTransport,
    required this.canShowCloudSyncEntryPoint,
    required this.canRegisterInApp,
    required this.canShowPaymentOrPurchaseUi,
    required this.canActivatePromoOrLicenseInApp,
    required this.requiresEntitlementBeforeWebApp,
    required this.allowsLocalOnlyUsage,
    required this.expiredEntitlementMode,
    required this.firebaseEnvironment,
  });

  factory AppCapabilities.fromRuntime() {
    final AppRuntimeFlavor flavor = AppRuntimeConfig.flavor;

    switch (flavor) {
      case AppRuntimeFlavor.offlineOnly:
        return const AppCapabilities(
          canInitializeFirebase: false,
          canUseFirebaseAuth: false,
          canUseFirestore: false,
          canUseRemoteConfig: false,
          canRunCloudSync: false,
          canUseAiTransport: false,
          canShowCloudSyncEntryPoint: false,
          canRegisterInApp: false,
          canShowPaymentOrPurchaseUi: false,
          canActivatePromoOrLicenseInApp: false,
          requiresEntitlementBeforeWebApp: false,
          allowsLocalOnlyUsage: true,
          expiredEntitlementMode: ExpiredEntitlementMode.none,
          firebaseEnvironment: null,
        );

      case AppRuntimeFlavor.storeProdLocalFirst:
        return const AppCapabilities(
          canInitializeFirebase: true,
          canUseFirebaseAuth: true,
          canUseFirestore: true,
          canUseRemoteConfig: true,
          canRunCloudSync: true,
          canUseAiTransport: true,
          canShowCloudSyncEntryPoint: true,
          canRegisterInApp: false,
          canShowPaymentOrPurchaseUi: false,
          canActivatePromoOrLicenseInApp: false,
          requiresEntitlementBeforeWebApp: false,
          allowsLocalOnlyUsage: true,
          expiredEntitlementMode:
              ExpiredEntitlementMode.localWritableSyncPaused,
          firebaseEnvironment: FirebaseEnvironment.prod,
        );

      case AppRuntimeFlavor.webProdCloudOnly:
        return const AppCapabilities(
          canInitializeFirebase: true,
          canUseFirebaseAuth: true,
          canUseFirestore: true,
          canUseRemoteConfig: true,
          canRunCloudSync: true,
          canUseAiTransport: true,
          canShowCloudSyncEntryPoint: true,
          canRegisterInApp: true,
          canShowPaymentOrPurchaseUi: true,
          canActivatePromoOrLicenseInApp: false,
          requiresEntitlementBeforeWebApp: true,
          allowsLocalOnlyUsage: false,
          expiredEntitlementMode: ExpiredEntitlementMode.readOnly,
          firebaseEnvironment: FirebaseEnvironment.prod,
        );

      case AppRuntimeFlavor.firebaseDev:
        return const AppCapabilities(
          canInitializeFirebase: true,
          canUseFirebaseAuth: true,
          canUseFirestore: true,
          canUseRemoteConfig: true,
          canRunCloudSync: true,
          canUseAiTransport: true,
          canShowCloudSyncEntryPoint: true,
          canRegisterInApp: kIsWeb,
          canShowPaymentOrPurchaseUi: kIsWeb,
          canActivatePromoOrLicenseInApp: false,
          requiresEntitlementBeforeWebApp: kIsWeb,
          allowsLocalOnlyUsage: !kIsWeb,
          expiredEntitlementMode: kIsWeb
              ? ExpiredEntitlementMode.readOnly
              : ExpiredEntitlementMode.localWritableSyncPaused,
          firebaseEnvironment: FirebaseEnvironment.dev,
        );
    }
  }

  final bool canInitializeFirebase;
  final bool canUseFirebaseAuth;
  final bool canUseFirestore;
  final bool canUseRemoteConfig;
  final bool canRunCloudSync;
  final bool canUseAiTransport;
  final bool canShowCloudSyncEntryPoint;
  final bool canRegisterInApp;
  final bool canShowPaymentOrPurchaseUi;
  final bool canActivatePromoOrLicenseInApp;
  final bool requiresEntitlementBeforeWebApp;
  final bool allowsLocalOnlyUsage;
  final ExpiredEntitlementMode expiredEntitlementMode;
  final FirebaseEnvironment? firebaseEnvironment;
}

final Provider<AppCapabilities> appCapabilitiesProvider =
    Provider<AppCapabilities>((Ref ref) {
      return AppCapabilities.fromRuntime();
    });
