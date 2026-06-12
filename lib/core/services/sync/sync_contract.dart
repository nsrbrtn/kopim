import 'package:kopim/features/transactions/domain/entities/transaction.dart';

enum SyncDeleteSemantics {
  tombstone,
  archive,
  deactivate,
  complete,
  localOnly,
  remoteDocumentDelete,
}

enum SyncConflictPolicy {
  lastWriteWins,
  typeVersionAwareLww,
  derivedRebuild,
  bestEffortCounter,
}

class SyncEntityManifestEntry {
  const SyncEntityManifestEntry({
    required this.key,
    required this.localTable,
    required this.remoteCollection,
    required this.outboxEntityType,
    required this.participatesInLoginSync,
    required this.participatesInExport,
    required this.participatesInImport,
    required this.participatesInAccountCleanup,
    required this.isDerivedOrRebuildable,
    required this.isLocalOnlyRemoteArtifact,
    required this.deleteSemantics,
    required this.conflictPolicy,
    required this.dependencyOrder,
    required this.canonicalSource,
  });

  final String key;
  final String? localTable;
  final String? remoteCollection;
  final String? outboxEntityType;
  final bool participatesInLoginSync;
  final bool participatesInExport;
  final bool participatesInImport;
  final bool participatesInAccountCleanup;
  final bool isDerivedOrRebuildable;
  final bool isLocalOnlyRemoteArtifact;
  final SyncDeleteSemantics deleteSemantics;
  final SyncConflictPolicy conflictPolicy;
  final int dependencyOrder;
  final String canonicalSource;
}

/// Единый контракт удалённого snapshot, backup/import и cleanup для sync-пайплайна.
class SyncContract {
  const SyncContract._();

  static const String accountsCollection = 'accounts';
  static const String categoriesCollection = 'categories';
  static const String tagsCollection = 'tags';
  static const String transactionTagsCollection = 'transaction_tags';
  static const String transactionsCollection = 'transactions';
  static const String creditsCollection = 'credits';
  static const String creditCardsCollection = 'credit_cards';
  static const String debtsCollection = 'debts';
  static const String profileCollection = 'profile';
  static const String progressCollection = 'progress';
  static const String budgetsCollection = 'budgets';
  static const String budgetInstancesCollection = 'budget_instances';
  static const String savingGoalsCollection = 'saving_goals';
  static const String upcomingPaymentsCollection = 'recurring_payments';
  static const String paymentRemindersCollection = 'reminders';
  static const String creditPaymentGroupsCollection = 'credit_payment_groups';
  static const String creditPaymentSchedulesCollection =
      'credit_payment_schedules';

  static const String accountEntityType = 'account';
  static const String categoryEntityType = 'category';
  static const String tagEntityType = 'tag';
  static const String transactionTagEntityType = 'transaction_tag';
  static const String transactionEntityType = 'transaction';
  static const String creditEntityType = 'credit';
  static const String creditCardEntityType = 'credit_card';
  static const String debtEntityType = 'debt';
  static const String profileEntityType = 'profile';
  static const String budgetEntityType = 'budget';
  static const String budgetInstanceEntityType = 'budget_instance';
  static const String savingGoalEntityType = 'saving_goal';
  static const String upcomingPaymentEntityType = 'upcoming_payment';
  static const String paymentReminderEntityType = 'payment_reminder';
  static const String creditPaymentGroupEntityType = 'credit_payment_group';
  static const String creditPaymentScheduleEntityType =
      'credit_payment_schedule';

