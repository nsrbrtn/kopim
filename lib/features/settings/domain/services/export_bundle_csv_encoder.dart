import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/services/csv_codec.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Кодирует `ExportBundle` в CSV-файл с секциями.
class ExportBundleCsvEncoder {
  const ExportBundleCsvEncoder();

  ExportedFile encode(ExportBundle bundle) {
    final List<List<String>> rows = <List<String>>[
      <String>['#kopim-export'],
      <String>['#schema_version', bundle.schemaVersion],
      <String>['#generated_at', bundle.generatedAt.toIso8601String()],
    ];

    _addAccounts(rows, bundle.accounts);
    _addCategories(rows, bundle.categories);
    _addTags(rows, bundle.tags);
    _addTransactionTags(rows, bundle.transactionTags);
    _addSavingGoals(rows, bundle.savingGoals);
    _addCredits(rows, bundle.credits);
    _addCreditCards(rows, bundle.creditCards);
    _addDebts(rows, bundle.debts);
    _addBudgets(rows, bundle.budgets);
    _addBudgetInstances(rows, bundle.budgetInstances);
    _addUpcomingPayments(rows, bundle.upcomingPayments);
    _addPaymentReminders(rows, bundle.paymentReminders);
    _addTransactions(rows, bundle.transactions);

    final String csv = CsvCodec.encode(rows);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    final String timestamp = bundle.generatedAt.toIso8601String().replaceAll(
      ':',
      '-',
    );
    final String fileName = 'kopim-export-$timestamp.csv';

    return ExportedFile(fileName: fileName, mimeType: 'text/csv', bytes: bytes);
  }

  void _addAccounts(List<List<String>> rows, List<AccountEntity> accounts) {
    rows
      ..add(<String>['#accounts'])
      ..add(<String>[
        'id',
        'name',
        'balance',
        'opening_balance',
        'balance_minor',
        'opening_balance_minor',
        'currency_scale',
        'currency',
        'type',
        'type_version',
        'created_at',
        'updated_at',
        'color',
        'gradient_id',
        'icon_name',
        'icon_style',
        'is_deleted',
        'is_primary',
        'is_hidden',
      ]);

    for (final AccountEntity account in accounts) {
      final MoneyAmount balance = account.balanceAmount;
      final MoneyAmount openingBalance = account.openingBalanceAmount;
      rows.add(<String>[
        account.id,
        account.name,
        balance.toDouble().toString(),
        openingBalance.toDouble().toString(),
        balance.minor.toString(),
        openingBalance.minor.toString(),
        account.currencyScale?.toString() ?? '',
        account.currency,
        account.type,
        account.typeVersion.toString(),
        account.createdAt.toIso8601String(),
        account.updatedAt.toIso8601String(),
        account.color ?? '',
        account.gradientId ?? '',
        account.iconName ?? '',
        account.iconStyle ?? '',
        _bool(account.isDeleted),
        _bool(account.isPrimary),
        _bool(account.isHidden),
      ]);
    }
  }

  void _addCategories(List<List<String>> rows, List<Category> categories) {
    rows
      ..add(<String>['#categories'])
      ..add(<String>[
        'id',
        'name',
        'type',
        'icon_json',
        'color',
        'parent_id',
        'created_at',
        'updated_at',
        'is_deleted',
        'is_system',
        'is_hidden',
        'is_favorite',
      ]);

    for (final Category category in categories) {
      rows.add(<String>[
        category.id,
        category.name,
        category.type,
        _encodeIcon(category.icon),
        category.color ?? '',
        category.parentId ?? '',
        category.createdAt.toIso8601String(),
        category.updatedAt.toIso8601String(),
        _bool(category.isDeleted),
        _bool(category.isSystem),
        _bool(category.isHidden),
        _bool(category.isFavorite),
      ]);
    }
  }

