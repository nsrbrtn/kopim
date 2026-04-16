import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

/// Реализация сценария импорта пользовательских данных из CSV/JSON-бэкапа.
class ImportUserDataUseCaseImpl implements ImportUserDataUseCase {
  ImportUserDataUseCaseImpl({
    required ImportFilePicker filePicker,
    required ExportBundleJsonDecoder jsonDecoder,
    required ExportBundleCsvDecoder csvDecoder,
    required ImportDataRepository repository,
  }) : _filePicker = filePicker,
       _jsonDecoder = jsonDecoder,
       _csvDecoder = csvDecoder,
       _repository = repository;

  final ImportFilePicker _filePicker;
  final ExportBundleJsonDecoder _jsonDecoder;
  final ExportBundleCsvDecoder _csvDecoder;
  final ImportDataRepository _repository;

  @override
  Future<ImportUserDataResult> call(ImportUserDataParams params) async {
    try {
      final PickedImportFile? pickedFile = await _filePicker.pickFile(
        params.format,
      );
      if (pickedFile == null) {
        return const ImportUserDataResult.cancelled();
      }

      final ExportBundle bundle = switch (params.format) {
        DataTransferFormat.csv => _csvDecoder.decode(pickedFile.bytes),
        DataTransferFormat.json => _jsonDecoder.decode(pickedFile.bytes),
      };
      final List<TransactionEntity> transactions = _sanitizeTransactions(
        bundle.transactions,
        bundle: bundle,
      );
      final List<TransactionTagEntity> transactionTags =
          _sanitizeTransactionTags(bundle.transactionTags, bundle: bundle);
      final List<Budget> budgets = _sanitizeBudgets(
        bundle.budgets,
        bundle: bundle,
      );
      final List<BudgetInstance> budgetInstances = _sanitizeBudgetInstances(
        bundle.budgetInstances,
        budgets: budgets,
      );
      final List<UpcomingPayment> upcomingPayments = _sanitizeUpcomingPayments(
        bundle.upcomingPayments,
        bundle: bundle,
      );
      final ExportBundle sanitizedBundle = bundle.copyWith(
        transactions: transactions,
        transactionTags: transactionTags,
        budgets: budgets,
        budgetInstances: budgetInstances,
        upcomingPayments: upcomingPayments,
      );
      await _repository.importData(bundle: sanitizedBundle);

      return ImportUserDataResult.success(
        accounts: sanitizedBundle.accounts.length,
        categories: sanitizedBundle.categories.length,
        transactions: transactions.length,
      );
    } on FormatException catch (error) {
      return ImportUserDataResult.failure(error.message);
    } on Object catch (error) {
      return ImportUserDataResult.failure(error.toString());
    }
  }

  List<TransactionEntity> _sanitizeTransactions(
    List<TransactionEntity> transactions, {
    required ExportBundle bundle,
  }) {
    final Set<String> importedAccountIds = bundle.accounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final Set<String> importedCategoryIds = bundle.categories
        .map((Category category) => category.id)
        .toSet();
    final Set<String> importedSavingGoalIds = bundle.savingGoals
        .map((SavingGoal goal) => goal.id)
        .toSet();

    return transactions
        .where(
          (TransactionEntity transaction) =>
              importedAccountIds.contains(transaction.accountId),
        )
        .map((TransactionEntity transaction) {
          final String? transferAccountId =
              transaction.transferAccountId != null &&
                  importedAccountIds.contains(transaction.transferAccountId)
              ? transaction.transferAccountId
              : null;
          final String? categoryId =
              transaction.categoryId != null &&
                  importedCategoryIds.contains(transaction.categoryId)
              ? transaction.categoryId
              : null;
          final String? savingGoalId =
              transaction.savingGoalId != null &&
                  importedSavingGoalIds.contains(transaction.savingGoalId)
              ? transaction.savingGoalId
              : null;
          return transaction.copyWith(
            transferAccountId: transferAccountId,
            categoryId: categoryId,
            savingGoalId: savingGoalId,
          );
        })
        .toList(growable: false);
  }

  List<TransactionTagEntity> _sanitizeTransactionTags(
    List<TransactionTagEntity> links, {
    required ExportBundle bundle,
  }) {
    final Set<String> transactionIds = bundle.transactions
        .map((TransactionEntity transaction) => transaction.id)
        .toSet();
    final Set<String> tagIds = bundle.tags
        .map((TagEntity tag) => tag.id)
        .toSet();
    return links
        .where(
          (TransactionTagEntity link) =>
              transactionIds.contains(link.transactionId) &&
              tagIds.contains(link.tagId),
        )
        .toList(growable: false);
  }

  List<Budget> _sanitizeBudgets(
    List<Budget> budgets, {
    required ExportBundle bundle,
  }) {
    final Set<String> accountIds = bundle.accounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final Set<String> categoryIds = bundle.categories
        .map((Category category) => category.id)
        .toSet();

    return budgets
        .map((Budget budget) {
          final List<String> filteredAccounts = budget.accounts
              .where(accountIds.contains)
              .toList(growable: false);
          final List<String> filteredCategories = budget.categories
              .where(categoryIds.contains)
              .toList(growable: false);
          final List<BudgetCategoryAllocation> filteredAllocations = budget
              .categoryAllocations
              .where(
                (BudgetCategoryAllocation allocation) =>
                    categoryIds.contains(allocation.categoryId),
              )
              .toList(growable: false);
          return budget.copyWith(
            accounts: filteredAccounts,
            categories: filteredCategories,
            categoryAllocations: filteredAllocations,
          );
        })
        .toList(growable: false);
  }

  List<BudgetInstance> _sanitizeBudgetInstances(
    List<BudgetInstance> instances, {
    required List<Budget> budgets,
  }) {
    final Set<String> budgetIds = budgets
        .map((Budget budget) => budget.id)
        .toSet();
    return instances
        .where(
          (BudgetInstance instance) => budgetIds.contains(instance.budgetId),
        )
        .toList(growable: false);
  }

  List<UpcomingPayment> _sanitizeUpcomingPayments(
    List<UpcomingPayment> payments, {
    required ExportBundle bundle,
  }) {
    final Set<String> accountIds = bundle.accounts
        .map((AccountEntity account) => account.id)
        .toSet();
    final Set<String> categoryIds = bundle.categories
        .map((Category category) => category.id)
        .toSet();
    return payments
        .where(
          (UpcomingPayment payment) =>
              accountIds.contains(payment.accountId) &&
              categoryIds.contains(payment.categoryId),
        )
        .toList(growable: false);
  }
}
