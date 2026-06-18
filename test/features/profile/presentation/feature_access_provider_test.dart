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

      expect(access.canUseCloudSync, isFalse);
      expect(access.canUseAiAssistant, isFalse);
      expect(access.canUseAdvancedAnalytics, isFalse);
    },
  );

  test('cloudTrial entitlement enables cloud feature gates', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudTrial,
      dataMode: DataMode.cloudEnabled,
    );

    expect(access.canUseCloudSync, isTrue);
    expect(access.canUseAiAssistant, isTrue);
    expect(access.canUseAdvancedAnalytics, isTrue);
  });

  test('cloudActive entitlement enables cloud feature gates', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudActive,
      dataMode: DataMode.cloudEnabled,
    );

    expect(access.canUseCloudSync, isTrue);
    expect(access.canUseAiAssistant, isTrue);
    expect(access.canUseAdvancedAnalytics, isTrue);
  });

  test('cloudExpired entitlement disables sync writes and AI', () {
    final FeatureAccess access = FeatureAccess.fromState(
      capabilities: capabilities,
      entitlementState: EntitlementAccessState.cloudExpired,
      dataMode: DataMode.localOnly,
    );

    expect(access.canUseCloudSync, isFalse);
    expect(access.canUseAiAssistant, isFalse);
  });
}
