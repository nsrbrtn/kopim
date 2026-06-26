import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/ownership_projection_integrity_service.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';

import 'package:riverpod/riverpod.dart';
import 'package:kopim/core/di/injectors.dart';

enum LocalToCloudMigrationLocalOwnershipConversionStatus {
  succeeded,
  blocked,
  failed,
}

enum LocalToCloudMigrationLocalOwnershipConversionBlockReason {
  missingPreparedState,
  invalidPreparedState,
  integrityViolation,
}

class LocalToCloudMigrationLocalOwnershipConversionResult {
  const LocalToCloudMigrationLocalOwnershipConversionResult._({
    required this.status,
    this.blockReason,
    this.message,
    this.convertedRowCount = 0,
  });

  const LocalToCloudMigrationLocalOwnershipConversionResult.succeeded({
    required int convertedRowCount,
    String? message,
  }) : this._(
         status: LocalToCloudMigrationLocalOwnershipConversionStatus.succeeded,
         convertedRowCount: convertedRowCount,
         message: message,
       );

  const LocalToCloudMigrationLocalOwnershipConversionResult.blocked(
    LocalToCloudMigrationLocalOwnershipConversionBlockReason reason, {
    String? message,
  }) : this._(
         status: LocalToCloudMigrationLocalOwnershipConversionStatus.blocked,
         blockReason: reason,
         message: message,
       );

  const LocalToCloudMigrationLocalOwnershipConversionResult.failed({
    String? message,
  }) : this._(
         status: LocalToCloudMigrationLocalOwnershipConversionStatus.failed,
         message: message,
       );

  final LocalToCloudMigrationLocalOwnershipConversionStatus status;
  final LocalToCloudMigrationLocalOwnershipConversionBlockReason? blockReason;
  final String? message;
  final int convertedRowCount;
}

class LocalToCloudMigrationLocalOwnershipConversionService {
  LocalToCloudMigrationLocalOwnershipConversionService({
    required db.AppDatabase database,
    required OutboxDao outboxDao,
    required LocalToCloudMigrationStateRepository migrationStateRepository,
    required LoggerService logger,
  }) : _database = database,
       _outboxDao = outboxDao,
       _migrationStateRepository = migrationStateRepository,
       _logger = logger;

  final db.AppDatabase _database;
  final OutboxDao _outboxDao;
  final LocalToCloudMigrationStateRepository _migrationStateRepository;
  final LoggerService _logger;