  void _addTags(List<List<String>> rows, List<TagEntity> tags) {
    rows
      ..add(<String>['#tags'])
      ..add(<String>[
        'id',
        'name',
        'color',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final TagEntity tag in tags) {
      rows.add(<String>[
        tag.id,
        tag.name,
        tag.color,
        tag.createdAt.toIso8601String(),
        tag.updatedAt.toIso8601String(),
        _bool(tag.isDeleted),
      ]);
    }
  }

  void _addTransactionTags(
    List<List<String>> rows,
    List<TransactionTagEntity> links,
  ) {
    rows
      ..add(<String>['#transaction_tags'])
      ..add(<String>[
        'transaction_id',
        'tag_id',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final TransactionTagEntity link in links) {
      rows.add(<String>[
        link.transactionId,
        link.tagId,
        link.createdAt.toIso8601String(),
        link.updatedAt.toIso8601String(),
        _bool(link.isDeleted),
      ]);
    }
  }

  void _addTransactions(
    List<List<String>> rows,
    List<TransactionEntity> transactions,
  ) {
    rows
      ..add(<String>['#transactions'])
      ..add(<String>[
        'id',
        'account_id',
        'transfer_account_id',
        'category_id',
        'saving_goal_id',
        'idempotency_key',
        'group_id',
        'amount',
        'amount_minor',
        'amount_scale',
        'date',
        'note',
        'type',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final TransactionEntity transaction in transactions) {
      final MoneyAmount amount = transaction.amountValue.abs();
      rows.add(<String>[
        transaction.id,
        transaction.accountId,
        transaction.transferAccountId ?? '',
        transaction.categoryId ?? '',
        transaction.savingGoalId ?? '',
        transaction.idempotencyKey ?? '',
        transaction.groupId ?? '',
        amount.toDouble().toString(),
        amount.minor.toString(),
        amount.scale.toString(),
        transaction.date.toIso8601String(),
        transaction.note ?? '',
        transaction.type,
        transaction.createdAt.toIso8601String(),
        transaction.updatedAt.toIso8601String(),
        _bool(transaction.isDeleted),
      ]);
    }
  }

  void _addSavingGoals(List<List<String>> rows, List<SavingGoal> goals) {
    rows
      ..add(<String>['#saving_goals'])
      ..add(<String>[
        'id',
        'user_id',
        'name',
        'account_id',
        'storage_account_ids',
        'target_date',
        'target_amount',
        'current_amount',
        'note',
        'created_at',
        'updated_at',
        'archived_at',
      ]);

    for (final SavingGoal goal in goals) {
      rows.add(<String>[
        goal.id,
        goal.userId,
        goal.name,
        goal.accountId ?? '',
        goal.effectiveStorageAccountIds.join('|'),
        goal.targetDate?.toIso8601String() ?? '',
        goal.targetAmount.toString(),
        goal.currentAmount.toString(),
        goal.note ?? '',
        goal.createdAt.toIso8601String(),
        goal.updatedAt.toIso8601String(),
        goal.archivedAt?.toIso8601String() ?? '',
      ]);
    }
  }

  void _addCredits(List<List<String>> rows, List<CreditEntity> credits) {
    rows
      ..add(<String>['#credits'])
      ..add(<String>[
        'id',
        'account_id',
        'category_id',
        'interest_category_id',
        'fees_category_id',
        'total_amount',
        'total_amount_minor',
        'total_amount_scale',
        'interest_rate',
        'term_months',
        'start_date',
        'first_payment_date',
        'payment_day',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final CreditEntity credit in credits) {
      final MoneyAmount totalAmount = credit.totalAmountValue;
      rows.add(<String>[
        credit.id,
        credit.accountId,
        credit.categoryId ?? '',
        credit.interestCategoryId ?? '',
        credit.feesCategoryId ?? '',
        totalAmount.toDouble().toString(),
        totalAmount.minor.toString(),
        totalAmount.scale.toString(),
        credit.interestRate.toString(),
        credit.termMonths.toString(),
        credit.startDate.toIso8601String(),
        credit.firstPaymentDate?.toIso8601String() ?? '',
        credit.paymentDay.toString(),
        credit.createdAt.toIso8601String(),
        credit.updatedAt.toIso8601String(),
        _bool(credit.isDeleted),
      ]);
    }
  }

  void _addCreditCards(
    List<List<String>> rows,
    List<CreditCardEntity> creditCards,
  ) {
    rows
      ..add(<String>['#credit_cards'])
      ..add(<String>[
        'id',
        'account_id',
        'credit_limit',
        'credit_limit_minor',
        'credit_limit_scale',
        'statement_day',
        'payment_due_days',
        'interest_rate_annual',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final CreditCardEntity creditCard in creditCards) {
      final MoneyAmount creditLimit = creditCard.creditLimitValue;
      rows.add(<String>[
        creditCard.id,
        creditCard.accountId,
        creditLimit.toDouble().toString(),
        creditLimit.minor.toString(),
        creditLimit.scale.toString(),
        creditCard.statementDay.toString(),
        creditCard.paymentDueDays.toString(),
        creditCard.interestRateAnnual.toString(),
        creditCard.createdAt.toIso8601String(),
        creditCard.updatedAt.toIso8601String(),
        _bool(creditCard.isDeleted),
      ]);
    }
  }

  void _addDebts(List<List<String>> rows, List<DebtEntity> debts) {
    rows
      ..add(<String>['#debts'])
      ..add(<String>[
        'id',
        'account_id',
        'name',
        'amount',
        'amount_minor',
        'amount_scale',
        'due_date',
        'note',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final DebtEntity debt in debts) {
      final MoneyAmount amount = debt.amountValue;
      rows.add(<String>[
        debt.id,
        debt.accountId,
        debt.name,
        amount.toDouble().toString(),
        amount.minor.toString(),
        amount.scale.toString(),
        debt.dueDate.toIso8601String(),
        debt.note ?? '',
        debt.createdAt.toIso8601String(),
        debt.updatedAt.toIso8601String(),
        _bool(debt.isDeleted),
      ]);
    }
  }

  void _addBudgets(List<List<String>> rows, List<Budget> budgets) {
    rows
      ..add(<String>['#budgets'])
      ..add(<String>[
        'id',
        'title',
        'period',
        'start_date',
        'end_date',
        'amount',
        'amount_minor',
        'amount_scale',
        'scope',
        'categories_json',
        'accounts_json',
        'category_allocations_json',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final Budget budget in budgets) {
      final MoneyAmount amount = budget.amountValue;
      rows.add(<String>[
        budget.id,
        budget.title,
        budget.period.storageValue,
        budget.startDate.toIso8601String(),
        budget.endDate?.toIso8601String() ?? '',
        amount.toDouble().toString(),
        amount.minor.toString(),
        amount.scale.toString(),
        budget.scope.storageValue,
        jsonEncode(budget.categories),
        jsonEncode(budget.accounts),
        jsonEncode(
          budget.categoryAllocations
              .map((BudgetCategoryAllocation allocation) => allocation.toJson())
              .toList(growable: false),
        ),
        budget.createdAt.toIso8601String(),
        budget.updatedAt.toIso8601String(),
        _bool(budget.isDeleted),
      ]);
    }
  }

  void _addBudgetInstances(
    List<List<String>> rows,
    List<BudgetInstance> instances,
  ) {
    rows
      ..add(<String>['#budget_instances'])
      ..add(<String>[
        'id',
        'budget_id',
        'period_start',
        'period_end',
        'amount',
        'amount_minor',
        'spent',
        'spent_minor',
        'amount_scale',
        'status',
        'created_at',
        'updated_at',
      ]);

    for (final BudgetInstance instance in instances) {
      final MoneyAmount amount = instance.amountValue;
      final MoneyAmount spent = instance.spentValue;
      rows.add(<String>[
        instance.id,
        instance.budgetId,
        instance.periodStart.toIso8601String(),
        instance.periodEnd.toIso8601String(),
        amount.toDouble().toString(),
        amount.minor.toString(),
        spent.toDouble().toString(),
        spent.minor.toString(),
        amount.scale.toString(),
        instance.status.storageValue,
        instance.createdAt.toIso8601String(),
        instance.updatedAt.toIso8601String(),
      ]);
    }
  }

  void _addUpcomingPayments(
    List<List<String>> rows,
    List<UpcomingPayment> payments,
  ) {
    rows
      ..add(<String>['#upcoming_payments'])
      ..add(<String>[
        'id',
        'title',
        'account_id',
        'category_id',
        'amount',
        'amount_minor',
        'amount_scale',
        'day_of_month',
        'notify_days_before',
        'notify_time_hhmm',
        'note',
        'auto_post',
        'flow_type',
        'is_active',
        'next_run_at_ms',
        'next_notify_at_ms',
        'last_generated_period',
        'created_at_ms',
        'updated_at_ms',
      ]);

    for (final UpcomingPayment payment in payments) {
      final MoneyAmount amount = payment.amountValue;
      rows.add(<String>[
        payment.id,
        payment.title,
        payment.accountId,
        payment.categoryId,
        amount.toDouble().toString(),
        amount.minor.toString(),
        amount.scale.toString(),
        payment.dayOfMonth.toString(),
        payment.notifyDaysBefore.toString(),
        payment.notifyTimeHhmm,
        payment.note ?? '',
        _bool(payment.autoPost),
        payment.flowType.name,
        _bool(payment.isActive),
        payment.nextRunAtMs?.toString() ?? '',
        payment.nextNotifyAtMs?.toString() ?? '',
        payment.lastGeneratedPeriod ?? '',
        payment.createdAtMs.toString(),
        payment.updatedAtMs.toString(),
      ]);
    }
  }

  void _addPaymentReminders(
    List<List<String>> rows,
    List<PaymentReminder> reminders,
  ) {
    rows
      ..add(<String>['#payment_reminders'])
      ..add(<String>[
        'id',
        'title',
        'amount',
        'amount_minor',
        'amount_scale',
        'when_at_ms',
        'note',
        'is_done',
        'last_notified_at_ms',
        'created_at_ms',
        'updated_at_ms',
      ]);

    for (final PaymentReminder reminder in reminders) {
      final MoneyAmount amount = reminder.amountValue;
      rows.add(<String>[
        reminder.id,
        reminder.title,
        amount.toDouble().toString(),
        amount.minor.toString(),
        amount.scale.toString(),
        reminder.whenAtMs.toString(),
        reminder.note ?? '',
        _bool(reminder.isDone),
        reminder.lastNotifiedAtMs?.toString() ?? '',
        reminder.createdAtMs.toString(),
        reminder.updatedAtMs.toString(),
      ]);
    }
  }

  String _encodeIcon(PhosphorIconDescriptor? icon) {
    if (icon == null || icon.isEmpty) {
      return '';
    }
    return jsonEncode(icon.toJson());
  }

  String _bool(bool value) => value ? 'true' : 'false';
}
