import 'package:kopim/core/config/app_runtime.dart';

class SyncOwnershipException implements Exception {
  const SyncOwnershipException(this.message);

  final String message;

  @override
  String toString() => 'SyncOwnershipException: $message';
}

class SyncOwnershipGuard {
  const SyncOwnershipGuard();

  Future<void> ensureCanStartCloudSync({
    required String currentCloudUid,
    required MigrationDecision migrationDecision,
    required bool hasLocalData,
  }) async {
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      throw const SyncOwnershipException(
        'Cloud sync is completely disabled in offline-only build.',
      );
    }

    if (hasLocalData) {
      if (migrationDecision == MigrationDecision.none ||
          migrationDecision == MigrationDecision.stayLocalOnly) {
        throw const SyncOwnershipException(
          'Синхронизация заблокирована: обнаружены локальные данные, перенос которых еще не настроен.',
        );
      }
      if (migrationDecision == MigrationDecision.migrateLocalToCloud) {
        throw const SyncOwnershipException(
          'Перенос локальных данных в облако временно недоступен в этой версии.',
        );
      }
      if (migrationDecision == MigrationDecision.startWithEmptyCloud) {
        throw const SyncOwnershipException(
          'Использование облака с пустого профиля при наличии локальных данных заблокировано.',
        );
      }
    }
  }

  Future<void> ensureOutboxEntryCanBePushed({
    required String currentCloudUid,
    required String? entryOwnerUid,
  }) async {
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      throw const SyncOwnershipException(
        'Cloud sync is completely disabled in offline-only build.',
      );
    }

    if (entryOwnerUid == null) {
      throw const SyncOwnershipException(
        'Legacy OutboxEntry с пустым ownerUid заблокирована от отправки в Firestore.',
      );
    }

    if (entryOwnerUid.startsWith('local-')) {
      throw const SyncOwnershipException(
        'Локальная OutboxEntry заблокирована от автоматической отправки в Firestore.',
      );
    }

    if (entryOwnerUid != currentCloudUid) {
      throw SyncOwnershipException(
        'OutboxEntry владельца $entryOwnerUid не может быть отправлена для пользователя $currentCloudUid.',
      );
    }
  }
}
