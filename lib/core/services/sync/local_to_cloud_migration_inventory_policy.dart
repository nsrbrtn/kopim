import 'dart:convert';

import 'package:kopim/core/services/sync/sync_contract.dart';

enum LocalToCloudMigrationFamilyStatus {
  includedInV1,
  excludedFromV1,
  blocksV1UntilFollowUp,
}

enum LocalToCloudMigrationReadinessStatus { ready, blocked }

enum LocalToCloudMigrationReadinessReasonCode {
  unsafeDocumentId,
  missingRequiredDependency,
  excludedRequiredDependency,
  unclassifiedEntityFamily,
  systemReferenceWithoutCanonicalHandling,
  unknownIdStrategy,
  blockedEntityFamily,
}

class FirestoreDocumentIdSafetyCheck {
  const FirestoreDocumentIdSafetyCheck._({
    required this.pathSegment,
    required this.isSafe,
    this.message,
  });

  const FirestoreDocumentIdSafetyCheck.safe(String pathSegment)
    : this._(pathSegment: pathSegment, isSafe: true);

  const FirestoreDocumentIdSafetyCheck.unsafe(
    String pathSegment,
    String message,
  ) : this._(pathSegment: pathSegment, isSafe: false, message: message);

  final String pathSegment;
  final bool isSafe;
  final String? message;
}

class FirestoreDocumentIdSafety {
  const FirestoreDocumentIdSafety();

  static final RegExp _reservedPattern = RegExp(r'^__.*__$');

  FirestoreDocumentIdSafetyCheck validatePathSegment(String pathSegment) {
    if (pathSegment.isEmpty) {
      return const FirestoreDocumentIdSafetyCheck.unsafe(
        '',
        'Firestore document path segment must not be empty.',
      );
    }

    final List<int> utf8Bytes;
    try {
      utf8Bytes = utf8.encode(pathSegment);
    } catch (_) {
      return FirestoreDocumentIdSafetyCheck.unsafe(
        pathSegment,
        'Firestore document path segment must be valid UTF-8.',
      );
    }

    if (utf8Bytes.length > 1500) {
      return FirestoreDocumentIdSafetyCheck.unsafe(
        pathSegment,
        'Firestore document path segment must be at most 1500 bytes.',
      );
    }
    if (pathSegment.contains('/')) {
      return FirestoreDocumentIdSafetyCheck.unsafe(
        pathSegment,
        'Firestore document path segment must not contain a forward slash.',
      );
    }
    if (pathSegment == '.' || pathSegment == '..') {
      return FirestoreDocumentIdSafetyCheck.unsafe(
        pathSegment,
        'Firestore document path segment must not be "." or "..".',
      );
    }
    if (_reservedPattern.hasMatch(pathSegment)) {
      return FirestoreDocumentIdSafetyCheck.unsafe(
        pathSegment,
        'Firestore document path segment must not match __.*__.',
      );
    }

    return FirestoreDocumentIdSafetyCheck.safe(pathSegment);
  }
}

class LocalToCloudMigrationFamilyReferencePolicy {
  const LocalToCloudMigrationFamilyReferencePolicy({
    required this.fieldName,
    required this.targetFamilyKey,
    this.nullable = false,
  });

  final String fieldName;
  final String targetFamilyKey;
  final bool nullable;
}

class LocalToCloudMigrationFamilyPolicy {
  const LocalToCloudMigrationFamilyPolicy({
    required this.familyKey,
    required this.status,
    this.localTable,
    this.remoteCollection,
    this.participatesInExport = false,
    this.participatesInImport = false,
    this.referencePolicies =
        const <LocalToCloudMigrationFamilyReferencePolicy>[],
    this.canonicalSystemReferenceFields = const <String>{},
    this.notes,
  });

  final String familyKey;
  final LocalToCloudMigrationFamilyStatus status;
  final String? localTable;
  final String? remoteCollection;
  final bool participatesInExport;
  final bool participatesInImport;
  final List<LocalToCloudMigrationFamilyReferencePolicy> referencePolicies;
  final Set<String> canonicalSystemReferenceFields;
  final String? notes;

  bool allowsCanonicalSystemReference(String fieldName) {
    return canonicalSystemReferenceFields.contains(fieldName);
  }
}

class LocalToCloudMigrationRowReference {
  const LocalToCloudMigrationRowReference({
    required this.fieldName,
    required this.targetFamilyKey,
    this.targetRowId,
    this.nullable = false,
  });

  final String fieldName;
  final String targetFamilyKey;
  final String? targetRowId;
  final bool nullable;
}

