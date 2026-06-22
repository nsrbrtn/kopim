import 'dart:convert';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart';

class SyncOwnershipException implements Exception {
  const SyncOwnershipException(this.message);

  final String message;

  @override
  String toString() => 'SyncOwnershipException: $message';
}

class SyncOwnershipGuard {
  const SyncOwnershipGuard([this._db]);

  final AppDatabase? _db;

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
          'Перенос локальных данных в облако временно недоступен in этой версии.',
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
    String? entityType,
    String? entityId,
    String? payload,
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

    // Skip row-level validation if database or lookup parameters are missing (backward compatibility)
    if (_db == null || entityType == null || entityId == null) {
      return;
    }

    // Skip row-level check for profiles
    if (entityType == 'profile') {
      return;
    }

    String checkType = entityType;
    String checkId = entityId;

    if (entityType == 'transaction_tag') {
      if (payload == null) {
        throw const SyncOwnershipException(
          'Ошибка валидации: transaction_tag не содержит payload.',
        );
      }
      try {
        final Map<String, dynamic> decoded =
            jsonDecode(payload) as Map<String, dynamic>;
        final String? transactionId = decoded['transactionId'] as String?;
        if (transactionId == null) {
          throw const SyncOwnershipException(
            'Ошибка валидации: transaction_tag не содержит transactionId.',
          );
        }
        checkType = 'transaction';
        checkId = transactionId;
      } catch (e) {
        throw SyncOwnershipException(
          'Не удалось извлечь transactionId из transaction_tag: $e',
        );
      }
    }

    final LocalRowOwnershipRow? ownership = await _db.getOwnership(
      checkType,
      checkId,
    );
    if (ownership == null) {
      throw SyncOwnershipException(
        'Валидация владельца провалена: отсутствует запись владения для $checkType:$checkId.',
      );
    }

    if (ownership.ownershipState != 'cloudOwned') {
      throw SyncOwnershipException(
        'Валидация владельца провалена: строка $checkType:$checkId имеет статус ${ownership.ownershipState}, а не cloudOwned.',
      );
    }

    if (ownership.ownerUid != currentCloudUid) {
      throw SyncOwnershipException(
        'Валидация владельца провалена: строка $checkType:$checkId принадлежит ${ownership.ownerUid}, а текущий пользователь $currentCloudUid.',
      );
    }
  }
}
