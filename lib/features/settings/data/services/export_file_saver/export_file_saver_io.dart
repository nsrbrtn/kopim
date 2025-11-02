import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

ExportFileSaver buildExportFileSaver() => _ExportFileSaverIo();

class _ExportFileSaverIo implements ExportFileSaver {
  static const String _exportFolderName = 'kopim_exports';

  @override
  Future<ExportFileSaveResult> save(ExportedFile file) async {
    try {
      final Directory baseDir = await getApplicationDocumentsDirectory();
      final Directory exportDir = Directory(
        p.join(baseDir.path, _exportFolderName),
      );
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final File targetFile = File(p.join(exportDir.path, file.fileName));
      await targetFile.writeAsBytes(file.bytes, flush: true);
      return ExportFileSaveResult.success(filePath: targetFile.path);
    } on Object catch (error) {
      return ExportFileSaveResult.failure(error.toString());
    }
  }
}
