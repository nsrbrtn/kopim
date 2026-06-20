import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

CloudActivationReadinessState resolveCloudActivationReadinessState({
  required CloudActivationPreflightState preflightState,
  required AsyncValue<LocalSnapshotSummary> localSummaryAsync,
  required AsyncValue<CloudSnapshotSummary>? remoteSummaryAsync,
  required CloudActivationIntentState intentState,
}) {
  return switch (preflightState.status) {
    CloudActivationPreflightStatus.cloudUnavailableInBuild =>
      const CloudActivationReadinessState(
        status: CloudActivationReadinessStatus.unavailable,
        localSnapshotState: LocalSnapshotState.unknown,
        remoteSnapshotState: RemoteSnapshotState.unknown,
        blockReason: CloudActivationBlockReason.capabilitiesDisabled,
      ),
    CloudActivationPreflightStatus.signedOut =>
      const CloudActivationReadinessState(
        status: CloudActivationReadinessStatus.unavailable,
        localSnapshotState: LocalSnapshotState.unknown,
        remoteSnapshotState: RemoteSnapshotState.unknown,
        blockReason: CloudActivationBlockReason.signInRequired,
      ),
    CloudActivationPreflightStatus.entitlementRequired =>
      const CloudActivationReadinessState(
        status: CloudActivationReadinessStatus.unavailable,
        localSnapshotState: LocalSnapshotState.unknown,
        remoteSnapshotState: RemoteSnapshotState.unknown,
        blockReason: CloudActivationBlockReason.entitlementRequired,
      ),
    CloudActivationPreflightStatus.alreadyCloudEnabled =>
      const CloudActivationReadinessState(
        status: CloudActivationReadinessStatus.executionBlocked,
        localSnapshotState: LocalSnapshotState.unknown,
        remoteSnapshotState: RemoteSnapshotState.unknown,
      ),
    CloudActivationPreflightStatus.unknown =>
      const CloudActivationReadinessState(
        status: CloudActivationReadinessStatus.unknown,
        localSnapshotState: LocalSnapshotState.unknown,
        remoteSnapshotState: RemoteSnapshotState.unknown,
      ),
    CloudActivationPreflightStatus.blockedByLocalOnlyData ||
    CloudActivationPreflightStatus.readyForNextStep => _resolveChoiceReadiness(
      localSummaryAsync,
      remoteSummaryAsync,
      intentState,
    ),
  };
}

CloudActivationReadinessState _resolveChoiceReadiness(
  AsyncValue<LocalSnapshotSummary> localSummaryAsync,
  AsyncValue<CloudSnapshotSummary>? remoteSummaryAsync,
  CloudActivationIntentState intentState,
) {
  if (localSummaryAsync.isLoading) {
    return const CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.loading,
      localSnapshotState: LocalSnapshotState.unknown,
      remoteSnapshotState: RemoteSnapshotState.unknown,
    );
  }

  final LocalSnapshotSummary? localSummary = localSummaryAsync.asData?.value;
  if (localSummary == null) {
    return const CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unknown,
      localSnapshotState: LocalSnapshotState.unknown,
      remoteSnapshotState: RemoteSnapshotState.unknown,
      blockReason: CloudActivationBlockReason.localSnapshotUnknown,
    );
  }

  final _LocalMatrixState localMatrixState = _mapLocalState(localSummary.state);
  if (localMatrixState == _LocalMatrixState.unknown) {
    return CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unknown,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: RemoteSnapshotState.unknown,
      blockReason: CloudActivationBlockReason.localSnapshotUnknown,
      localFingerprint: localSummary.fingerprint,
    );
  }

  if (remoteSummaryAsync == null || remoteSummaryAsync.isLoading) {
    return CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.loading,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: RemoteSnapshotState.unknown,
      localFingerprint: localSummary.fingerprint,
    );
  }

  final CloudSnapshotSummary? remoteSummary = remoteSummaryAsync.asData?.value;
  if (remoteSummary == null) {
    return CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unknown,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: RemoteSnapshotState.unknown,
      blockReason: CloudActivationBlockReason.remoteSnapshotUnknown,
      localFingerprint: localSummary.fingerprint,
    );
  }

  final CloudActivationReadinessState? blockedState =
      _resolveRemoteBlockedState(
        localSummary: localSummary,
        remoteSummary: remoteSummary,
      );
  if (blockedState != null) {
    return blockedState;
  }

  final CloudActivationMatrixScenario matrixScenario = _resolveMatrixScenario(
    localMatrixState: localMatrixState,
    remoteState: remoteSummary.state,
  );

  final bool fingerprintMismatch =
      intentState.hasPendingChoice &&
      (intentState.localFingerprint != localSummary.fingerprint ||
          intentState.remoteFingerprint != remoteSummary.fingerprint);

  if (fingerprintMismatch) {
    return CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.readyForChoice,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      matrixScenario: matrixScenario,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    );
  }

  if (intentState.hasPendingChoice) {
    return CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.waitingForConfirmation,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      matrixScenario: matrixScenario,
      pendingChoice: intentState.pendingChoice,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    );
  }

  return CloudActivationReadinessState(
    status: CloudActivationReadinessStatus.readyForChoice,
    localSnapshotState: localSummary.state,
    remoteSnapshotState: remoteSummary.state,
    matrixScenario: matrixScenario,
    localFingerprint: localSummary.fingerprint,
    remoteFingerprint: remoteSummary.fingerprint,
  );
}

