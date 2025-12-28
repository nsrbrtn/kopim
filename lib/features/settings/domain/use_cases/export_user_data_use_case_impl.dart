import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_encoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_encoder.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';

/// Use case, orchestrирующий экспорт данных в CSV/JSON и сохранение файла.
class ExportUserDataUseCaseImpl implements ExportUserDataUseCase {
  ExportUserDataUseCaseImpl({
    required PrepareExportBundleUseCase prepareExportBundle,
    required ExportBundleJsonEncoder jsonEncoder,
    required ExportBundleCsvEncoder csvEncoder,
    required ExportFileSaver fileSaver,
  }) : _prepareExportBundle = prepareExportBundle,
       _jsonEncoder = jsonEncoder,
       _csvEncoder = csvEncoder,
       _fileSaver = fileSaver;

  final PrepareExportBundleUseCase _prepareExportBundle;
  final ExportBundleJsonEncoder _jsonEncoder;
  final ExportBundleCsvEncoder _csvEncoder;
  final ExportFileSaver _fileSaver;

  @override
  Future<ExportFileSaveResult> call(ExportUserDataParams params) async {
    try {
      final ExportBundle bundle = await _prepareExportBundle();
      final ExportedFile file = switch (params.format) {
        DataTransferFormat.csv => _csvEncoder.encode(bundle),
        DataTransferFormat.json => _jsonEncoder.encode(bundle),
      };
      return await _fileSaver.save(file, directoryPath: params.directoryPath);
    } on Object catch (error) {
      return ExportFileSaveResult.failure(error.toString());
    }
  }
}
