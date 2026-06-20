import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';

enum CloudActivationPreflightStatus {
  cloudUnavailableInBuild,
  signedOut,
  entitlementRequired,
  blockedByLocalOnlyData,
  readyForNextStep,
  alreadyCloudEnabled,
  unknown,
}

class CloudActivationPreflightState {
  const CloudActivationPreflightState(this.status);

  final CloudActivationPreflightStatus status;
}

CloudActivationPreflightState resolveCloudActivationPreflightState({
  required AppCapabilities capabilities,
  required FeatureAccess featureAccess,
  required AsyncValue<DataModeState> dataModeAsync,
}) {
  if (!capabilities.canRunCloudSync ||
      !capabilities.canUseFirebaseAuth ||
      !capabilities.canUseFirestore) {
    return const CloudActivationPreflightState(
      CloudActivationPreflightStatus.cloudUnavailableInBuild,
    );
  }

  return switch (featureAccess.cloudSync.status) {
    FeatureAccessStatus.disabledByBuild => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.cloudUnavailableInBuild,
    ),
    FeatureAccessStatus.requiresSignIn => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.signedOut,
    ),
    FeatureAccessStatus.requiresEntitlement =>
      const CloudActivationPreflightState(
        CloudActivationPreflightStatus.entitlementRequired,
      ),
    FeatureAccessStatus.blockedByLocalData =>
      const CloudActivationPreflightState(
        CloudActivationPreflightStatus.blockedByLocalOnlyData,
      ),
    FeatureAccessStatus.unavailable => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.unknown,
    ),
    FeatureAccessStatus.enabled => _resolveEnabledState(dataModeAsync),
  };
}

CloudActivationPreflightState _resolveEnabledState(
  AsyncValue<DataModeState> dataModeAsync,
) {
  final DataMode? dataMode = dataModeAsync.asData?.value.dataMode;

  return switch (dataMode) {
    DataMode.cloudEnabled => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.alreadyCloudEnabled,
    ),
    DataMode.cloudBlockedByLocalData => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.blockedByLocalOnlyData,
    ),
    DataMode.localOnly => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.readyForNextStep,
    ),
    null => const CloudActivationPreflightState(
      CloudActivationPreflightStatus.unknown,
    ),
  };
}

final Provider<CloudActivationPreflightState> cloudActivationPreflightProvider =
    Provider<CloudActivationPreflightState>((Ref ref) {
      return resolveCloudActivationPreflightState(
        capabilities: ref.watch(appCapabilitiesProvider),
        featureAccess: ref.watch(featureAccessProvider),
        dataModeAsync: ref.watch(dataModeControllerProvider),
      );
    });
