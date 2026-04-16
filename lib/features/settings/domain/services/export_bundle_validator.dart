import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class ExportBundleValidator {
  const ExportBundleValidator();

  void validateOrThrow(ExportBundle bundle) {
    final List<String> issues = validate(bundle);
    if (issues.isEmpty) {
      return;
    }
    throw FormatException('Экспорт отклонён: ${issues.join(' ')}');
  }

  List<String> validate(ExportBundle bundle) {
    final List<String> issues = <String>[];

    _requireUniqueIds(
      issues,
      section: 'accounts',
      ids: bundle.accounts.map((AccountEntity account) => account.id),
    );
    _requireUniqueIds(
      issues,
      section: 'transactions',
      ids: bundle.transactions.map(
        (TransactionEntity transaction) => transaction.id,
      ),
    );
    _requireUniqueIds(
      issues,
      section: 'categories',
      ids: bundle.categories.map((Category category) => category.id),
    );
    _requireUniqueIds(
      issues,
      section: 'tags',
      ids: bundle.tags.map((TagEntity tag) => tag.id),
    );
    _requireUniqueIds(
      issues,
      section: 'savingGoals',
      ids: bundle.savingGoals.map((SavingGoal goal) => goal.id),
    );
    _requireUniqueIds(
      issues,
      section: 'credits',
      ids: bundle.credits.map((CreditEntity credit) => credit.id),
    );
    _requireUniqueIds(
      issues,
      section: 'creditCards',
      ids: bundle.creditCards.map((CreditCardEntity card) => card.id),
    );
    _requireUniqueIds(
      issues,
      section: 'debts',
      ids: bundle.debts.map((DebtEntity debt) => debt.id),
    );
    _requireUniqueIds(
      issues,
      section: 'budgets',
      ids: bundle.budgets.map((Budget budget) => budget.id),
    );
    _requireUniqueIds(
      issues,
      section: 'budgetInstances',
      ids: bundle.budgetInstances.map((BudgetInstance instance) => instance.id),
    );
    _requireUniqueIds(
      issues,
      section: 'upcomingPayments',
      ids: bundle.upcomingPayments.map((UpcomingPayment payment) => payment.id),
    );
    _requireUniqueIds(
      issues,
      section: 'paymentReminders',
      ids: bundle.paymentReminders.map(
        (PaymentReminder reminder) => reminder.id,
      ),
    );
    _requireUniqueIds(
      issues,
      section: 'transactionTags',
      ids: bundle.transactionTags.map(
        (TransactionTagEntity link) => '${link.transactionId}:${link.tagId}',
      ),
    );

    final Set<String> accountIds = bundle.accounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final Set<String> categoryIds = bundle.categories
        .map((Category category) => category.id)
        .toSet();
    final Set<String> tagIds = bundle.tags
        .map((TagEntity tag) => tag.id)
        .toSet();
    final Set<String> transactionIds = bundle.transactions
        .map((TransactionEntity transaction) => transaction.id)
        .toSet();
    final Set<String> savingGoalIds = bundle.savingGoals
        .map((SavingGoal goal) => goal.id)
        .toSet();
    final Set<String> budgetIds = bundle.budgets
        .map((Budget budget) => budget.id)
        .toSet();

    for (final AccountEntity account in bundle.accounts) {
      if (account.name.trim().isEmpty) {
        issues.add(
          'Секция accounts содержит счёт ${account.id} с пустым name.',
        );
      }
    }
    for (final Category category in bundle.categories) {
      if (category.name.trim().isEmpty) {
        issues.add(
          'Секция categories содержит категорию ${category.id} с пустым name.',
        );
      }
    }
    for (final TagEntity tag in bundle.tags) {
      if (tag.name.trim().isEmpty) {
        issues.add('Секция tags содержит тег ${tag.id} с пустым name.');
      }
    }
    for (final SavingGoal goal in bundle.savingGoals) {
      if (goal.name.trim().isEmpty) {
        issues.add(
          'Секция savingGoals содержит цель ${goal.id} с пустым name.',
        );
      }
      if (goal.accountId != null && !accountIds.contains(goal.accountId)) {
        issues.add(
          'Цель ${goal.id} ссылается на отсутствующий accountId ${goal.accountId}.',
        );
      }
      for (final String storageAccountId in goal.effectiveStorageAccountIds) {
        if (!accountIds.contains(storageAccountId)) {
          issues.add(
            'Цель ${goal.id} ссылается на отсутствующий storageAccountId $storageAccountId.',
          );
        }
      }
    }
    for (final CreditEntity credit in bundle.credits) {
      if (!accountIds.contains(credit.accountId)) {
        issues.add(
          'Кредит ${credit.id} ссылается на отсутствующий accountId ${credit.accountId}.',
        );
      }
    }
    for (final CreditCardEntity card in bundle.creditCards) {
      if (!accountIds.contains(card.accountId)) {
        issues.add(
          'Кредитная карта ${card.id} ссылается на отсутствующий accountId ${card.accountId}.',
        );
      }
    }
    for (final DebtEntity debt in bundle.debts) {
      if (debt.name.trim().isEmpty) {
        issues.add('Долг ${debt.id} содержит пустой name.');
      }
      if (!accountIds.contains(debt.accountId)) {
        issues.add(
          'Долг ${debt.id} ссылается на отсутствующий accountId ${debt.accountId}.',
        );
      }
    }
    for (final TransactionEntity transaction in bundle.transactions) {
      if (!accountIds.contains(transaction.accountId)) {
        issues.add(
          'Транзакция ${transaction.id} ссылается на отсутствующий accountId ${transaction.accountId}.',
        );
      }
      if (transaction.transferAccountId != null &&
          !accountIds.contains(transaction.transferAccountId)) {
        issues.add(
          'Транзакция ${transaction.id} ссылается на отсутствующий transferAccountId ${transaction.transferAccountId}.',
        );
      }
      if (transaction.categoryId != null &&
          !categoryIds.contains(transaction.categoryId)) {
        issues.add(
          'Транзакция ${transaction.id} ссылается на отсутствующий categoryId ${transaction.categoryId}.',
        );
      }
      if (transaction.savingGoalId != null &&
          !savingGoalIds.contains(transaction.savingGoalId)) {
        issues.add(
          'Транзакция ${transaction.id} ссылается на отсутствующий savingGoalId ${transaction.savingGoalId}.',
        );
      }
    }
    for (final TransactionTagEntity link in bundle.transactionTags) {
      if (!transactionIds.contains(link.transactionId)) {
        issues.add(
          'Связь transactionTags ${link.transactionId}:${link.tagId} ссылается на отсутствующую транзакцию.',
        );
      }
      if (!tagIds.contains(link.tagId)) {
        issues.add(
          'Связь transactionTags ${link.transactionId}:${link.tagId} ссылается на отсутствующий тег.',
        );
      }
    }
    for (final Budget budget in bundle.budgets) {
      if (budget.title.trim().isEmpty) {
        issues.add('Бюджет ${budget.id} содержит пустой title.');
      }
      for (final String categoryId in budget.categories) {
        if (!categoryIds.contains(categoryId)) {
          issues.add(
            'Бюджет ${budget.id} ссылается на отсутствующую категорию $categoryId.',
          );
        }
      }
      for (final String accountId in budget.accounts) {
        if (!accountIds.contains(accountId)) {
          issues.add(
            'Бюджет ${budget.id} ссылается на отсутствующий счёт $accountId.',
          );
        }
      }
      for (final BudgetCategoryAllocation allocation
          in budget.categoryAllocations) {
        if (!categoryIds.contains(allocation.categoryId)) {
          issues.add(
            'Бюджет ${budget.id} содержит allocation для отсутствующей категории ${allocation.categoryId}.',
          );
        }
      }
    }
    for (final BudgetInstance instance in bundle.budgetInstances) {
      if (!budgetIds.contains(instance.budgetId)) {
        issues.add(
          'Инстанс бюджета ${instance.id} ссылается на отсутствующий budgetId ${instance.budgetId}.',
        );
      }
    }
    for (final UpcomingPayment payment in bundle.upcomingPayments) {
      if (payment.title.trim().isEmpty) {
        issues.add('Recurring payment ${payment.id} содержит пустой title.');
      }
      if (!accountIds.contains(payment.accountId)) {
        issues.add(
          'Recurring payment ${payment.id} ссылается на отсутствующий accountId ${payment.accountId}.',
        );
      }
      if (!categoryIds.contains(payment.categoryId)) {
        issues.add(
          'Recurring payment ${payment.id} ссылается на отсутствующий categoryId ${payment.categoryId}.',
        );
      }
    }
    for (final PaymentReminder reminder in bundle.paymentReminders) {
      if (reminder.title.trim().isEmpty) {
        issues.add('Reminder ${reminder.id} содержит пустой title.');
      }
    }

    final Profile? profile = bundle.profile;
    if (profile != null && profile.uid.trim().isEmpty) {
      issues.add('Секция profile содержит пустой uid.');
    }

    final UserProgress? progress = bundle.progress;
    if (progress != null && progress.title.trim().isEmpty) {
      issues.add('Секция progress содержит пустой title.');
    }

    return issues;
  }

  void _requireUniqueIds(
    List<String> issues, {
    required String section,
    required Iterable<String> ids,
  }) {
    final Set<String> seen = <String>{};
    final Set<String> duplicates = <String>{};
    for (final String id in ids) {
      if (!seen.add(id)) {
        duplicates.add(id);
      }
    }
    for (final String duplicate in duplicates) {
      issues.add('Секция $section содержит дублирующийся id $duplicate.');
    }
  }
}
