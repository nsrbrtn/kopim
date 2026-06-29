import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_readiness_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/profile/domain/entities/migration_freeze_state.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

class _FakeMigrationWriteGuard extends MigrationWriteGuard {
  _FakeMigrationWriteGuard(this.calls);

  final List<String> calls;
  MigrationFreezeState? state;
  MigrationMutationActivitySnapshot snapshot =
      const MigrationMutationActivitySnapshot(
        activeRepositoryWrites: 0,
        activeImportMutations: 0,
        activeBackgroundMutations: 0,
        activeMigrationInternalWrites: 0,
        persistedImportInProgress: false,
      );
  bool throwQuiescence = false;

  @override
  Future<void> activateFreeze({
    String? uid,
    String phase = 'pre_inventory_capture',
    bool uploadStarted = false,
  }) async {
    calls.add('activateFreeze:$phase');
    state = MigrationFreezeState(
      uid: uid,
      startedAt: DateTime.utc(2026, 6, 23),
      phase: phase,
      uploadStarted: uploadStarted,
      version: 1,
    );
  }

  @override
  Future<MigrationFreezeState?> currentState() async {
    calls.add('currentState');
    return state;
  }

  @override
  Future<void> ensureOutboxMutationAllowed({
    required String entityType,
  }) async {}

  @override
  Future<void> ensureQuiescentForInventoryCapture() async {
    calls.add('ensureQuiescentForInventoryCapture');
    if (throwQuiescence) {
      throw MigrationQuiescenceRequired(snapshot);
    }
  }

  @override
  Future<void> refreshState() async {}

  @override
  Future<void> releaseFreeze({String? expectedPhase}) async {
    calls.add('releaseFreeze');
    state = null;
  }

  @override
  Future<T> runBackgroundMutation<T>({
    required Future<T> Function() action,
  }) async {
    return action();
  }

  @override
  Future<T> runImportMutation<T>({required Future<T> Function() action}) async {
    return action();
  }

  @override
  Future<T> runRepositoryWrite<T>({
    required String entityType,
    required Future<T> Function() action,
  }) async {
    return action();
  }

  @override
  Future<T> runWithMigrationContext<T>(Future<T> Function() action) async {
    return action();
  }

  @override
  Future<MigrationMutationActivitySnapshot> snapshotActivity() async {
    return snapshot;
  }
}

class _FakeLocalSnapshotSummaryService extends LocalSnapshotSummaryService {
  _FakeLocalSnapshotSummaryService(this.summary, this.calls)
    : super(
        database: AppDatabase.connect(
          DatabaseConnection(NativeDatabase.memory()),
        ),
        outboxDao: OutboxDao(
          AppDatabase.connect(DatabaseConnection(NativeDatabase.memory())),
          () => null,
        ),
        activationRuntimeGuard: CloudActivationRuntimeGuard(),
      );

  final LocalSnapshotSummary summary;
  final List<String> calls;
  bool? lastIncludeActivationGuard;

  @override
  Future<LocalSnapshotSummary> summarize({
    bool includeActivationGuard = true,
  }) async {
    calls.add('summarize');
    lastIncludeActivationGuard = includeActivationGuard;
    return summary;
  }
}

class _FakeSnapshotBuilder
    extends LocalToCloudMigrationInventorySnapshotBuilder {
  _FakeSnapshotBuilder(this.snapshot, this.calls)
    : super(AppDatabase.connect(DatabaseConnection(NativeDatabase.memory())));

  final LocalToCloudMigrationInventorySnapshot snapshot;
  final List<String> calls;

  @override
  Future<LocalToCloudMigrationInventorySnapshot> build() async {
    calls.add('buildSnapshot');
    return snapshot;
  }
}

class _FakeInventoryValidator extends LocalToCloudMigrationInventoryValidator {
  _FakeInventoryValidator(this.result, this.calls)
    : super(policy: LocalToCloudMigrationInventoryPolicy());

  final LocalToCloudMigrationReadinessResult result;
  final List<String> calls;

