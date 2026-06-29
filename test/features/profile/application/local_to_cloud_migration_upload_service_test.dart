import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_upload_service.dart';
import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

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

class _FakePrepareExportBundleUseCase implements PrepareExportBundleUseCase {
  _FakePrepareExportBundleUseCase(this.bundle);

  final ExportBundle bundle;

  @override
  Future<ExportBundle> call() async => bundle;
}

ExportBundle _buildBundle({
  List<AccountEntity> accounts = const <AccountEntity>[],
  List<TransactionEntity> transactions = const <TransactionEntity>[],
}) {
  final ExportBundle base = ExportBundle(
    schemaVersion: '2026-01',
    generatedAt: DateTime.utc(2024, 1, 1),
    accounts: accounts,
    transactions: transactions,
  );
  const ExportBundleIntegrityService integrityService =
      ExportBundleIntegrityService();
  return base.copyWith(integrity: integrityService.buildIntegrity(base));
}

LocalToCloudMigrationState _preparedState({
  required List<LocalToCloudMigrationPlanRow> rows,
}) {
  return LocalToCloudMigrationState(
    uid: 'cloud-user-1',
    stage: LocalToCloudMigrationStage.backupCreated,
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
  );
}

void main() {
  test(
    'uploads prepared accounts and transactions and persists progress',
    () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final AccountRemoteDataSource accountRemoteDataSource =
          AccountRemoteDataSource(firestore);
      final TransactionRemoteDataSource transactionRemoteDataSource =
          TransactionRemoteDataSource(firestore);
      final AccountEntity account = AccountEntity(
        id: 'acc-1',
        name: 'Cash',
        balanceMinor: BigInt.zero,
        openingBalanceMinor: BigInt.zero,
        currency: 'RUB',
        currencyScale: 2,
        type: 'cash',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        amountMinor: BigInt.from(1500),
        amountScale: 2,
        date: DateTime.utc(2024, 1, 2),
        type: 'expense',
        createdAt: DateTime.utc(2024, 1, 2),
        updatedAt: DateTime.utc(2024, 1, 2),
      );

      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository(
            _preparedState(
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

      final LocalToCloudMigrationUploadService service =
          LocalToCloudMigrationUploadService(
            firestore: firestore,
            migrationStateRepository: migrationStateRepository,
            prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
              _buildBundle(
                accounts: <AccountEntity>[account],
                transactions: <TransactionEntity>[transaction],
              ),
            ),
            uploaders: <String, LocalToCloudMigrationEntityUploader>{
              'accounts': (String uid, Object entity) {
                return accountRemoteDataSource.upsert(
                  uid,
                  entity as AccountEntity,
                );
              },
              'transactions': (String uid, Object entity) {
                return transactionRemoteDataSource.upsert(
                  uid,
                  entity as TransactionEntity,
                );
              },
            },
            logger: _FakeLoggerService(),
          );

      final LocalToCloudMigrationUploadResult result = await service
          .uploadPreparedMigration(uid: 'cloud-user-1');

      expect(result.status, LocalToCloudMigrationUploadStatus.succeeded);
      expect(result.uploadedRowCountsByFamily['accounts'], 1);
      expect(result.uploadedRowCountsByFamily['transactions'], 1);
      expect(
        migrationStateRepository.state!.stage,
        LocalToCloudMigrationStage.uploadCompleted,
      );
      expect(
        migrationStateRepository.state!.uploadedRowCountsByFamily['accounts'],
        1,
      );
      expect(
        (await firestore
                .collection('users')
                .doc('cloud-user-1')
                .collection('accounts')
                .doc('acc-1')
                .get())
            .exists,
        isTrue,
      );
      expect(
        (await firestore
                .collection('users')
                .doc('cloud-user-1')
                .collection('transactions')
                .doc('tx-1')
                .get())
            .exists,
        isTrue,
      );
    },
  );

  test(
    'blocks upload when prepared plan no longer matches export bundle',
    () async {
      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository(
            _preparedState(
              rows: const <LocalToCloudMigrationPlanRow>[
                LocalToCloudMigrationPlanRow(
                  familyKey: 'accounts',
                  localRowId: 'acc-missing',
                  documentId: 'acc-missing',
                ),
              ],
            ),
          );

      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final LocalToCloudMigrationUploadService service =
          LocalToCloudMigrationUploadService(
            firestore: firestore,
            migrationStateRepository: migrationStateRepository,
            prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
              _buildBundle(),
            ),
            uploaders: const <String, LocalToCloudMigrationEntityUploader>{},
            logger: _FakeLoggerService(),
          );

      final LocalToCloudMigrationUploadResult result = await service
          .uploadPreparedMigration(uid: 'cloud-user-1');

      expect(result.status, LocalToCloudMigrationUploadStatus.blocked);
      expect(
        result.blockReason,
        LocalToCloudMigrationUploadBlockReason.planMismatch,
      );
      expect(
        migrationStateRepository.state!.stage,
        LocalToCloudMigrationStage.backupCreated,
      );
    },
  );
}
