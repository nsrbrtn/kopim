import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';

void main() {
  test('savePendingChoice stores selected scenario snapshot', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    const CloudActivationDecisionState decisionState =
        CloudActivationDecisionState(
          status: CloudActivationDecisionStatus.choiceRequired,
          title: 'Как включить облачные функции',
          subtitle: 'Сначала выберите сценарий.',
          body: 'Данные пока не меняются.',
          followupNote: 'Только подготовительный этап.',
          recommendedChoice: null,
          localSnapshotState: CloudActivationSnapshotState.empty,
          remoteSnapshotState: CloudActivationSnapshotState.unknown,
          localFingerprint: 'local:empty',
          remoteFingerprint: 'remote:empty|uid:test',
          scenario: CloudActivationScenario.localEmptyRemoteEmpty,
          options: <CloudActivationDecisionOption>[],
        );

    container
        .read(cloudActivationIntentProvider.notifier)
        .savePendingChoice(
          choice: CloudActivationChoice.enableCloudSync,
          decisionState: decisionState,
        );

    final CloudActivationIntentState state = container.read(
      cloudActivationIntentProvider,
    );
    expect(state.stage, CloudActivationIntentStage.pendingChoice);
    expect(state.pendingChoice, CloudActivationChoice.enableCloudSync);
    expect(state.scenario, CloudActivationScenario.localEmptyRemoteEmpty);
    expect(state.localSnapshotState, CloudActivationSnapshotState.empty);
    expect(state.remoteSnapshotState, CloudActivationSnapshotState.unknown);
    expect(state.localFingerprint, 'local:empty');
    expect(state.remoteFingerprint, 'remote:empty|uid:test');
  });

  test('clearPendingChoice resets controller to idle state', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(cloudActivationIntentProvider.notifier)
        .savePendingChoice(
          choice: CloudActivationChoice.startWithEmptyCloud,
          decisionState: const CloudActivationDecisionState(
            status: CloudActivationDecisionStatus.blocked,
            title: 'Как включить облачные функции',
            subtitle: 'Сначала выберите сценарий.',
            body: 'Данные пока не меняются.',
            followupNote: 'Только подготовительный этап.',
            recommendedChoice: null,
            localSnapshotState: CloudActivationSnapshotState.hasData,
            remoteSnapshotState: CloudActivationSnapshotState.unknown,
            localFingerprint: 'local:hasData',
            remoteFingerprint: 'remote:empty|uid:test',
            scenario: CloudActivationScenario.localHasDataRemoteEmpty,
            options: <CloudActivationDecisionOption>[],
          ),
        );

    container.read(cloudActivationIntentProvider.notifier).clearPendingChoice();

    final CloudActivationIntentState state = container.read(
      cloudActivationIntentProvider,
    );
    expect(state.hasPendingChoice, isFalse);
    expect(state.pendingChoice, isNull);
    expect(state.stage, CloudActivationIntentStage.idle);
    expect(state.scenario, isNull);
  });
}
