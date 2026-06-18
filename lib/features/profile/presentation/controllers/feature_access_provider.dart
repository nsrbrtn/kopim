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

class FeatureAccess {
  const FeatureAccess({
    required this.entitlementState,
    required this.canUseCloudSync,
    required this.canUseWebSync,
    required this.canUseAiAssistant,
    required this.canUseAdvancedAnalytics,
    required this.isWebReadOnly,
  });

  factory FeatureAccess.fromState({
    required AppCapabilities capabilities,
    required EntitlementAccessState entitlementState,
    required DataMode? dataMode,
  }) {
    final bool hasCloudEntitlement =
        entitlementState == EntitlementAccessState.cloudTrial ||
        entitlementState == EntitlementAccessState.cloudActive;

    return FeatureAccess(
      entitlementState: entitlementState,
      canUseCloudSync:
          capabilities.canRunCloudSync &&
          hasCloudEntitlement &&
          dataMode == DataMode.cloudEnabled,
      canUseWebSync: capabilities.canRunCloudSync && hasCloudEntitlement,
      canUseAiAssistant: capabilities.canUseAiTransport && hasCloudEntitlement,
      canUseAdvancedAnalytics: hasCloudEntitlement,
      isWebReadOnly:
          kIsWeb && entitlementState == EntitlementAccessState.cloudExpired,
    );
  }

  final EntitlementAccessState entitlementState;
  final bool canUseCloudSync;
  final bool canUseWebSync;
  final bool canUseAiAssistant;
  final bool canUseAdvancedAnalytics;
  final bool isWebReadOnly;
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
