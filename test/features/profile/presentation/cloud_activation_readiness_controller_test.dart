import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_readiness_controller.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

void main() {
  test('signed out preflight stays unavailable with sign-in block reason', () {
    final CloudActivationReadinessState state =
        resolveCloudActivationReadinessState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.signedOut,
          ),
          localSummaryAsync: const AsyncValue<LocalSnapshotSummary>.loading(),
          remoteSummaryAsync: null,
          intentState: const CloudActivationIntentState.idle(),
        );

    expect(state.status, CloudActivationReadinessStatus.unavailable);
    expect(state.blockReason, CloudActivationBlockReason.signInRequired);
  });

  test('ready preflight plus local summary opens choice readiness', () {
    final CloudActivationReadinessState state =
        resolveCloudActivationReadinessState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.readyForNextStep,
          ),
          localSummaryAsync: const AsyncValue<LocalSnapshotSummary>.data(
            LocalSnapshotSummary(
              state: LocalSnapshotState.hasOnlySystemData,
              hasUserData: false,
              hasSystemData: true,
              pendingOutboxCount: 0,
              fingerprint:
                  'local:hasOnlySystemData|user:false|system:true|outbox:0',
            ),
          ),
          remoteSummaryAsync: const AsyncValue<CloudSnapshotSummary>.data(
            CloudSnapshotSummary(
              state: RemoteSnapshotState.hasOnlyMetadata,
              hasUserData: false,
              hasMetadata: true,
              hasTombstonesOnly: false,
              fingerprint: 'remote:hasOnlyMetadata|uid:user-1',
            ),
          ),
          intentState: const CloudActivationIntentState.idle(),
        );

    expect(state.status, CloudActivationReadinessStatus.readyForChoice);
    expect(state.localSnapshotState, LocalSnapshotState.hasOnlySystemData);
    expect(state.remoteSnapshotState, RemoteSnapshotState.hasOnlyMetadata);
    expect(
      state.matrixScenario,
      CloudActivationMatrixScenario.localEmptyRemoteMetadataOnly,
    );
  });

  test('pending session intent moves readiness to waitingForConfirmation', () {
    final CloudActivationReadinessState state =
        resolveCloudActivationReadinessState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.readyForNextStep,
          ),
          localSummaryAsync: const AsyncValue<LocalSnapshotSummary>.data(
            LocalSnapshotSummary(
              state: LocalSnapshotState.empty,
              hasUserData: false,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:empty|user:false|system:false|outbox:0',
            ),
          ),
          intentState: const CloudActivationIntentState(
            pendingChoice: CloudActivationChoice.enableCloudSync,
            stage: CloudActivationIntentStage.pendingChoice,
            scenario: CloudActivationScenario.localEmptyRemoteEmpty,
            localSnapshotState: CloudActivationSnapshotState.empty,
            remoteSnapshotState: CloudActivationSnapshotState.empty,
            localFingerprint: 'local:empty|user:false|system:false|outbox:0',
            remoteFingerprint: 'remote:empty|uid:user-1',
          ),
          remoteSummaryAsync: const AsyncValue<CloudSnapshotSummary>.data(
            CloudSnapshotSummary(
              state: RemoteSnapshotState.empty,
              hasUserData: false,
              hasMetadata: false,
              hasTombstonesOnly: false,
              fingerprint: 'remote:empty|uid:user-1',
            ),
          ),
        );

    expect(state.status, CloudActivationReadinessStatus.waitingForConfirmation);
    expect(state.pendingChoice, CloudActivationChoice.enableCloudSync);
    expect(state.localFingerprint, contains('local:empty'));
  });

  test('remote tombstones stay fail-closed instead of metadata-only', () {
    final CloudActivationReadinessState state =
        resolveCloudActivationReadinessState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.blockedByLocalOnlyData,
          ),
          localSummaryAsync: const AsyncValue<LocalSnapshotSummary>.data(
            LocalSnapshotSummary(
              state: LocalSnapshotState.hasUserData,
              hasUserData: true,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:hasUserData|user:true|system:false|outbox:0',
            ),
          ),
          remoteSummaryAsync: const AsyncValue<CloudSnapshotSummary>.data(
            CloudSnapshotSummary(
              state: RemoteSnapshotState.hasTombstonesOnly,
              hasUserData: false,
              hasMetadata: false,
              hasTombstonesOnly: true,
              fingerprint: 'remote:hasTombstonesOnly|uid:user-1',
            ),
          ),
          intentState: const CloudActivationIntentState.idle(),
        );

    expect(state.status, CloudActivationReadinessStatus.unknown);
    expect(state.blockReason, CloudActivationBlockReason.remoteSnapshotUnknown);
  });

  test('local summary failure stays fail-closed', () {
    final CloudActivationReadinessState state =
        resolveCloudActivationReadinessState(
          preflightState: const CloudActivationPreflightState(
            CloudActivationPreflightStatus.blockedByLocalOnlyData,
          ),
          localSummaryAsync: AsyncValue<LocalSnapshotSummary>.error(
            StateError('failed'),
            StackTrace.empty,
          ),
          remoteSummaryAsync: const AsyncValue<CloudSnapshotSummary>.loading(),
          intentState: const CloudActivationIntentState.idle(),
        );

    expect(state.status, CloudActivationReadinessStatus.unknown);
    expect(state.blockReason, CloudActivationBlockReason.localSnapshotUnknown);
  });

  test(
    'remote probe is not invoked for activation-irrelevant preflight states',
    () {
      int remoteProbeCount = 0;
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          cloudActivationPreflightProvider.overrideWithValue(
            const CloudActivationPreflightState(
              CloudActivationPreflightStatus.signedOut,
            ),
          ),
          localSnapshotSummaryProvider.overrideWith(
            (Ref ref) async => const LocalSnapshotSummary(
              state: LocalSnapshotState.empty,
              hasUserData: false,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:empty|user:false|system:false|outbox:0',
            ),
          ),
          cloudSnapshotSummaryServiceProvider.overrideWithValue(
            CloudSnapshotSummaryService(
              firestore: FakeFirebaseFirestore(),
              readCollection: (String uid, String collection) async {
                remoteProbeCount += 1;
                return <Map<String, dynamic>>[];
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final CloudActivationReadinessState state = container
          .read(cloudActivationReadinessProvider)
          .asData!
          .value;

      expect(state.status, CloudActivationReadinessStatus.unavailable);
      expect(remoteProbeCount, 0);
    },
  );
}
