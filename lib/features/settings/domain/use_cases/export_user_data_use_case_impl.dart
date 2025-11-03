import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_encoder.dart';
import 'package:kopim/features/settings/domain/use_cases/export_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';

/// Use case, orchestrирующий экспорт данных в JSON и сохранение файла.
class ExportUserDataUseCaseImpl implements ExportUserDataUseCase {
  ExportUserDataUseCaseImpl({
    required PrepareExportBundleUseCase prepareExportBundle,
    required ExportBundleJsonEncoder encoder,
    required ExportFileSaver fileSaver,
  })  : _prepareExportBundle = prepareExportBundle,
        _encoder = encoder,
        _fileSaver = fileSaver;

  final PrepareExportBundleUseCase _prepareExportBundle;
  final ExportBundleJsonEncoder _encoder;
  final ExportFileSaver _fileSaver;

  @override
  Future<ExportFileSaveResult> call(ExportUserDataParams params) async {
    try {
      final ExportBundle bundle = await _prepareExportBundle();
      final ExportedFile file = _encoder.encode(bundle);
      return await _fileSaver.save(
        file,
        directoryPath: params.directoryPath,
      );
    } on Object catch (error) {
      return ExportFileSaveResult.failure(error.toString());
    }
  }
}
