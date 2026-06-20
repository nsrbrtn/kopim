import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';

void main() {
  DataModeState stateFor(DataMode mode) {
    return DataModeState(
      dataMode: mode,
      entitlementState: CloudEntitlementState.active,
      migrationDecision: MigrationDecision.none,
    );
  }

  test('blocked preflight maps to localHasData choice model', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.blockedByLocalOnlyData,
          ),
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.cloudBlockedByLocalData),
          ),
        );

    expect(state.status, CloudActivationDecisionStatus.blocked);
    expect(state.scenario, CloudActivationScenario.localHasDataRemoteUnknown);
    expect(state.localSnapshotState, CloudActivationSnapshotState.hasData);
    expect(state.remoteSnapshotState, CloudActivationSnapshotState.unknown);
    expect(state.options, hasLength(5));
    expect(
      state.options.first.availability,
      CloudActivationChoiceAvailability.available,
    );
    expect(
      state.options[1].availability,
      CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
    );
    expect(
      state.options[2].availability,
      CloudActivationChoiceAvailability.requiresConfirmation,
    );
  });

  test('ready preflight maps to localEmpty choice model', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.readyForNextStep,
          ),
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.localOnly),
          ),
        );

    expect(state.status, CloudActivationDecisionStatus.choiceRequired);
    expect(state.scenario, CloudActivationScenario.localEmptyRemoteUnknown);
    expect(state.localSnapshotState, CloudActivationSnapshotState.empty);
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.startWithEmptyCloud,
          )
          .availability,
      CloudActivationChoiceAvailability.requiresConfirmation,
    );
    expect(
      state.options
          .firstWhere(
            (CloudActivationDecisionOption option) =>
                option.choice == CloudActivationChoice.migrateLocalToCloud,
          )
          .availability,
      CloudActivationChoiceAvailability.unavailableForCurrentScenario,
    );
  });

  test('unknown local state stays fail-closed', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.blockedByLocalOnlyData,
          ),
          dataModeAsync: const AsyncValue<DataModeState>.loading(),
        );

    expect(state.status, CloudActivationDecisionStatus.unknown);
    expect(state.options, isEmpty);
  });

  test('signed out preflight does not open choice model', () {
    final CloudActivationDecisionState state =
        resolveCloudActivationDecisionState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.signedOut,
          ),
          dataModeAsync: AsyncValue<DataModeState>.data(
            stateFor(DataMode.localOnly),
          ),
        );

    expect(state.status, CloudActivationDecisionStatus.unavailable);
    expect(state.canChoose, isFalse);
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
