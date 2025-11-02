import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

ExportFileSaver buildExportFileSaver() => _UnsupportedExportFileSaver();

class _UnsupportedExportFileSaver implements ExportFileSaver {
  @override
  Future<ExportFileSaveResult> save(ExportedFile file) async {
    return ExportFileSaveResult.failure(
      'Сохранение экспорта недоступно на данной платформе.',
    );
  }
}
