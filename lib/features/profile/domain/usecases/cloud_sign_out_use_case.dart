// lib/features/profile/domain/usecases/cloud_sign_out_use_case.dart
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:riverpod/riverpod.dart';

class CloudSignOutUseCase {
  const CloudSignOutUseCase(this._ref);

  final Ref _ref;

  Future<void> execute() async {
    final LoggerService logger = _ref.read(loggerServiceProvider);
    logger.logInfo('CloudSignOutUseCase: starting cloud sign out workflow');

    // 1. Получаем текущего вошедшего облачного пользователя
    final AuthRepository cloudAuth = _ref.read(cloudAuthRepositoryProvider);
    final AuthUser? cloudUser = cloudAuth.currentUser;
    if (cloudUser == null) {
      logger.logInfo(
        'CloudSignOutUseCase: no active cloud user, skipping metadata cleanup',
      );
      return;
    }
    final String cloudUid = cloudUser.uid;

    // Считываем зависимости до первого await для исключения UnmountedRefException
    final SyncService syncService = _ref.read(syncServiceProvider);
    final CloudEntitlementRepository entitlementRepo = _ref.read(
      cloudEntitlementRepositoryProvider,
    );
    final AppDatabase db = _ref.read(appDatabaseProvider);

    // 2. Останавливаем синхронизацию
    await syncService.dispose();

    // 3. Сбрасываем лицензионный ключ
    await entitlementRepo.clearEntitlement();

    // 4. Очищаем метаданные синхронизации для данного пользователя
    // Сохраняем baseline для pending outbox:
    // await metadataRepo.clear(cloudUid);

    // 5. Pending outbox не удаляем: локальные изменения должны пережить logout
    // и остаться привязанными к владельцу до его следующего входа.

    // 6. Удаляем профиль пользователя из локальной БД profiles
    await (db.delete(
      db.profiles,
    )..where(($ProfilesTable tbl) => tbl.uid.equals(cloudUid))).go();

    await db.updateCurrentSyncState(null, false);

    // 7. Очищаем конфликты синхронизации
    // Сохраняем конфликты для восстановления синхронизации:
    // await db.delete(db.syncConflicts).go();

    // 8. Сбрасываем облачную сессию Firebase Auth
    await cloudAuth.signOut();

    logger.logInfo(
      'CloudSignOutUseCase: cloud sign out completed successfully',
    );
  }
}
