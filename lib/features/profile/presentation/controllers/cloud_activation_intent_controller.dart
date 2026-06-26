import 'package:riverpod/riverpod.dart';

import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';

enum CloudActivationIntentStage { idle, pendingChoice }

class CloudActivationIntentState {
  const CloudActivationIntentState({
    required this.pendingChoice,
    required this.stage,
    required this.scenario,
    required this.localSnapshotState,
    required this.remoteSnapshotState,
    required this.localFingerprint,
    required this.remoteFingerprint,
  });

  const CloudActivationIntentState.idle()
    : this(
        pendingChoice: null,
        stage: CloudActivationIntentStage.idle,
        scenario: null,
        localSnapshotState: CloudActivationSnapshotState.unknown,
        remoteSnapshotState: CloudActivationSnapshotState.unknown,
        localFingerprint: null,
        remoteFingerprint: null,
      );

  final CloudActivationChoice? pendingChoice;
  final CloudActivationIntentStage stage;
  final CloudActivationScenario? scenario;
  final CloudActivationSnapshotState localSnapshotState;
  final CloudActivationSnapshotState remoteSnapshotState;
  final String? localFingerprint;
  final String? remoteFingerprint;

  bool get hasPendingChoice =>
      pendingChoice != null &&
      stage == CloudActivationIntentStage.pendingChoice;

  CloudActivationIntentState copyWith({
    CloudActivationChoice? pendingChoice,
    CloudActivationIntentStage? stage,
    CloudActivationScenario? scenario,
    CloudActivationSnapshotState? localSnapshotState,
    CloudActivationSnapshotState? remoteSnapshotState,
    String? localFingerprint,
    String? remoteFingerprint,
  }) {
    return CloudActivationIntentState(
      pendingChoice: pendingChoice ?? this.pendingChoice,
      stage: stage ?? this.stage,
      scenario: scenario ?? this.scenario,
      localSnapshotState: localSnapshotState ?? this.localSnapshotState,
      remoteSnapshotState: remoteSnapshotState ?? this.remoteSnapshotState,
      localFingerprint: localFingerprint ?? this.localFingerprint,
      remoteFingerprint: remoteFingerprint ?? this.remoteFingerprint,
    );
  }
}

class CloudActivationIntentController
    extends Notifier<CloudActivationIntentState> {
  @override
  CloudActivationIntentState build() => const CloudActivationIntentState.idle();

  void savePendingChoice({
    required CloudActivationChoice choice,
    required CloudActivationDecisionState decisionState,
  }) {
    state = CloudActivationIntentState(
      pendingChoice: choice,
      stage: CloudActivationIntentStage.pendingChoice,
      scenario: decisionState.scenario,
      localSnapshotState: decisionState.localSnapshotState,
      remoteSnapshotState: decisionState.remoteSnapshotState,
      localFingerprint: decisionState.localFingerprint,
      remoteFingerprint: decisionState.remoteFingerprint,
    );
  }

  void clearPendingChoice() {
    state = const CloudActivationIntentState.idle();
  }
}

final NotifierProvider<
  CloudActivationIntentController,
  CloudActivationIntentState
>
cloudActivationIntentProvider =
    NotifierProvider<
      CloudActivationIntentController,
      CloudActivationIntentState
    >(CloudActivationIntentController.new);
