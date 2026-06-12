import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';

void main() {
  group('SyncContract manifest', () {
    test('has unique keys, remote collections and outbox entity types', () {
      const List<SyncEntityManifestEntry> manifest = SyncContract.manifest;

      final List<String> keys = manifest
          .map((SyncEntityManifestEntry entry) => entry.key)
          .toList(growable: false);
      final List<String> collections = manifest
          .map((SyncEntityManifestEntry entry) => entry.remoteCollection)
          .whereType<String>()
          .toList(growable: false);
      final List<String> outboxTypes = manifest
          .map((SyncEntityManifestEntry entry) => entry.outboxEntityType)
          .whereType<String>()
          .toList(growable: false);

      expect(keys, hasLength(keys.toSet().length));
      expect(collections, hasLength(collections.toSet().length));
      expect(outboxTypes, hasLength(outboxTypes.toSet().length));
    });

    test(
      'login snapshot collections match current supported remote snapshot',
      () {
        expect(
          SyncContract.loginSnapshotCollections,
          unorderedEquals(<String>[
            SyncContract.accountsCollection,
            SyncContract.categoriesCollection,
            SyncContract.tagsCollection,
            SyncContract.transactionTagsCollection,
            SyncContract.transactionsCollection,
            SyncContract.creditsCollection,
            SyncContract.creditCardsCollection,
            SyncContract.debtsCollection,
            SyncContract.creditPaymentGroupsCollection,
            SyncContract.creditPaymentSchedulesCollection,
            SyncContract.profileCollection,
            SyncContract.budgetsCollection,
            SyncContract.budgetInstancesCollection,
            SyncContract.savingGoalsCollection,
            SyncContract.upcomingPaymentsCollection,
            SyncContract.paymentRemindersCollection,
          ]),
        );
      },
    );

    test('remote cleanup collections include all synced user collections', () {
      expect(
        SyncContract.remoteCleanupCollections,
        unorderedEquals(<String>[
          ...SyncContract.loginSnapshotCollections,
          SyncContract.progressCollection,
        ]),
      );
    });

    test('local-only remote artifacts stay empty for synced entities', () {
      expect(SyncContract.localOnlyRemoteArtifacts, isEmpty);
    });

    test('supported outbox entity types match current sync dispatchers', () {
      expect(
        SyncContract.supportedOutboxEntityTypes,
        unorderedEquals(<String>[
          SyncContract.accountEntityType,
          SyncContract.categoryEntityType,
          SyncContract.tagEntityType,
          SyncContract.transactionTagEntityType,
          SyncContract.transactionEntityType,
          SyncContract.creditEntityType,
          SyncContract.creditCardEntityType,
          SyncContract.debtEntityType,
          SyncContract.creditPaymentGroupEntityType,
          SyncContract.creditPaymentScheduleEntityType,
          SyncContract.profileEntityType,
          SyncContract.budgetEntityType,
          SyncContract.budgetInstanceEntityType,
          SyncContract.savingGoalEntityType,
          SyncContract.upcomingPaymentEntityType,
          SyncContract.paymentReminderEntityType,
        ]),
      );
    });

    test('export and import keys reflect current backup contract', () {
      expect(
        SyncContract.exportSnapshotKeys,
        unorderedEquals(<String>[
          'accounts',
          'transactions',
          'categories',
          'tags',
          'transaction_tags',
          'saving_goals',
          'credits',
          'credit_cards',
          'debts',
          'credit_payment_groups',
          'credit_payment_schedules',
          'budgets',
          'budget_instances',
          'upcoming_payments',
          'payment_reminders',
          'profile',
          'progress',
        ]),
      );
      expect(
        SyncContract.importSnapshotKeys,
        unorderedEquals(<String>[
          'accounts',
          'transactions',
          'categories',
          'tags',
          'transaction_tags',
          'saving_goals',
          'credits',
          'credit_cards',
          'debts',
          'credit_payment_groups',
          'credit_payment_schedules',
          'budgets',
          'budget_instances',
          'upcoming_payments',
          'payment_reminders',
          'profile',
        ]),
      );
    });

    test(
      'goal contributions remain local rebuild artifacts in current contract',
      () {
        final SyncEntityManifestEntry? goalContributions =
            SyncContract.manifestByKey['goal_contributions'];

        expect(goalContributions, isNotNull);
        expect(goalContributions!.localTable, 'goal_contributions');
        expect(goalContributions.remoteCollection, isNull);
        expect(goalContributions.outboxEntityType, isNull);
        expect(goalContributions.isDerivedOrRebuildable, isTrue);
        expect(goalContributions.participatesInExport, isFalse);
        expect(goalContributions.participatesInImport, isFalse);
      },
    );

    test(
      'progress remains derived export-only state and not a login snapshot entity',
      () {
        final SyncEntityManifestEntry? progress =
            SyncContract.manifestByKey['progress'];

        expect(progress, isNotNull);
        expect(progress!.remoteCollection, SyncContract.progressCollection);
        expect(progress.participatesInLoginSync, isFalse);
        expect(progress.participatesInExport, isTrue);
        expect(progress.participatesInImport, isFalse);
        expect(progress.isDerivedOrRebuildable, isTrue);
        expect(progress.conflictPolicy, SyncConflictPolicy.bestEffortCounter);
        expect(progress.canonicalSource, 'derived transaction stats');
      },
    );

    test(
      'credit payment artifacts use tombstone delete semantics to avoid resurrection',
      () {
        final SyncEntityManifestEntry? groups =
            SyncContract.manifestByKey['credit_payment_groups'];
        final SyncEntityManifestEntry? schedules =
            SyncContract.manifestByKey['credit_payment_schedules'];

        expect(groups, isNotNull);
        expect(schedules, isNotNull);
        expect(groups!.deleteSemantics, SyncDeleteSemantics.tombstone);
        expect(schedules!.deleteSemantics, SyncDeleteSemantics.tombstone);
      },
    );

    test(
      'credit payment artifacts are ordered before transactions in dependency graph',
      () {
        final SyncEntityManifestEntry? transactions =
            SyncContract.manifestByKey['transactions'];
        final SyncEntityManifestEntry? groups =
            SyncContract.manifestByKey['credit_payment_groups'];
        final SyncEntityManifestEntry? schedules =
            SyncContract.manifestByKey['credit_payment_schedules'];

        expect(transactions, isNotNull);
        expect(groups, isNotNull);
        expect(schedules, isNotNull);
        expect(
          groups!.dependencyOrder,
          lessThan(transactions!.dependencyOrder),
        );
        expect(
          schedules!.dependencyOrder,
          lessThan(transactions.dependencyOrder),
        );
        expect(groups.dependencyOrder, greaterThan(schedules.dependencyOrder));
      },
    );
  });
}
