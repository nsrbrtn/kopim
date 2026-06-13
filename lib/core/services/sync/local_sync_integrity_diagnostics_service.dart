import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/liability_account_links.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/transactions/data/services/transaction_balance_helper.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

enum LocalSyncIntegrityIssueType {
  orphanTransactionAccount,
  orphanTransactionCategory,
  orphanTransactionTagLink,
  invalidSavingGoalLink,
  savingGoalCurrentAmountMismatch,
  accountBalanceMismatch,
  invalidMoneyField,
  invalidTransferLink,
  savingGoalMissingStorageAccount,
  invalidCreditGroupLink,
  invalidCreditSchedule,
  staleSendingOutbox,
  unsupportedOutboxEntityType,
  orphanLiabilityAccount,
}

class LocalSyncIntegrityIssue {
  const LocalSyncIntegrityIssue({
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.message,
  });

  final LocalSyncIntegrityIssueType type;
  final String entityType;
  final String entityId;
  final String message;
}

class LocalSyncIntegrityReport {
  const LocalSyncIntegrityReport({
    required this.generatedAt,
    required this.issues,
  });

  final DateTime generatedAt;
  final List<LocalSyncIntegrityIssue> issues;

  bool get hasIssues => issues.isNotEmpty;

  int get issueCount => issues.length;

  int countByType(LocalSyncIntegrityIssueType type) {
    return issues
        .where((LocalSyncIntegrityIssue issue) => issue.type == type)
        .length;
  }
}

class LocalSyncIntegrityReportFormatter {
  const LocalSyncIntegrityReportFormatter();

  String format(LocalSyncIntegrityReport report) {
    final StringBuffer buffer = StringBuffer()
      ..writeln(
        'Local sync integrity report at ${report.generatedAt.toUtc().toIso8601String()}',
      )
      ..writeln('Issues: ${report.issueCount}');
    if (!report.hasIssues) {
      buffer.write('No problems detected.');
      return buffer.toString();
    }

    final Map<LocalSyncIntegrityIssueType, List<LocalSyncIntegrityIssue>>
    grouped = <LocalSyncIntegrityIssueType, List<LocalSyncIntegrityIssue>>{};
    for (final LocalSyncIntegrityIssue issue in report.issues) {
      grouped
          .putIfAbsent(issue.type, () => <LocalSyncIntegrityIssue>[])
          .add(issue);
    }

    for (final MapEntry<
          LocalSyncIntegrityIssueType,
          List<LocalSyncIntegrityIssue>
        >
        entry
        in grouped.entries) {
      buffer.writeln('- ${entry.key.name}: ${entry.value.length}');
      for (final LocalSyncIntegrityIssue issue in entry.value.take(3)) {
        buffer.writeln(
          '  * ${issue.entityType}:${issue.entityId} - ${issue.message}',
        );
      }
      if (entry.value.length > 3) {
        buffer.writeln('  * ... +${entry.value.length - 3} more');
      }
    }
    return buffer.toString().trimRight();
  }
}

class LocalSyncIntegrityDiagnosticsService {
  LocalSyncIntegrityDiagnosticsService(this._database);

  final db.AppDatabase _database;

