import 'dart:convert';
import 'dart:typed_data';

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
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Кодирует `ExportBundle` в читаемый JSON-файл.
class ExportBundleJsonEncoder {
  const ExportBundleJsonEncoder({this.indent = '  '});

  /// Отступ для форматированного JSON.
  final String indent;

  /// Создаёт DTO файла, готового к сохранению.
  ExportedFile encode(ExportBundle bundle) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'schemaVersion': bundle.schemaVersion,
      'generatedAt': bundle.generatedAt.toIso8601String(),
      'accounts': bundle.accounts.map(_mapAccount).toList(growable: false),
      'transactions': bundle.transactions
          .map(_mapTransaction)
          .toList(growable: false),
      'categories': bundle.categories
          .map((Category category) => category.toJson())
          .toList(growable: false),
      'tags': bundle.tags
          .map((TagEntity tag) => tag.toJson())
          .toList(growable: false),
      'transactionTags': bundle.transactionTags
          .map((TransactionTagEntity link) => link.toJson())
          .toList(growable: false),
      'savingGoals': bundle.savingGoals
          .map((SavingGoal goal) => goal.toJson())
          .toList(growable: false),
      'credits': bundle.credits.map(_mapCredit).toList(growable: false),
      'creditCards': bundle.creditCards
          .map(_mapCreditCard)
          .toList(growable: false),
      'debts': bundle.debts.map(_mapDebt).toList(growable: false),
      'budgets': bundle.budgets.map(_mapBudget).toList(growable: false),
      'budgetInstances': bundle.budgetInstances
          .map(_mapBudgetInstance)
          .toList(growable: false),
      'upcomingPayments': bundle.upcomingPayments
          .map((UpcomingPayment payment) => payment.toJson())
          .toList(growable: false),
      'paymentReminders': bundle.paymentReminders
          .map((PaymentReminder reminder) => reminder.toJson())
          .toList(growable: false),
    };

    final JsonEncoder encoder = JsonEncoder.withIndent(indent);
    final String jsonString = encoder.convert(payload);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    final String timestamp = bundle.generatedAt.toIso8601String().replaceAll(
      ':',
      '-',
    );

    final String fileName = 'kopim-export-$timestamp.json';

    return ExportedFile(
      fileName: fileName,
      mimeType: 'application/json',
      bytes: bytes,
    );
  }

  Map<String, dynamic> _mapAccount(AccountEntity account) {
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount openingBalance = account.openingBalanceAmount;
    return <String, dynamic>{
      'id': account.id,
      'name': account.name,
      'balance': balance.toDouble(),
      'balanceMinor': balance.minor.toString(),
      'openingBalance': openingBalance.toDouble(),
      'openingBalanceMinor': openingBalance.minor.toString(),
      'currency': account.currency,
      'currencyScale': account.currencyScale,
      'type': account.type,
      'createdAt': account.createdAt.toIso8601String(),
      'updatedAt': account.updatedAt.toIso8601String(),
      'color': account.color,
      'gradientId': account.gradientId,
      'iconName': account.iconName,
      'iconStyle': account.iconStyle,
      'isDeleted': account.isDeleted,
      'isPrimary': account.isPrimary,
      'isHidden': account.isHidden,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapTransaction(TransactionEntity transaction) {
    final MoneyAmount amount = transaction.amountValue.abs();
    return <String, dynamic>{
      'id': transaction.id,
      'accountId': transaction.accountId,
      'transferAccountId': transaction.transferAccountId,
      'categoryId': transaction.categoryId,
      'savingGoalId': transaction.savingGoalId,
      'idempotencyKey': transaction.idempotencyKey,
      'groupId': transaction.groupId,
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'amountScale': amount.scale,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'type': transaction.type,
      'createdAt': transaction.createdAt.toIso8601String(),
      'updatedAt': transaction.updatedAt.toIso8601String(),
      'isDeleted': transaction.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapCredit(CreditEntity credit) {
    final MoneyAmount totalAmount = credit.totalAmountValue;
    return <String, dynamic>{
      'id': credit.id,
      'accountId': credit.accountId,
      'categoryId': credit.categoryId,
      'interestCategoryId': credit.interestCategoryId,
      'feesCategoryId': credit.feesCategoryId,
      'totalAmount': totalAmount.toDouble(),
      'totalAmountMinor': totalAmount.minor.toString(),
      'totalAmountScale': totalAmount.scale,
      'interestRate': credit.interestRate,
      'termMonths': credit.termMonths,
      'startDate': credit.startDate.toIso8601String(),
      'firstPaymentDate': credit.firstPaymentDate?.toIso8601String(),
      'paymentDay': credit.paymentDay,
      'createdAt': credit.createdAt.toIso8601String(),
      'updatedAt': credit.updatedAt.toIso8601String(),
      'isDeleted': credit.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapCreditCard(CreditCardEntity creditCard) {
    final MoneyAmount creditLimit = creditCard.creditLimitValue;
    return <String, dynamic>{
      'id': creditCard.id,
      'accountId': creditCard.accountId,
      'creditLimit': creditLimit.toDouble(),
      'creditLimitMinor': creditLimit.minor.toString(),
      'creditLimitScale': creditLimit.scale,
      'statementDay': creditCard.statementDay,
      'paymentDueDays': creditCard.paymentDueDays,
      'interestRateAnnual': creditCard.interestRateAnnual,
      'createdAt': creditCard.createdAt.toIso8601String(),
      'updatedAt': creditCard.updatedAt.toIso8601String(),
      'isDeleted': creditCard.isDeleted,
    };
  }

  Map<String, dynamic> _mapDebt(DebtEntity debt) {
    final MoneyAmount amount = debt.amountValue;
    return <String, dynamic>{
      'id': debt.id,
      'accountId': debt.accountId,
      'name': debt.name,
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'amountScale': amount.scale,
      'dueDate': debt.dueDate.toIso8601String(),
      'note': debt.note,
      'createdAt': debt.createdAt.toIso8601String(),
      'updatedAt': debt.updatedAt.toIso8601String(),
      'isDeleted': debt.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapBudget(Budget budget) {
    final MoneyAmount amount = budget.amountValue;
    return <String, dynamic>{
      'id': budget.id,
      'title': budget.title,
      'period': budget.period.storageValue,
      'startDate': budget.startDate.toIso8601String(),
      'endDate': budget.endDate?.toIso8601String(),
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'amountScale': amount.scale,
      'scope': budget.scope.storageValue,
      'categories': budget.categories,
      'accounts': budget.accounts,
      'categoryAllocations': budget.categoryAllocations
          .map((BudgetCategoryAllocation allocation) => allocation.toJson())
          .toList(growable: false),
      'createdAt': budget.createdAt.toIso8601String(),
      'updatedAt': budget.updatedAt.toIso8601String(),
      'isDeleted': budget.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapBudgetInstance(BudgetInstance instance) {
    final MoneyAmount amount = instance.amountValue;
    final MoneyAmount spent = instance.spentValue;
    return <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'spent': spent.toDouble(),
      'spentMinor': spent.minor.toString(),
      'amountScale': amount.scale,
      'status': instance.status.storageValue,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    }..removeWhere((String key, Object? value) => value == null);
  }
}
