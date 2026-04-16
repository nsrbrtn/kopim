import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
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
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle_integrity.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class ExportBundleIntegrityService {
  const ExportBundleIntegrityService();

  static const String canonicalFormat = 'json';

  static const List<String> sectionOrder = <String>[
    'accounts',
    'transactions',
    'categories',
    'tags',
    'transactionTags',
    'savingGoals',
    'credits',
    'creditCards',
    'debts',
    'budgets',
    'budgetInstances',
    'upcomingPayments',
    'paymentReminders',
    'profile',
    'progress',
  ];

  ExportBundleIntegrity buildIntegrity(ExportBundle bundle) {
    final ExportBundle source = bundle.copyWith(integrity: null);
    final Map<String, Object?> sections = buildSectionPayloads(source);
    final Map<String, String> sectionHashes = <String, String>{
      for (final String section in sectionOrder)
        section: _hashJson(sections[section]),
    };
    final Map<String, int> entityCounts = <String, int>{
      'accounts': source.accounts.length,
      'transactions': source.transactions.length,
      'categories': source.categories.length,
      'tags': source.tags.length,
      'transactionTags': source.transactionTags.length,
      'savingGoals': source.savingGoals.length,
      'credits': source.credits.length,
      'creditCards': source.creditCards.length,
      'debts': source.debts.length,
      'budgets': source.budgets.length,
      'budgetInstances': source.budgetInstances.length,
      'upcomingPayments': source.upcomingPayments.length,
      'paymentReminders': source.paymentReminders.length,
      'profile': source.profile == null ? 0 : 1,
      'progress': source.progress == null ? 0 : 1,
    };
    final Map<String, Object?> contentPayload = <String, Object?>{
      'format': canonicalFormat,
      'schemaVersion': source.schemaVersion,
      'generatedAt': source.generatedAt.toIso8601String(),
      'sectionHashes': sectionHashes,
      'entityCounts': entityCounts,
    };

    return ExportBundleIntegrity(
      format: canonicalFormat,
      contentHash: _hashJson(contentPayload),
      sectionHashes: sectionHashes,
      entityCounts: entityCounts,
    );
  }

  Map<String, Object?> buildPayload(ExportBundle bundle) {
    final ExportBundle source = bundle.copyWith(integrity: null);
    final ExportBundleIntegrity integrity = buildIntegrity(source);
    return <String, Object?>{
      'schemaVersion': source.schemaVersion,
      'generatedAt': source.generatedAt.toIso8601String(),
      ...buildSectionPayloads(source),
      'integrity': integrity.toJson(),
    };
  }

  void verify(ExportBundle bundle) {
    final ExportBundleIntegrity? expected = bundle.integrity;
    if (expected == null) {
      throw const FormatException(
        'Не найдены метаданные целостности JSON-экспорта.',
      );
    }
    if (expected.format != canonicalFormat) {
      throw FormatException(
        'Неподдерживаемый формат integrity manifest: ${expected.format}.',
      );
    }

    final ExportBundleIntegrity actual = buildIntegrity(bundle);
    final Map<String, String> expectedSectionHashes = expected.sectionHashes;
    for (final String section in sectionOrder) {
      final String? expectedHash = expectedSectionHashes[section];
      if (expectedHash == null || expectedHash.isEmpty) {
        throw FormatException(
          'В integrity manifest отсутствует hash для секции $section.',
        );
      }
      final String actualHash = actual.sectionHashes[section]!;
      if (expectedHash != actualHash) {
        throw FormatException(
          'Нарушена целостность секции $section: ожидался hash $expectedHash, получен $actualHash.',
        );
      }
    }

    final Map<String, int> expectedCounts = expected.entityCounts;
    for (final String section in sectionOrder) {
      final int? expectedCount = expectedCounts[section];
      if (expectedCount == null) {
        throw FormatException(
          'В integrity manifest отсутствует count для секции $section.',
        );
      }
      final int actualCount = actual.entityCounts[section]!;
      if (expectedCount != actualCount) {
        throw FormatException(
          'Нарушена целостность секции $section: ожидался count $expectedCount, получен $actualCount.',
        );
      }
    }

    if (expected.contentHash != actual.contentHash) {
      throw const FormatException(
        'Нарушена целостность экспортированного файла: content hash не совпадает.',
      );
    }
  }

  Map<String, Object?> buildSectionPayloads(ExportBundle bundle) {
    return <String, Object?>{
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
      'profile': bundle.profile == null ? null : _mapProfile(bundle.profile!),
      'progress': bundle.progress == null
          ? null
          : _mapProgress(bundle.progress!),
    };
  }

  Map<String, Object?> _mapAccount(AccountEntity account) {
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount openingBalance = account.openingBalanceAmount;
    return <String, Object?>{
      'id': account.id,
      'name': account.name,
      'balance': balance.toDouble(),
      'balanceMinor': balance.minor.toString(),
      'openingBalance': openingBalance.toDouble(),
      'openingBalanceMinor': openingBalance.minor.toString(),
      'currency': account.currency,
      'currencyScale': account.currencyScale,
      'type': account.type,
      'typeVersion': account.typeVersion,
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

  Map<String, Object?> _mapTransaction(TransactionEntity transaction) {
    final MoneyAmount amount = transaction.amountValue.abs();
    return <String, Object?>{
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

  Map<String, Object?> _mapCredit(CreditEntity credit) {
    final MoneyAmount totalAmount = credit.totalAmountValue;
    return <String, Object?>{
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

  Map<String, Object?> _mapCreditCard(CreditCardEntity creditCard) {
    final MoneyAmount creditLimit = creditCard.creditLimitValue;
    return <String, Object?>{
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

  Map<String, Object?> _mapDebt(DebtEntity debt) {
    final MoneyAmount amount = debt.amountValue;
    return <String, Object?>{
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

  Map<String, Object?> _mapBudget(Budget budget) {
    final MoneyAmount amount = budget.amountValue;
    return <String, Object?>{
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

  Map<String, Object?> _mapBudgetInstance(BudgetInstance instance) {
    final MoneyAmount amount = instance.amountValue;
    final MoneyAmount spent = instance.spentValue;
    return <String, Object?>{
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

  Map<String, Object?> _mapProfile(Profile profile) {
    return <String, Object?>{
      'uid': profile.uid,
      'name': profile.name,
      'currency': profile.currency.name,
      'locale': profile.locale,
      'photoUrl': profile.photoUrl,
      'updatedAt': profile.updatedAt.toIso8601String(),
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, Object?> _mapProgress(UserProgress progress) {
    return <String, Object?>{
      'totalTx': progress.totalTx,
      'level': progress.level,
      'title': progress.title,
      'nextThreshold': progress.nextThreshold,
      'updatedAt': progress.updatedAt.toIso8601String(),
    };
  }

  String _hashJson(Object? value) {
    final Object? canonical = _canonicalizeJson(value);
    return sha256.convert(utf8.encode(jsonEncode(canonical))).toString();
  }

  Object? _canonicalizeJson(Object? value) {
    if (value is Map) {
      final SplayTreeMap<String, Object?> ordered =
          SplayTreeMap<String, Object?>();
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        ordered[entry.key.toString()] = _canonicalizeJson(entry.value);
      }
      return ordered;
    }
    if (value is List) {
      final List<Object?> items = value
          .map(_canonicalizeJson)
          .toList(growable: false);
      items.sort(
        (Object? left, Object? right) =>
            jsonEncode(left).compareTo(jsonEncode(right)),
      );
      return items;
    }
    return value;
  }
}
