import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';

void main() {
  group('LocalToCloudMigrationInventoryPolicy', () {
    test('classifies every current candidate family', () {
      final LocalToCloudMigrationInventoryPolicy policy =
          LocalToCloudMigrationInventoryPolicy();

      expect(policy.unclassifiedCandidateFamilyKeys(), isEmpty);
    });

    test(
      'composite or parent-derived ID with slash is unsafe path segment',
      () {
        const FirestoreDocumentIdSafety safety = FirestoreDocumentIdSafety();

        final FirestoreDocumentIdSafetyCheck result = safety
            .validatePathSegment('transaction/tag-1');

        expect(result.isSafe, isFalse);
        expect(result.message, contains('forward slash'));
      },
    );
  });

  group('LocalToCloudMigrationInventoryValidator', () {
    late LocalToCloudMigrationInventoryPolicy policy;
    late LocalToCloudMigrationInventoryValidator validator;

    setUp(() {
      policy = LocalToCloudMigrationInventoryPolicy();
      validator = LocalToCloudMigrationInventoryValidator(policy: policy);
    });

    test(
      'fails when a local business or export/import family is unclassified',
      () {
        final LocalToCloudMigrationReadinessResult result = validator.validate(
          rowsByFamily: const <String, List<LocalToCloudMigrationRow>>{},
          candidateFamilyKeys: <String>{
            ...LocalToCloudMigrationInventoryPolicy.currentCandidateFamilyKeys,
            'custom_export_family',
          },
        );

        expect(result.isReady, isFalse);
        expect(result.allowsPartialUpload, isFalse);
        expect(
          result.issues.any(
            (LocalToCloudMigrationReadinessIssue issue) =>
                issue.code ==
                    LocalToCloudMigrationReadinessReasonCode
                        .unclassifiedEntityFamily &&
                issue.familyKey == 'custom_export_family',
          ),
          isTrue,
        );
      },
    );

    test(
      'included family with one unsafe row blocks readiness and partial upload',
      () {
        final LocalToCloudMigrationReadinessResult result = validator.validate(
          rowsByFamily: const <String, List<LocalToCloudMigrationRow>>{
            'accounts': <LocalToCloudMigrationRow>[
              LocalToCloudMigrationRow(
                familyKey: 'accounts',
                localRowId: 'acc-safe',
                reusedDocumentId: 'acc-safe',
              ),
              LocalToCloudMigrationRow(
                familyKey: 'accounts',
                localRowId: 'acc-unsafe',
                reusedDocumentId: 'legacy/unsafe-id',
              ),
            ],
          },
        );

        expect(result.isReady, isFalse);
        expect(result.allowsPartialUpload, isFalse);
        expect(
          result.issues.any(
            (LocalToCloudMigrationReadinessIssue issue) =>
                issue.code ==
                    LocalToCloudMigrationReadinessReasonCode.unsafeDocumentId &&
                issue.familyKey == 'accounts' &&
                issue.rowId == 'acc-unsafe',
          ),
          isTrue,
        );
      },
    );

    test('included family with unsafe imported row ID blocks readiness', () {
      final LocalToCloudMigrationReadinessResult result = validator.validate(
        rowsByFamily: const <String, List<LocalToCloudMigrationRow>>{
          'transactions': <LocalToCloudMigrationRow>[
            LocalToCloudMigrationRow(
              familyKey: 'transactions',
              localRowId: 'txn-import-1',
              reusedDocumentId: '__legacy__',
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: 'acc-1',
                ),
              ],
            ),
          ],
          'accounts': <LocalToCloudMigrationRow>[
            LocalToCloudMigrationRow(
              familyKey: 'accounts',
              localRowId: 'acc-1',
              reusedDocumentId: 'acc-1',
            ),
          ],
        },
      );

      expect(result.isReady, isFalse);
      expect(
        result.issues.any(
          (LocalToCloudMigrationReadinessIssue issue) =>
              issue.code ==
                  LocalToCloudMigrationReadinessReasonCode.unsafeDocumentId &&
              issue.familyKey == 'transactions' &&
              issue.rowId == 'txn-import-1',
        ),
        isTrue,
      );
    });

    test(
      'transaction referencing placeholder system category blocks without canonical handling',
      () {
        final LocalToCloudMigrationReadinessResult result = validator.validate(
          rowsByFamily: const <String, List<LocalToCloudMigrationRow>>{
            'accounts': <LocalToCloudMigrationRow>[
              LocalToCloudMigrationRow(
                familyKey: 'accounts',
                localRowId: 'acc-1',
                reusedDocumentId: 'acc-1',
              ),
            ],
            'categories': <LocalToCloudMigrationRow>[
              LocalToCloudMigrationRow(
                familyKey: 'categories',
                localRowId: 'cat-missing',
                reusedDocumentId: 'cat-missing',
                isSystem: true,
                isPlaceholder: true,
              ),
            ],
            'transactions': <LocalToCloudMigrationRow>[
              LocalToCloudMigrationRow(
                familyKey: 'transactions',
                localRowId: 'txn-1',
                reusedDocumentId: 'txn-1',
                references: <LocalToCloudMigrationRowReference>[
                  LocalToCloudMigrationRowReference(
                    fieldName: 'accountId',
                    targetFamilyKey: 'accounts',
                    targetRowId: 'acc-1',
                  ),
                  LocalToCloudMigrationRowReference(
                    fieldName: 'categoryId',
                    targetFamilyKey: 'categories',
                    targetRowId: 'cat-missing',
                    nullable: true,
                  ),
                ],
              ),
            ],
          },
        );

        expect(result.isReady, isFalse);
        expect(
          result.issues.any(
            (LocalToCloudMigrationReadinessIssue issue) =>
                issue.code ==
                    LocalToCloudMigrationReadinessReasonCode
                        .systemReferenceWithoutCanonicalHandling &&
                issue.familyKey == 'transactions' &&
                issue.rowId == 'txn-1' &&
                issue.referenceField == 'categoryId',
          ),
          isTrue,
        );
      },
    );

    test(
      'transaction referencing placeholder system category is allowed with canonical handling',
      () {
        final LocalToCloudMigrationFamilyPolicy transactionsPolicy = policy
            .policyFor('transactions')!;
        final LocalToCloudMigrationInventoryPolicy canonicalPolicy =
            LocalToCloudMigrationInventoryPolicy(
              families: <String, LocalToCloudMigrationFamilyPolicy>{
                ...policy.families,
                'transactions': LocalToCloudMigrationFamilyPolicy(
                  familyKey: transactionsPolicy.familyKey,
                  status: transactionsPolicy.status,
                  localTable: transactionsPolicy.localTable,
                  remoteCollection: transactionsPolicy.remoteCollection,
                  participatesInExport: transactionsPolicy.participatesInExport,
                  participatesInImport: transactionsPolicy.participatesInImport,
                  referencePolicies: transactionsPolicy.referencePolicies,
                  canonicalSystemReferenceFields: const <String>{'categoryId'},
                  notes: transactionsPolicy.notes,
                ),
              },
            );
        final LocalToCloudMigrationInventoryValidator canonicalValidator =
            LocalToCloudMigrationInventoryValidator(policy: canonicalPolicy);

        final LocalToCloudMigrationReadinessResult result = canonicalValidator
            .validate(
              rowsByFamily: const <String, List<LocalToCloudMigrationRow>>{
                'accounts': <LocalToCloudMigrationRow>[
                  LocalToCloudMigrationRow(
                    familyKey: 'accounts',
                    localRowId: 'acc-1',
                    reusedDocumentId: 'acc-1',
                  ),
                ],
                'categories': <LocalToCloudMigrationRow>[
                  LocalToCloudMigrationRow(
                    familyKey: 'categories',
                    localRowId: 'cat-missing',
                    reusedDocumentId: 'cat-missing',
                    isSystem: true,
                    isPlaceholder: true,
                  ),
                ],
                'transactions': <LocalToCloudMigrationRow>[
                  LocalToCloudMigrationRow(
                    familyKey: 'transactions',
                    localRowId: 'txn-1',
                    reusedDocumentId: 'txn-1',
                    references: <LocalToCloudMigrationRowReference>[
                      LocalToCloudMigrationRowReference(
                        fieldName: 'accountId',
                        targetFamilyKey: 'accounts',
                        targetRowId: 'acc-1',
                      ),
                      LocalToCloudMigrationRowReference(
                        fieldName: 'categoryId',
                        targetFamilyKey: 'categories',
                        targetRowId: 'cat-missing',
                        nullable: true,
                      ),
                    ],
                  ),
                ],
              },
            );

        expect(result.isReady, isTrue);
        expect(result.allowsPartialUpload, isTrue);
      },
    );
  });
}