class LocalToCloudMigrationRow {
  const LocalToCloudMigrationRow({
    required this.familyKey,
    required this.localRowId,
    required this.reusedDocumentId,
    this.hasKnownIdStrategy = true,
    this.references = const <LocalToCloudMigrationRowReference>[],
    this.isSystem = false,
    this.isPlaceholder = false,
  });

  final String familyKey;
  final String localRowId;
  final String reusedDocumentId;
  final bool hasKnownIdStrategy;
  final List<LocalToCloudMigrationRowReference> references;
  final bool isSystem;
  final bool isPlaceholder;

  bool get isSystemLike => isSystem || isPlaceholder;
}

class LocalToCloudMigrationReadinessIssue {
  const LocalToCloudMigrationReadinessIssue({
    required this.code,
    required this.familyKey,
    this.rowId,
    this.referenceField,
    this.targetFamilyKey,
    this.targetRowId,
    required this.message,
  });

  final LocalToCloudMigrationReadinessReasonCode code;
  final String familyKey;
  final String? rowId;
  final String? referenceField;
  final String? targetFamilyKey;
  final String? targetRowId;
  final String message;
}

class LocalToCloudMigrationReadinessResult {
  const LocalToCloudMigrationReadinessResult({
    required this.status,
    required this.issues,
  });

  const LocalToCloudMigrationReadinessResult.ready()
    : status = LocalToCloudMigrationReadinessStatus.ready,
      issues = const <LocalToCloudMigrationReadinessIssue>[];

  final LocalToCloudMigrationReadinessStatus status;
  final List<LocalToCloudMigrationReadinessIssue> issues;

  bool get isReady => status == LocalToCloudMigrationReadinessStatus.ready;

  bool get allowsPartialUpload => isReady;
}

class LocalToCloudMigrationInventoryPolicy {
  LocalToCloudMigrationInventoryPolicy({
    Map<String, LocalToCloudMigrationFamilyPolicy>? families,
  }) : families = Map<String, LocalToCloudMigrationFamilyPolicy>.unmodifiable(
         families ?? _buildDefaultFamilies(),
       );

  static const Set<String> _extraLocalBusinessFamilyKeys = <String>{
    'goal_account_links',
  };

  static final Set<String> localBusinessFamilyKeys = <String>{
    for (final SyncEntityManifestEntry entry in SyncContract.manifest)
      if (entry.localTable != null) entry.key,
    ..._extraLocalBusinessFamilyKeys,
  };

  static final Set<String> currentCandidateFamilyKeys = <String>{
    ...SyncContract.manifest.map((SyncEntityManifestEntry entry) => entry.key),
    ...localBusinessFamilyKeys,
    ...SyncContract.exportSnapshotKeys,
    ...SyncContract.importSnapshotKeys,
  };

  final Map<String, LocalToCloudMigrationFamilyPolicy> families;

  Iterable<String> get classifiedFamilyKeys => families.keys;

  LocalToCloudMigrationFamilyPolicy? policyFor(String familyKey) {
    return families[familyKey];
  }

  Set<String> unclassifiedCandidateFamilyKeys({
    Iterable<String>? candidateFamilyKeys,
  }) {
    final Set<String> current =
        (candidateFamilyKeys ?? currentCandidateFamilyKeys).toSet();
    return current.difference(families.keys.toSet());
  }

