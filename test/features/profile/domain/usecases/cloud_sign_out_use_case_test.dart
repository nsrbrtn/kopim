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
      'should stop sync, clear entitlements, keep pending outbox, delete profile and conflicts, and signOut',
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
        when(() => mockSyncMetaRepo.clear(cloudUid)).thenAnswer((_) async {});
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
        verify(() => mockSyncMetaRepo.clear(cloudUid)).called(1);
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
        expect(conflicts.isEmpty, isTrue); // конфликты очистились

        final List<OutboxEntryRow> outboxEntries = await database
            .select(database.outboxEntries)
            .get();
        expect(outboxEntries, hasLength(1));
        expect(outboxEntries.single.ownerUid, equals(cloudUid));
      },
    );
  });
}
