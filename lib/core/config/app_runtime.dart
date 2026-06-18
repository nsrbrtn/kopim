enum AppRuntimeFlavor { offline, firebaseDev, firebaseProd }

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
      _flavor == AppRuntimeFlavor.offline
      ? AppDistributionMode.offlineOnly
      : AppDistributionMode.cloudCapable;

  static bool get isOfflineOnlyDistribution =>
      distributionMode == AppDistributionMode.offlineOnly;

  static bool get isCloudCapableDistribution =>
      distributionMode == AppDistributionMode.cloudCapable;

  @Deprecated('Use isOfflineOnlyDistribution or DataMode instead')
  static bool get isOffline => _flavor == AppRuntimeFlavor.offline;

  @Deprecated('Use usesFirebase or DataMode instead')
  static bool get usesFirebase => !isOffline;

  static void configure(AppRuntimeFlavor flavor) {
    _flavor = flavor;
  }
}