  static Map<String, LocalToCloudMigrationFamilyPolicy>
  _buildDefaultFamilies() {
    const Map<String, LocalToCloudMigrationFamilyStatus>
    statuses = <String, LocalToCloudMigrationFamilyStatus>{
      'accounts': LocalToCloudMigrationFamilyStatus.includedInV1,
      'categories': LocalToCloudMigrationFamilyStatus.includedInV1,
      'tags': LocalToCloudMigrationFamilyStatus.includedInV1,
      'transaction_tags': LocalToCloudMigrationFamilyStatus.includedInV1,
      'transactions': LocalToCloudMigrationFamilyStatus.includedInV1,
      'goal_contributions': LocalToCloudMigrationFamilyStatus.excludedFromV1,
      'credits': LocalToCloudMigrationFamilyStatus.includedInV1,
      'credit_cards': LocalToCloudMigrationFamilyStatus.includedInV1,
      'debts': LocalToCloudMigrationFamilyStatus.includedInV1,
      'profile': LocalToCloudMigrationFamilyStatus.excludedFromV1,
      'progress': LocalToCloudMigrationFamilyStatus.excludedFromV1,
      'budgets': LocalToCloudMigrationFamilyStatus.includedInV1,
      'budget_instances': LocalToCloudMigrationFamilyStatus.includedInV1,
      'saving_goals': LocalToCloudMigrationFamilyStatus.includedInV1,
      'upcoming_payments': LocalToCloudMigrationFamilyStatus.includedInV1,
      'payment_reminders': LocalToCloudMigrationFamilyStatus.includedInV1,
      'credit_payment_groups': LocalToCloudMigrationFamilyStatus.includedInV1,
      'credit_payment_schedules':
          LocalToCloudMigrationFamilyStatus.includedInV1,
      'goal_account_links': LocalToCloudMigrationFamilyStatus.excludedFromV1,
    };

    final Map<String, String> familyKeyByEntityType = <String, String>{
      for (final SyncEntityManifestEntry entry in SyncContract.manifest)
        if (entry.outboxEntityType != null) entry.outboxEntityType!: entry.key,
    };

    final Map<String, LocalToCloudMigrationFamilyPolicy> result =
        <String, LocalToCloudMigrationFamilyPolicy>{};
    for (final SyncEntityManifestEntry entry in SyncContract.manifest) {
      final LocalToCloudMigrationFamilyStatus? status = statuses[entry.key];
      if (status == null) {
        throw StateError(
          'LocalToCloudMigrationInventoryPolicy is missing a status for '
          'SyncContract family ${entry.key}.',
        );
      }
      result[entry.key] = LocalToCloudMigrationFamilyPolicy(
        familyKey: entry.key,
        status: status,
        localTable: entry.localTable,
        remoteCollection: entry.remoteCollection,
        participatesInExport: entry.participatesInExport,
        participatesInImport: entry.participatesInImport,
        referencePolicies: entry.references
            .map(
              (SyncReferenceDescriptor reference) =>
                  LocalToCloudMigrationFamilyReferencePolicy(
                    fieldName: reference.fieldName,
                    targetFamilyKey:
                        familyKeyByEntityType[reference.parentEntityType] ??
                        reference.parentEntityType,
                    nullable: reference.nullable,
                  ),
            )
            .toList(growable: false),
        notes: switch (entry.key) {
          'goal_contributions' =>
            'Derived-only rows rebuilt from migrated transactions.',
          'profile' => 'Safe to omit from v1 financial migration graph.',
          'progress' => 'Derived export-only progress snapshot.',
          _ => null,
        },
      );
    }

    result['goal_account_links'] = const LocalToCloudMigrationFamilyPolicy(
      familyKey: 'goal_account_links',
      status: LocalToCloudMigrationFamilyStatus.excludedFromV1,
      localTable: 'goal_account_links',
      participatesInExport: false,
      participatesInImport: true,
      referencePolicies: <LocalToCloudMigrationFamilyReferencePolicy>[
        LocalToCloudMigrationFamilyReferencePolicy(
          fieldName: 'goalId',
          targetFamilyKey: 'saving_goals',
        ),
        LocalToCloudMigrationFamilyReferencePolicy(
          fieldName: 'accountId',
          targetFamilyKey: 'accounts',
        ),
      ],
      notes:
          'Safe to omit as a standalone family because v1 reuses '
          'saving_goal.storageAccountIds as the canonical graph.',
    );

    return result;
  }
}

class LocalToCloudMigrationInventoryValidator {
  LocalToCloudMigrationInventoryValidator({
    required LocalToCloudMigrationInventoryPolicy policy,
    FirestoreDocumentIdSafety? documentIdSafety,
  }) : _policy = policy,
       _documentIdSafety =
           documentIdSafety ?? const FirestoreDocumentIdSafety();

  final LocalToCloudMigrationInventoryPolicy _policy;
  final FirestoreDocumentIdSafety _documentIdSafety;

