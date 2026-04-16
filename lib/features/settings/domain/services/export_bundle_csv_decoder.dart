import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
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
import 'package:kopim/features/settings/domain/services/csv_codec.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_schema.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Декодирует CSV-представление экспортированного бандла обратно в модель.
class ExportBundleCsvDecoder {
  const ExportBundleCsvDecoder();

  ExportBundle decode(Uint8List bytes) {
    try {
      final String csvString = utf8.decode(bytes);
      final List<List<String>> rows = CsvCodec.decode(csvString);
      return _parse(rows);
    } on FormatException catch (error) {
      throw FormatException(
        'Некорректный формат CSV-файла экспорта: ${error.message}',
      );
    } on Object catch (error) {
      throw FormatException('Не удалось разобрать CSV-файл экспорта: $error');
    }
  }

  ExportBundle _parse(List<List<String>> rows) {
    String? schemaVersion;
    DateTime? generatedAt;
    bool hasAccounts = false;
    bool hasCategories = false;
    bool hasTags = false;
    bool hasTransactionTags = false;
    bool hasSavingGoals = false;
    bool hasCredits = false;
    bool hasCreditCards = false;
    bool hasDebts = false;
    bool hasBudgets = false;
    bool hasBudgetInstances = false;
    bool hasUpcomingPayments = false;
    bool hasPaymentReminders = false;
    bool hasTransactions = false;
    final List<AccountEntity> accounts = <AccountEntity>[];
    final List<Category> categories = <Category>[];
    final List<TagEntity> tags = <TagEntity>[];
    final List<TransactionTagEntity> transactionTags = <TransactionTagEntity>[];
    final List<SavingGoal> savingGoals = <SavingGoal>[];
    final List<CreditEntity> credits = <CreditEntity>[];
    final List<CreditCardEntity> creditCards = <CreditCardEntity>[];
    final List<DebtEntity> debts = <DebtEntity>[];
    final List<Budget> budgets = <Budget>[];
    final List<BudgetInstance> budgetInstances = <BudgetInstance>[];
    final List<UpcomingPayment> upcomingPayments = <UpcomingPayment>[];
    final List<PaymentReminder> paymentReminders = <PaymentReminder>[];
    final List<TransactionEntity> transactions = <TransactionEntity>[];

    int index = 0;
    while (index < rows.length) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      final String marker = row.first.trim();
      if (!marker.startsWith('#')) {
        index += 1;
        continue;
      }

      switch (marker) {
        case '#kopim-export':
          index += 1;
          break;
        case '#schema_version':
          schemaVersion = _readMetaValue(row, marker);
          index += 1;
          break;
        case '#generated_at':
          generatedAt = DateTime.parse(_readMetaValue(row, marker));
          index += 1;
          break;
        case '#accounts':
          hasAccounts = true;
          index = _parseAccounts(rows, index + 1, accounts);
          break;
        case '#categories':
          hasCategories = true;
          index = _parseCategories(rows, index + 1, categories);
          break;
        case '#tags':
          hasTags = true;
          index = _parseTags(rows, index + 1, tags);
          break;
        case '#transaction_tags':
          hasTransactionTags = true;
          index = _parseTransactionTags(rows, index + 1, transactionTags);
          break;
        case '#saving_goals':
          hasSavingGoals = true;
          index = _parseSavingGoals(rows, index + 1, savingGoals);
          break;
        case '#credits':
          hasCredits = true;
          index = _parseCredits(rows, index + 1, credits);
          break;
        case '#credit_cards':
          hasCreditCards = true;
          index = _parseCreditCards(rows, index + 1, creditCards);
          break;
        case '#debts':
          hasDebts = true;
          index = _parseDebts(rows, index + 1, debts);
          break;
        case '#budgets':
          hasBudgets = true;
          index = _parseBudgets(rows, index + 1, budgets);
          break;
        case '#budget_instances':
          hasBudgetInstances = true;
          index = _parseBudgetInstances(rows, index + 1, budgetInstances);
          break;
        case '#upcoming_payments':
          hasUpcomingPayments = true;
          index = _parseUpcomingPayments(rows, index + 1, upcomingPayments);
          break;
        case '#payment_reminders':
          hasPaymentReminders = true;
          index = _parsePaymentReminders(rows, index + 1, paymentReminders);
          break;
        case '#transactions':
          hasTransactions = true;
          index = _parseTransactions(rows, index + 1, transactions);
          break;
        default:
          index += 1;
          break;
      }
    }

