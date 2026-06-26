import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_snapshot_builder.dart';

void main() {
  late AppDatabase database;
  late LocalToCloudMigrationInventorySnapshotBuilder builder;
  late LocalToCloudMigrationInventoryValidator validator;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    builder = LocalToCloudMigrationInventorySnapshotBuilder(database);
    validator = LocalToCloudMigrationInventoryValidator(
      policy: LocalToCloudMigrationInventoryPolicy(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'builds snapshot with current candidate families and transaction tag doc IDs aligned to remote shape',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Cash',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
            ),
          );
      await database
          .into(database.tags)
          .insert(
            TagsCompanion.insert(
              id: 'tag-1',
              name: 'Tag',
              color: '#FFFFFF',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'txn-1',
              accountId: 'acc-1',
              amount: 10,
              date: DateTime.utc(2024, 1, 2),
              type: 'expense',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
            ),
          );
      await database
          .into(database.transactionTags)
          .insert(
            TransactionTagsCompanion.insert(
              transactionId: 'txn-1',
              tagId: 'tag-1',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
            ),
          );

      final LocalToCloudMigrationInventorySnapshot snapshot = await builder
          .build();

      expect(
        snapshot.candidateFamilyKeys,
        containsAll(<String>['transaction_tags', 'goal_account_links']),
      );
      final LocalToCloudMigrationRow row =
          snapshot.rowsByFamily['transaction_tags']!.single;
      expect(row.localRowId, 'txn-1::tag-1');
      expect(row.reusedDocumentId, 'txn-1::tag-1');
      expect(row.references, hasLength(2));
    },
  );

  test(
    'builder plus validator blocks transaction referencing placeholder system category',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Cash',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
            ),
          );
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-missing',
              name: 'Категория недоступна (cat-missing)',
              type: 'expense',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              isDeleted: const Value<bool>(true),
              isSystem: const Value<bool>(true),
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'txn-1',
              accountId: 'acc-1',
              categoryId: const Value<String>('cat-missing'),
              amount: 10,
              date: DateTime.utc(2024, 1, 2),
              type: 'expense',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
            ),
          );

      final LocalToCloudMigrationInventorySnapshot snapshot = await builder
          .build();
      final LocalToCloudMigrationReadinessResult result = validator.validate(
        rowsByFamily: snapshot.rowsByFamily,
        candidateFamilyKeys: snapshot.candidateFamilyKeys,
      );

      expect(result.isReady, isFalse);
      expect(result.allowsPartialUpload, isFalse);
      expect(
        result.issues.any(
          (LocalToCloudMigrationReadinessIssue issue) =>
              issue.code ==
                  LocalToCloudMigrationReadinessReasonCode
                      .systemReferenceWithoutCanonicalHandling &&
              issue.familyKey == 'transactions' &&
              issue.rowId == 'txn-1',
        ),
        isTrue,
      );
    },
  );
}
