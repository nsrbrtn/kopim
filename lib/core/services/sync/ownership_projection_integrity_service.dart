import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;

enum OwnershipIntegrityIssueType {
  missingProjection,
  orphanProjection,
  invalidCloudOwner,
  invalidLocalOwner,
  unknownEntityType,
}

class OwnershipIntegrityIssue {
  const OwnershipIntegrityIssue({
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.message,
  });

  final OwnershipIntegrityIssueType type;
  final String entityType;
  final String entityId;
  final String message;
}

class OwnershipProjectionIntegrityService {
  const OwnershipProjectionIntegrityService(this._db);

  final db.AppDatabase _db;

  Future<List<OwnershipIntegrityIssue>> runDiagnostics() async {
    final List<OwnershipIntegrityIssue> issues = <OwnershipIntegrityIssue>[];

    // 1. Get all local row ownerships
    final List<db.LocalRowOwnershipRow> ownershipRows = await _db
        .select(_db.localRowOwnership)
        .get();

    // Mapping table names to entity types
    const List<Map<String, String>> tablesAndTypes = <Map<String, String>>[
      <String, String>{'table': 'accounts', 'type': 'account'},
      <String, String>{'table': 'categories', 'type': 'category'},
      <String, String>{'table': 'tags', 'type': 'tag'},
      <String, String>{'table': 'transactions', 'type': 'transaction'},
      <String, String>{'table': 'budgets', 'type': 'budget'},
      <String, String>{'table': 'budget_instances', 'type': 'budget_instance'},
      <String, String>{'table': 'saving_goals', 'type': 'saving_goal'},
      <String, String>{
        'table': 'upcoming_payments',
        'type': 'upcoming_payment',
      },
      <String, String>{
        'table': 'payment_reminders',
        'type': 'payment_reminder',
      },
      <String, String>{'table': 'debts', 'type': 'debt'},
      <String, String>{'table': 'credits', 'type': 'credit'},
      <String, String>{'table': 'credit_cards', 'type': 'credit_card'},
      <String, String>{
        'table': 'credit_payment_schedules',
        'type': 'credit_payment_schedule',
      },
      <String, String>{
        'table': 'credit_payment_groups',
        'type': 'credit_payment_group',
      },
    ];

    final Map<String, Set<String>> existingIdsByType = <String, Set<String>>{};
    final Set<String> knownEntityTypes = tablesAndTypes
        .map((Map<String, String> item) => item['type']!)
        .toSet();

    for (final Map<String, String> item in tablesAndTypes) {
      final String tableName = item['table']!;
      final String entityType = item['type']!;

      final List<QueryRow> rows = await _db
          .customSelect('SELECT id FROM $tableName')
          .get();
      final Set<String> ids = rows
          .map((QueryRow r) => r.read<String>('id'))
          .toSet();
      existingIdsByType[entityType] = ids;
    }

    final Map<String, Set<String>> projectedIdsByType = <String, Set<String>>{};

    // 2. Validate ownership rows
    for (final db.LocalRowOwnershipRow r in ownershipRows) {
      if (!knownEntityTypes.contains(r.entityType)) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.unknownEntityType,
            entityType: r.entityType,
            entityId: r.entityId,
            message: 'Неизвестный entityType: ${r.entityType}',
          ),
        );
        continue;
      }

      projectedIdsByType
          .putIfAbsent(r.entityType, () => <String>{})
          .add(r.entityId);

      // Check if business row actually exists
      final Set<String>? businessIds = existingIdsByType[r.entityType];
      if (businessIds == null || !businessIds.contains(r.entityId)) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.orphanProjection,
            entityType: r.entityType,
            entityId: r.entityId,
            message:
                'Запись владения существует для несуществующей строки ${r.entityType}:${r.entityId}.',
          ),
        );
      }

      // Check invalid ownerUid / state combinations
      if (r.ownershipState == 'cloudOwned' && r.ownerUid == null) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.invalidCloudOwner,
            entityType: r.entityType,
            entityId: r.entityId,
            message: 'Строка cloudOwned не имеет ownerUid.',
          ),
        );
      }

      if ((r.ownershipState == 'localOnly' ||
              r.ownershipState == 'systemDefault') &&
          r.ownerUid != null) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.invalidLocalOwner,
            entityType: r.entityType,
            entityId: r.entityId,
            message:
                'Строка ${r.ownershipState} имеет ненулевой ownerUid: ${r.ownerUid}.',
          ),
        );
      }
    }

    // 3. Validate missing ownership projections
    for (final Map<String, String> item in tablesAndTypes) {
      final String entityType = item['type']!;
      final Set<String> businessIds =
          existingIdsByType[entityType] ?? <String>{};
      final Set<String> projectedIds =
          projectedIdsByType[entityType] ?? <String>{};

      final Set<String> missingIds = businessIds.difference(projectedIds);
      for (final String id in missingIds) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.missingProjection,
            entityType: entityType,
            entityId: id,
            message: 'Отсутствует запись владения для строки $entityType:$id.',
          ),
        );
      }
    }

    return issues;
  }
}
