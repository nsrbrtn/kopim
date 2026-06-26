import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/profile/data/local_to_cloud_migration_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/local_to_cloud_migration_state.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late SharedPrefsLocalToCloudMigrationStateRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = SharedPrefsLocalToCloudMigrationStateRepository(
      preferences: Future<SharedPreferences>.value(sharedPreferences),
    );
  });

  test('persists migrateLocalToCloud state per uid', () async {
    await repository.saveState(
      LocalToCloudMigrationState(
        uid: 'cloud-user-1',
        stage: LocalToCloudMigrationStage.backupCreated,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1, 0, 5),
        plan: LocalToCloudMigrationPlan(
          migrationId: 'ltc-1',
          createdAt: DateTime.utc(2024, 1, 1),
          localFingerprint: 'local:hasUserData',
          remoteFingerprint: 'remote:empty|uid:cloud-user-1',
          candidateFamilyKeys: const <String>['transactions'],
          rows: const <LocalToCloudMigrationPlanRow>[
            LocalToCloudMigrationPlanRow(
              familyKey: 'transactions',
              localRowId: 'tx-1',
              documentId: 'tx-1',
            ),
          ],
        ),
        version: 2,
        backupArtifactReference: '/tmp/migrate-backup.json',
        backupChecksum: 'content-hash-1',
        localFingerprintBeforeUpload: 'local:hasUserData',
        remoteFingerprintBeforeUpload: 'remote:empty|uid:cloud-user-1',
        verifiedRowCountsByFamily: const <String, int>{'transactions': 1},
      ),
    );

    final LocalToCloudMigrationState? state = await repository.getStateForUid(
      'cloud-user-1',
    );

    expect(state, isNotNull);
    expect(state!.uid, 'cloud-user-1');
    expect(state.stage, LocalToCloudMigrationStage.backupCreated);
    expect(state.plan.migrationId, 'ltc-1');
    expect(state.plan.totalRowCount, 1);
    expect(state.plan.rowCountsByFamily['transactions'], 1);
    expect(state.backupArtifactReference, '/tmp/migrate-backup.json');
    expect(state.backupChecksum, 'content-hash-1');
    expect(state.verifiedRowCountsByFamily['transactions'], 1);
    expect(state.version, 2);
  });
}
