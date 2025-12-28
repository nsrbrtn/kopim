import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

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

  List<RecurringRule> sanitizeRecurringRules({
    required List<RecurringRule> rules,
    required Set<String> validAccountIds,
    required Set<String> validCategoryIds,
  }) {
    if (rules.isEmpty) return rules;

    final List<RecurringRule> sanitized = <RecurringRule>[];
    int skippedCount = 0;

    for (final RecurringRule rule in rules) {
      // 1. Check mandatory Account dependency
      if (!validAccountIds.contains(rule.accountId)) {
        skippedCount++;
        continue;
      }

      String? categoryId = rule.categoryId;
      bool changed = false;

      // 2. Check optional Category dependency
      if (categoryId != null && !validCategoryIds.contains(categoryId)) {
        categoryId = null;
        changed = true;
      }

      if (changed) {
        // RecurringRule categoryId is NOT nullable in the entity definition we saw (required String categoryId)
        // BUT wait, looking at the file viewed: required String categoryId.
        // So we CANNOT set it to null if it's missing?
        // Let's re-read the recurring_rule.dart carefully.
        // It says: required String categoryId.
        // So if category is missing, we MUST SKIP the rule?
        // Or is there a "None" category ID?
        // Re-reading implementation plan: "Category: Уже реализовано (пропуск правила)".
        // Ah, so if category is missing for a rule, we skip it?
        // But implementation plan says "Category: Уже реализовано (пропуск правила)" for rules.
        // Wait, in my sanitizer implementation I tried to set it to null.
        // Since it is non-nullable, I must SKIP the rule if category is missing.

        // CORRECTION: Since categoryId is required String, and we don't have it (it's invalid),
        // we must treat it as a broken dependency -> SKIP RULE.
        skippedCount++;
        continue;
      } else {
        sanitized.add(rule);
      }
    }

    if (skippedCount > 0) {
      logger.logInfo(
        'SyncDataSanitizer: skipped $skippedCount recurring rules due to missing accounts or categories.',
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
