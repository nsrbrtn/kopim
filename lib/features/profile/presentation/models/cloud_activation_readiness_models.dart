import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';

enum CloudActivationReadinessStatus {
  unavailable,
  loading,
  readyForChoice,
  waitingForConfirmation,
  executionBlocked,
  unknown,
}

enum LocalSnapshotState {
  empty,
  hasUserData,
  hasOnlySystemData,
  hasPendingOutbox,
  hasLocalOnlyPlaceholders,
  activationInProgress,
  unknown,
}

enum RemoteSnapshotState {
  empty,
  hasUserData,
  hasOnlyMetadata,
  hasTombstonesOnly,
  activationInProgress,
  unavailable,
  permissionDenied,
  unauthenticated,
  unknown,
}

enum CloudActivationBlockReason {
  capabilitiesDisabled,
  signInRequired,
  entitlementRequired,
  entitlementExpired,
  remoteUnavailable,
  remotePermissionDenied,
  localSnapshotUnknown,
  remoteSnapshotUnknown,
  activationAlreadyInProgress,
  syncConflict,
}

class LocalSnapshotSummary {
  const LocalSnapshotSummary({
    required this.state,
    required this.hasUserData,
    required this.hasSystemData,
    required this.pendingOutboxCount,
    required this.fingerprint,
  });

  final LocalSnapshotState state;
  final bool hasUserData;
  final bool hasSystemData;
  final int pendingOutboxCount;
  final String fingerprint;
}

class CloudSnapshotSummary {
  const CloudSnapshotSummary({
    required this.state,
    required this.hasUserData,
    required this.hasMetadata,
    required this.hasTombstonesOnly,
    required this.fingerprint,
  });

  final RemoteSnapshotState state;
  final bool hasUserData;
  final bool hasMetadata;
  final bool hasTombstonesOnly;
  final String fingerprint;
}

enum CloudActivationMatrixScenario {
  localEmptyRemoteEmpty,
  localEmptyRemoteMetadataOnly,
  localEmptyRemoteHasUserData,
  localHasUserDataRemoteEmpty,
  localHasUserDataRemoteMetadataOnly,
  localHasUserDataRemoteHasUserData,
}

class CloudActivationReadinessState {
  const CloudActivationReadinessState({
    required this.status,
    required this.localSnapshotState,
    required this.remoteSnapshotState,
    this.matrixScenario,
    this.blockReason,
    this.pendingChoice,
    this.localFingerprint,
    this.remoteFingerprint,
  });

  final CloudActivationReadinessStatus status;
  final LocalSnapshotState localSnapshotState;
  final RemoteSnapshotState remoteSnapshotState;
  final CloudActivationMatrixScenario? matrixScenario;
  final CloudActivationBlockReason? blockReason;
  final CloudActivationChoice? pendingChoice;
  final String? localFingerprint;
  final String? remoteFingerprint;
}
