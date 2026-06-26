import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/sync/local_to_cloud_migration_inventory_policy.dart';

class LocalToCloudMigrationInventorySnapshot {
  const LocalToCloudMigrationInventorySnapshot({
    required this.candidateFamilyKeys,
    required this.rowsByFamily,
  });

  final Set<String> candidateFamilyKeys;
  final Map<String, List<LocalToCloudMigrationRow>> rowsByFamily;
}

class LocalToCloudMigrationInventorySnapshotBuilder {
  LocalToCloudMigrationInventorySnapshotBuilder(this._database);

  final db.AppDatabase _database;

  Future<LocalToCloudMigrationInventorySnapshot> build() async {
    final List<db.AccountRow> accounts = await _database
        .select(_database.accounts)
        .get();
    final List<db.CategoryRow> categories = await _database
        .select(_database.categories)
        .get();
    final List<db.TagRow> tags = await _database.select(_database.tags).get();
    final List<db.TransactionRow> transactions = await _database
        .select(_database.transactions)
        .get();
    final List<db.TransactionTagRow> transactionTags = await _database
        .select(_database.transactionTags)
        .get();
    final List<db.BudgetRow> budgets = await _database
        .select(_database.budgets)
        .get();
    final List<db.BudgetInstanceRow> budgetInstances = await _database
        .select(_database.budgetInstances)
        .get();
    final List<db.SavingGoalRow> savingGoals = await _database
        .select(_database.savingGoals)
        .get();
    final List<db.GoalAccountLinkRow> goalAccountLinks = await _database
        .select(_database.goalAccountLinks)
        .get();
    final List<db.GoalContributionRow> goalContributions = await _database
        .select(_database.goalContributions)
        .get();
    final List<db.CreditRow> credits = await _database
        .select(_database.credits)
        .get();
    final List<db.CreditCardRow> creditCards = await _database
        .select(_database.creditCards)
        .get();
    final List<db.DebtRow> debts = await _database
        .select(_database.debts)
        .get();
    final List<db.CreditPaymentScheduleRow> creditPaymentSchedules =
        await _database.select(_database.creditPaymentSchedules).get();
    final List<db.CreditPaymentGroupRow> creditPaymentGroups = await _database
        .select(_database.creditPaymentGroups)
        .get();
    final List<db.ProfileRow> profiles = await _database
        .select(_database.profiles)
        .get();
    final List<db.UpcomingPaymentRow> upcomingPayments = await _database
        .select(_database.upcomingPayments)
        .get();
    final List<db.PaymentReminderRow> paymentReminders = await _database
        .select(_database.paymentReminders)
        .get();

    final Map<String, Set<String>> goalStorageAccountIds =
        <String, Set<String>>{};
    for (final db.SavingGoalRow row in savingGoals) {
      goalStorageAccountIds[row.id] = <String>{
        if (row.accountId?.trim().isNotEmpty ?? false) row.accountId!.trim(),
      };
    }
    for (final db.GoalAccountLinkRow row in goalAccountLinks) {
      goalStorageAccountIds
          .putIfAbsent(row.goalId, () => <String>{})
          .add(row.accountId);
    }

    final Map<String, List<LocalToCloudMigrationRow>>
    rowsByFamily = <String, List<LocalToCloudMigrationRow>>{
      'accounts': accounts
          .map(
            (db.AccountRow row) => LocalToCloudMigrationRow(
              familyKey: 'accounts',
              localRowId: row.id,
              reusedDocumentId: row.id,
            ),
          )
          .toList(growable: false),
      'categories': categories
          .map(
            (db.CategoryRow row) => LocalToCloudMigrationRow(
              familyKey: 'categories',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                if (row.parentId?.trim().isNotEmpty ?? false)
                  LocalToCloudMigrationRowReference(
                    fieldName: 'parentId',
                    targetFamilyKey: 'categories',
                    targetRowId: row.parentId!.trim(),
                    nullable: true,
                  ),
              ],
              isSystem: row.isSystem,
              isPlaceholder: _isMissingReferencePlaceholder(row),
            ),
          )
          .toList(growable: false),
      'tags': tags
          .map(
            (db.TagRow row) => LocalToCloudMigrationRow(
              familyKey: 'tags',
              localRowId: row.id,
              reusedDocumentId: row.id,
            ),
          )
          .toList(growable: false),
      'transactions': transactions
          .map(
            (db.TransactionRow row) => LocalToCloudMigrationRow(
              familyKey: 'transactions',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'transferAccountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.transferAccountId?.trim(),
                  nullable: true,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'categoryId',
                  targetFamilyKey: 'categories',
                  targetRowId: row.categoryId?.trim(),
                  nullable: true,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'savingGoalId',
                  targetFamilyKey: 'saving_goals',
                  targetRowId: row.savingGoalId?.trim(),
                  nullable: true,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'groupId',
                  targetFamilyKey: 'credit_payment_groups',
                  targetRowId: row.groupId?.trim(),
                  nullable: true,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'transaction_tags': transactionTags
          .map(
            (db.TransactionTagRow row) => LocalToCloudMigrationRow(
              familyKey: 'transaction_tags',
              localRowId: _composeLinkRowId(row.transactionId, row.tagId),
              reusedDocumentId: _composeLinkRowId(row.transactionId, row.tagId),
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'transactionId',
                  targetFamilyKey: 'transactions',
                  targetRowId: row.transactionId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'tagId',
                  targetFamilyKey: 'tags',
                  targetRowId: row.tagId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'budgets': budgets
          .map(
            (db.BudgetRow row) => LocalToCloudMigrationRow(
              familyKey: 'budgets',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                ...row.accounts.map(
                  (String accountId) => LocalToCloudMigrationRowReference(
                    fieldName: 'accounts',
                    targetFamilyKey: 'accounts',
                    targetRowId: accountId,
                  ),
                ),
                ...row.categories.map(
                  (String categoryId) => LocalToCloudMigrationRowReference(
                    fieldName: 'categories',
                    targetFamilyKey: 'categories',
                    targetRowId: categoryId,
                  ),
                ),
                ...row.categoryAllocations.map(
                  (Map<String, dynamic> allocation) =>
                      LocalToCloudMigrationRowReference(
                        fieldName: 'categoryAllocations',
                        targetFamilyKey: 'categories',
                        targetRowId: allocation['categoryId'] as String?,
                      ),
                ),
              ],
            ),
          )
          .toList(growable: false),
      'budget_instances': budgetInstances
          .map(
            (db.BudgetInstanceRow row) => LocalToCloudMigrationRow(
              familyKey: 'budget_instances',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'budgetId',
                  targetFamilyKey: 'budgets',
                  targetRowId: row.budgetId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'saving_goals': savingGoals
          .map(
            (db.SavingGoalRow row) => LocalToCloudMigrationRow(
              familyKey: 'saving_goals',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId?.trim(),
                  nullable: true,
                ),
                ...?goalStorageAccountIds[row.id]?.map(
                  (String accountId) => LocalToCloudMigrationRowReference(
                    fieldName: 'storageAccountIds',
                    targetFamilyKey: 'accounts',
                    targetRowId: accountId,
                  ),
                ),
              ],
            ),
          )
          .toList(growable: false),
      'goal_account_links': goalAccountLinks
          .map(
            (db.GoalAccountLinkRow row) => LocalToCloudMigrationRow(
              familyKey: 'goal_account_links',
              localRowId: _composeLinkRowId(row.goalId, row.accountId),
              reusedDocumentId: _composeLinkRowId(row.goalId, row.accountId),
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'goalId',
                  targetFamilyKey: 'saving_goals',
                  targetRowId: row.goalId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'goal_contributions': goalContributions
          .map(
            (db.GoalContributionRow row) => LocalToCloudMigrationRow(
              familyKey: 'goal_contributions',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'goalId',
                  targetFamilyKey: 'saving_goals',
                  targetRowId: row.goalId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'transactionId',
                  targetFamilyKey: 'transactions',
                  targetRowId: row.transactionId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'storageAccountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.storageAccountId?.trim(),
                  nullable: true,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'credits': credits
          .map(
            (db.CreditRow row) => LocalToCloudMigrationRow(
              familyKey: 'credits',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'targetAccountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.targetAccountId?.trim(),
                  nullable: true,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'categoryId',
                  targetFamilyKey: 'categories',
                  targetRowId: row.categoryId?.trim(),
                  nullable: true,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'interestCategoryId',
                  targetFamilyKey: 'categories',
                  targetRowId: row.interestCategoryId?.trim(),
                  nullable: true,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'feesCategoryId',
                  targetFamilyKey: 'categories',
                  targetRowId: row.feesCategoryId?.trim(),
                  nullable: true,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'credit_cards': creditCards
          .map(
            (db.CreditCardRow row) => LocalToCloudMigrationRow(
              familyKey: 'credit_cards',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'debts': debts
          .map(
            (db.DebtRow row) => LocalToCloudMigrationRow(
              familyKey: 'debts',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'credit_payment_schedules': creditPaymentSchedules
          .map(
            (db.CreditPaymentScheduleRow row) => LocalToCloudMigrationRow(
              familyKey: 'credit_payment_schedules',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'creditId',
                  targetFamilyKey: 'credits',
                  targetRowId: row.creditId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'credit_payment_groups': creditPaymentGroups
          .map(
            (db.CreditPaymentGroupRow row) => LocalToCloudMigrationRow(
              familyKey: 'credit_payment_groups',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'creditId',
                  targetFamilyKey: 'credits',
                  targetRowId: row.creditId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'sourceAccountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.sourceAccountId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'scheduleItemId',
                  targetFamilyKey: 'credit_payment_schedules',
                  targetRowId: row.scheduleItemId?.trim(),
                  nullable: true,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'profile': profiles
          .map(
            (db.ProfileRow row) => LocalToCloudMigrationRow(
              familyKey: 'profile',
              localRowId: row.uid,
              reusedDocumentId: row.uid,
            ),
          )
          .toList(growable: false),
      'upcoming_payments': upcomingPayments
          .map(
            (db.UpcomingPaymentRow row) => LocalToCloudMigrationRow(
              familyKey: 'upcoming_payments',
              localRowId: row.id,
              reusedDocumentId: row.id,
              references: <LocalToCloudMigrationRowReference>[
                LocalToCloudMigrationRowReference(
                  fieldName: 'accountId',
                  targetFamilyKey: 'accounts',
                  targetRowId: row.accountId,
                ),
                LocalToCloudMigrationRowReference(
                  fieldName: 'categoryId',
                  targetFamilyKey: 'categories',
                  targetRowId: row.categoryId,
                ),
              ],
            ),
          )
          .toList(growable: false),
      'payment_reminders': paymentReminders
          .map(
            (db.PaymentReminderRow row) => LocalToCloudMigrationRow(
              familyKey: 'payment_reminders',
              localRowId: row.id,
              reusedDocumentId: row.id,
            ),
          )
          .toList(growable: false),
    };

    return LocalToCloudMigrationInventorySnapshot(
      candidateFamilyKeys:
          LocalToCloudMigrationInventoryPolicy.currentCandidateFamilyKeys,
      rowsByFamily: Map<String, List<LocalToCloudMigrationRow>>.unmodifiable(
        rowsByFamily,
      ),
    );
  }

  String _composeLinkRowId(String leftId, String rightId) {
    return '$leftId::$rightId';
  }

  bool _isMissingReferencePlaceholder(db.CategoryRow row) {
    return row.isSystem &&
        row.isDeleted &&
        row.name.startsWith('Категория недоступна');
  }
}
