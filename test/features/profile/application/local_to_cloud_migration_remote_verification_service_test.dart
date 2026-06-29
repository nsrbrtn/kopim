import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/profile/application/local_to_cloud_migration_remote_verification_service.dart';
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

LocalToCloudMigrationState _uploadedState({
  required List<LocalToCloudMigrationPlanRow> rows,
}) {
  return LocalToCloudMigrationState(
    uid: 'cloud-user-1',
    stage: LocalToCloudMigrationStage.uploadCompleted,
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
  );
}

Future<Map<String, Map<String, dynamic>>> _readCollection(
  FakeFirebaseFirestore firestore,
  String uid,
  String collection,
) async {
  final QuerySnapshot<Map<String, dynamic>> query = await firestore
      .collection('users')
      .doc(uid)
      .collection(collection)
      .get();
  return <String, Map<String, dynamic>>{
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in query.docs)
      doc.id: doc.data(),
  };
}

void main() {
  test(
    'verifies uploaded remote graph and persists remoteVerified stage',
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
      await accountRemoteDataSource.upsert('cloud-user-1', account);
      await transactionRemoteDataSource.upsert('cloud-user-1', transaction);

      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository(
            _uploadedState(
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

      final LocalToCloudMigrationRemoteVerificationService service =
          LocalToCloudMigrationRemoteVerificationService(
            migrationStateRepository: migrationStateRepository,
            prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
              _buildBundle(
                accounts: <AccountEntity>[account],
                transactions: <TransactionEntity>[transaction],
              ),
            ),
            readers: <String, LocalToCloudMigrationRemoteCollectionReader>{
              'accounts': (String uid) {
                return _readCollection(firestore, uid, 'accounts');
              },
              'transactions': (String uid) {
                return _readCollection(firestore, uid, 'transactions');
              },
            },
            expectedPayloadBuilders:
                <String, LocalToCloudMigrationExpectedRemotePayloadBuilder>{
                  'accounts': (Object entity) {
                    return accountRemoteDataSource.mapAccount(
                      entity as AccountEntity,
                    );
                  },
                  'transactions': (Object entity) {
                    return transactionRemoteDataSource.mapTransaction(
                      entity as TransactionEntity,
                    );
                  },
                },
            logger: _FakeLoggerService(),
          );

      final LocalToCloudMigrationRemoteVerificationResult result = await service
          .verifyUploadedGraph(uid: 'cloud-user-1');

      expect(
        result.status,
        LocalToCloudMigrationRemoteVerificationStatus.succeeded,
      );
      expect(result.verifiedRowCountsByFamily['accounts'], 1);
      expect(result.verifiedRowCountsByFamily['transactions'], 1);
      expect(
        migrationStateRepository.state!.stage,
        LocalToCloudMigrationStage.remoteVerified,
      );
      expect(
        migrationStateRepository
            .state!
            .verifiedRowCountsByFamily['transactions'],
        1,
      );
    },
  );

  test(
    'blocks verification when unexpected remote documents are present',
    () async {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final AccountRemoteDataSource accountRemoteDataSource =
          AccountRemoteDataSource(firestore);
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
      await accountRemoteDataSource.upsert('cloud-user-1', account);
      await firestore
          .collection('users')
          .doc('cloud-user-1')
          .collection('accounts')
          .doc('acc-extra')
          .set(<String, dynamic>{'id': 'acc-extra', 'name': 'Unexpected'});

      final _FakeMigrationStateRepository migrationStateRepository =
          _FakeMigrationStateRepository(
            _uploadedState(
              rows: const <LocalToCloudMigrationPlanRow>[
                LocalToCloudMigrationPlanRow(
                  familyKey: 'accounts',
                  localRowId: 'acc-1',
                  documentId: 'acc-1',
                ),
              ],
            ),
          );

      final LocalToCloudMigrationRemoteVerificationService service =
          LocalToCloudMigrationRemoteVerificationService(
            migrationStateRepository: migrationStateRepository,
            prepareExportBundleUseCase: _FakePrepareExportBundleUseCase(
              _buildBundle(accounts: <AccountEntity>[account]),
            ),
            readers: <String, LocalToCloudMigrationRemoteCollectionReader>{
              'accounts': (String uid) {
                return _readCollection(firestore, uid, 'accounts');
              },
            },
            expectedPayloadBuilders:
                <String, LocalToCloudMigrationExpectedRemotePayloadBuilder>{
                  'accounts': (Object entity) {
                    return accountRemoteDataSource.mapAccount(
                      entity as AccountEntity,
                    );
                  },
                },
            logger: _FakeLoggerService(),
          );

      final LocalToCloudMigrationRemoteVerificationResult result = await service
          .verifyUploadedGraph(uid: 'cloud-user-1');

      expect(
        result.status,
        LocalToCloudMigrationRemoteVerificationStatus.blocked,
      );
      expect(
        result.blockReason,
        LocalToCloudMigrationRemoteVerificationBlockReason.remoteDataMismatch,
      );
      expect(
        migrationStateRepository.state!.stage,
        LocalToCloudMigrationStage.remoteVerificationInProgress,
      );
    },
  );
}
