import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';

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
