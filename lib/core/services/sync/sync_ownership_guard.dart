import 'dart:convert';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync/ownership_projection_resolver.dart';

class SyncOwnershipException implements Exception {
  const SyncOwnershipException(this.message);

  final String message;

  @override
  String toString() => 'SyncOwnershipException: $message';
}

class SyncOwnershipGuard {
  const SyncOwnershipGuard([this._db]);

  final AppDatabase? _db;
  OwnershipProjectionResolver? get _resolver =>
      _db == null ? null : OwnershipProjectionResolver(_db);

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
      checkType = 'transaction';
      try {
        final Map<String, dynamic> decoded =
            jsonDecode(payload ?? '') as Map<String, dynamic>;
        final String? transactionId = decoded['transactionId'] as String?;
        if (transactionId == null || transactionId.isEmpty) {
          throw const SyncOwnershipException(
            'Ошибка валидации: transaction_tag не содержит transactionId.',
          );
        }
        checkId = transactionId;
      } on SyncOwnershipException {
        rethrow;
      } catch (e) {
        if (payload == null) {
          throw const SyncOwnershipException(
            'Ошибка валидации: transaction_tag не содержит payload.',
          );
        }
        throw SyncOwnershipException(
          'Не удалось извлечь transactionId из transaction_tag: $e',
        );
      }
    } else if (entityType == 'goal_account_link') {
      checkType = 'saving_goal';
      try {
        final Map<String, dynamic> decoded =
            jsonDecode(payload ?? '') as Map<String, dynamic>;
        final String? goalId = decoded['goalId'] as String?;
        if (goalId == null || goalId.isEmpty) {
          throw const SyncOwnershipException(
            'Ошибка валидации: goal_account_link не содержит goalId.',
          );
        }
        checkId = goalId;
      } on SyncOwnershipException {
        rethrow;
      } catch (e) {
        if (payload == null) {
          throw const SyncOwnershipException(
            'Ошибка валидации: goal_account_link не содержит payload.',
          );
        }
        throw SyncOwnershipException(
          'Не удалось извлечь goalId из goal_account_link: $e',
        );
      }
    }

    final LocalRowOwnershipRow? ownership;
    try {
      ownership = await _resolver!.resolveForDispatch(
        entityType: entityType,
        entityId: entityId,
        payload: payload,
      );
    } on OwnershipLookupException catch (error) {
      throw SyncOwnershipException(error.message);
    }
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
