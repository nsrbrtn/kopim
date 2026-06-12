import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Единый контракт удалённого snapshot и переносимого backup для sync-пайплайна.
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

  /// Коллекции, которые реально участвуют в login sync snapshot.
  static const List<String> loginSnapshotCollections = <String>[
    accountsCollection,
    categoriesCollection,
    tagsCollection,
    transactionTagsCollection,
    transactionsCollection,
    creditsCollection,
    creditCardsCollection,
    debtsCollection,
    profileCollection,
    progressCollection,
    budgetsCollection,
    budgetInstancesCollection,
    savingGoalsCollection,
    upcomingPaymentsCollection,
    paymentRemindersCollection,
  ];

  /// Коллекции, которые должны удаляться при account cleanup.
  static const List<String> remoteCleanupCollections = <String>[
    ...loginSnapshotCollections,
    creditPaymentGroupsCollection,
    creditPaymentSchedulesCollection,
  ];

  /// Артефакты credit payment пока остаются локальными derivation-данными.
  static const Set<String> localOnlyRemoteArtifacts = <String>{
    creditPaymentGroupsCollection,
    creditPaymentSchedulesCollection,
  };

  /// `groupId` нельзя переносить через Firestore snapshot или backup,
  /// пока payment groups не входят в этот же контракт.
  static TransactionEntity normalizeTransactionForPortableSync(
    TransactionEntity transaction,
  ) {
    if (transaction.groupId == null) {
      return transaction;
    }
    return transaction.copyWith(groupId: null);
  }

  static List<TransactionEntity> normalizeTransactionsForPortableSync(
    Iterable<TransactionEntity> transactions,
  ) {
    return transactions
        .map(normalizeTransactionForPortableSync)
        .toList(growable: false);
  }
}
