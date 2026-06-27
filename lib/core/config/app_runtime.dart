enum AppRuntimeFlavor {
  offlineOnly,
  storeProdLocalFirst,
  webProdCloudOnly,
  firebaseDev,
}

enum ExpiredEntitlementMode {
  none,
  localWritableSyncPaused,
  readOnly,
  configurable,
}

enum AppDistributionMode { offlineOnly, cloudCapable }

enum DataMode { localOnly, cloudBlockedByLocalData, cloudEnabled }

enum CloudEntitlementState {
  unavailable,
  notActivated,
  checking,
  active,
  invalid,
  expired,
}

enum MigrationDecision {
  none,
  stayLocalOnly,
  startWithEmptyCloud,
  migrateLocalToCloud,
}

final class AppRuntimeConfig {
  AppRuntimeConfig._();

  static AppRuntimeFlavor _flavor = AppRuntimeFlavor.firebaseDev;

  static AppRuntimeFlavor get flavor => _flavor;

  static AppDistributionMode get distributionMode =>
      _flavor == AppRuntimeFlavor.offlineOnly
      ? AppDistributionMode.offlineOnly
      : AppDistributionMode.cloudCapable;

  static bool get isOfflineOnlyDistribution =>
      distributionMode == AppDistributionMode.offlineOnly;

  static bool get isCloudCapableDistribution =>
      distributionMode == AppDistributionMode.cloudCapable;

  @Deprecated('Use isOfflineOnlyDistribution or AppCapabilities instead')
  static bool get isOffline => _flavor == AppRuntimeFlavor.offlineOnly;

  @Deprecated('Use AppCapabilities instead')
  static bool get usesFirebase => !isOffline;

  static void configure(AppRuntimeFlavor flavor) {
    _flavor = flavor;
  }
}
