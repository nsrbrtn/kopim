import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/config/firebase_environment.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';

void main() {
  const AppCapabilities capabilities = AppCapabilities(
    canInitializeFirebase: true,
    canUseFirebaseAuth: true,
    canUseFirestore: true,
    canUseRemoteConfig: true,
    canRunCloudSync: true,
    canUseAiTransport: true,
    firebaseEnvironment: FirebaseEnvironment.dev,
  );

  test(
    'freeLocal entitlement keeps cloud sync, AI, and analytics disabled',
    () {
      final FeatureAccess access = FeatureAccess.fromState(
        capabilities: capabilities,
        entitlementState: EntitlementAccessState.freeLocal,
        dataMode: DataMode.localOnly,
      );

      expect(access.cloudSync.status, FeatureAccessStatus.requiresEntitlement);
      expect(
        access.aiAssistant.status,
        FeatureAccessStatus.requiresEntitlement,
      );
      expect(
        access.advancedAnalytics.status,
        FeatureAccessStatus.requiresEntitlement,
      );
    },
  );

  test('cloudTrial entitlement requires sign-in before cloud sync', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudTrial,
      dataMode: DataMode.localOnly,
    );

    expect(access.cloudSync.status, FeatureAccessStatus.requiresSignIn);
    expect(access.aiAssistant.status, FeatureAccessStatus.enabled);
    expect(access.advancedAnalytics.status, FeatureAccessStatus.enabled);
  });

  test('cloudActive entitlement enables cloud feature gates', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudActive,
      dataMode: DataMode.cloudEnabled,
    );

    expect(access.cloudSync.status, FeatureAccessStatus.enabled);
    expect(access.aiAssistant.status, FeatureAccessStatus.enabled);
    expect(access.advancedAnalytics.status, FeatureAccessStatus.enabled);
  });

  test('blocked local data is exposed as a dedicated cloud sync status', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudActive,
      dataMode: DataMode.cloudBlockedByLocalData,
    );

    expect(access.cloudSync.status, FeatureAccessStatus.blockedByLocalData);
    expect(access.canUseCloudSync, isFalse);
  });

  test('cloudExpired entitlement disables sync writes and AI', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudExpired,
      dataMode: DataMode.localOnly,
    );

    expect(access.cloudSync.status, FeatureAccessStatus.requiresEntitlement);
    expect(access.aiAssistant.status, FeatureAccessStatus.requiresEntitlement);
  });

  test('offline build disables gates at capability level', () {
    const AppCapabilities offlineCapabilities = AppCapabilities(
      canInitializeFirebase: false,
      canUseFirebaseAuth: false,
      canUseFirestore: false,
      canUseRemoteConfig: false,
      canRunCloudSync: false,
      canUseAiTransport: false,
      firebaseEnvironment: null,
    );

    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: offlineCapabilities,
      entitlementState: EntitlementAccessState.cloudActive,
      dataMode: DataMode.cloudEnabled,
    );

    expect(access.cloudSync.status, FeatureAccessStatus.disabledByBuild);
    expect(access.aiAssistant.status, FeatureAccessStatus.disabledByBuild);
  });
}
