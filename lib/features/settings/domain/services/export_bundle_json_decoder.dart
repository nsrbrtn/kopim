import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
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
import 'package:kopim/features/settings/domain/services/export_bundle_schema.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Декодирует JSON-представление экспортированного бандла обратно в модель.
class ExportBundleJsonDecoder {
  const ExportBundleJsonDecoder();

  /// Преобразует набор байтов JSON в [`ExportBundle`].
  ExportBundle decode(Uint8List bytes) {
    try {
      final String jsonString = utf8.decode(bytes);
      final Map<String, Object?> jsonMap =
          json.decode(jsonString) as Map<String, Object?>;
      return _parse(jsonMap);
    } on FormatException catch (error) {
      throw FormatException(
        'Некорректный формат файла экспорта: ${error.message}',
      );
    } on Object catch (error) {
      throw FormatException('Не удалось разобрать файл экспорта: $error');
    }
  }

  ExportBundle _parse(Map<String, Object?> jsonMap) {
    final String schemaVersion =
        (jsonMap['schemaVersion'] as String?)?.trim() ?? '';
    if (schemaVersion.isEmpty) {
      throw const FormatException('Не найдена версия схемы экспорта.');
    }
    final dynamic version = ExportBundleSchema.parseAndValidate(schemaVersion);
    final String? generatedAtRaw = jsonMap['generatedAt'] as String?;
    if (generatedAtRaw == null || generatedAtRaw.isEmpty) {
      throw const FormatException('Не найдена дата генерации экспорта.');
    }
    final DateTime generatedAt = DateTime.parse(generatedAtRaw);

    final List<AccountEntity> accounts = _parseAccounts(
      _readSection(jsonMap, 'accounts'),
    );
    final List<TransactionEntity> transactions = _parseTransactions(
      _readSection(jsonMap, 'transactions'),
    );
    final List<Category> categories = _parseCategories(
      _readSection(jsonMap, 'categories'),
    );
    final List<TagEntity> tags = _parseTags(
      _readSection(
        jsonMap,
        'tags',
        required: ExportBundleSchema.requiresExtendedSnapshot(version),
      ),
    );
    final List<TransactionTagEntity> transactionTags = _parseTransactionTags(
      _readSection(
        jsonMap,
        'transactionTags',
        required: ExportBundleSchema.requiresExtendedSnapshot(version),
      ),
    );
    final List<SavingGoal> savingGoals = _parseSavingGoals(
      _readSection(
        jsonMap,
        'savingGoals',
        required: ExportBundleSchema.requiresSavingGoals(version),
      ),
    );
    final List<CreditEntity> credits = _parseCredits(
      _readSection(
        jsonMap,
        'credits',
        required: ExportBundleSchema.requiresLiabilities(version),
      ),
    );
    final List<CreditCardEntity> creditCards = _parseCreditCards(
      _readSection(
        jsonMap,
        'creditCards',
        required: ExportBundleSchema.requiresLiabilities(version),
      ),
    );
    final List<DebtEntity> debts = _parseDebts(
      _readSection(
        jsonMap,
        'debts',
        required: ExportBundleSchema.requiresLiabilities(version),
      ),
    );
    final List<Budget> budgets = _parseBudgets(
      _readSection(
        jsonMap,
        'budgets',
        required: ExportBundleSchema.requiresExtendedSnapshot(version),
      ),
    );
    final List<BudgetInstance> budgetInstances = _parseBudgetInstances(
      _readSection(
        jsonMap,
        'budgetInstances',
        required: ExportBundleSchema.requiresExtendedSnapshot(version),
      ),
    );
    final List<UpcomingPayment> upcomingPayments = _parseUpcomingPayments(
      _readSection(
        jsonMap,
        'upcomingPayments',
        required: ExportBundleSchema.requiresExtendedSnapshot(version),
      ),
    );
    final List<PaymentReminder> paymentReminders = _parsePaymentReminders(
      _readSection(
        jsonMap,
        'paymentReminders',
        required: ExportBundleSchema.requiresExtendedSnapshot(version),
      ),
    );

    return ExportBundle(
      schemaVersion: schemaVersion,
      generatedAt: generatedAt,
      accounts: accounts,
      transactions: transactions,
      categories: categories,
      tags: tags,
      transactionTags: transactionTags,
      savingGoals: savingGoals,
      credits: credits,
      creditCards: creditCards,
      debts: debts,
      budgets: budgets,
      budgetInstances: budgetInstances,
      upcomingPayments: upcomingPayments,
      paymentReminders: paymentReminders,
    );
  }

