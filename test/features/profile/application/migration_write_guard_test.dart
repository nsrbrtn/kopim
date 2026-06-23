import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/profile/application/migration_write_guard.dart';
import 'package:kopim/features/profile/data/migration_freeze_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/migration_freeze_state.dart';

void main() {
  late db.AppDatabase database;
  late SharedPrefsMigrationFreezeStateRepository stateRepository;
  late SharedPrefsMigrationWriteGuard guard;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    stateRepository = SharedPrefsMigrationFreezeStateRepository();
    guard = SharedPrefsMigrationWriteGuard(
      database: database,
      stateRepository: stateRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'rehydrates durable freeze state and blocks covered repository writes',
    () async {
      await stateRepository.saveState(
        MigrationFreezeState(
          uid: 'cloud-user-1',
          startedAt: DateTime.utc(2026, 6, 22),
          phase: 'pre_inventory_capture',
          uploadStarted: false,
          version: 1,
        ),
      );

      final SharedPrefsMigrationWriteGuard restartedGuard =
          SharedPrefsMigrationWriteGuard(
            database: database,
            stateRepository: stateRepository,
          );

      await expectLater(
        restartedGuard.runRepositoryWrite(
          entityType: 'account',
          action: () async {},
        ),
        throwsA(isA<MigrationFreezeActive>()),
      );
    },
  );

  test(
    'migration execution context bypasses freeze for covered writes',
    () async {
      await guard.activateFreeze(
        uid: 'cloud-user-1',
        phase: 'upload_in_progress',
      );

      await expectLater(
        guard.runWithMigrationContext(() {
          return guard.runRepositoryWrite(
            entityType: 'account',
            action: () async {},
          );
        }),
        completes,
      );
    },
  );

  test('quiescence check fails while persisted import is active', () async {
    await database
        .into(database.currentSyncStates)
        .insertOnConflictUpdate(
          const db.CurrentSyncStatesCompanion(
            id: Value<int>(1),
            importInProgress: Value<bool>(true),
          ),
        );

    await expectLater(
      guard.ensureQuiescentForInventoryCapture(),
      throwsA(isA<MigrationQuiescenceRequired>()),
    );
  });
}
