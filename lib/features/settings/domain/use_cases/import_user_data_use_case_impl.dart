import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
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
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

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
      await _repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: transactions,
      );

      return ImportUserDataResult.success(
        accounts: bundle.accounts.length,
        categories: bundle.categories.length,
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
}