  static const List<SyncEntityManifestEntry> manifest =
      <SyncEntityManifestEntry>[
        SyncEntityManifestEntry(
          key: 'accounts',
          localTable: 'accounts',
          remoteCollection: accountsCollection,
          outboxEntityType: accountEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.typeVersionAwareLww,
          dependencyOrder: 10,
          canonicalSource: 'opening_balance + transactions',
        ),
        SyncEntityManifestEntry(
          key: 'categories',
          localTable: 'categories',
          remoteCollection: categoriesCollection,
          outboxEntityType: categoryEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 20,
          canonicalSource: 'category entity',
        ),
        SyncEntityManifestEntry(
          key: 'tags',
          localTable: 'tags',
          remoteCollection: tagsCollection,
          outboxEntityType: tagEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 30,
          canonicalSource: 'tag entity',
        ),
        SyncEntityManifestEntry(
          key: 'transaction_tags',
          localTable: 'transaction_tags',
          remoteCollection: transactionTagsCollection,
          outboxEntityType: transactionTagEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 90,
          canonicalSource: 'transaction-tag link',
        ),
        SyncEntityManifestEntry(
          key: 'transactions',
          localTable: 'transactions',
          remoteCollection: transactionsCollection,
          outboxEntityType: transactionEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 80,
          canonicalSource: 'transaction entity',
        ),
        SyncEntityManifestEntry(
          key: 'goal_contributions',
          localTable: 'goal_contributions',
          remoteCollection: null,
          outboxEntityType: null,
          participatesInLoginSync: false,
          participatesInExport: false,
          participatesInImport: false,
          participatesInAccountCleanup: false,
          isDerivedOrRebuildable: true,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.localOnly,
          conflictPolicy: SyncConflictPolicy.derivedRebuild,
          dependencyOrder: 95,
          canonicalSource: 'transactions with savingGoalId',
        ),
        SyncEntityManifestEntry(
          key: 'credits',
          localTable: 'credits',
          remoteCollection: creditsCollection,
          outboxEntityType: creditEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 40,
          canonicalSource: 'credit entity',
        ),
        SyncEntityManifestEntry(
          key: 'credit_cards',
          localTable: 'credit_cards',
          remoteCollection: creditCardsCollection,
          outboxEntityType: creditCardEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 50,
          canonicalSource: 'credit card entity',
        ),
        SyncEntityManifestEntry(
          key: 'debts',
          localTable: 'debts',
          remoteCollection: debtsCollection,
          outboxEntityType: debtEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 60,
          canonicalSource: 'debt entity',
        ),
        SyncEntityManifestEntry(
          key: 'profile',
          localTable: 'profiles',
          remoteCollection: profileCollection,
          outboxEntityType: profileEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.remoteDocumentDelete,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 70,
          canonicalSource: 'profile entity',
        ),
        SyncEntityManifestEntry(
          key: 'progress',
          localTable: null,
          remoteCollection: progressCollection,
          outboxEntityType: null,
          participatesInLoginSync: false,
          participatesInExport: true,
          participatesInImport: false,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: true,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.remoteDocumentDelete,
          conflictPolicy: SyncConflictPolicy.bestEffortCounter,
          dependencyOrder: 75,
          canonicalSource: 'derived transaction stats',
        ),
        SyncEntityManifestEntry(
          key: 'budgets',
          localTable: 'budgets',
          remoteCollection: budgetsCollection,
          outboxEntityType: budgetEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 100,
          canonicalSource: 'budget entity',
        ),
        SyncEntityManifestEntry(
          key: 'budget_instances',
          localTable: 'budget_instances',
          remoteCollection: budgetInstancesCollection,
          outboxEntityType: budgetInstanceEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 110,
          canonicalSource: 'budget instance entity',
        ),
        SyncEntityManifestEntry(
          key: 'saving_goals',
          localTable: 'saving_goals',
          remoteCollection: savingGoalsCollection,
          outboxEntityType: savingGoalEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.remoteDocumentDelete,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 35,
          canonicalSource: 'saving goal entity',
        ),
        SyncEntityManifestEntry(
          key: 'upcoming_payments',
          localTable: 'upcoming_payments',
          remoteCollection: upcomingPaymentsCollection,
          outboxEntityType: upcomingPaymentEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.deactivate,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 120,
          canonicalSource: 'recurring payment rule',
        ),
        SyncEntityManifestEntry(
          key: 'payment_reminders',
          localTable: 'payment_reminders',
          remoteCollection: paymentRemindersCollection,
          outboxEntityType: paymentReminderEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.complete,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 130,
          canonicalSource: 'payment reminder entity',
        ),
        SyncEntityManifestEntry(
          key: 'credit_payment_groups',
          localTable: 'credit_payment_groups',
          remoteCollection: creditPaymentGroupsCollection,
          outboxEntityType: creditPaymentGroupEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 46,
          canonicalSource: 'credit payment group entity',
        ),
        SyncEntityManifestEntry(
          key: 'credit_payment_schedules',
          localTable: 'credit_payment_schedules',
          remoteCollection: creditPaymentSchedulesCollection,
          outboxEntityType: creditPaymentScheduleEntityType,
          participatesInLoginSync: true,
          participatesInExport: true,
          participatesInImport: true,
          participatesInAccountCleanup: true,
          isDerivedOrRebuildable: false,
          isLocalOnlyRemoteArtifact: false,
          deleteSemantics: SyncDeleteSemantics.tombstone,
          conflictPolicy: SyncConflictPolicy.lastWriteWins,
          dependencyOrder: 45,
          canonicalSource: 'credit payment schedule entity',
        ),
      ];

