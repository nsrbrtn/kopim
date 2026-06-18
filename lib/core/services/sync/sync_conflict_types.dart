// lib/core/services/sync/sync_conflict_types.dart

/// Статус конфликта синхронизации.
enum SyncConflictStatus {
  pending('pending'),
  resolved('resolved'),
  ignored('ignored'),
  autoResolved('autoResolved');

  const SyncConflictStatus(this.value);
  final String value;

  static SyncConflictStatus fromValue(String value) {
    return SyncConflictStatus.values.firstWhere(
      (SyncConflictStatus e) => e.value == value,
      orElse: () => SyncConflictStatus.pending,
    );
  }
}

/// Уровень серьезности конфликта синхронизации.
enum SyncConflictSeverity {
  info('info'),
  warning('warning'),
  blocking('blocking');

  const SyncConflictSeverity(this.value);
  final String value;

  static SyncConflictSeverity fromValue(String value) {
    return SyncConflictSeverity.values.firstWhere(
      (SyncConflictSeverity e) => e.value == value,
      orElse: () => SyncConflictSeverity.warning,
    );
  }
}

/// Тип конфликта синхронизации.
enum SyncConflictType {
  missingOptionalReference('missingOptionalReference'),
  missingRequiredReference('missingRequiredReference'),
  updateUpdate('updateUpdate'),
  deleteUpdate('deleteUpdate'),
  outboxDependencyCycle('outboxDependencyCycle'),
  integrityError('integrityError');

  const SyncConflictType(this.value);
  final String value;

  static SyncConflictType fromValue(String value) {
    return SyncConflictType.values.firstWhere(
      (SyncConflictType e) => e.value == value,
      orElse: () => SyncConflictType.integrityError,
    );
  }
}