    if (schemaVersion == null || schemaVersion.isEmpty) {
      throw const FormatException('Не найдена версия схемы экспорта.');
    }
    final dynamic version = ExportBundleSchema.parseAndValidate(schemaVersion);
    if (generatedAt == null) {
      throw const FormatException('Не найдена дата генерации экспорта.');
    }
    _ensureSection(
      sectionName: '#accounts',
      present: hasAccounts,
      required: true,
    );
    _ensureSection(
      sectionName: '#categories',
      present: hasCategories,
      required: true,
    );
    _ensureSection(
      sectionName: '#tags',
      present: hasTags,
      required: ExportBundleSchema.requiresExtendedSnapshot(version),
    );
    _ensureSection(
      sectionName: '#transaction_tags',
      present: hasTransactionTags,
      required: ExportBundleSchema.requiresExtendedSnapshot(version),
    );
    _ensureSection(
      sectionName: '#transactions',
      present: hasTransactions,
      required: true,
    );
    _ensureSection(
      sectionName: '#saving_goals',
      present: hasSavingGoals,
      required: ExportBundleSchema.requiresSavingGoals(version),
    );
    _ensureSection(
      sectionName: '#credits',
      present: hasCredits,
      required: ExportBundleSchema.requiresLiabilities(version),
    );
    _ensureSection(
      sectionName: '#credit_cards',
      present: hasCreditCards,
      required: ExportBundleSchema.requiresLiabilities(version),
    );
    _ensureSection(
      sectionName: '#debts',
      present: hasDebts,
      required: ExportBundleSchema.requiresLiabilities(version),
    );
    _ensureSection(
      sectionName: '#budgets',
      present: hasBudgets,
      required: ExportBundleSchema.requiresExtendedSnapshot(version),
    );
    _ensureSection(
      sectionName: '#budget_instances',
      present: hasBudgetInstances,
      required: ExportBundleSchema.requiresExtendedSnapshot(version),
    );
    _ensureSection(
      sectionName: '#upcoming_payments',
      present: hasUpcomingPayments,
      required: ExportBundleSchema.requiresExtendedSnapshot(version),
    );
    _ensureSection(
      sectionName: '#payment_reminders',
      present: hasPaymentReminders,
      required: ExportBundleSchema.requiresExtendedSnapshot(version),
    );

