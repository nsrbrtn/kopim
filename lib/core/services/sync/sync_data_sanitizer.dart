import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class SyncDataSanitizer {
  const SyncDataSanitizer({required this.logger});

  final LoggerService logger;

  List<TransactionEntity> sanitizeTransactions({
    required List<TransactionEntity> transactions,
    required Set<String> validAccountIds,
    required Set<String> validCategoryIds,
    required Set<String> validSavingGoalIds,
  }) {
    if (transactions.isEmpty) return transactions;

    final List<TransactionEntity> sanitized = <TransactionEntity>[];
    int skippedCount = 0;
    int sanitizedCount = 0;

    for (final TransactionEntity tx in transactions) {
      // 1. Check mandatory Account dependency (Tier 1)
      if (!validAccountIds.contains(tx.accountId)) {
        skippedCount++;
        continue;
      }

      String? categoryId = tx.categoryId;
      String? savingGoalId = tx.savingGoalId;
      bool changed = false;

      // 2. Check optional Category dependency (Tier 1)
      if (categoryId != null && !validCategoryIds.contains(categoryId)) {
        categoryId = null;
        changed = true;
      }

      // 3. Check optional Saving Goal dependency (Tier 2)
      if (savingGoalId != null && !validSavingGoalIds.contains(savingGoalId)) {
        savingGoalId = null;
        changed = true;
      }

      if (changed) {
        sanitizedCount++;
        sanitized.add(
          tx.copyWith(categoryId: categoryId, savingGoalId: savingGoalId),
        );
      } else {
        sanitized.add(tx);
      }
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount transactions due to missing accounts.',
      );
    }
    if (sanitizedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: sanitized $sanitizedCount transactions (cleared missing categories/goals).',
      );
    }

    return sanitized;
  }

  List<UpcomingPayment> sanitizeUpcomingPayments({
    required List<UpcomingPayment> payments,
    required Set<String> validAccountIds,
    required Set<String> validCategoryIds,
  }) {
    if (payments.isEmpty) return payments;

    final List<UpcomingPayment> sanitized = <UpcomingPayment>[];
    int skippedCount = 0;

    for (final UpcomingPayment payment in payments) {
      if (!validAccountIds.contains(payment.accountId)) {
        skippedCount++;
        continue;
      }

      if (!validCategoryIds.contains(payment.categoryId)) {
        skippedCount++;
        continue;
      }

      sanitized.add(payment);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount recurring payments due to missing accounts or categories.',
      );
    }

    return sanitized;
  }

  List<TransactionTagEntity> sanitizeTransactionTags({
    required List<TransactionTagEntity> transactionTags,
    required Set<String> validTransactionIds,
    required Set<String> validTagIds,
  }) {
    if (transactionTags.isEmpty) return transactionTags;

    final List<TransactionTagEntity> sanitized = <TransactionTagEntity>[];
    int skippedCount = 0;

    for (final TransactionTagEntity link in transactionTags) {
      if (!validTransactionIds.contains(link.transactionId) ||
          !validTagIds.contains(link.tagId)) {
        skippedCount++;
        continue;
      }
      sanitized.add(link);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount transaction tags due to missing references.',
      );
    }

    return sanitized;
  }

  List<CategoryGroupLink> sanitizeCategoryGroupLinks({
    required List<CategoryGroupLink> links,
    required Set<String> validGroupIds,
    required Set<String> validCategoryIds,
  }) {
    if (links.isEmpty) return links;

    final List<CategoryGroupLink> sanitized = <CategoryGroupLink>[];
    int skippedCount = 0;

    for (final CategoryGroupLink link in links) {
      if (!validGroupIds.contains(link.groupId) ||
          !validCategoryIds.contains(link.categoryId)) {
        skippedCount++;
        continue;
      }
      sanitized.add(link);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount category group links due to missing references.',
      );
    }

    return sanitized;
  }

  List<CreditEntity> sanitizeCredits({
    required List<CreditEntity> credits,
    required Set<String> validAccountIds,
    required Set<String> validCategoryIds,
  }) {
    if (credits.isEmpty) return credits;

    final List<CreditEntity> sanitized = <CreditEntity>[];
    int skippedCount = 0;
    int clearedCategories = 0;

    for (final CreditEntity credit in credits) {
      if (!validAccountIds.contains(credit.accountId)) {
        skippedCount++;
        continue;
      }

      final String? categoryId = credit.categoryId;
      if (categoryId != null && !validCategoryIds.contains(categoryId)) {
        clearedCategories++;
        sanitized.add(credit.copyWith(categoryId: null));
        continue;
      }

      sanitized.add(credit);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount credits due to missing accounts.',
      );
    }
    if (clearedCategories > 0) {
      logger.logInfo(
        'SyncDataSanitizer: cleared $clearedCategories credit categories due to missing references.',
      );
    }

    return sanitized;
  }

  List<CreditCardEntity> sanitizeCreditCards({
    required List<CreditCardEntity> creditCards,
    required Set<String> validAccountIds,
  }) {
    if (creditCards.isEmpty) return creditCards;

    final List<CreditCardEntity> sanitized = <CreditCardEntity>[];
    int skippedCount = 0;

    for (final CreditCardEntity creditCard in creditCards) {
      if (!validAccountIds.contains(creditCard.accountId)) {
        skippedCount++;
        continue;
      }
      sanitized.add(creditCard);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount credit cards due to missing accounts.',
      );
    }

    return sanitized;
  }

  List<DebtEntity> sanitizeDebts({
    required List<DebtEntity> debts,
    required Set<String> validAccountIds,
  }) {
    if (debts.isEmpty) return debts;

    final List<DebtEntity> sanitized = <DebtEntity>[];
    int skippedCount = 0;

    for (final DebtEntity debt in debts) {
      if (!validAccountIds.contains(debt.accountId)) {
        skippedCount++;
        continue;
      }
      sanitized.add(debt);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount debts due to missing accounts.',
      );
    }

    return sanitized;
  }

  List<BudgetInstance> sanitizeBudgetInstances({
    required List<BudgetInstance> instances,
    required Set<String> validBudgetIds,
  }) {
    if (instances.isEmpty) return instances;

    final List<BudgetInstance> sanitized = <BudgetInstance>[];
    int skippedCount = 0;

    for (final BudgetInstance instance in instances) {
      // 1. Check mandatory Budget dependency (Tier 3)
      if (!validBudgetIds.contains(instance.budgetId)) {
        skippedCount++;
        continue;
      }
      sanitized.add(instance);
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount budget instances due to missing budgets.',
      );
    }

    return sanitized;
  }
}
