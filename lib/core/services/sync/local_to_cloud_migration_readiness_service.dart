import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/profile/domain/entities/migration_freeze_state.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

enum LocalToCloudMigrationPreflightStatus { ready, blocked }

enum LocalToCloudMigrationPreflightBlockReason {
  freezeAlreadyActive,
  localSnapshotNotMigratable,
  activeMutationsDetected,
  inventoryReadinessBlocked,
}

class LocalToCloudMigrationPreflightResult {
  const LocalToCloudMigrationPreflightResult._({
    required this.status,
    this.blockReason,
    this.localSummary,
    this.inventorySnapshot,
    this.readinessResult,
    this.activitySnapshot,
    this.existingFreezeState,
  });

  const LocalToCloudMigrationPreflightResult.ready({
    required LocalSnapshotSummary localSummary,
    required LocalToCloudMigrationInventorySnapshot inventorySnapshot,
    required LocalToCloudMigrationReadinessResult readinessResult,
  }) : this._(
         status: LocalToCloudMigrationPreflightStatus.ready,
         localSummary: localSummary,
         inventorySnapshot: inventorySnapshot,
         readinessResult: readinessResult,
       );

  const LocalToCloudMigrationPreflightResult.blocked({
    required LocalToCloudMigrationPreflightBlockReason reason,
    LocalSnapshotSummary? localSummary,
    LocalToCloudMigrationInventorySnapshot? inventorySnapshot,
    LocalToCloudMigrationReadinessResult? readinessResult,
    MigrationMutationActivitySnapshot? activitySnapshot,
    MigrationFreezeState? existingFreezeState,
  }) : this._(
         status: LocalToCloudMigrationPreflightStatus.blocked,
         blockReason: reason,
         localSummary: localSummary,
         inventorySnapshot: inventorySnapshot,
         readinessResult: readinessResult,
         activitySnapshot: activitySnapshot,
         existingFreezeState: existingFreezeState,
       );

  final LocalToCloudMigrationPreflightStatus status;
  final LocalToCloudMigrationPreflightBlockReason? blockReason;
  final LocalSnapshotSummary? localSummary;
  final LocalToCloudMigrationInventorySnapshot? inventorySnapshot;
  final LocalToCloudMigrationReadinessResult? readinessResult;
  final MigrationMutationActivitySnapshot? activitySnapshot;
  final MigrationFreezeState? existingFreezeState;

  bool get isReady => status == LocalToCloudMigrationPreflightStatus.ready;
}

class LocalToCloudMigrationReadinessService {
  const LocalToCloudMigrationReadinessService({
    required MigrationWriteGuard migrationWriteGuard,
    required LocalSnapshotSummaryService localSnapshotSummaryService,
    required LocalToCloudMigrationInventorySnapshotBuilder snapshotBuilder,
    required LocalToCloudMigrationInventoryValidator inventoryValidator,
  }) : _migrationWriteGuard = migrationWriteGuard,
       _localSnapshotSummaryService = localSnapshotSummaryService,
       _snapshotBuilder = snapshotBuilder,
       _inventoryValidator = inventoryValidator;

  final MigrationWriteGuard _migrationWriteGuard;
  final LocalSnapshotSummaryService _localSnapshotSummaryService;
  final LocalToCloudMigrationInventorySnapshotBuilder _snapshotBuilder;
  final LocalToCloudMigrationInventoryValidator _inventoryValidator;

  Future<LocalToCloudMigrationPreflightResult> captureReadiness({
    String? uid,
  }) async {
    final MigrationFreezeState? existingFreeze = await _migrationWriteGuard
        .currentState();
    if (existingFreeze != null) {
      return LocalToCloudMigrationPreflightResult.blocked(
        reason: LocalToCloudMigrationPreflightBlockReason.freezeAlreadyActive,
        existingFreezeState: existingFreeze,
      );
    }

    await _migrationWriteGuard.activateFreeze(
      uid: uid,
      phase: 'pre_inventory_capture',
      uploadStarted: false,
    );

    try {
      await _migrationWriteGuard.ensureQuiescentForInventoryCapture();

      final LocalSnapshotSummary localSummary =
          await _localSnapshotSummaryService.summarize(
            includeActivationGuard: false,
          );
      if (!_isMigratableLocalSummary(localSummary)) {
        return LocalToCloudMigrationPreflightResult.blocked(
          reason: LocalToCloudMigrationPreflightBlockReason
              .localSnapshotNotMigratable,
          localSummary: localSummary,
        );
      }

      final LocalToCloudMigrationInventorySnapshot inventorySnapshot =
          await _snapshotBuilder.build();
      final LocalToCloudMigrationReadinessResult readinessResult =
          _inventoryValidator.validate(
            rowsByFamily: inventorySnapshot.rowsByFamily,
            candidateFamilyKeys: inventorySnapshot.candidateFamilyKeys,
          );

      if (!readinessResult.isReady) {
        return LocalToCloudMigrationPreflightResult.blocked(
          reason: LocalToCloudMigrationPreflightBlockReason
              .inventoryReadinessBlocked,
          localSummary: localSummary,
          inventorySnapshot: inventorySnapshot,
          readinessResult: readinessResult,
        );
      }

      return LocalToCloudMigrationPreflightResult.ready(
        localSummary: localSummary,
        inventorySnapshot: inventorySnapshot,
        readinessResult: readinessResult,
      );
    } on MigrationQuiescenceRequired catch (error) {
      return LocalToCloudMigrationPreflightResult.blocked(
        reason:
            LocalToCloudMigrationPreflightBlockReason.activeMutationsDetected,
        activitySnapshot: error.snapshot,
      );
    } finally {
      await _migrationWriteGuard.releaseFreeze();
    }
  }

  bool _isMigratableLocalSummary(LocalSnapshotSummary summary) {
    return summary.state == LocalSnapshotState.hasUserData &&
        summary.pendingOutboxCount == 0;
  }
}
