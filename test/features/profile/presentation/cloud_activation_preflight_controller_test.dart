import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';

void main() {
  const AppCapabilities cloudCapabilities = AppCapabilities(
    canInitializeFirebase: true,
    canUseFirebaseAuth: true,
    canUseFirestore: true,
    canUseRemoteConfig: true,
    canRunCloudSync: true,
    canUseAiTransport: true,
    firebaseEnvironment: FirebaseEnvironment.dev,
  );

  const AppCapabilities offlineCapabilities = AppCapabilities(
    canInitializeFirebase: false,
    canUseFirebaseAuth: false,
    canUseFirestore: false,
    canUseRemoteConfig: false,
    canRunCloudSync: false,
    canUseAiTransport: false,
    firebaseEnvironment: null,
  );

  const FeatureAccess signedOutAccess = FeatureAccess(
    entitlementState: EntitlementAccessState.cloudActive,
    cloudSync: FeatureGate(FeatureAccessStatus.requiresSignIn),
    webApp: FeatureGate(FeatureAccessStatus.enabled),
    aiAssistant: FeatureGate(FeatureAccessStatus.enabled),
    advancedAnalytics: FeatureGate(FeatureAccessStatus.enabled),
    isWebReadOnly: false,
  );

  const FeatureAccess entitlementRequiredAccess = FeatureAccess(
    entitlementState: EntitlementAccessState.freeLocal,
    cloudSync: FeatureGate(FeatureAccessStatus.requiresEntitlement),
    webApp: FeatureGate(FeatureAccessStatus.requiresEntitlement),
    aiAssistant: FeatureGate(FeatureAccessStatus.requiresEntitlement),
    advancedAnalytics: FeatureGate(FeatureAccessStatus.requiresEntitlement),
    isWebReadOnly: false,
  );

  const FeatureAccess blockedAccess = FeatureAccess(
    entitlementState: EntitlementAccessState.cloudActive,
    cloudSync: FeatureGate(FeatureAccessStatus.blockedByLocalData),
    webApp: FeatureGate(FeatureAccessStatus.enabled),
    aiAssistant: FeatureGate(FeatureAccessStatus.enabled),
    advancedAnalytics: FeatureGate(FeatureAccessStatus.enabled),
    isWebReadOnly: false,
  );

  const FeatureAccess enabledAccess = FeatureAccess(
    entitlementState: EntitlementAccessState.cloudActive,
    cloudSync: FeatureGate(FeatureAccessStatus.enabled),
    webApp: FeatureGate(FeatureAccessStatus.enabled),
    aiAssistant: FeatureGate(FeatureAccessStatus.enabled),
    advancedAnalytics: FeatureGate(FeatureAccessStatus.enabled),
    isWebReadOnly: false,
  );

  DataModeState stateFor(DataMode mode) {
    return DataModeState(
      dataMode: mode,
      entitlementState: CloudEntitlementState.active,
      migrationDecision: MigrationDecision.none,
    );
  }

  test('offline build resolves to cloudUnavailableInBuild', () {
    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: offlineCapabilities,
          featureAccess: enabledAccess,
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.cloudEnabled),
          ),
        );

    expect(
      state.status,
      CloudActivationPreflightStatus.cloudUnavailableInBuild,
    );
  });

  test('requiresSignIn resolves to signedOut', () {
    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: cloudCapabilities,
          featureAccess: signedOutAccess,
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.localOnly),
          ),
        );

    expect(state.status, CloudActivationPreflightStatus.signedOut);
  });

  test('requiresEntitlement resolves to entitlementRequired', () {
    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: cloudCapabilities,
          featureAccess: entitlementRequiredAccess,
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.localOnly),
          ),
        );

    expect(state.status, CloudActivationPreflightStatus.entitlementRequired);
  });

  test('blockedByLocalData resolves to blockedByLocalOnlyData', () {
    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: cloudCapabilities,
          featureAccess: blockedAccess,
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.cloudBlockedByLocalData),
          ),
        );

    expect(state.status, CloudActivationPreflightStatus.blockedByLocalOnlyData);
  });

  test('cloudEnabled resolves to alreadyCloudEnabled', () {
    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: cloudCapabilities,
          featureAccess: enabledAccess,
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.cloudEnabled),
          ),
        );

    expect(state.status, CloudActivationPreflightStatus.alreadyCloudEnabled);
  });

  test('enabled localOnly resolves to readyForNextStep', () {
    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: cloudCapabilities,
          featureAccess: enabledAccess,
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.localOnly),
          ),
        );

    expect(state.status, CloudActivationPreflightStatus.readyForNextStep);
  });

  test('unavailable gate resolves to unknown', () {
    const FeatureAccess unavailableAccess = FeatureAccess(
      entitlementState: EntitlementAccessState.unknown,
      cloudSync: FeatureGate(FeatureAccessStatus.unavailable),
      webApp: FeatureGate(FeatureAccessStatus.unavailable),
      aiAssistant: FeatureGate(FeatureAccessStatus.unavailable),
      advancedAnalytics: FeatureGate(FeatureAccessStatus.unavailable),
      isWebReadOnly: false,
    );

    final CloudActivationPreflightState state =
        resolveCloudActivationPreflightState(
          capabilities: cloudCapabilities,
          featureAccess: unavailableAccess,
          dataModeAsync: const AsyncValue<DataModeState>.loading(),
        );

    expect(state.status, CloudActivationPreflightStatus.unknown);
  });
}