enum _LocalMatrixState { emptyEquivalent, hasUserData, unknown }

_LocalMatrixState _mapLocalState(LocalSnapshotState state) {
  return switch (state) {
    LocalSnapshotState.empty ||
    LocalSnapshotState.hasOnlySystemData => _LocalMatrixState.emptyEquivalent,
    LocalSnapshotState.hasUserData => _LocalMatrixState.hasUserData,
    LocalSnapshotState.hasPendingOutbox ||
    LocalSnapshotState.hasLocalOnlyPlaceholders ||
    LocalSnapshotState.activationInProgress ||
    LocalSnapshotState.unknown => _LocalMatrixState.unknown,
  };
}

CloudActivationReadinessState? _resolveRemoteBlockedState({
  required LocalSnapshotSummary localSummary,
  required CloudSnapshotSummary remoteSummary,
}) {
  return switch (remoteSummary.state) {
    RemoteSnapshotState.permissionDenied => CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unavailable,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      blockReason: CloudActivationBlockReason.remotePermissionDenied,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    ),
    RemoteSnapshotState.unavailable => CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unavailable,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      blockReason: CloudActivationBlockReason.remoteUnavailable,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    ),
    RemoteSnapshotState.unauthenticated => CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unavailable,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      blockReason: CloudActivationBlockReason.signInRequired,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    ),
    RemoteSnapshotState.hasTombstonesOnly ||
    RemoteSnapshotState.activationInProgress => CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unknown,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      blockReason: CloudActivationBlockReason.remoteSnapshotUnknown,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    ),
    RemoteSnapshotState.unknown => CloudActivationReadinessState(
      status: CloudActivationReadinessStatus.unknown,
      localSnapshotState: localSummary.state,
      remoteSnapshotState: remoteSummary.state,
      blockReason: CloudActivationBlockReason.remoteSnapshotUnknown,
      localFingerprint: localSummary.fingerprint,
      remoteFingerprint: remoteSummary.fingerprint,
    ),
    RemoteSnapshotState.empty ||
    RemoteSnapshotState.hasOnlyMetadata ||
    RemoteSnapshotState.hasUserData => null,
  };
}

CloudActivationMatrixScenario _resolveMatrixScenario({
  required _LocalMatrixState localMatrixState,
  required RemoteSnapshotState remoteState,
}) {
  return switch ((localMatrixState, remoteState)) {
    (_LocalMatrixState.emptyEquivalent, RemoteSnapshotState.empty) =>
      CloudActivationMatrixScenario.localEmptyRemoteEmpty,
    (_LocalMatrixState.emptyEquivalent, RemoteSnapshotState.hasOnlyMetadata) =>
      CloudActivationMatrixScenario.localEmptyRemoteMetadataOnly,
    (_LocalMatrixState.emptyEquivalent, RemoteSnapshotState.hasUserData) =>
      CloudActivationMatrixScenario.localEmptyRemoteHasUserData,
    (_LocalMatrixState.hasUserData, RemoteSnapshotState.empty) =>
      CloudActivationMatrixScenario.localHasUserDataRemoteEmpty,
    (_LocalMatrixState.hasUserData, RemoteSnapshotState.hasOnlyMetadata) =>
      CloudActivationMatrixScenario.localHasUserDataRemoteMetadataOnly,
    (_LocalMatrixState.hasUserData, RemoteSnapshotState.hasUserData) =>
      CloudActivationMatrixScenario.localHasUserDataRemoteHasUserData,
    _ => CloudActivationMatrixScenario.localEmptyRemoteEmpty,
  };
}

final FutureProvider<LocalSnapshotSummary> localSnapshotSummaryProvider =
    FutureProvider<LocalSnapshotSummary>((Ref ref) async {
      return ref.watch(localSnapshotSummaryServiceProvider).summarize();
    });

final FutureProvider<CloudSnapshotSummary> cloudSnapshotSummaryProvider =
    FutureProvider<CloudSnapshotSummary>((Ref ref) async {
      final AuthUser? user = ref.watch(authControllerProvider).asData?.value;
      return ref
          .watch(cloudSnapshotSummaryServiceProvider)
          .summarize(user?.uid ?? '');
    });

final Provider<AsyncValue<CloudActivationReadinessState>>
cloudActivationReadinessProvider =
    Provider<AsyncValue<CloudActivationReadinessState>>((Ref ref) {
      final AsyncValue<LocalSnapshotSummary> localSummaryAsync = ref.watch(
        localSnapshotSummaryProvider,
      );
      final CloudActivationPreflightState preflightState = ref.watch(
        cloudActivationPreflightProvider,
      );
      final bool shouldProbeRemote =
          preflightState.status ==
              CloudActivationPreflightStatus.blockedByLocalOnlyData ||
          preflightState.status ==
              CloudActivationPreflightStatus.readyForNextStep;
      final AsyncValue<CloudSnapshotSummary>? remoteSummaryAsync =
          shouldProbeRemote ? ref.watch(cloudSnapshotSummaryProvider) : null;
      return AsyncValue<CloudActivationReadinessState>.data(
        resolveCloudActivationReadinessState(
          preflightState: preflightState,
          localSummaryAsync: localSummaryAsync,
          remoteSummaryAsync: remoteSummaryAsync,
          intentState: ref.watch(cloudActivationIntentProvider),
        ),
      );
    });