  @override
  LocalToCloudMigrationReadinessResult validate({
    required Map<String, List<LocalToCloudMigrationRow>> rowsByFamily,
    Iterable<String>? candidateFamilyKeys,
  }) {
    calls.add('validate');
    return result;
  }
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test(
    'runs freeze, stable snapshot, builder, validator, then releases freeze',
    () async {
      final List<String> calls = <String>[];
      final _FakeMigrationWriteGuard guard = _FakeMigrationWriteGuard(calls);
      final _FakeLocalSnapshotSummaryService summaryService =
          _FakeLocalSnapshotSummaryService(
            const LocalSnapshotSummary(
              state: LocalSnapshotState.hasUserData,
              hasUserData: true,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:hasUserData',
            ),
            calls,
          );
      final _FakeSnapshotBuilder snapshotBuilder = _FakeSnapshotBuilder(
        const LocalToCloudMigrationInventorySnapshot(
          candidateFamilyKeys: <String>{'accounts'},
          rowsByFamily: <String, List<LocalToCloudMigrationRow>>{
            'accounts': <LocalToCloudMigrationRow>[
              LocalToCloudMigrationRow(
                familyKey: 'accounts',
                localRowId: 'acc-1',
                reusedDocumentId: 'acc-1',
              ),
            ],
          },
        ),
        calls,
      );
      final _FakeInventoryValidator validator = _FakeInventoryValidator(
        const LocalToCloudMigrationReadinessResult.ready(),
        calls,
      );
      final LocalToCloudMigrationReadinessService service =
          LocalToCloudMigrationReadinessService(
            migrationWriteGuard: guard,
            localSnapshotSummaryService: summaryService,
            snapshotBuilder: snapshotBuilder,
            inventoryValidator: validator,
          );

      final LocalToCloudMigrationPreflightResult result = await service
          .captureReadiness(uid: 'cloud-user-1');

      expect(result.isReady, isTrue);
      expect(summaryService.lastIncludeActivationGuard, isFalse);
      expect(calls, <String>[
        'currentState',
        'activateFreeze:pre_inventory_capture',
        'ensureQuiescentForInventoryCapture',
        'summarize',
        'buildSnapshot',
        'validate',
        'releaseFreeze',
      ]);
    },
  );

  test('blocks on active mutations and still releases freeze', () async {
    final _FakeMigrationWriteGuard guard = _FakeMigrationWriteGuard(<String>[])
      ..throwQuiescence = true
      ..snapshot = const MigrationMutationActivitySnapshot(
        activeRepositoryWrites: 1,
        activeImportMutations: 0,
        activeBackgroundMutations: 0,
        activeMigrationInternalWrites: 0,
        persistedImportInProgress: false,
      );
    final LocalToCloudMigrationReadinessService service =
        LocalToCloudMigrationReadinessService(
          migrationWriteGuard: guard,
          localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
            const LocalSnapshotSummary(
              state: LocalSnapshotState.hasUserData,
              hasUserData: true,
              hasSystemData: false,
              pendingOutboxCount: 0,
              fingerprint: 'local:hasUserData',
            ),
            <String>[],
          ),
          snapshotBuilder: _FakeSnapshotBuilder(
            const LocalToCloudMigrationInventorySnapshot(
              candidateFamilyKeys: <String>{},
              rowsByFamily: <String, List<LocalToCloudMigrationRow>>{},
            ),
            <String>[],
          ),
          inventoryValidator: _FakeInventoryValidator(
            const LocalToCloudMigrationReadinessResult.ready(),
            <String>[],
          ),
        );

    final LocalToCloudMigrationPreflightResult result = await service
        .captureReadiness(uid: 'cloud-user-1');

    expect(result.isReady, isFalse);
    expect(
      result.blockReason,
      LocalToCloudMigrationPreflightBlockReason.activeMutationsDetected,
    );
    expect(result.activitySnapshot?.activeRepositoryWrites, 1);
    expect(guard.calls.last, 'releaseFreeze');
  });

  test('blocks before builder when local snapshot is not migratable', () async {
    final List<String> calls = <String>[];
    final _FakeMigrationWriteGuard guard = _FakeMigrationWriteGuard(calls);
    final LocalToCloudMigrationReadinessService service =
        LocalToCloudMigrationReadinessService(
          migrationWriteGuard: guard,
          localSnapshotSummaryService: _FakeLocalSnapshotSummaryService(
            const LocalSnapshotSummary(
              state: LocalSnapshotState.hasPendingOutbox,
              hasUserData: true,
              hasSystemData: false,
              pendingOutboxCount: 1,
              fingerprint: 'local:pendingOutbox',
            ),
            calls,
          ),
          snapshotBuilder: _FakeSnapshotBuilder(
            const LocalToCloudMigrationInventorySnapshot(
              candidateFamilyKeys: <String>{},
              rowsByFamily: <String, List<LocalToCloudMigrationRow>>{},
            ),
            calls,
          ),
          inventoryValidator: _FakeInventoryValidator(
            const LocalToCloudMigrationReadinessResult.ready(),
            calls,
          ),
        );

    final LocalToCloudMigrationPreflightResult result = await service
        .captureReadiness(uid: 'cloud-user-1');

    expect(result.isReady, isFalse);
    expect(
      result.blockReason,
      LocalToCloudMigrationPreflightBlockReason.localSnapshotNotMigratable,
    );
    expect(calls, <String>[
      'currentState',
      'activateFreeze:pre_inventory_capture',
      'ensureQuiescentForInventoryCapture',
      'summarize',
      'releaseFreeze',
    ]);
  });
}
