import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/noop_sync_service.dart';
import 'package:kopim/core/services/sync/sync_conflict_types.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync_status.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/tags/data/sources/remote/tag_remote_data_source.dart';
import 'package:kopim/features/tags/data/sources/remote/transaction_tag_remote_data_source.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_sync_test_harness.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    registerFallbackValue(<ConnectivityResult>[]);
  });

  group('Incremental Sync Tests', () {
    late AuthSyncTestHarness harness;
    late _MockFirebaseAuth firebaseAuth;
    late _MockUser firebaseUser;
    late _MockConnectivity connectivity;
    late StreamController<List<ConnectivityResult>> connectivityController;
    const String userId = 'test-user-1';
    SyncService? syncService;

    setUp(() async {
      harness = AuthSyncTestHarness();
      await harness.setUp();

      firebaseAuth = _MockFirebaseAuth();
      firebaseUser = _MockUser();
      when(() => firebaseUser.uid).thenReturn(userId);
      when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);

      connectivity = _MockConnectivity();
      connectivityController =
          StreamController<List<ConnectivityResult>>.broadcast();
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      when(
        () => connectivity.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
    });

    tearDown(() async {
      await syncService?.dispose();
      syncService = null;
      await connectivityController.close();
      await harness.tearDown();
    });

    SyncService buildSyncService(AuthSyncService authSyncService) {
      syncService = FirebaseSyncService(
        outboxDao: harness.outboxDao,
        accountRemoteDataSource: AccountRemoteDataSource(harness.firestore),
        categoryRemoteDataSource: CategoryRemoteDataSource(harness.firestore),
        tagRemoteDataSource: TagRemoteDataSource(harness.firestore),
        transactionTagRemoteDataSource: TransactionTagRemoteDataSource(
          harness.firestore,
        ),
        transactionRemoteDataSource: TransactionRemoteDataSource(
          harness.firestore,
        ),
        creditRemoteDataSource: harness.creditRemote,
        creditCardRemoteDataSource: harness.creditCardRemote,
        debtRemoteDataSource: harness.debtRemote,
        creditPaymentGroupRemoteDataSource: harness.creditPaymentGroupRemote,
        creditPaymentScheduleRemoteDataSource:
            harness.creditPaymentScheduleRemote,
        profileRemoteDataSource: ProfileRemoteDataSource(harness.firestore),
        budgetRemoteDataSource: harness.budgetRemote,
        budgetInstanceRemoteDataSource: harness.budgetInstanceRemote,
        savingGoalRemoteDataSource: harness.savingGoalRemote,
        upcomingPaymentRemoteDataSource: harness.upcomingPaymentRemote,
        paymentReminderRemoteDataSource: harness.paymentReminderRemote,
        firebaseAuth: firebaseAuth,
        authSyncService: authSyncService,
        syncOwnershipGuard: const FakeSyncOwnershipGuard(),
        syncConflictDao: SyncConflictDao(harness.database),
        connectivity: connectivity,
      );
      return syncService!;
    }

    test('1. Cursor Init on Login', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
      );

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          final DateTime? lastPulled = await harness.syncMetadataRepository
              .getLastPulledAt(userId, entry.outboxEntityType!);
          expect(lastPulled, isNull);
        }
      }

      await authSyncService.synchronizeOnLogin(
        user: authUser,
        migrationDecision: MigrationDecision.none,
      );

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          final DateTime? lastPulled = await harness.syncMetadataRepository
              .getLastPulledAt(userId, entry.outboxEntityType!);
          expect(lastPulled, isNotNull);
        }
      }
    });

    test('2. Push Failure Blocks Pull', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      await harness.outboxDao.enqueue(
        entityType: 'account',
        entityId: 'acc-failed',
        operation: OutboxOperation.upsert,
        payload: <String, Object>{'id': 'acc-failed', 'name': 'Failed Account'},
      );
      final List<db.OutboxEntryRow> pending = await harness.outboxDao
          .fetchPending(limit: 1);
      expect(pending, isNotEmpty);

      await harness.outboxDao.prepareForSend(pending.first);
      await harness.outboxDao.markAsFailed(pending.first.id, 'Network error');

      await harness.syncMetadataRepository.setLastPulledAt(
        userId,
        'account',
        DateTime.now(),
      );

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.pushFailed));
    });

    test('3. Overlap Window', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime cursor = DateTime.utc(2025, 1, 1, 12, 0, 0);
      await harness.syncMetadataRepository.setLastPulledAt(
        userId,
        'account',
        cursor,
      );

      final DateTime itemTime = cursor.subtract(const Duration(seconds: 2));
      final AccountEntity account = AccountEntity(
        id: 'acc-overlap',
        name: 'Overlap Account',
        balanceMinor: BigInt.from(100),
        currency: 'RUB',
        currencyScale: 2,
        type: 'checking',
        createdAt: itemTime,
        updatedAt: itemTime,
      );

      await harness.firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc('acc-overlap')
          .set(
            account.toJson()
              ..['updatedAt'] = Timestamp.fromDate(account.updatedAt),
          );

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            cursor,
          );
        }
      }

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.success));
      expect(status.pulledCount, equals(1));

      final db.AccountRow? localAcc = await harness.accountDao.findById(
        'acc-overlap',
      );
      expect(localAcc, isNotNull);
      expect(localAcc?.name, equals('Overlap Account'));
    });

    test('4. Idempotent LWW Merge', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime baseTime = DateTime.utc(2025, 1, 1, 12, 0, 0);

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            baseTime,
          );
        }
      }

      final DateTime localTime = baseTime.add(const Duration(minutes: 5));
      final AccountEntity localAccount = AccountEntity(
        id: 'acc-merge',
        name: 'Local New Account',
        balanceMinor: BigInt.from(200),
        currency: 'RUB',
        currencyScale: 2,
        type: 'checking',
        createdAt: baseTime,
        updatedAt: localTime,
      );
      await harness.accountDao.upsertAll(<AccountEntity>[localAccount]);

      final DateTime remoteTime = baseTime.add(const Duration(minutes: 1));
      final AccountEntity remoteAccount = AccountEntity(
        id: 'acc-merge',
        name: 'Remote Old Account',
        balanceMinor: BigInt.from(100),
        currency: 'RUB',
        currencyScale: 2,
        type: 'checking',
        createdAt: baseTime,
        updatedAt: remoteTime,
      );
      await harness.firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc('acc-merge')
          .set(
            remoteAccount.toJson()
              ..['updatedAt'] = Timestamp.fromDate(remoteAccount.updatedAt),
          );

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.success));

      final db.AccountRow? acc = await harness.accountDao.findById('acc-merge');
      expect(acc, isNotNull);
      expect(acc?.name, equals('Local New Account'));
    });

    test('5. Pagination', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime baseTime = DateTime.utc(2025, 1, 1, 12, 0, 0);

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            baseTime,
          );
        }
      }

      final WriteBatch batch = harness.firestore.batch();
      for (int i = 0; i < 105; i++) {
        final DateTime itemTime = baseTime.add(Duration(seconds: i + 1));
        final AccountEntity account = AccountEntity(
          id: 'acc-$i',
          name: 'Account $i',
          balanceMinor: BigInt.from(100),
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: itemTime,
          updatedAt: itemTime,
        );
        final DocumentReference<Map<String, dynamic>> docRef = harness.firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc('acc-$i');
        batch.set(
          docRef,
          account.toJson()
            ..['updatedAt'] = Timestamp.fromDate(account.updatedAt),
        );
      }
      await batch.commit();

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.success));
      expect(status.pulledCount, equals(105));

      final List<AccountEntity> localAccs = await harness.accountDao
          .getAllAccounts();
      expect(localAccs.length, equals(105));
    });

    test('6. Topological Ordering', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime baseTime = DateTime.utc(2025, 1, 1, 12, 0, 0);

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            baseTime,
          );
        }
      }

      final DateTime itemTime = baseTime.add(const Duration(seconds: 1));
      final AccountEntity account = AccountEntity(
        id: 'acc-topo',
        name: 'Topo Account',
        balanceMinor: BigInt.from(100),
        currency: 'RUB',
        currencyScale: 2,
        type: 'checking',
        createdAt: itemTime,
        updatedAt: itemTime,
      );
      final Category category = Category(
        id: 'cat-topo',
        name: 'Topo Category',
        type: 'expense',
        createdAt: itemTime,
        updatedAt: itemTime,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-topo',
        accountId: 'acc-topo',
        categoryId: 'cat-topo',
        amountMinor: BigInt.from(10),
        amountScale: 2,
        date: itemTime,
        type: 'expense',
        createdAt: itemTime,
        updatedAt: itemTime,
      );

      await harness.firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc('acc-topo')
          .set(
            account.toJson()
              ..['updatedAt'] = Timestamp.fromDate(account.updatedAt),
          );
      await harness.firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc('cat-topo')
          .set(
            category.toJson()
              ..['updatedAt'] = Timestamp.fromDate(category.updatedAt),
          );
      await harness.firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('tx-topo')
          .set(
            transaction.toJson()
              ..['amount'] = 0.1
              ..['amountMinor'] = '10'
              ..['amountScale'] = 2
              ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt),
          );

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.success));

      final db.TransactionRow? tx = await harness.transactionDao.findById(
        'tx-topo',
      );
      expect(tx, isNotNull);
      expect(tx?.accountId, equals('acc-topo'));
      expect(tx?.categoryId, equals('cat-topo'));
    });

    test('7. Rollback Cursor on DB Error', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime baseTime = DateTime.utc(2025, 1, 1, 12, 0, 0);

      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            baseTime,
          );
        }
      }

      final DateTime itemTime = baseTime.add(const Duration(seconds: 1));
      final TransactionEntity invalidTx = TransactionEntity(
        id: 'tx-invalid',
        accountId: '',
        categoryId: 'cat-non-existent',
        amountMinor: BigInt.from(10),
        amountScale: 2,
        date: itemTime,
        type: 'expense',
        createdAt: itemTime,
        updatedAt: itemTime,
      );

      await harness.firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('tx-invalid')
          .set(
            invalidTx.toJson()
              ..['amount'] = 0.1
              ..['amountMinor'] = '10'
              ..['amountScale'] = 2
              ..['updatedAt'] = Timestamp.fromDate(invalidTx.updatedAt)
              ..['accountId'] = null,
          );

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.error));

      final DateTime? currentCursor = await harness.syncMetadataRepository
          .getLastPulledAt(userId, 'transaction');
      expect(currentCursor, equals(baseTime));
    });

    test('8. Sync Lock', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime baseTime = DateTime.utc(2025, 1, 1, 12, 0, 0);
      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            baseTime,
          );
        }
      }

      final Future<IncrementalSyncStatus> firstSync = syncService
          .triggerManualSync();
      final IncrementalSyncStatus secondStatus = await syncService
          .triggerManualSync();

      expect(secondStatus.result, equals(IncrementalSyncResult.alreadySyncing));

      final IncrementalSyncStatus firstStatus = await firstSync;
      expect(firstStatus.result, equals(IncrementalSyncResult.noChanges));
    });

    test('9. Empty Collection', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      final DateTime baseTime = DateTime.utc(2025, 1, 1, 12, 0, 0);
      for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
        if (entry.outboxEntityType != null && entry.participatesInLoginSync) {
          await harness.syncMetadataRepository.setLastPulledAt(
            userId,
            entry.outboxEntityType!,
            baseTime,
          );
        }
      }

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.noChanges));
      expect(status.pulledCount, equals(0));
    });

    test('10. Dependency cycle does not dispatch affected entries', () async {
      final AuthSyncService authSyncService = harness.buildService();
      final SyncService syncService = buildSyncService(authSyncService);

      await harness.outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-cycle-a',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{
          'id': 'cat-cycle-a',
          'parentId': 'cat-cycle-b',
        },
      );
      await harness.outboxDao.enqueue(
        entityType: 'category',
        entityId: 'cat-cycle-b',
        operation: OutboxOperation.upsert,
        payload: <String, dynamic>{
          'id': 'cat-cycle-b',
          'parentId': 'cat-cycle-a',
        },
      );

      final IncrementalSyncStatus status = await syncService
          .triggerManualSync();

      expect(
        status.result,
        equals(IncrementalSyncResult.dependencyCycleDetected),
      );

      final QuerySnapshot<Map<String, dynamic>> remoteCategories = await harness
          .firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();
      expect(remoteCategories.docs, isEmpty);

      final List<db.OutboxEntryRow> pendingRows = await harness.database
          .select(harness.database.outboxEntries)
          .get();
      expect(
        pendingRows.map((db.OutboxEntryRow row) => row.status).toSet(),
        equals(<String>{OutboxStatus.pending.name}),
      );

      final List<db.SyncConflictRow> conflicts = await SyncConflictDao(
        harness.database,
      ).getPendingConflicts();
      expect(
        conflicts.any(
          (db.SyncConflictRow row) =>
              row.conflictType == SyncConflictType.outboxDependencyCycle.value,
        ),
        isTrue,
      );
    });
  });

  group('NoopSyncService', () {
    test(
      'returns blockedByLocalData when cloud is blocked by local data',
      () async {
        final IncrementalSyncStatus status = await NoopSyncService(
          reason: NoopSyncReason.blockedByLocalData,
        ).triggerManualSync();

        expect(status.result, equals(IncrementalSyncResult.blockedByLocalData));
      },
    );

    test('returns cloudSyncDisabled when cloud sync is disabled', () async {
      final IncrementalSyncStatus status = await NoopSyncService(
        reason: NoopSyncReason.cloudSyncDisabled,
      ).triggerManualSync();

      expect(status.result, equals(IncrementalSyncResult.cloudSyncDisabled));
    });
  });
}
