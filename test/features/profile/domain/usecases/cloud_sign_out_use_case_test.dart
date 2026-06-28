import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync/sync_metadata_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/usecases/cloud_sign_out_use_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockLoggerService extends Mock implements LoggerService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSyncService extends Mock implements SyncService {}

class MockCloudEntitlementRepository extends Mock
    implements CloudEntitlementRepository {}

class MockSyncMetadataRepository extends Mock
    implements SyncMetadataRepository {}

void main() {
  group('CloudSignOutUseCase Tests', () {
    late MockLoggerService mockLogger;
    late MockAuthRepository mockCloudAuth;
    late MockSyncService mockSyncService;
    late MockCloudEntitlementRepository mockEntitlementRepo;
    late MockSyncMetadataRepository mockSyncMetaRepo;
    late AppDatabase database;
    late ProviderContainer container;
    late CloudSignOutUseCase useCase;

    setUp(() async {
      mockLogger = MockLoggerService();
      mockCloudAuth = MockAuthRepository();
      mockSyncService = MockSyncService();
      mockEntitlementRepo = MockCloudEntitlementRepository();
      mockSyncMetaRepo = MockSyncMetadataRepository();
      database = AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );

      container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          loggerServiceProvider.overrideWithValue(mockLogger),
          cloudAuthRepositoryProvider.overrideWithValue(mockCloudAuth),
          syncServiceProvider.overrideWithValue(mockSyncService),
          cloudEntitlementRepositoryProvider.overrideWithValue(
            mockEntitlementRepo,
          ),
          syncMetadataRepositoryProvider.overrideWithValue(mockSyncMetaRepo),
          appDatabaseProvider.overrideWithValue(database),
        ],
      );

      useCase = container.read(cloudSignOutUseCaseProvider);

      // Заглушки логирования
      when(() => mockLogger.logInfo(any())).thenReturn(null);
      when(() => mockLogger.logWarning(any())).thenReturn(null);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('should do nothing if currentCloudUser is null', () async {
      when(() => mockCloudAuth.currentUser).thenReturn(null);

      await useCase.execute();

      verify(() => mockLogger.logInfo(any())).called(greaterThan(0));
      verifyNever(() => mockSyncService.dispose());
      verifyNever(() => mockCloudAuth.signOut());
    });

    test(
      'should stop sync, clear entitlements, keep pending outbox, keep sync_metadata and conflicts, and signOut',
      () async {
        const String cloudUid = 'firebase-cloud-uid-123';
        const AuthUser authUser = AuthUser(
          uid: cloudUid,
          email: 'test@kopim.app',
          emailVerified: true,
        );

        when(() => mockCloudAuth.currentUser).thenReturn(authUser);
        when(() => mockSyncService.dispose()).thenAnswer((_) async {});
        when(
          () => mockEntitlementRepo.clearEntitlement(),
        ).thenAnswer((_) async {});
        // sync_metadata.clear() is NOT called on sign-out: preserved per plan §9.4
        when(() => mockSyncMetaRepo.clear(any())).thenAnswer((_) async {});
        when(() => mockCloudAuth.signOut()).thenAnswer((_) async {});

        // Наполняем базу данных тестовыми данными: профиль текущего пользователя и другого, а также конфликт
        await database
            .into(database.profiles)
            .insert(
              ProfilesCompanion.insert(
                uid: cloudUid,
                updatedAt: Value<DateTime>(DateTime.now()),
              ),
            );
        await database
            .into(database.profiles)
            .insert(
              ProfilesCompanion.insert(
                uid: 'another-user',
                updatedAt: Value<DateTime>(DateTime.now()),
              ),
            );
        await database
            .into(database.syncConflicts)
            .insert(
              SyncConflictsCompanion.insert(
                conflictKey: 'test-conflict',
                entityType: 'transaction',
                entityId: 'tx-1',
                conflictType: 'update_update',
                severity: 'warning',
                status: 'pending',
                createdAt: Value<DateTime>(DateTime.now()),
                updatedAt: Value<DateTime>(DateTime.now()),
              ),
            );
        await database
            .into(database.outboxEntries)
            .insert(
              OutboxEntriesCompanion.insert(
                entityType: 'account',
                entityId: 'pending-account',
                operation: 'upsert',
                payload: jsonEncode(<String, Object>{
                  'id': 'pending-account',
                  'name': 'Unsynced account',
                }),
                ownerUid: const Value<String?>(cloudUid),
              ),
            );

        // Вызов
        await useCase.execute();

        // Проверки вызова внешних сервисов
        verify(() => mockSyncService.dispose()).called(1);
        verify(() => mockEntitlementRepo.clearEntitlement()).called(1);
        // sync_metadata is NOT cleared on sign-out (plan §9.4): verifyNever
        verifyNever(() => mockSyncMetaRepo.clear(any()));
        verify(() => mockCloudAuth.signOut()).called(1);

        // Проверки удаления из БД
        final List<ProfileRow> profiles = await database
            .select(database.profiles)
            .get();
        expect(profiles.length, equals(1));
        expect(
          profiles.first.uid,
          equals('another-user'),
        ); // профиль другого остался

        final List<SyncConflictRow> conflicts = await database
            .select(database.syncConflicts)
            .get();
        // syncConflicts are preserved on sign-out (plan §9.4)
        expect(conflicts, hasLength(1));

        final List<OutboxEntryRow> outboxEntries = await database
            .select(database.outboxEntries)
            .get();
        expect(outboxEntries, hasLength(1));
        expect(outboxEntries.single.ownerUid, equals(cloudUid));
      },
    );

    test(
      'sign-out keeps old cloud-owned rows foreign and new writes become local-only',
      () async {
        const String cloudUid = 'firebase-cloud-uid-123';
        const AuthUser authUser = AuthUser(
          uid: cloudUid,
          email: 'test@kopim.app',
          emailVerified: true,
        );

        when(() => mockCloudAuth.currentUser).thenReturn(authUser);
        when(() => mockSyncService.dispose()).thenAnswer((_) async {});
        when(
          () => mockEntitlementRepo.clearEntitlement(),
        ).thenAnswer((_) async {});
        when(() => mockCloudAuth.signOut()).thenAnswer((_) async {});

        await database.updateCurrentSyncState(cloudUid, true);
        await database
            .into(database.accounts)
            .insert(
              AccountsCompanion.insert(
                id: 'cloud-owned-before-sign-out',
                name: 'Cloud account',
                balance: 0,
                currency: 'RUB',
                type: 'cash',
                createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
                updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              ),
            );

        final LocalRowOwnershipRow? beforeSignOutOwnership = await database
            .getOwnership('account', 'cloud-owned-before-sign-out');
        expect(beforeSignOutOwnership != null, isTrue);
        expect(beforeSignOutOwnership!.ownershipState, equals('cloudOwned'));
        expect(beforeSignOutOwnership.ownerUid, equals(cloudUid));

        await useCase.execute();

        await database
            .into(database.accounts)
            .insert(
              AccountsCompanion.insert(
                id: 'local-after-sign-out',
                name: 'Local account',
                balance: 0,
                currency: 'RUB',
                type: 'cash',
                createdAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
                updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
              ),
            );

        await (database.update(database.accounts)..where(
              ($AccountsTable tbl) =>
                  tbl.id.equals('cloud-owned-before-sign-out'),
            ))
            .write(
              AccountsCompanion(
                name: const Value<String>('Edited offline'),
                updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 3)),
              ),
            );

        final LocalRowOwnershipRow? oldOwnership = await database.getOwnership(
          'account',
          'cloud-owned-before-sign-out',
        );
        final LocalRowOwnershipRow? newOwnership = await database.getOwnership(
          'account',
          'local-after-sign-out',
        );

        expect(oldOwnership != null, isTrue);
        expect(oldOwnership!.ownershipState, equals('cloudOwned'));
        expect(oldOwnership.ownerUid, equals(cloudUid));

        expect(newOwnership != null, isTrue);
        expect(newOwnership!.ownershipState, equals('localOnly'));
        expect(newOwnership.ownerUid, equals(null));

        final CurrentSyncStateRow syncState = await database
            .select(database.currentSyncStates)
            .getSingle();
        expect(syncState.currentUid, equals(null));
        expect(syncState.syncActive, isFalse);
      },
    );
  });
}
