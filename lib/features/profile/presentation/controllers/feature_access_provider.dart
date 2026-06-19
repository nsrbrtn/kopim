import 'package:flutter/foundation.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:riverpod/riverpod.dart';

import 'data_mode_controller.dart';

enum EntitlementAccessState {
  freeLocal,
  cloudTrial,
  cloudActive,
  cloudExpired,
  unknown,
}

enum FeatureAccessStatus {
  enabled,
  disabledByBuild,
  requiresSignIn,
  requiresEntitlement,
  blockedByLocalData,
  unavailable,
}

class FeatureGate {
  const FeatureGate(this.status);

  final FeatureAccessStatus status;

  bool get isEnabled => status == FeatureAccessStatus.enabled;

  bool get canPromptUpgrade =>
      status == FeatureAccessStatus.requiresEntitlement;
}

class FeatureAccess {
  const FeatureAccess({
    required this.entitlementState,
    required this.cloudSync,
    required this.webApp,
    required this.aiAssistant,
    required this.advancedAnalytics,
    required this.isWebReadOnly,
  });

  factory FeatureAccess.fromState({
    required AppCapabilities capabilities,
    required EntitlementAccessState entitlementState,
    required DataMode? dataMode,
  }) {
    return FeatureAccess(
      entitlementState: entitlementState,
      cloudSync: _resolveCloudSyncGate(
        capabilities: capabilities,
        entitlementState: entitlementState,
        dataMode: dataMode,
      ),
      webApp: _resolveWebAppGate(
        capabilities: capabilities,
        entitlementState: entitlementState,
      ),
      aiAssistant: _resolveAiAssistantGate(
        capabilities: capabilities,
        entitlementState: entitlementState,
      ),
      advancedAnalytics: _resolveAdvancedAnalyticsGate(
        capabilities: capabilities,
        entitlementState: entitlementState,
      ),
      isWebReadOnly:
          kIsWeb && entitlementState == EntitlementAccessState.cloudExpired,
    );
  }

  final EntitlementAccessState entitlementState;
  final FeatureGate cloudSync;
  final FeatureGate webApp;
  final FeatureGate aiAssistant;
  final FeatureGate advancedAnalytics;
  final bool isWebReadOnly;

  bool get canUseCloudSync => cloudSync.isEnabled;
  bool get canUseWebSync => webApp.isEnabled;
  bool get canUseAiAssistant => aiAssistant.isEnabled;
  bool get canUseAdvancedAnalytics => advancedAnalytics.isEnabled;
}

final Provider<FeatureAccess> featureAccessProvider = Provider<FeatureAccess>((
  Ref ref,
) {
  final AppCapabilities capabilities = ref.watch(appCapabilitiesProvider);
  final AsyncValue<DataModeState> dataModeAsync = ref.watch(
    dataModeControllerProvider,
  );
  final DataModeState? state = dataModeAsync.asData?.value;

  return FeatureAccess.fromState(
    capabilities: capabilities,
    entitlementState: _mapEntitlementState(
      state?.entitlementState ??
          (capabilities.canRunCloudSync
              ? CloudEntitlementState.checking
              : CloudEntitlementState.unavailable),
    ),
    dataMode: state?.dataMode,
  );
});

EntitlementAccessState _mapEntitlementState(
  CloudEntitlementState entitlementState,
) {
  return switch (entitlementState) {
    CloudEntitlementState.active => EntitlementAccessState.cloudActive,
    CloudEntitlementState.expired => EntitlementAccessState.cloudExpired,
    CloudEntitlementState.checking => EntitlementAccessState.unknown,
    CloudEntitlementState.unavailable ||
    CloudEntitlementState.notActivated ||
    CloudEntitlementState.invalid => EntitlementAccessState.freeLocal,
  };
}

FeatureGate _resolveCloudSyncGate({
  required AppCapabilities capabilities,
  required EntitlementAccessState entitlementState,
  required DataMode? dataMode,
}) {
  if (!capabilities.canRunCloudSync) {
    return const FeatureGate(FeatureAccessStatus.disabledByBuild);
  }

  if (dataMode == DataMode.cloudBlockedByLocalData) {
    return const FeatureGate(FeatureAccessStatus.blockedByLocalData);
  }

  if (dataMode == DataMode.cloudEnabled) {
    return const FeatureGate(FeatureAccessStatus.enabled);
  }

  return switch (entitlementState) {
    EntitlementAccessState.freeLocal || EntitlementAccessState.cloudExpired =>
      const FeatureGate(FeatureAccessStatus.requiresEntitlement),
    EntitlementAccessState.cloudTrial || EntitlementAccessState.cloudActive =>
      const FeatureGate(FeatureAccessStatus.requiresSignIn),
    EntitlementAccessState.unknown => const FeatureGate(
      FeatureAccessStatus.unavailable,
    ),
  };
}

FeatureGate _resolveWebAppGate({
  required AppCapabilities capabilities,
  required EntitlementAccessState entitlementState,
}) {
  if (!capabilities.canRunCloudSync) {
    return const FeatureGate(FeatureAccessStatus.disabledByBuild);
  }

  return switch (entitlementState) {
    EntitlementAccessState.cloudTrial || EntitlementAccessState.cloudActive =>
      const FeatureGate(FeatureAccessStatus.enabled),
    EntitlementAccessState.freeLocal || EntitlementAccessState.cloudExpired =>
      const FeatureGate(FeatureAccessStatus.requiresEntitlement),
    EntitlementAccessState.unknown => const FeatureGate(
      FeatureAccessStatus.unavailable,
    ),
  };
}

FeatureGate _resolveAiAssistantGate({
  required AppCapabilities capabilities,
  required EntitlementAccessState entitlementState,
}) {
  if (!capabilities.canUseAiTransport) {
    return const FeatureGate(FeatureAccessStatus.disabledByBuild);
  }

  return switch (entitlementState) {
    EntitlementAccessState.cloudTrial || EntitlementAccessState.cloudActive =>
      const FeatureGate(FeatureAccessStatus.enabled),
    EntitlementAccessState.freeLocal || EntitlementAccessState.cloudExpired =>
      const FeatureGate(FeatureAccessStatus.requiresEntitlement),
    EntitlementAccessState.unknown => const FeatureGate(
      FeatureAccessStatus.unavailable,
    ),
  };
}

FeatureGate _resolveAdvancedAnalyticsGate({
  required AppCapabilities capabilities,
  required EntitlementAccessState entitlementState,
}) {
  if (!capabilities.canRunCloudSync) {
    return const FeatureGate(FeatureAccessStatus.disabledByBuild);
  }

  return switch (entitlementState) {
    EntitlementAccessState.cloudTrial || EntitlementAccessState.cloudActive =>
      const FeatureGate(FeatureAccessStatus.enabled),
    EntitlementAccessState.freeLocal || EntitlementAccessState.cloudExpired =>
      const FeatureGate(FeatureAccessStatus.requiresEntitlement),
    EntitlementAccessState.unknown => const FeatureGate(
      FeatureAccessStatus.unavailable,
    ),
  };
}
