import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/sync/local_snapshot_summary_service.dart';
import 'package:kopim/features/profile/application/cloud_activation_runtime_guard.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

void main() {
  late AppDatabase database;
  late OutboxDao outboxDao;
  late CloudActivationRuntimeGuard activationRuntimeGuard;
  late LocalSnapshotSummaryService service;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    outboxDao = OutboxDao(database, () => 'local-user-1');
    activationRuntimeGuard = CloudActivationRuntimeGuard();
    service = LocalSnapshotSummaryService(
      database: database,
      outboxDao: outboxDao,
      activationRuntimeGuard: activationRuntimeGuard,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('returns empty for a pristine local database', () async {
    final LocalSnapshotSummary summary = await service.summarize();

    expect(summary.state, LocalSnapshotState.empty);
    expect(summary.hasUserData, isFalse);
    expect(summary.hasSystemData, isFalse);
    expect(summary.pendingOutboxCount, 0);
  });

  test('returns hasOnlySystemData when only system categories exist', () async {
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'system-category-1',
            name: 'System',
            type: 'expense',
            createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
            updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
            isSystem: const Value<bool>(true),
          ),
        );

    final LocalSnapshotSummary summary = await service.summarize();

    expect(summary.state, LocalSnapshotState.hasOnlySystemData);
    expect(summary.hasUserData, isFalse);
    expect(summary.hasSystemData, isTrue);
  });

  test('returns hasUserData when user financial data exists locally', () async {
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'account-1',
            name: 'Cash',
            balance: 0,
            currency: 'RUB',
            type: 'cash',
            createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
            updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
          ),
        );

    final LocalSnapshotSummary summary = await service.summarize();

    expect(summary.state, LocalSnapshotState.hasUserData);
    expect(summary.hasUserData, isTrue);
    expect(summary.pendingOutboxCount, 0);
  });

  test(
    'ownership projection rows alone do not make snapshot report user data',
    () async {
      await database
          .into(database.localRowOwnership)
          .insert(
            const LocalRowOwnershipCompanion(
              entityType: Value<String>('account'),
              entityId: Value<String>('acc-orphan'),
              ownershipState: Value<String>('localOnly'),
              ownerUid: Value<String?>(null),
              source: Value<String>('schema_backfill'),
            ),
          );

      final LocalSnapshotSummary summary = await service.summarize();

      expect(summary.state, LocalSnapshotState.empty);
      expect(summary.hasUserData, isFalse);
      expect(summary.hasSystemData, isFalse);
    },
  );

  test('returns hasPendingOutbox when pending local changes exist', () async {
    await outboxDao.enqueue(
      entityType: 'profile',
      entityId: 'local-user-1',
      operation: OutboxOperation.upsert,
      payload: <String, dynamic>{'uid': 'local-user-1'},
    );

    final LocalSnapshotSummary summary = await service.summarize();

    expect(summary.state, LocalSnapshotState.hasPendingOutbox);
    expect(summary.pendingOutboxCount, 1);
    expect(summary.fingerprint, contains('outbox:1'));
  });

  test(
    'returns activationInProgress while cloud activation guard is active',
    () async {
      expect(activationRuntimeGuard.tryAcquire(), isTrue);

      final LocalSnapshotSummary summary = await service.summarize();

      expect(summary.state, LocalSnapshotState.activationInProgress);
    },
  );
}
