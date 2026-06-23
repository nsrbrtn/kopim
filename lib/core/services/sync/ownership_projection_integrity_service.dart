import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/sync/ownership_projection_resolver.dart';

enum OwnershipIntegrityIssueType {
  missingProjection,
  orphanProjection,
  invalidCloudOwner,
  invalidLocalOwner,
  invalidOwnershipState,
  invalidSource,
  unknownEntityType,
  missingInheritedParentOwnership,
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
  OwnershipProjectionIntegrityService(this._db)
    : _resolver = OwnershipProjectionResolver(_db);

  final db.AppDatabase _db;
  final OwnershipProjectionResolver _resolver;

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
    final Set<String> knownEntityTypes = <String>{
      ...tablesAndTypes.map((Map<String, String> item) => item['type']!),
      ...kExcludedOwnershipEntityTypes,
      'transaction_tag',
      'goal_account_link',
    };

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
      if (!kOwnershipStates.contains(r.ownershipState)) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.invalidOwnershipState,
            entityType: r.entityType,
            entityId: r.entityId,
            message: 'Неизвестный ownershipState: ${r.ownershipState}.',
          ),
        );
      }

      if (!kOwnershipSources.contains(r.source)) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.invalidSource,
            entityType: r.entityType,
            entityId: r.entityId,
            message: 'Неизвестный source: ${r.source}.',
          ),
        );
      }

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

    // 3. Validate missing ownership projections for direct-projection families
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

    // 4. Validate inherited ownership coverage for link entities.
    final List<db.TransactionTagRow> transactionTagRows = await _db
        .select(_db.transactionTags)
        .get();
    for (final db.TransactionTagRow row in transactionTagRows) {
      final db.LocalRowOwnershipRow? ownership = await _resolver
          .resolveTransactionTagOwnership(transactionId: row.transactionId);
      if (ownership == null) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.missingInheritedParentOwnership,
            entityType: 'transaction_tag',
            entityId: '${row.transactionId}:${row.tagId}',
            message:
                'Для transaction_tag отсутствует запись владения родительской transaction:${row.transactionId}.',
          ),
        );
      }
    }

    final List<db.GoalAccountLinkRow> goalAccountLinkRows = await _db
        .select(_db.goalAccountLinks)
        .get();
    for (final db.GoalAccountLinkRow row in goalAccountLinkRows) {
      final db.LocalRowOwnershipRow? ownership = await _resolver
          .resolveGoalAccountLinkOwnership(
            goalId: row.goalId,
            accountId: row.accountId,
          );
      if (ownership == null) {
        issues.add(
          OwnershipIntegrityIssue(
            type: OwnershipIntegrityIssueType.missingInheritedParentOwnership,
            entityType: 'goal_account_link',
            entityId: '${row.goalId}:${row.accountId}',
            message:
                'Для goal_account_link отсутствует запись владения родительской saving_goal:${row.goalId}.',
          ),
        );
      }
    }

    return issues;
  }
}