  Future<LocalSyncIntegrityReport> run({
    DateTime? now,
    Duration staleSendingThreshold = const Duration(minutes: 5),
  }) async {
    final DateTime timestamp = now ?? DateTime.now();
    final DateTime staleCutoff = timestamp.subtract(staleSendingThreshold);
    final List<LocalSyncIntegrityIssue> issues = <LocalSyncIntegrityIssue>[];

    final List<db.AccountRow> accountRows = await _database
        .select(_database.accounts)
        .get();
    final List<db.TransactionRow> transactionRows = await _database
        .select(_database.transactions)
        .get();
    final List<db.TransactionTagRow> transactionTagRows = await _database
        .select(_database.transactionTags)
        .get();
    final List<db.CategoryRow> categoryRows = await _database
        .select(_database.categories)
        .get();
    final List<db.TagRow> tagRows = await _database
        .select(_database.tags)
        .get();
    final List<db.SavingGoalRow> savingGoalRows = await _database
        .select(_database.savingGoals)
        .get();
    final List<db.GoalAccountLinkRow> goalAccountLinkRows = await _database
        .select(_database.goalAccountLinks)
        .get();
    final List<db.GoalContributionRow> contributionRows = await _database
        .select(_database.goalContributions)
        .get();
    final List<db.CreditPaymentGroupRow> creditPaymentGroupRows =
        await _database.select(_database.creditPaymentGroups).get();
    final List<db.CreditPaymentScheduleRow> creditPaymentScheduleRows =
        await _database.select(_database.creditPaymentSchedules).get();
    final List<db.CreditRow> creditRows = await _database
        .select(_database.credits)
        .get();
    final List<db.CreditCardRow> creditCardRows = await _database
        .select(_database.creditCards)
        .get();
    final List<db.DebtRow> debtRows = await _database
        .select(_database.debts)
        .get();
    final List<db.OutboxEntryRow> outboxRows = await _database
        .select(_database.outboxEntries)
        .get();

    final Set<String> accountIds = accountRows
        .map((db.AccountRow row) => row.id)
        .toSet();
    final Set<String> transactionIds = transactionRows
        .map((db.TransactionRow row) => row.id)
        .toSet();
    final Set<String> categoryIds = categoryRows
        .map((db.CategoryRow row) => row.id)
        .toSet();
    final Set<String> tagIds = tagRows.map((db.TagRow row) => row.id).toSet();
    final Set<String> savingGoalIds = savingGoalRows
        .map((db.SavingGoalRow row) => row.id)
        .toSet();
    final Set<String> creditPaymentGroupIds = creditPaymentGroupRows
        .where((db.CreditPaymentGroupRow row) => !row.isDeleted)
        .map((db.CreditPaymentGroupRow row) => row.id)
        .toSet();
    final Set<String> creditIds = creditRows
        .map((db.CreditRow row) => row.id)
        .toSet();

    for (final db.AccountRow row in accountRows) {
      if (BigInt.tryParse(row.balanceMinor) == null) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.invalidMoneyField,
            entityType: 'account',
            entityId: row.id,
            message: 'balanceMinor не является корректным minor-значением.',
          ),
        );
      }
    }

    final Set<String> activeLiabilityAccountIds =
        collectActiveLiabilityAccountIds(
          credits: creditRows.map(_mapCreditRow),
          creditCards: creditCardRows.map(_mapCreditCardRow),
          debts: debtRows.map(_mapDebtRow),
        );
    for (final db.AccountRow row in accountRows) {
      final AccountEntity account = _mapAccountRow(row);
      if (account.isDeleted ||
          !isOrphanedLiabilityAccount(
            account,
            activeLiabilityAccountIds: activeLiabilityAccountIds,
          )) {
        continue;
      }
      issues.add(
        LocalSyncIntegrityIssue(
          type: LocalSyncIntegrityIssueType.orphanLiabilityAccount,
          entityType: 'account',
          entityId: row.id,
          message:
              'Liability account не имеет активной credit/debt/credit_card сущности.',
        ),
      );
    }

    for (final db.TransactionRow row in transactionRows) {
      if (BigInt.tryParse(row.amountMinor) == null || row.amountScale < 0) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.invalidMoneyField,
            entityType: 'transaction',
            entityId: row.id,
            message:
                'amountMinor/amountScale содержит некорректное денежное значение.',
          ),
        );
      }
      if (row.isDeleted) {
        continue;
      }
      if (!accountIds.contains(row.accountId)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.orphanTransactionAccount,
            entityType: 'transaction',
            entityId: row.id,
            message:
                'Активная транзакция ссылается на отсутствующий accountId.',
          ),
        );
      }
      final String? categoryId = row.categoryId?.trim();
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          !categoryIds.contains(categoryId)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.orphanTransactionCategory,
            entityType: 'transaction',
            entityId: row.id,
            message:
                'Активная транзакция ссылается на отсутствующий categoryId.',
          ),
        );
      }

      final TransactionType type = parseTransactionType(row.type);
      final String? transferAccountId = row.transferAccountId?.trim();
      if (type.isTransfer &&
          (transferAccountId == null ||
              transferAccountId.isEmpty ||
              !accountIds.contains(transferAccountId))) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.invalidTransferLink,
            entityType: 'transaction',
            entityId: row.id,
            message:
                'Transfer-транзакция содержит невалидный transferAccountId.',
          ),
        );
      }

      final String? savingGoalId = row.savingGoalId?.trim();
      if (savingGoalId != null &&
          savingGoalId.isNotEmpty &&
          !savingGoalIds.contains(savingGoalId)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.invalidSavingGoalLink,
            entityType: 'transaction',
            entityId: row.id,
            message: 'Транзакция ссылается на отсутствующую saving goal.',
          ),
        );
      }

      final String? groupId = row.groupId?.trim();
      if (groupId != null &&
          groupId.isNotEmpty &&
          !creditPaymentGroupIds.contains(groupId)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.invalidCreditGroupLink,
            entityType: 'transaction',
            entityId: row.id,
            message:
                'Транзакция ссылается на отсутствующую credit payment group.',
          ),
        );
      }
    }

    final Map<String, MoneyAmount> deltas = <String, MoneyAmount>{};
    final Map<String, String> creditAccountByCategoryId = <String, String>{
      for (final db.CreditRow row in creditRows)
        if (row.categoryId != null) row.categoryId!: row.accountId,
    };
    for (final db.AccountRow row in accountRows) {
      deltas[row.id] = MoneyAmount(
        minor: BigInt.zero,
        scale: row.currencyScale,
      );
    }
    for (final db.TransactionRow row in transactionRows) {
      if (row.isDeleted) {
        continue;
      }
      final Map<String, MoneyAmount> effect = buildTransactionEffect(
        transaction: _mapTransactionRow(row),
        creditAccountId: row.categoryId == null
            ? null
            : creditAccountByCategoryId[row.categoryId!],
      );
      applyTransactionEffect(deltas, effect);
    }
    for (final db.AccountRow row in accountRows) {
      final BigInt? openingBalanceMinor = BigInt.tryParse(
        row.openingBalanceMinor,
      );
      final BigInt? balanceMinor = BigInt.tryParse(row.balanceMinor);
      if (openingBalanceMinor == null || balanceMinor == null) {
        continue;
      }
      final BigInt expected =
          openingBalanceMinor + (deltas[row.id]?.minor ?? BigInt.zero);
      if (balanceMinor != expected) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.accountBalanceMismatch,
            entityType: 'account',
            entityId: row.id,
            message:
                'balanceMinor не совпадает с openingBalanceMinor + transaction deltas.',
          ),
        );
      }
    }

    for (final db.TransactionTagRow row in transactionTagRows) {
      if (row.isDeleted) {
        continue;
      }
      if (!transactionIds.contains(row.transactionId) ||
          !tagIds.contains(row.tagId)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.orphanTransactionTagLink,
            entityType: 'transaction_tag',
            entityId: '${row.transactionId}:${row.tagId}',
            message:
                'Связь transaction_tag ссылается на отсутствующую транзакцию или тег.',
          ),
        );
      }
    }

    final Map<String, Set<String>> storageAccountIdsByGoal =
        <String, Set<String>>{};
    for (final db.SavingGoalRow row in savingGoalRows) {
      storageAccountIdsByGoal[row.id] = <String>{
        if (row.accountId?.trim().isNotEmpty ?? false) row.accountId!.trim(),
      };
    }
    for (final db.GoalAccountLinkRow row in goalAccountLinkRows) {
      storageAccountIdsByGoal
          .putIfAbsent(row.goalId, () => <String>{})
          .add(row.accountId);
    }
    final Map<String, int> contributionSumByGoalId = <String, int>{};
    for (final db.GoalContributionRow row in contributionRows) {
      contributionSumByGoalId.update(
        row.goalId,
        (int current) => current + row.amount,
        ifAbsent: () => row.amount,
      );
    }
    for (final db.SavingGoalRow row in savingGoalRows) {
      final Set<String> storageIds =
          storageAccountIdsByGoal[row.id] ?? <String>{};
      if (storageIds.isEmpty ||
          storageIds.any((String id) => !accountIds.contains(id))) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.savingGoalMissingStorageAccount,
            entityType: 'saving_goal',
            entityId: row.id,
            message: 'Копилка не имеет валидного storage account.',
          ),
        );
      }
      final int expectedCurrentAmount = (contributionSumByGoalId[row.id] ?? 0)
          .clamp(0, row.targetAmount);
      if (row.currentAmount != expectedCurrentAmount) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.savingGoalCurrentAmountMismatch,
            entityType: 'saving_goal',
            entityId: row.id,
            message: 'currentAmount не совпадает с суммой contributions.',
          ),
        );
      }
    }

    for (final db.CreditPaymentScheduleRow row in creditPaymentScheduleRows) {
      if (row.isDeleted) {
        continue;
      }
      if (!creditIds.contains(row.creditId)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.invalidCreditSchedule,
            entityType: 'credit_payment_schedule',
            entityId: row.id,
            message: 'График платежей ссылается на отсутствующий creditId.',
          ),
        );
      }
    }

    final Set<String> supportedOutboxEntityTypes = SyncContract
        .supportedOutboxEntityTypes
        .toSet();
    for (final db.OutboxEntryRow row in outboxRows) {
      if (!supportedOutboxEntityTypes.contains(row.entityType)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.unsupportedOutboxEntityType,
            entityType: 'outbox',
            entityId: row.id.toString(),
            message:
                'Outbox содержит неподдерживаемый entityType ${row.entityType}.',
          ),
        );
      }
      if (row.status == OutboxStatus.sending.name &&
          !row.updatedAt.isAfter(staleCutoff)) {
        issues.add(
          LocalSyncIntegrityIssue(
            type: LocalSyncIntegrityIssueType.staleSendingOutbox,
            entityType: 'outbox',
            entityId: row.id.toString(),
            message: 'Outbox entry завис в sending дольше допустимого окна.',
          ),
        );
      }
    }

    return LocalSyncIntegrityReport(generatedAt: timestamp, issues: issues);
  }

  TransactionEntity _mapTransactionRow(db.TransactionRow row) {
    return TransactionEntity(
      id: row.id,
      accountId: row.accountId,
      transferAccountId: row.transferAccountId,
      categoryId: row.categoryId,
      savingGoalId: row.savingGoalId,
      idempotencyKey: row.idempotencyKey,
      groupId: row.groupId,
      amountMinor: BigInt.tryParse(row.amountMinor) ?? BigInt.zero,
      amountScale: row.amountScale,
      date: row.date,
      note: row.note,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }

  AccountEntity _mapAccountRow(db.AccountRow row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      balanceMinor: BigInt.tryParse(row.balanceMinor) ?? BigInt.zero,
      openingBalanceMinor:
          BigInt.tryParse(row.openingBalanceMinor) ?? BigInt.zero,
      currency: row.currency,
      currencyScale: row.currencyScale,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      color: row.color,
      gradientId: row.gradientId,
      isDeleted: row.isDeleted,
      isPrimary: row.isPrimary,
      isHidden: row.isHidden,
      iconName: row.iconName,
      iconStyle: row.iconStyle,
    );
  }

  CreditEntity _mapCreditRow(db.CreditRow row) {
    return CreditEntity(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      interestCategoryId: row.interestCategoryId,
      feesCategoryId: row.feesCategoryId,
      totalAmountMinor: BigInt.tryParse(row.totalAmountMinor),
      totalAmountScale: row.totalAmountScale,
      interestRate: row.interestRate,
      termMonths: row.termMonths,
      startDate: row.startDate,
      firstPaymentDate: row.firstPaymentDate,
      paymentDay: row.paymentDay,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }

  CreditCardEntity _mapCreditCardRow(db.CreditCardRow row) {
    return CreditCardEntity(
      id: row.id,
      accountId: row.accountId,
      creditLimitMinor: BigInt.tryParse(row.creditLimitMinor),
      creditLimitScale: row.creditLimitScale,
      statementDay: row.statementDay,
      paymentDueDays: row.paymentDueDays,
      interestRateAnnual: row.interestRateAnnual,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }

  DebtEntity _mapDebtRow(db.DebtRow row) {
    return DebtEntity(
      id: row.id,
      accountId: row.accountId,
      name: row.name ?? '',
      amountMinor: BigInt.tryParse(row.amountMinor),
      amountScale: row.amountScale,
      dueDate: row.dueDate,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