  static final List<String> loginSnapshotCollections = _manifestCollections(
    (SyncEntityManifestEntry entry) => entry.participatesInLoginSync,
  );

  static final List<String> remoteCleanupCollections = _manifestCollections(
    (SyncEntityManifestEntry entry) => entry.participatesInAccountCleanup,
  );

  static final Set<String> localOnlyRemoteArtifacts = _manifestCollections(
    (SyncEntityManifestEntry entry) => entry.isLocalOnlyRemoteArtifact,
  ).toSet();

  static final List<String> exportSnapshotKeys = manifest
      .where((SyncEntityManifestEntry entry) => entry.participatesInExport)
      .map((SyncEntityManifestEntry entry) => entry.key)
      .toList(growable: false);

  static final List<String> importSnapshotKeys = manifest
      .where((SyncEntityManifestEntry entry) => entry.participatesInImport)
      .map((SyncEntityManifestEntry entry) => entry.key)
      .toList(growable: false);

  static final List<String> supportedOutboxEntityTypes = manifest
      .map((SyncEntityManifestEntry entry) => entry.outboxEntityType)
      .whereType<String>()
      .toList(growable: false);

  static final Map<String, SyncEntityManifestEntry> manifestByKey =
      <String, SyncEntityManifestEntry>{
        for (final SyncEntityManifestEntry entry in manifest) entry.key: entry,
      };

  static final Map<String, SyncEntityManifestEntry> manifestByCollection =
      <String, SyncEntityManifestEntry>{
        for (final SyncEntityManifestEntry entry in manifest)
          if (entry.remoteCollection != null) entry.remoteCollection!: entry,
      };

  static final Map<String, SyncEntityManifestEntry> manifestByOutboxType =
      <String, SyncEntityManifestEntry>{
        for (final SyncEntityManifestEntry entry in manifest)
          if (entry.outboxEntityType != null) entry.outboxEntityType!: entry,
      };

  static List<String> _manifestCollections(
    bool Function(SyncEntityManifestEntry entry) predicate,
  ) {
    return manifest
        .where(predicate)
        .map((SyncEntityManifestEntry entry) => entry.remoteCollection)
        .whereType<String>()
        .toList(growable: false);
  }

  static TransactionEntity normalizeTransactionForPortableSync(
    TransactionEntity transaction,
  ) {
    return transaction;
  }

  static List<TransactionEntity> normalizeTransactionsForPortableSync(
    Iterable<TransactionEntity> transactions,
  ) {
    return transactions
        .map(normalizeTransactionForPortableSync)
        .toList(growable: false);
  }
}
