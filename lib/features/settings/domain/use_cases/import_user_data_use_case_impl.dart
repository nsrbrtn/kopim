import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case.dart';

/// Реализация сценария импорта пользовательских данных из JSON-бэкапа.
class ImportUserDataUseCaseImpl implements ImportUserDataUseCase {
  ImportUserDataUseCaseImpl({
    required ImportFilePicker filePicker,
    required ExportBundleJsonDecoder decoder,
    required ImportDataRepository repository,
  }) : _filePicker = filePicker,
       _decoder = decoder,
       _repository = repository;

  final ImportFilePicker _filePicker;
  final ExportBundleJsonDecoder _decoder;
  final ImportDataRepository _repository;

  @override
  Future<ImportUserDataResult> call() async {
    try {
      final PickedImportFile? pickedFile = await _filePicker.pickJsonFile();
      if (pickedFile == null) {
        return const ImportUserDataResult.cancelled();
      }

      final ExportBundle bundle = _decoder.decode(pickedFile.bytes);
      await _repository.upsertAccounts(bundle.accounts);
      await _repository.upsertCategories(bundle.categories);
      await _repository.upsertTransactions(bundle.transactions);

      return ImportUserDataResult.success(
        accounts: bundle.accounts.length,
        categories: bundle.categories.length,
        transactions: bundle.transactions.length,
      );
    } on FormatException catch (error) {
      return ImportUserDataResult.failure(error.message);
    } on Object catch (error) {
      return ImportUserDataResult.failure(error.toString());
    }
  }
}
