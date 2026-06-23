import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

void main() {
  CloudActivationReadinessState readiness({
    required LocalSnapshotState local,
    required RemoteSnapshotState remote,
    required CloudActivationMatrixScenario scenario,
    CloudActivationReadinessStatus status =
        CloudActivationReadinessStatus.readyForChoice,
  }) {
    return CloudActivationReadinessState(
      status: status,
      localSnapshotState: local,
      remoteSnapshotState: remote,
      matrixScenario: scenario,
      localFingerprint: 'local:${local.name}',
      remoteFingerprint: 'remote:${remote.name}|uid:user-1',
    );
  }

  test('empty local plus empty remote enables normal cloud sync only', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          readinessState: readiness(
            local: LocalSnapshotState.empty,
            remote: RemoteSnapshotState.empty,
            scenario: CloudActivationMatrixScenario.localEmptyRemoteEmpty,
          ),
        );

    expect(state.status, CloudActivationDecisionStatus.choiceRequired);
    expect(state.scenario, CloudActivationScenario.localEmptyRemoteEmpty);
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.enableCloudSync,
          )
          .availability,
      CloudActivationChoiceAvailability.available,
    );
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.startWithEmptyCloud,
          )
          .availability,
      CloudActivationChoiceAvailability.unavailableForCurrentScenario,
    );
  });

  test('metadata-only remote keeps enableCloudSync unavailable in v1', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          readinessState: readiness(
            local: LocalSnapshotState.empty,
            remote: RemoteSnapshotState.hasOnlyMetadata,
            scenario:
                CloudActivationMatrixScenario.localEmptyRemoteMetadataOnly,
          ),
        );

    expect(state.status, CloudActivationDecisionStatus.choiceRequired);
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.enableCloudSync,
          )
          .availability,
      CloudActivationChoiceAvailability.unavailableForCurrentScenario,
    );
  });

  test(
    'local data plus metadata-only remote keeps startWithEmptyCloud distinct',
    () {
      final CloudActivationDecisionState state =
          resolveCloudActivationDecisionState(
            readinessState: readiness(
              local: LocalSnapshotState.hasUserData,
              remote: RemoteSnapshotState.hasOnlyMetadata,
              scenario: CloudActivationMatrixScenario
                  .localHasUserDataRemoteMetadataOnly,
            ),
          );

      expect(state.status, CloudActivationDecisionStatus.blocked);
      expect(
        state.options
            .firstWhere(
              (CloudActivationDecisionOption option) =>
                  option.choice == CloudActivationChoice.startWithEmptyCloud,
            )
            .availability,
        CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
      );
      expect(
        state.options
            .firstWhere(
              (CloudActivationDecisionOption option) =>
                  option.choice == CloudActivationChoice.enableCloudSync,
            )
            .availability,
        CloudActivationChoiceAvailability.unavailableForCurrentScenario,
      );
      expect(
        state.options
            .firstWhere(
              (CloudActivationDecisionOption option) =>
                  option.choice == CloudActivationChoice.migrateLocalToCloud,
            )
            .availability,
        CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
      );
    },
  );

  test(
    'local data plus empty remote exposes migrateLocalToCloud as confirmation-gated preflight',
    () {
      final CloudActivationDecisionState state =
          resolveCloudActivationDecisionState(
            readinessState: readiness(
              local: LocalSnapshotState.hasUserData,
              remote: RemoteSnapshotState.empty,
              scenario:
                  CloudActivationMatrixScenario.localHasUserDataRemoteEmpty,
            ),
          );

      expect(state.status, CloudActivationDecisionStatus.blocked);
      expect(
        state.options
            .firstWhere(
              (CloudActivationDecisionOption option) =>
                  option.choice == CloudActivationChoice.migrateLocalToCloud,
            )
            .availability,
        CloudActivationChoiceAvailability.requiresConfirmation,
      );
      expect(
        state.options
            .firstWhere(
              (CloudActivationDecisionOption option) =>
                  option.choice == CloudActivationChoice.startWithEmptyCloud,
            )
            .availability,
        CloudActivationChoiceAvailability.requiresConfirmation,
      );
    },
  );

  test('remote user data surfaces replace flow as execution-gated', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          readinessState: readiness(
            local: LocalSnapshotState.empty,
            remote: RemoteSnapshotState.hasUserData,
            scenario: CloudActivationMatrixScenario.localEmptyRemoteHasUserData,
          ),
        );

    expect(state.scenario, CloudActivationScenario.localEmptyRemoteHasData);
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.replaceLocalWithCloud,
          )
          .availability,
      CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
    );
  });

  test('both local and remote user data surface merge as execution-gated', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          readinessState: readiness(
            local: LocalSnapshotState.hasUserData,
            remote: RemoteSnapshotState.hasUserData,
            scenario:
                CloudActivationMatrixScenario.localHasUserDataRemoteHasUserData,
          ),
        );

    expect(state.scenario, CloudActivationScenario.localHasDataRemoteHasData);
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.mergeLocalAndCloud,
          )
          .availability,
      CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
    );
  });

  test('unknown readiness stays fail-closed', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          readinessState: const CloudActivationReadinessState(
            status: CloudActivationReadinessStatus.unknown,
            localSnapshotState: LocalSnapshotState.unknown,
            remoteSnapshotState: RemoteSnapshotState.unknown,
          ),
        );

    expect(state.status, CloudActivationDecisionStatus.unknown);
    expect(state.options, isEmpty);
  });

  test('helper only opens choice screen for blocked and ready states', () {
    expect(
      canOpenCloudActivationChoiceScreen(
        CloudActivationPreflightStatus.blockedByLocalOnlyData,
      ),
      isTrue,
    );
    expect(
      canOpenCloudActivationChoiceScreen(
        CloudActivationPreflightStatus.readyForNextStep,
      ),
      isTrue,
    );
    expect(
      canOpenCloudActivationChoiceScreen(
        CloudActivationPreflightStatus.signedOut,
      ),
      isFalse,
    );
  });
}
