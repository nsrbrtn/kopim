import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/services/sync/sync_ownership_guard.dart';

void main() {
  group('SyncOwnershipGuard Tests', () {
    const SyncOwnershipGuard guard = SyncOwnershipGuard();

    tearDown(() {
      // Возвращаем в дефолтное состояние после каждого теста
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    });

    group('ensureCanStartCloudSync', () {
      test(
        'should throw SyncOwnershipException if offlineOnly distribution',
        () async {
          AppRuntimeConfig.configure(AppRuntimeFlavor.offline);

          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.none,
              hasLocalData: false,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('disabled in offline-only build'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is none',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.none,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('обнаружены локальные данные'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is stayLocalOnly',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.stayLocalOnly,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('обнаружены локальные данные'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is migrateLocalToCloud',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.migrateLocalToCloud,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains(
                  'Перенос локальных данных в облако временно недоступен',
                ),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if hasLocalData and MigrationDecision is startWithEmptyCloud',
        () async {
          expect(
            () => guard.ensureCanStartCloudSync(
              currentCloudUid: 'cloud-user-123',
              migrationDecision: MigrationDecision.startWithEmptyCloud,
              hasLocalData: true,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains(
                  'Использование облака с пустого профиля при наличии локальных данных заблокировано',
                ),
              ),
            ),
          );
        },
      );

      test('should complete successfully if hasLocalData is false', () async {
        await expectLater(
          guard.ensureCanStartCloudSync(
            currentCloudUid: 'cloud-user-123',
            migrationDecision: MigrationDecision.none,
            hasLocalData: false,
          ),
          completes,
        );
      });
    });

    group('ensureOutboxEntryCanBePushed', () {
      test(
        'should throw SyncOwnershipException if offlineOnly distribution',
        () async {
          AppRuntimeConfig.configure(AppRuntimeFlavor.offline);

          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'cloud-user-123',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('disabled in offline-only build'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if entryOwnerUid is null',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: null,
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('Legacy OutboxEntry с пустым ownerUid заблокирована'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if entryOwnerUid starts with local-',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'local-profile-abc',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('Локальная OutboxEntry заблокирована'),
              ),
            ),
          );
        },
      );

      test(
        'should throw SyncOwnershipException if entryOwnerUid does not match currentCloudUid',
        () async {
          expect(
            () => guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'cloud-user-999',
            ),
            throwsA(
              isA<SyncOwnershipException>().having(
                (SyncOwnershipException e) => e.message,
                'message',
                contains('не может быть отправлена для пользователя'),
              ),
            ),
          );
        },
      );

      test(
        'should complete successfully if entryOwnerUid matches currentCloudUid',
        () async {
          await expectLater(
            guard.ensureOutboxEntryCanBePushed(
              currentCloudUid: 'cloud-user-123',
              entryOwnerUid: 'cloud-user-123',
            ),
            completes,
          );
        },
      );
    });
  });
}
