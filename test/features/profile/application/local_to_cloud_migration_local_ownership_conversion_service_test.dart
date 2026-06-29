import 'package:drift/drift.dart' as drift show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_local_ownership_conversion_service.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';

class _FakeLoggerService extends LoggerService {
  @override
  void logError(String message, [dynamic error, StackTrace? stackTrace]) {}

  @override
  void logInfo(String message) {}

  @override
  void logWarning(String message) {}
}

class _FakeMigrationStateRepository
    implements LocalToCloudMigrationStateRepository {
  _FakeMigrationStateRepository(this.state);

  LocalToCloudMigrationState? state;

  @override
  Future<void> clearStateForUid(String uid) async {
    if (state?.uid == uid) {
      state = null;
    }
  }

  @override
  Future<LocalToCloudMigrationState?> getStateForUid(String uid) async {
    if (state?.uid == uid) {
      return state;
    }
    return null;
  }

  @override
  Future<void> saveState(LocalToCloudMigrationState state) async {
    this.state = state;
  }
}

LocalToCloudMigrationState _remoteVerifiedState({
  required List<LocalToCloudMigrationPlanRow> rows,
}) {
  return LocalToCloudMigrationState(
    uid: 'cloud-user-1',
    stage: LocalToCloudMigrationStage.remoteVerified,
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
    plan: LocalToCloudMigrationPlan(
      migrationId: 'ltc-1',
      createdAt: DateTime.utc(2024, 1, 1),
      localFingerprint: 'local:hasUserData',
      remoteFingerprint: 'remote:empty|uid:cloud-user-1',
      candidateFamilyKeys: const <String>['accounts', 'transactions'],
      rows: rows,
    ),
    version: 2,
    backupArtifactReference: '/tmp/migrate-backup.json',
    backupChecksum: 'content-hash',
    localFingerprintBeforeUpload: 'local:hasUserData',
    remoteFingerprintBeforeUpload: 'remote:empty|uid:cloud-user-1',
    uploadedRowCountsByFamily: const <String, int>{
      'accounts': 1,
      'transactions': 1,
    },
    verifiedRowCountsByFamily: const <String, int>{
      'accounts': 1,
      'transactions': 1,
    },
  );
}

void main() {
  late db.AppDatabase database;
  late OutboxDao outboxDao;

  setUp(() {
    database = db.AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    outboxDao = OutboxDao(database, () => 'local-user-1', _FakeLoggerService());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'converts verified ownership rows to cloudOwned and consumes local-only outbox',
    () async {
      await database
          .into(database.accounts)
          .insert(
            db.AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Cash',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            db.TransactionsCompanion.insert(
              id: 'tx-1',
              accountId: 'acc-1',
              amount: 15,
              date: DateTime.utc(2024, 1, 2),
              type: 'expense',
            ),
          );

      await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-1',
        operation: OutboxOperation.upsert,
        payload: const <String, dynamic>{'id': 'acc-1'},
      );
      await outboxDao.enqueue(
        entityType: 'transaction',
        entityId: 'tx-1',
        operation: OutboxOperation.upsert,
        payload: const <String, dynamic>{'id': 'tx-1'},
      );

      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository(
            _remoteVerifiedState(
              rows: const <LocalToCloudMigrationPlanRow>[
                LocalToCloudMigrationPlanRow(
                  familyKey: 'accounts',
                  localRowId: 'acc-1',
                  documentId: 'acc-1',
                ),
                LocalToCloudMigrationPlanRow(
                  familyKey: 'transactions',
                  localRowId: 'tx-1',
                  documentId: 'tx-1',
                ),
              ],
            ),
          );

      final LocalToCloudMigrationLocalOwnershipConversionService service =
          LocalToCloudMigrationLocalOwnershipConversionService(
            database: database,
            outboxDao: outboxDao,
            migrationStateRepository: migrationStateRepository,
            logger: _FakeLoggerService(),
          );

      final LocalToCloudMigrationLocalOwnershipConversionResult result =
          await service.convertVerifiedMigration(uid: 'cloud-user-1');

      expect(
        result.status,
        LocalToCloudMigrationLocalOwnershipConversionStatus.succeeded,
      );
      expect(result.convertedRowCount, 2);
      expect(
        migrationStateRepository.state!.stage,
        LocalToCloudMigrationStage.localOwnershipConverted,
      );

      final db.LocalRowOwnershipRow? accountOwnership = await database
          .getOwnership('account', 'acc-1');
      final db.LocalRowOwnershipRow? transactionOwnership = await database
          .getOwnership('transaction', 'tx-1');
      expect(accountOwnership, isNotNull);
      expect(accountOwnership!.ownershipState, 'cloudOwned');
      expect(accountOwnership.ownerUid, 'cloud-user-1');
      expect(accountOwnership.source, 'migration_conversion');
      expect(transactionOwnership, isNotNull);
      expect(transactionOwnership!.ownershipState, 'cloudOwned');
      expect(transactionOwnership.ownerUid, 'cloud-user-1');
      expect(transactionOwnership.source, 'migration_conversion');

      final List<db.CurrentSyncStateRow> syncStates = await database
          .select(database.currentSyncStates)
          .get();
      expect(syncStates, hasLength(1));
      expect(syncStates.first.currentUid, 'cloud-user-1');
      expect(syncStates.first.syncActive, isTrue);

      expect(await outboxDao.selectLocalOnlyOutboxRows(), isEmpty);
      expect(await outboxDao.selectNullOwnerOutboxRows(), isEmpty);
      expect(await outboxDao.pendingCount(), 0);
    },
  );

  test(
    'blocks conversion and keeps local state when a planned ownership row is missing',
    () async {
      await database
          .into(database.accounts)
          .insert(
            db.AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Cash',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
            ),
          );
      await database.customStatement(
        "DELETE FROM local_row_ownership WHERE entity_type = 'account' AND entity_id = 'acc-1'",
      );

      await outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-1',
        operation: OutboxOperation.upsert,
        payload: const <String, dynamic>{'id': 'acc-1'},
      );

      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository(
            _remoteVerifiedState(
              rows: const <LocalToCloudMigrationPlanRow>[
                LocalToCloudMigrationPlanRow(
                  familyKey: 'accounts',
                  localRowId: 'acc-1',
                  documentId: 'acc-1',
                ),
              ],
            ),
          );

      final LocalToCloudMigrationLocalOwnershipConversionService service =
          LocalToCloudMigrationLocalOwnershipConversionService(
            database: database,
            outboxDao: outboxDao,
            migrationStateRepository: migrationStateRepository,
            logger: _FakeLoggerService(),
          );

      final LocalToCloudMigrationLocalOwnershipConversionResult result =
          await service.convertVerifiedMigration(uid: 'cloud-user-1');

      expect(
        result.status,
        LocalToCloudMigrationLocalOwnershipConversionStatus.blocked,
      );
      expect(
        result.blockReason,
        LocalToCloudMigrationLocalOwnershipConversionBlockReason
            .integrityViolation,
      );
      expect(
        migrationStateRepository.state!.stage,
        LocalToCloudMigrationStage.blockedNeedsUserAction,
      );

      expect(await outboxDao.selectLocalOnlyOutboxRows(), isNotEmpty);
      final List<db.CurrentSyncStateRow> syncStates = await database
          .select(database.currentSyncStates)
          .get();
      expect(syncStates.first.currentUid, isNull);
      expect(syncStates.first.syncActive, isFalse);
    },
  );
}