    return ExportBundle(
      schemaVersion: schemaVersion,
      generatedAt: generatedAt,
      accounts: accounts,
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
      transactions: transactions,
    );
  }

  int _parseAccounts(
    List<List<String>> rows,
    int startIndex,
    List<AccountEntity> accounts,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#accounts');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      accounts.add(() {
        final String currency = _readRequired(header.columns, row, 'currency');
        final int scale =
            _readOptionalInt(header.columns, row, 'currency_scale') ??
            resolveCurrencyScale(currency);
        final double legacyBalance = _readDouble(
          header.columns,
          row,
          'balance',
        );
        final double legacyOpening = _readOptionalDouble(
          header.columns,
          row,
          'opening_balance',
        );
        final BigInt? balanceMinor = _readOptionalBigInt(
          header.columns,
          row,
          'balance_minor',
        );
        final BigInt? openingMinor = _readOptionalBigInt(
          header.columns,
          row,
          'opening_balance_minor',
        );
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
          id: _readRequired(header.columns, row, 'id'),
          name: _readRequired(header.columns, row, 'name'),
          balanceMinor: resolvedBalanceMinor,
          openingBalanceMinor: resolvedOpeningMinor,
          currency: currency,
          currencyScale: scale,
          type: _readRequired(header.columns, row, 'type'),
          typeVersion:
              _readOptionalInt(header.columns, row, 'type_version') ?? 0,
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          color: _readOptional(header.columns, row, 'color'),
          gradientId: _readOptional(header.columns, row, 'gradient_id'),
          iconName: _readOptional(header.columns, row, 'icon_name'),
          iconStyle: _readOptional(header.columns, row, 'icon_style'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
          isPrimary: _readBool(header.columns, row, 'is_primary'),
          isHidden: _readBool(header.columns, row, 'is_hidden'),
        );
      }());
      index += 1;
    }
    return index;
  }

  void _ensureSection({
    required String sectionName,
    required bool present,
    required bool required,
  }) {
    if (required && !present) {
      throw FormatException('Отсутствует обязательная секция $sectionName.');
    }
  }

  int _parseCategories(
    List<List<String>> rows,
    int startIndex,
    List<Category> categories,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#categories');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      categories.add(
        Category(
          id: _readRequired(header.columns, row, 'id'),
          name: _readRequired(header.columns, row, 'name'),
          type: _readRequired(header.columns, row, 'type'),
          icon: _readIcon(header.columns, row, 'icon_json'),
          color: _readOptional(header.columns, row, 'color'),
          parentId: _readOptional(header.columns, row, 'parent_id'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
          isSystem: _readBool(header.columns, row, 'is_system'),
          isHidden: _readBool(header.columns, row, 'is_hidden'),
          isFavorite: _readBool(header.columns, row, 'is_favorite'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parseTags(
    List<List<String>> rows,
    int startIndex,
    List<TagEntity> tags,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#tags');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      tags.add(
        TagEntity(
          id: _readRequired(header.columns, row, 'id'),
          name: _readRequired(header.columns, row, 'name'),
          color: _readRequired(header.columns, row, 'color'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parseTransactionTags(
    List<List<String>> rows,
    int startIndex,
    List<TransactionTagEntity> links,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#transaction_tags',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      links.add(
        TransactionTagEntity(
          transactionId: _readRequired(header.columns, row, 'transaction_id'),
          tagId: _readRequired(header.columns, row, 'tag_id'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parseTransactions(
    List<List<String>> rows,
    int startIndex,
    List<TransactionEntity> transactions,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#transactions',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      transactions.add(() {
        final int scale =
            _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
        final double legacyAmount = _readDouble(header.columns, row, 'amount');
        final BigInt? amountMinor = _readOptionalBigInt(
          header.columns,
          row,
          'amount_minor',
        );
        final BigInt resolvedMinor =
            amountMinor ??
            Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
        return TransactionEntity(
          id: _readRequired(header.columns, row, 'id'),
          accountId: _readRequired(header.columns, row, 'account_id'),
          transferAccountId: _readOptional(
            header.columns,
            row,
            'transfer_account_id',
          ),
          categoryId: _readOptional(header.columns, row, 'category_id'),
          savingGoalId: _readOptional(header.columns, row, 'saving_goal_id'),
          idempotencyKey: _readOptional(header.columns, row, 'idempotency_key'),
          groupId: _readOptional(header.columns, row, 'group_id'),
          amountMinor: resolvedMinor,
          amountScale: scale,
          date: _readDate(header.columns, row, 'date'),
          note: _readOptional(header.columns, row, 'note'),
          type: _readRequired(header.columns, row, 'type'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        );
      }());
      index += 1;
    }
    return index;
  }

  int _parseSavingGoals(
    List<List<String>> rows,
    int startIndex,
    List<SavingGoal> savingGoals,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#saving_goals',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      savingGoals.add(() {
        final String? accountId = _readOptional(
          header.columns,
          row,
          'account_id',
        );
        final String? rawStorageAccountIds = _readOptional(
          header.columns,
          row,
          'storage_account_ids',
        );
        final List<String> storageAccountIds =
            rawStorageAccountIds == null || rawStorageAccountIds.isEmpty
            ? (accountId == null || accountId.isEmpty)
                  ? const <String>[]
                  : <String>[accountId]
            : rawStorageAccountIds
                  .split('|')
                  .map((String value) => value.trim())
                  .where((String value) => value.isNotEmpty)
                  .toSet()
                  .toList(growable: false);
        return SavingGoal(
          id: _readRequired(header.columns, row, 'id'),
          userId: _readRequired(header.columns, row, 'user_id'),
          name: _readRequired(header.columns, row, 'name'),
          accountId: accountId,
          storageAccountIds: storageAccountIds,
          targetDate: _readOptionalDate(header.columns, row, 'target_date'),
          targetAmount: _readRequiredInt(header.columns, row, 'target_amount'),
          currentAmount: _readRequiredInt(
            header.columns,
            row,
            'current_amount',
          ),
          note: _readOptional(header.columns, row, 'note'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          archivedAt: _readOptionalDate(header.columns, row, 'archived_at'),
        );
      }());
      index += 1;
    }
    return index;
  }

  int _parseCredits(
    List<List<String>> rows,
    int startIndex,
    List<CreditEntity> credits,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#credits');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      credits.add(() {
        final int scale =
            _readOptionalInt(header.columns, row, 'total_amount_scale') ?? 2;
        final double legacyAmount = _readDouble(
          header.columns,
          row,
          'total_amount',
        );
        final BigInt? totalAmountMinor = _readOptionalBigInt(
          header.columns,
          row,
          'total_amount_minor',
        );
        final BigInt resolvedMinor =
            totalAmountMinor ??
            Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
        return CreditEntity(
          id: _readRequired(header.columns, row, 'id'),
          accountId: _readRequired(header.columns, row, 'account_id'),
          categoryId: _readOptional(header.columns, row, 'category_id'),
          interestCategoryId: _readOptional(
            header.columns,
            row,
            'interest_category_id',
          ),
          feesCategoryId: _readOptional(
            header.columns,
            row,
            'fees_category_id',
          ),
          totalAmountMinor: resolvedMinor,
          totalAmountScale: scale,
          interestRate: _readDouble(header.columns, row, 'interest_rate'),
          termMonths: _readRequiredInt(header.columns, row, 'term_months'),
          startDate: _readDate(header.columns, row, 'start_date'),
          firstPaymentDate: _readOptionalDate(
            header.columns,
            row,
            'first_payment_date',
          ),
          paymentDay: _readRequiredInt(header.columns, row, 'payment_day'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        );
      }());
      index += 1;
    }
    return index;
  }

  int _parseCreditCards(
    List<List<String>> rows,
    int startIndex,
    List<CreditCardEntity> creditCards,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#credit_cards',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      creditCards.add(() {
        final int scale =
            _readOptionalInt(header.columns, row, 'credit_limit_scale') ?? 2;
        final double legacyLimit = _readDouble(
          header.columns,
          row,
          'credit_limit',
        );
        final BigInt? creditLimitMinor = _readOptionalBigInt(
          header.columns,
          row,
          'credit_limit_minor',
        );
        final BigInt resolvedMinor =
            creditLimitMinor ??
            Money.fromDouble(legacyLimit, currency: 'XXX', scale: scale).minor;
        return CreditCardEntity(
          id: _readRequired(header.columns, row, 'id'),
          accountId: _readRequired(header.columns, row, 'account_id'),
          creditLimitMinor: resolvedMinor,
          creditLimitScale: scale,
          statementDay: _readRequiredInt(header.columns, row, 'statement_day'),
          paymentDueDays: _readRequiredInt(
            header.columns,
            row,
            'payment_due_days',
          ),
          interestRateAnnual: _readDouble(
            header.columns,
            row,
            'interest_rate_annual',
          ),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        );
      }());
      index += 1;
    }
    return index;
  }

  int _parseDebts(
    List<List<String>> rows,
    int startIndex,
    List<DebtEntity> debts,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#debts');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      debts.add(() {
        final int scale =
            _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
        final double legacyAmount = _readDouble(header.columns, row, 'amount');
        final BigInt? amountMinor = _readOptionalBigInt(
          header.columns,
          row,
          'amount_minor',
        );
        final BigInt resolvedMinor =
            amountMinor ??
            Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
        return DebtEntity(
          id: _readRequired(header.columns, row, 'id'),
          accountId: _readRequired(header.columns, row, 'account_id'),
          name: _readOptional(header.columns, row, 'name') ?? '',
          amountMinor: resolvedMinor,
          amountScale: scale,
          dueDate: _readDate(header.columns, row, 'due_date'),
          note: _readOptional(header.columns, row, 'note'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        );
      }());
      index += 1;
    }
    return index;
  }

  int _parseBudgets(
    List<List<String>> rows,
    int startIndex,
    List<Budget> budgets,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#budgets');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      final int scale =
          _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
      final double legacyAmount = _readDouble(header.columns, row, 'amount');
      final BigInt? amountMinor = _readOptionalBigInt(
        header.columns,
        row,
        'amount_minor',
      );
      final BigInt resolvedMinor =
          amountMinor ??
          Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
      budgets.add(
        Budget(
          id: _readRequired(header.columns, row, 'id'),
          title: _readRequired(header.columns, row, 'title'),
          period: BudgetPeriodX.fromStorage(
            _readRequired(header.columns, row, 'period'),
          ),
          startDate: _readDate(header.columns, row, 'start_date'),
          endDate: _readOptionalDate(header.columns, row, 'end_date'),
          amountMinor: resolvedMinor,
          amountScale: scale,
          scope: BudgetScopeX.fromStorage(
            _readRequired(header.columns, row, 'scope'),
          ),
          categories: _readJsonStringList(
            header.columns,
            row,
            'categories_json',
          ),
          accounts: _readJsonStringList(header.columns, row, 'accounts_json'),
          categoryAllocations: _readJsonAllocations(
            header.columns,
            row,
            'category_allocations_json',
          ),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parseBudgetInstances(
    List<List<String>> rows,
    int startIndex,
    List<BudgetInstance> instances,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#budget_instances',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      final int scale =
          _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
      final double legacyAmount = _readDouble(header.columns, row, 'amount');
      final double legacySpent = _readDouble(header.columns, row, 'spent');
      final BigInt? amountMinor = _readOptionalBigInt(
        header.columns,
        row,
        'amount_minor',
      );
      final BigInt? spentMinor = _readOptionalBigInt(
        header.columns,
        row,
        'spent_minor',
      );
      final BigInt resolvedAmount =
          amountMinor ??
          Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
      final BigInt resolvedSpent =
          spentMinor ??
          Money.fromDouble(legacySpent, currency: 'XXX', scale: scale).minor;
      instances.add(
        BudgetInstance(
          id: _readRequired(header.columns, row, 'id'),
          budgetId: _readRequired(header.columns, row, 'budget_id'),
          periodStart: _readDate(header.columns, row, 'period_start'),
          periodEnd: _readDate(header.columns, row, 'period_end'),
          amountMinor: resolvedAmount,
          spentMinor: resolvedSpent,
          amountScale: scale,
          status: BudgetInstanceStatusX.fromStorage(
            _readRequired(header.columns, row, 'status'),
          ),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parseUpcomingPayments(
    List<List<String>> rows,
    int startIndex,
    List<UpcomingPayment> payments,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#upcoming_payments',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      final int scale =
          _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
      final double legacyAmount = _readDouble(header.columns, row, 'amount');
      final BigInt? amountMinor = _readOptionalBigInt(
        header.columns,
        row,
        'amount_minor',
      );
      final BigInt resolvedMinor =
          amountMinor ??
          Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
      payments.add(
        UpcomingPayment(
          id: _readRequired(header.columns, row, 'id'),
          title: _readRequired(header.columns, row, 'title'),
          accountId: _readRequired(header.columns, row, 'account_id'),
          categoryId: _readRequired(header.columns, row, 'category_id'),
          amountMinor: resolvedMinor,
          amountScale: scale,
          dayOfMonth: _readRequiredInt(header.columns, row, 'day_of_month'),
          notifyDaysBefore: _readRequiredInt(
            header.columns,
            row,
            'notify_days_before',
          ),
          notifyTimeHhmm: _readRequired(
            header.columns,
            row,
            'notify_time_hhmm',
          ),
          note: _readOptional(header.columns, row, 'note'),
          autoPost: _readBool(header.columns, row, 'auto_post'),
          flowType: parseUpcomingPaymentFlowType(
            _readRequired(header.columns, row, 'flow_type'),
          ),
          isActive: _readBool(header.columns, row, 'is_active'),
          nextRunAtMs: _readOptionalInt(header.columns, row, 'next_run_at_ms'),
          nextNotifyAtMs: _readOptionalInt(
            header.columns,
            row,
            'next_notify_at_ms',
          ),
          lastGeneratedPeriod: _readOptional(
            header.columns,
            row,
            'last_generated_period',
          ),
          createdAtMs: _readRequiredInt(header.columns, row, 'created_at_ms'),
          updatedAtMs: _readRequiredInt(header.columns, row, 'updated_at_ms'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parsePaymentReminders(
    List<List<String>> rows,
    int startIndex,
    List<PaymentReminder> reminders,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#payment_reminders',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      final int scale =
          _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
      final double legacyAmount = _readDouble(header.columns, row, 'amount');
      final BigInt? amountMinor = _readOptionalBigInt(
        header.columns,
        row,
        'amount_minor',
      );
      final BigInt resolvedMinor =
          amountMinor ??
          Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
      reminders.add(
        PaymentReminder(
          id: _readRequired(header.columns, row, 'id'),
          title: _readRequired(header.columns, row, 'title'),
          amountMinor: resolvedMinor,
          amountScale: scale,
          whenAtMs: _readRequiredInt(header.columns, row, 'when_at_ms'),
          note: _readOptional(header.columns, row, 'note'),
          isDone: _readBool(header.columns, row, 'is_done'),
          lastNotifiedAtMs: _readOptionalInt(
            header.columns,
            row,
            'last_notified_at_ms',
          ),
          createdAtMs: _readRequiredInt(header.columns, row, 'created_at_ms'),
          updatedAtMs: _readRequiredInt(header.columns, row, 'updated_at_ms'),
        ),
      );
      index += 1;
    }
    return index;
  }

  _SectionHeader _readHeader(
    List<List<String>> rows,
    int startIndex,
    String sectionName,
  ) {
    if (startIndex >= rows.length) {
      throw FormatException('Отсутствует заголовок секции $sectionName.');
    }
    final List<String> headerRow = rows[startIndex];
    if (_isEmptyRow(headerRow) || _isSectionMarker(headerRow)) {
      throw FormatException('Пустой заголовок секции $sectionName.');
    }
    final Map<String, int> columns = <String, int>{};
    for (int index = 0; index < headerRow.length; index += 1) {
      final String key = headerRow[index].trim().toLowerCase();
      if (key.isEmpty) {
        continue;
      }
      columns[key] = index;
    }
    return _SectionHeader(columns: columns, nextIndex: startIndex + 1);
  }

  bool _isSectionMarker(List<String> row) {
    if (_isEmptyRow(row)) {
      return false;
    }
    return row.first.trim().startsWith('#');
  }

  bool _isEmptyRow(List<String> row) {
    return row.isEmpty || row.every((String cell) => cell.trim().isEmpty);
  }

  String _readMetaValue(List<String> row, String marker) {
    if (row.length < 2) {
      throw FormatException('Отсутствует значение для $marker.');
    }
    return row[1].trim();
  }

  String _readRequired(Map<String, int> columns, List<String> row, String key) {
    final int? index = columns[key];
    if (index == null) {
      throw FormatException('Отсутствует колонка $key.');
    }
    final String value = _readCell(row, index);
    if (value.isEmpty) {
      throw FormatException('Пустое значение для $key.');
    }
    return value;
  }

  String _readCell(List<String> row, int index) {
    if (index < 0 || index >= row.length) {
      return '';
    }
    return row[index].trim();
  }

  String? _readOptional(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final int? index = columns[key];
    if (index == null) {
      return null;
    }
    final String value = _readCell(row, index);
    return value.isEmpty ? null : value;
  }

  double _readDouble(Map<String, int> columns, List<String> row, String key) {
    final String raw = _readRequired(columns, row, key);
    return double.parse(raw.trim());
  }

  double _readOptionalDouble(
    Map<String, int> columns,
    List<String> row,
    String key, {
    double fallback = 0,
  }) {
    final int? index = columns[key];
    if (index == null) {
      return fallback;
    }
    final String raw = _readCell(row, index);
    if (raw.isEmpty) {
      return fallback;
    }
    return double.parse(raw.trim());
  }

  int? _readOptionalInt(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final int? index = columns[key];
    if (index == null) {
      return null;
    }
    final String raw = _readCell(row, index);
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw.trim());
  }

  int _readRequiredInt(Map<String, int> columns, List<String> row, String key) {
    final String raw = _readRequired(columns, row, key);
    return int.parse(raw.trim());
  }

  DateTime? _readOptionalDate(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null) {
      return null;
    }
    return DateTime.parse(raw);
  }

  BigInt? _readOptionalBigInt(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final int? index = columns[key];
    if (index == null) {
      return null;
    }
    final String raw = _readCell(row, index);
    if (raw.isEmpty) {
      return null;
    }
    return BigInt.tryParse(raw.trim());
  }

  DateTime _readDate(Map<String, int> columns, List<String> row, String key) {
    final String raw = _readRequired(columns, row, key);
    return DateTime.parse(raw.trim());
  }

  bool _readBool(Map<String, int> columns, List<String> row, String key) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null || raw.isEmpty) {
      return false;
    }
    final String normalized = raw.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    throw FormatException('Некорректное значение $key: $raw.');
  }

  PhosphorIconDescriptor? _readIcon(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Некорректный формат иконки категории.');
    }
    return PhosphorIconDescriptor.fromJson(decoded);
  }

  List<String> _readJsonStringList(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException('Некорректный JSON-массив в $key.');
    }
    return decoded
        .map((Object? item) => item?.toString() ?? '')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<BudgetCategoryAllocation> _readJsonAllocations(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null || raw.isEmpty) {
      return const <BudgetCategoryAllocation>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException('Некорректный JSON-массив в $key.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BudgetCategoryAllocation.fromJson)
        .toList(growable: false);
  }
}

class _SectionHeader {
  const _SectionHeader({required this.columns, required this.nextIndex});

  final Map<String, int> columns;
  final int nextIndex;
}