  List<AccountEntity> _parseAccounts(Object? raw) {
    if (raw is! List) return const <AccountEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final String currency = _readString(data, 'currency');
          final int scale =
              _readInt(data['currencyScale']) ?? resolveCurrencyScale(currency);
          final double legacyBalance = _readDouble(data, 'balance');
          final double legacyOpening = _readDouble(data, 'openingBalance');
          final BigInt? balanceMinor = _readBigInt(data['balanceMinor']);
          final BigInt? openingMinor = _readBigInt(data['openingBalanceMinor']);
          final BigInt resolvedBalanceMinor =
              balanceMinor ??
              Money.fromDouble(
                legacyBalance,
                currency: currency,
                scale: scale,
              ).minor;
          final BigInt resolvedOpeningMinor =
              openingMinor ??
              Money.fromDouble(
                legacyOpening,
                currency: currency,
                scale: scale,
              ).minor;
          return AccountEntity(
            id: _readString(data, 'id'),
            name: _readString(data, 'name'),
            balanceMinor: resolvedBalanceMinor,
            openingBalanceMinor: resolvedOpeningMinor,
            currency: currency,
            currencyScale: scale,
            type: _readString(data, 'type'),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            color: _readOptionalString(data, 'color'),
            gradientId: _readOptionalString(data, 'gradientId'),
            iconName: _readOptionalString(data, 'iconName'),
            iconStyle: _readOptionalString(data, 'iconStyle'),
            isDeleted: _readBool(data, 'isDeleted'),
            isPrimary: _readBool(data, 'isPrimary'),
            isHidden: _readBool(data, 'isHidden'),
          );
        })
        .toList(growable: false);
  }

  List<TransactionEntity> _parseTransactions(Object? raw) {
    if (raw is! List) return const <TransactionEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['amountScale']) ?? 2;
          final double legacyAmount = _readDouble(data, 'amount');
          final BigInt? amountMinor = _readBigInt(data['amountMinor']);
          final BigInt resolvedMinor =
              amountMinor ??
              Money.fromDouble(
                legacyAmount,
                currency: 'XXX',
                scale: scale,
              ).minor;
          return TransactionEntity(
            id: _readString(data, 'id'),
            accountId: _readString(data, 'accountId'),
            transferAccountId: _readOptionalString(data, 'transferAccountId'),
            categoryId: _readOptionalString(data, 'categoryId'),
            savingGoalId: _readOptionalString(data, 'savingGoalId'),
            idempotencyKey: _readOptionalString(data, 'idempotencyKey'),
            groupId: _readOptionalString(data, 'groupId'),
            amountMinor: resolvedMinor,
            amountScale: scale,
            date: _readDate(data, 'date'),
            note: _readOptionalString(data, 'note'),
            type: _readString(data, 'type'),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            isDeleted: _readBool(data, 'isDeleted'),
          );
        })
        .toList(growable: false);
  }

  List<Category> _parseCategories(Object? raw) {
    if (raw is! List) return const <Category>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(Category.fromJson)
        .toList(growable: false);
  }

  List<TagEntity> _parseTags(Object? raw) {
    if (raw is! List) return const <TagEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(TagEntity.fromJson)
        .toList(growable: false);
  }

  List<TransactionTagEntity> _parseTransactionTags(Object? raw) {
    if (raw is! List) return const <TransactionTagEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(TransactionTagEntity.fromJson)
        .toList(growable: false);
  }

  List<SavingGoal> _parseSavingGoals(Object? raw) {
    if (raw is! List) return const <SavingGoal>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(
          (Map<String, Object?> data) =>
              SavingGoal.fromJson(Map<String, dynamic>.from(data)),
        )
        .toList(growable: false);
  }

  List<CreditEntity> _parseCredits(Object? raw) {
    if (raw is! List) return const <CreditEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['totalAmountScale']) ?? 2;
          final double legacyAmount = _readDouble(data, 'totalAmount');
          final BigInt? totalAmountMinor = _readBigInt(
            data['totalAmountMinor'],
          );
          final BigInt resolvedMinor =
              totalAmountMinor ??
              Money.fromDouble(
                legacyAmount,
                currency: 'XXX',
                scale: scale,
              ).minor;
          return CreditEntity(
            id: _readString(data, 'id'),
            accountId: _readString(data, 'accountId'),
            categoryId: _readOptionalString(data, 'categoryId'),
            interestCategoryId: _readOptionalString(data, 'interestCategoryId'),
            feesCategoryId: _readOptionalString(data, 'feesCategoryId'),
            totalAmountMinor: resolvedMinor,
            totalAmountScale: scale,
            interestRate: _readDouble(data, 'interestRate'),
            termMonths: _readInt(data['termMonths']) ?? 0,
            startDate: _readDate(data, 'startDate'),
            firstPaymentDate: _readOptionalDate(data, 'firstPaymentDate'),
            paymentDay: _readInt(data['paymentDay']) ?? 1,
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            isDeleted: _readBool(data, 'isDeleted'),
          );
        })
        .toList(growable: false);
  }

  List<CreditCardEntity> _parseCreditCards(Object? raw) {
    if (raw is! List) return const <CreditCardEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['creditLimitScale']) ?? 2;
          final double legacyLimit = _readDouble(data, 'creditLimit');
          final BigInt? creditLimitMinor = _readBigInt(
            data['creditLimitMinor'],
          );
          final BigInt resolvedMinor =
              creditLimitMinor ??
              Money.fromDouble(
                legacyLimit,
                currency: 'XXX',
                scale: scale,
              ).minor;
          return CreditCardEntity(
            id: _readString(data, 'id'),
            accountId: _readString(data, 'accountId'),
            creditLimitMinor: resolvedMinor,
            creditLimitScale: scale,
            statementDay: _readInt(data['statementDay']) ?? 1,
            paymentDueDays: _readInt(data['paymentDueDays']) ?? 0,
            interestRateAnnual: _readDouble(data, 'interestRateAnnual'),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            isDeleted: _readBool(data, 'isDeleted'),
          );
        })
        .toList(growable: false);
  }

  List<DebtEntity> _parseDebts(Object? raw) {
    if (raw is! List) return const <DebtEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['amountScale']) ?? 2;
          final double legacyAmount = _readDouble(data, 'amount');
          final BigInt? amountMinor = _readBigInt(data['amountMinor']);
          final BigInt resolvedMinor =
              amountMinor ??
              Money.fromDouble(
                legacyAmount,
                currency: 'XXX',
                scale: scale,
              ).minor;
          return DebtEntity(
            id: _readString(data, 'id'),
            accountId: _readString(data, 'accountId'),
            name: _readOptionalString(data, 'name') ?? '',
            amountMinor: resolvedMinor,
            amountScale: scale,
            dueDate: _readDate(data, 'dueDate'),
            note: _readOptionalString(data, 'note'),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            isDeleted: _readBool(data, 'isDeleted'),
          );
        })
        .toList(growable: false);
  }

  List<Budget> _parseBudgets(Object? raw) {
    if (raw is! List) return const <Budget>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['amountScale']) ?? 2;
          final double legacyAmount = _readDouble(data, 'amount');
          final BigInt? amountMinor = _readBigInt(data['amountMinor']);
          final BigInt resolvedMinor =
              amountMinor ??
              Money.fromDouble(
                legacyAmount,
                currency: 'XXX',
                scale: scale,
              ).minor;
          return Budget(
            id: _readString(data, 'id'),
            title: _readString(data, 'title'),
            period: BudgetPeriodX.fromStorage(_readString(data, 'period')),
            startDate: _readDate(data, 'startDate'),
            endDate: _readOptionalDate(data, 'endDate'),
            amountMinor: resolvedMinor,
            amountScale: scale,
            scope: BudgetScopeX.fromStorage(_readString(data, 'scope')),
            categories: _readStringList(data['categories']),
            accounts: _readStringList(data['accounts']),
            categoryAllocations: _readAllocations(data['categoryAllocations']),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            isDeleted: _readBool(data, 'isDeleted'),
          );
        })
        .toList(growable: false);
  }

  List<BudgetInstance> _parseBudgetInstances(Object? raw) {
    if (raw is! List) return const <BudgetInstance>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['amountScale']) ?? 2;
          final double legacyAmount = _readDouble(data, 'amount');
          final double legacySpent = _readDouble(data, 'spent');
          final BigInt? amountMinor = _readBigInt(data['amountMinor']);
          final BigInt? spentMinor = _readBigInt(data['spentMinor']);
          final BigInt resolvedAmountMinor =
              amountMinor ??
              Money.fromDouble(
                legacyAmount,
                currency: 'XXX',
                scale: scale,
              ).minor;
          final BigInt resolvedSpentMinor =
              spentMinor ??
              Money.fromDouble(
                legacySpent,
                currency: 'XXX',
                scale: scale,
              ).minor;
          return BudgetInstance(
            id: _readString(data, 'id'),
            budgetId: _readString(data, 'budgetId'),
            periodStart: _readDate(data, 'periodStart'),
            periodEnd: _readDate(data, 'periodEnd'),
            amountMinor: resolvedAmountMinor,
            spentMinor: resolvedSpentMinor,
            amountScale: scale,
            status: BudgetInstanceStatusX.fromStorage(
              _readString(data, 'status'),
            ),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
          );
        })
        .toList(growable: false);
  }

  List<UpcomingPayment> _parseUpcomingPayments(Object? raw) {
    if (raw is! List) return const <UpcomingPayment>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(
          (Map<String, Object?> data) =>
              UpcomingPayment.fromJson(Map<String, Object?>.from(data)),
        )
        .toList(growable: false);
  }

  List<PaymentReminder> _parsePaymentReminders(Object? raw) {
    if (raw is! List) return const <PaymentReminder>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(
          (Map<String, Object?> data) =>
              PaymentReminder.fromJson(Map<String, Object?>.from(data)),
        )
        .toList(growable: false);
  }

  String _readString(Map<String, Object?> data, String key) {
    final String value = data[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw FormatException('Пустое значение для $key.');
    }
    return value;
  }

  String? _readOptionalString(Map<String, Object?> data, String key) {
    final String? value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  double _readDouble(Map<String, Object?> data, String key) {
    final Object? value = data[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.parse(value?.toString() ?? '0');
  }

  int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  BigInt? _readBigInt(Object? value) {
    if (value == null) return null;
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    return BigInt.tryParse(value.toString());
  }

  DateTime _readDate(Map<String, Object?> data, String key) {
    final String raw = _readString(data, key);
    return DateTime.parse(raw);
  }

  DateTime? _readOptionalDate(Map<String, Object?> data, String key) {
    final String? raw = _readOptionalString(data, key);
    if (raw == null) {
      return null;
    }
    return DateTime.parse(raw);
  }

  bool _readBool(Map<String, Object?> data, String key) {
    final Object? raw = data[key];
    if (raw is bool) return raw;
    if (raw == null) return false;
    final String normalized = raw.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    throw FormatException('Некорректное значение $key: $raw.');
  }

  List<String> _readStringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((Object? item) => item?.toString().trim() ?? '')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<BudgetCategoryAllocation> _readAllocations(Object? value) {
    if (value is! List) {
      return const <BudgetCategoryAllocation>[];
    }
    return value
        .whereType<Map<String, Object?>>()
        .map(
          (Map<String, Object?> json) => BudgetCategoryAllocation.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList(growable: false);
  }

  Object? _readSection(
    Map<String, Object?> jsonMap,
    String key, {
    bool required = true,
  }) {
    if (!jsonMap.containsKey(key)) {
      if (required) {
        throw FormatException('Отсутствует обязательная секция $key.');
      }
      return null;
    }

    final Object? value = jsonMap[key];
    if (value == null) {
      if (required) {
        throw FormatException('Секция $key не может быть пустой.');
      }
      return null;
    }
    if (value is! List) {
      throw FormatException('Секция $key имеет некорректный формат.');
    }
    return value;
  }
}