  LocalToCloudMigrationReadinessResult validate({
    required Map<String, List<LocalToCloudMigrationRow>> rowsByFamily,
    Iterable<String>? candidateFamilyKeys,
  }) {
    final Set<String> candidates =
        (candidateFamilyKeys ??
                LocalToCloudMigrationInventoryPolicy.currentCandidateFamilyKeys)
            .toSet();
    final List<LocalToCloudMigrationReadinessIssue> issues =
        <LocalToCloudMigrationReadinessIssue>[];

    for (final String familyKey in candidates.toList()..sort()) {
      final LocalToCloudMigrationFamilyPolicy? familyPolicy = _policy.policyFor(
        familyKey,
      );
      if (familyPolicy == null) {
        issues.add(
          LocalToCloudMigrationReadinessIssue(
            code: LocalToCloudMigrationReadinessReasonCode
                .unclassifiedEntityFamily,
            familyKey: familyKey,
            message:
                'Migration inventory policy does not classify family $familyKey.',
          ),
        );
      }
    }

    final Map<String, Map<String, LocalToCloudMigrationRow>> rowsByFamilyAndId =
        <String, Map<String, LocalToCloudMigrationRow>>{
          for (final MapEntry<String, List<LocalToCloudMigrationRow>> entry
              in rowsByFamily.entries)
            entry.key: <String, LocalToCloudMigrationRow>{
              for (final LocalToCloudMigrationRow row in entry.value)
                row.localRowId: row,
            },
        };

    for (final LocalToCloudMigrationFamilyPolicy familyPolicy
        in _policy.families.values) {
      if (familyPolicy.status !=
          LocalToCloudMigrationFamilyStatus.includedInV1) {
        continue;
      }
      for (final LocalToCloudMigrationFamilyReferencePolicy referencePolicy
          in familyPolicy.referencePolicies.where(
            (LocalToCloudMigrationFamilyReferencePolicy reference) =>
                !reference.nullable,
          )) {
        final LocalToCloudMigrationFamilyPolicy? dependencyPolicy = _policy
            .policyFor(referencePolicy.targetFamilyKey);
        if (dependencyPolicy == null) {
          issues.add(
            LocalToCloudMigrationReadinessIssue(
              code: LocalToCloudMigrationReadinessReasonCode
                  .unclassifiedEntityFamily,
              familyKey: familyPolicy.familyKey,
              referenceField: referencePolicy.fieldName,
              targetFamilyKey: referencePolicy.targetFamilyKey,
              message:
                  'Required dependency family ${referencePolicy.targetFamilyKey} '
                  'is not classified.',
            ),
          );
          continue;
        }
        if (dependencyPolicy.status ==
            LocalToCloudMigrationFamilyStatus.excludedFromV1) {
          issues.add(
            LocalToCloudMigrationReadinessIssue(
              code: LocalToCloudMigrationReadinessReasonCode
                  .excludedRequiredDependency,
              familyKey: familyPolicy.familyKey,
              referenceField: referencePolicy.fieldName,
              targetFamilyKey: referencePolicy.targetFamilyKey,
              message:
                  'Required dependency family ${referencePolicy.targetFamilyKey} '
                  'is excluded from v1.',
            ),
          );
        } else if (dependencyPolicy.status ==
            LocalToCloudMigrationFamilyStatus.blocksV1UntilFollowUp) {
          issues.add(
            LocalToCloudMigrationReadinessIssue(
              code:
                  LocalToCloudMigrationReadinessReasonCode.blockedEntityFamily,
              familyKey: familyPolicy.familyKey,
              referenceField: referencePolicy.fieldName,
              targetFamilyKey: referencePolicy.targetFamilyKey,
              message:
                  'Required dependency family ${referencePolicy.targetFamilyKey} '
                  'still blocks v1 migration.',
            ),
          );
        }
      }
    }

    for (final MapEntry<String, List<LocalToCloudMigrationRow>> familyEntry
        in rowsByFamily.entries) {
      final String familyKey = familyEntry.key;
      final LocalToCloudMigrationFamilyPolicy? familyPolicy = _policy.policyFor(
        familyKey,
      );
      if (familyPolicy == null ||
          familyPolicy.status !=
              LocalToCloudMigrationFamilyStatus.includedInV1) {
        continue;
      }

      for (final LocalToCloudMigrationRow row in familyEntry.value) {
        if (!row.hasKnownIdStrategy) {
          issues.add(
            LocalToCloudMigrationReadinessIssue(
              code: LocalToCloudMigrationReadinessReasonCode.unknownIdStrategy,
              familyKey: familyKey,
              rowId: row.localRowId,
              message:
                  'Row $familyKey:${row.localRowId} does not have a known ID strategy.',
            ),
          );
          continue;
        }

        final FirestoreDocumentIdSafetyCheck idCheck = _documentIdSafety
            .validatePathSegment(row.reusedDocumentId);
        if (!idCheck.isSafe) {
          issues.add(
            LocalToCloudMigrationReadinessIssue(
              code: LocalToCloudMigrationReadinessReasonCode.unsafeDocumentId,
              familyKey: familyKey,
              rowId: row.localRowId,
              message:
                  idCheck.message ??
                  'Row $familyKey:${row.localRowId} has an unsafe document ID.',
            ),
          );
        }

        for (final LocalToCloudMigrationRowReference reference
            in row.references) {
          final String? targetRowId = reference.targetRowId?.trim();
          if (targetRowId == null || targetRowId.isEmpty) {
            if (!reference.nullable) {
              issues.add(
                LocalToCloudMigrationReadinessIssue(
                  code: LocalToCloudMigrationReadinessReasonCode
                      .missingRequiredDependency,
                  familyKey: familyKey,
                  rowId: row.localRowId,
                  referenceField: reference.fieldName,
                  targetFamilyKey: reference.targetFamilyKey,
                  message:
                      'Row $familyKey:${row.localRowId} is missing required '
                      'reference ${reference.fieldName}.',
                ),
              );
            }
            continue;
          }

          final LocalToCloudMigrationFamilyPolicy? targetFamilyPolicy = _policy
              .policyFor(reference.targetFamilyKey);
          if (targetFamilyPolicy == null) {
            issues.add(
              LocalToCloudMigrationReadinessIssue(
                code: LocalToCloudMigrationReadinessReasonCode
                    .unclassifiedEntityFamily,
                familyKey: familyKey,
                rowId: row.localRowId,
                referenceField: reference.fieldName,
                targetFamilyKey: reference.targetFamilyKey,
                targetRowId: targetRowId,
                message:
                    'Row $familyKey:${row.localRowId} references unclassified '
                    'family ${reference.targetFamilyKey}.',
              ),
            );
            continue;
          }
          if (targetFamilyPolicy.status ==
              LocalToCloudMigrationFamilyStatus.excludedFromV1) {
            issues.add(
              LocalToCloudMigrationReadinessIssue(
                code: LocalToCloudMigrationReadinessReasonCode
                    .excludedRequiredDependency,
                familyKey: familyKey,
                rowId: row.localRowId,
                referenceField: reference.fieldName,
                targetFamilyKey: reference.targetFamilyKey,
                targetRowId: targetRowId,
                message:
                    'Row $familyKey:${row.localRowId} references excluded '
                    'family ${reference.targetFamilyKey}.',
              ),
            );
            continue;
          }
          if (targetFamilyPolicy.status ==
              LocalToCloudMigrationFamilyStatus.blocksV1UntilFollowUp) {
            issues.add(
              LocalToCloudMigrationReadinessIssue(
                code: LocalToCloudMigrationReadinessReasonCode
                    .blockedEntityFamily,
                familyKey: familyKey,
                rowId: row.localRowId,
                referenceField: reference.fieldName,
                targetFamilyKey: reference.targetFamilyKey,
                targetRowId: targetRowId,
                message:
                    'Row $familyKey:${row.localRowId} references blocked '
                    'family ${reference.targetFamilyKey}.',
              ),
            );
            continue;
          }

          final LocalToCloudMigrationRow? targetRow =
              rowsByFamilyAndId[reference.targetFamilyKey]?[targetRowId];
          if (targetRow == null) {
            issues.add(
              LocalToCloudMigrationReadinessIssue(
                code: LocalToCloudMigrationReadinessReasonCode
                    .missingRequiredDependency,
                familyKey: familyKey,
                rowId: row.localRowId,
                referenceField: reference.fieldName,
                targetFamilyKey: reference.targetFamilyKey,
                targetRowId: targetRowId,
                message:
                    'Row $familyKey:${row.localRowId} references missing row '
                    '${reference.targetFamilyKey}:$targetRowId.',
              ),
            );
            continue;
          }

          if (targetRow.isSystemLike &&
              !familyPolicy.allowsCanonicalSystemReference(
                reference.fieldName,
              )) {
            issues.add(
              LocalToCloudMigrationReadinessIssue(
                code: LocalToCloudMigrationReadinessReasonCode
                    .systemReferenceWithoutCanonicalHandling,
                familyKey: familyKey,
                rowId: row.localRowId,
                referenceField: reference.fieldName,
                targetFamilyKey: reference.targetFamilyKey,
                targetRowId: targetRowId,
                message:
                    'Row $familyKey:${row.localRowId} references '
                    'system/placeholder row ${reference.targetFamilyKey}:'
                    '$targetRowId without canonical handling.',
              ),
            );
          }
        }
      }
    }

    if (issues.isEmpty) {
      return const LocalToCloudMigrationReadinessResult.ready();
    }

    return LocalToCloudMigrationReadinessResult(
      status: LocalToCloudMigrationReadinessStatus.blocked,
      issues: List<LocalToCloudMigrationReadinessIssue>.unmodifiable(issues),
    );
  }
}
