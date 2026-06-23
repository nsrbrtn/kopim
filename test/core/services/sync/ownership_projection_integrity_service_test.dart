import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync/ownership_projection_integrity_service.dart';

void main() {
  late AppDatabase database;
  late OwnershipProjectionIntegrityService service;

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    service = OwnershipProjectionIntegrityService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('detects orphan and invalid ownership projection rows', () async {
    await database
        .into(database.localRowOwnership)
        .insert(
          const LocalRowOwnershipCompanion(
            entityType: Value<String>('account'),
            entityId: Value<String>('missing-account'),
            ownershipState: Value<String>('cloudOwned'),
            ownerUid: Value<String?>(null),
            source: Value<String>('unknown_source'),
          ),
        );

    final List<OwnershipIntegrityIssue> issues = await service.runDiagnostics();

    expect(
      issues.any(
        (OwnershipIntegrityIssue issue) =>
            issue.type == OwnershipIntegrityIssueType.orphanProjection,
      ),
      isTrue,
    );
    expect(
      issues.any(
        (OwnershipIntegrityIssue issue) =>
            issue.type == OwnershipIntegrityIssueType.invalidCloudOwner,
      ),
      isTrue,
    );
    expect(
      issues.any(
        (OwnershipIntegrityIssue issue) =>
            issue.type == OwnershipIntegrityIssueType.invalidSource,
      ),
      isTrue,
    );
  });

  test(
    'detects missing direct projection and inherited parent ownership',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Wallet',
              balance: 0,
              currency: 'USD',
              type: 'cash',
            ),
          );
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-1',
              name: 'Food',
              type: 'expense',
              isSystem: const Value<bool>(false),
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-1',
              accountId: 'acc-1',
              amount: 10,
              date: DateTime.utc(2024, 1, 1),
              type: 'expense',
              categoryId: const Value<String?>('cat-1'),
            ),
          );
      await database
          .into(database.tags)
          .insert(
            TagsCompanion.insert(id: 'tag-1', name: 'Tag', color: '#FF0000'),
          );
      await database
          .into(database.savingGoals)
          .insert(
            SavingGoalsCompanion.insert(
              id: 'goal-1',
              userId: 'local-user-1',
              name: 'Trip',
              targetAmount: 1000,
            ),
          );
      await database
          .into(database.transactionTags)
          .insert(
            TransactionTagsCompanion.insert(
              transactionId: 'tx-1',
              tagId: 'tag-1',
            ),
          );
      await database
          .into(database.goalAccountLinks)
          .insert(
            GoalAccountLinksCompanion.insert(
              goalId: 'goal-1',
              accountId: 'acc-1',
            ),
          );

      await database.customStatement(
        "DELETE FROM local_row_ownership WHERE entity_type = 'transaction' AND entity_id = 'tx-1'",
      );
      await database.customStatement(
        "DELETE FROM local_row_ownership WHERE entity_type = 'saving_goal' AND entity_id = 'goal-1'",
      );

      final List<OwnershipIntegrityIssue> issues = await service
          .runDiagnostics();

      expect(
        issues.any(
          (OwnershipIntegrityIssue issue) =>
              issue.type == OwnershipIntegrityIssueType.missingProjection &&
              issue.entityType == 'transaction',
        ),
        isTrue,
      );
      expect(
        issues.any(
          (OwnershipIntegrityIssue issue) =>
              issue.type ==
                  OwnershipIntegrityIssueType.missingInheritedParentOwnership &&
              issue.entityType == 'transaction_tag',
        ),
        isTrue,
      );
      expect(
        issues.any(
          (OwnershipIntegrityIssue issue) =>
              issue.type ==
                  OwnershipIntegrityIssueType.missingInheritedParentOwnership &&
              issue.entityType == 'goal_account_link',
        ),
        isTrue,
      );
    },
  );

  test('detects invalid local owner combination', () async {
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'acc-1',
            name: 'Wallet',
            balance: 0,
            currency: 'USD',
            type: 'cash',
          ),
        );
    await database
        .update(database.localRowOwnership)
        .replace(
          LocalRowOwnershipRow(
            entityType: 'account',
            entityId: 'acc-1',
            ownershipState: 'localOnly',
            ownerUid: 'cloud-user-1',
            source: 'local_creation',
            updatedAt: DateTime.utc(2024, 1, 1),
            version: 1,
          ),
        );

    final List<OwnershipIntegrityIssue> issues = await service.runDiagnostics();

    expect(
      issues.any(
        (OwnershipIntegrityIssue issue) =>
            issue.type == OwnershipIntegrityIssueType.invalidLocalOwner,
      ),
      isTrue,
    );
  });
}