  Future<LocalToCloudMigrationLocalOwnershipConversionResult>
  convertVerifiedMigration({required String uid}) async {
    final LocalToCloudMigrationState? existingState =
        await _migrationStateRepository.getStateForUid(uid);
    if (existingState == null) {
      return const LocalToCloudMigrationLocalOwnershipConversionResult.blocked(
        LocalToCloudMigrationLocalOwnershipConversionBlockReason
            .missingPreparedState,
        message: 'Для local ownership conversion нет prepared migration state.',
      );
    }

    if (!_canStartConversion(existingState.stage)) {
      return LocalToCloudMigrationLocalOwnershipConversionResult.blocked(
        LocalToCloudMigrationLocalOwnershipConversionBlockReason
            .invalidPreparedState,
        message:
            'Текущий migration state ${existingState.stage.name} не допускает local ownership conversion.',
      );
    }

    if (existingState.stage ==
        LocalToCloudMigrationStage.localOwnershipConverted) {
      return const LocalToCloudMigrationLocalOwnershipConversionResult.succeeded(
        convertedRowCount: 0,
        message: 'Local ownership conversion already completed.',
      );
    }

    final List<_OwnershipTarget> targets = _extractOwnershipTargets(
      existingState.plan.rows,
    );
    if (targets.isEmpty) {
      return const LocalToCloudMigrationLocalOwnershipConversionResult.blocked(
        LocalToCloudMigrationLocalOwnershipConversionBlockReason
            .invalidPreparedState,
        message:
            'Migration plan does not contain any direct local ownership targets.',
      );
    }

    await _migrationStateRepository.saveState(
      _copyState(
        existingState,
        stage: LocalToCloudMigrationStage.localOwnershipConversionInProgress,
      ),
    );

    try {
      int convertedRowCount = 0;
      await _database.transaction(() async {
        await _database.updateCurrentSyncState(uid, true);
        final DateTime now = DateTime.now().toUtc();

        for (final _OwnershipTarget target in targets) {
          final db.LocalRowOwnershipRow? currentRow = await _database
              .getOwnership(target.entityType, target.entityId);
          if (currentRow == null) {
            throw _OwnershipConversionBlocked(
              'Отсутствует ownership row для ${target.entityType}:${target.entityId}.',
            );
          }

          if (currentRow.ownershipState == 'cloudOwned' &&
              currentRow.ownerUid == uid) {
            continue;
          }

          if (currentRow.ownershipState != 'localOnly') {
            throw _OwnershipConversionBlocked(
              'Ownership row ${target.entityType}:${target.entityId} имеет статус ${currentRow.ownershipState}, а не localOnly.',
            );
          }

          await (_database.update(_database.localRowOwnership)..where(
                (db.$LocalRowOwnershipTable tbl) =>
                    tbl.entityType.equals(target.entityType) &
                    tbl.entityId.equals(target.entityId),
              ))
              .write(
                db.LocalRowOwnershipCompanion(
                  ownerUid: Value<String?>(uid),
                  ownershipState: const Value<String>('cloudOwned'),
                  source: const Value<String>('migration_conversion'),
                  updatedAt: Value<DateTime>(now),
                  version: Value<int>(currentRow.version + 1),
                ),
              );
          convertedRowCount += 1;
        }

        final List<(String, String)> targetsTuple = targets
            .map((_OwnershipTarget t) => (t.entityType, t.entityId))
            .toList();
        await _outboxDao.consumeMigrationOutboxEntries(targetsTuple);

        final OwnershipProjectionIntegrityService integrityService =
            OwnershipProjectionIntegrityService(_database);
        final List<OwnershipIntegrityIssue> issues = await integrityService
            .runDiagnostics();
        if (issues.isNotEmpty) {
          final OwnershipIntegrityIssue first = issues.first;
          throw _OwnershipConversionBlocked(
            'Ownership integrity check failed after conversion: ${first.type.name} for ${first.entityType}:${first.entityId}.',
          );
        }
      });

      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.localOwnershipConverted,
        ),
      );
      return LocalToCloudMigrationLocalOwnershipConversionResult.succeeded(
        convertedRowCount: convertedRowCount,
        message:
            'Local ownership rows were converted to cloudOwned and legacy local-only outbox entries were consumed.',
      );
    } on _OwnershipConversionBlocked catch (error) {
      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.blockedNeedsUserAction,
        ),
      );
      return LocalToCloudMigrationLocalOwnershipConversionResult.blocked(
        LocalToCloudMigrationLocalOwnershipConversionBlockReason
            .integrityViolation,
        message: error.message,
      );
    } catch (error) {
      _logger.logError(
        'Local ownership conversion failed for $uid: $error',
        error,
      );
      await _migrationStateRepository.saveState(
        _copyState(
          existingState,
          stage: LocalToCloudMigrationStage.blockedNeedsUserAction,
        ),
      );
      return LocalToCloudMigrationLocalOwnershipConversionResult.failed(
        message: error.toString(),
      );
    }
  }

  bool _canStartConversion(LocalToCloudMigrationStage stage) {
    return stage == LocalToCloudMigrationStage.remoteVerified ||
        stage ==
            LocalToCloudMigrationStage.localOwnershipConversionInProgress ||
        stage == LocalToCloudMigrationStage.localOwnershipConverted;
  }

  List<_OwnershipTarget> _extractOwnershipTargets(
    List<LocalToCloudMigrationPlanRow> rows,
  ) {
    final Set<String> seen = <String>{};
    final List<_OwnershipTarget> result = <_OwnershipTarget>[];
    for (final LocalToCloudMigrationPlanRow row in rows) {
      final String? entityType = switch (row.familyKey) {
        'accounts' => 'account',
        'categories' => 'category',
        'tags' => 'tag',
        'transactions' => 'transaction',
        'budgets' => 'budget',
        'budget_instances' => 'budget_instance',
        'saving_goals' => 'saving_goal',
        'credits' => 'credit',
        'credit_cards' => 'credit_card',
        'debts' => 'debt',
        'credit_payment_schedules' => 'credit_payment_schedule',
        'credit_payment_groups' => 'credit_payment_group',
        'upcoming_payments' => 'upcoming_payment',
        'payment_reminders' => 'payment_reminder',
        _ => null,
      };
      if (entityType == null) {
        continue;
      }
      final String key = '$entityType::${row.localRowId}';
      if (seen.add(key)) {
        result.add(
          _OwnershipTarget(entityType: entityType, entityId: row.localRowId),
        );
      }
    }
    return result;
  }

  LocalToCloudMigrationState _copyState(
    LocalToCloudMigrationState state, {
    required LocalToCloudMigrationStage stage,
  }) {
    return LocalToCloudMigrationState(
      uid: state.uid,
      stage: stage,
      createdAt: state.createdAt,
      updatedAt: DateTime.now().toUtc(),
      plan: state.plan,
      version: state.version,
      backupArtifactReference: state.backupArtifactReference,
      backupChecksum: state.backupChecksum,
      localFingerprintBeforeUpload: state.localFingerprintBeforeUpload,
      remoteFingerprintBeforeUpload: state.remoteFingerprintBeforeUpload,
      uploadedRowCountsByFamily: state.uploadedRowCountsByFamily,
      verifiedRowCountsByFamily: state.verifiedRowCountsByFamily,
    );
  }
}

class _OwnershipTarget {
  const _OwnershipTarget({required this.entityType, required this.entityId});

  final String entityType;
  final String entityId;
}

class _OwnershipConversionBlocked implements Exception {
  const _OwnershipConversionBlocked(this.message);

  final String message;
}

final Provider<LocalToCloudMigrationLocalOwnershipConversionService>
localToCloudMigrationLocalOwnershipConversionServiceProvider =
    Provider<LocalToCloudMigrationLocalOwnershipConversionService>((Ref ref) {
      return LocalToCloudMigrationLocalOwnershipConversionService(
        database: ref.watch(appDatabaseProvider),
        outboxDao: ref.watch(outboxDaoProvider),
        migrationStateRepository: ref.watch(
          localToCloudMigrationStateRepositoryProvider,
        ),
        logger: ref.watch(loggerServiceProvider),
      );
    });
