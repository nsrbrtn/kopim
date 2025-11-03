import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

ExportFileSaver buildExportFileSaver() => _ExportFileSaverIo();

class _ExportFileSaverIo implements ExportFileSaver {
  static const String _exportFolderName = 'kopim_exports';

  @override
  Future<ExportFileSaveResult> save(
    ExportedFile file, {
    String? directoryPath,
  }) async {
    try {
      final Directory exportDir;
      if (directoryPath != null && directoryPath.isNotEmpty) {
        exportDir = Directory(directoryPath);
      } else {
        final Directory baseDir = await _resolveDownloadsDirectory();
        exportDir = Directory(p.join(baseDir.path, _exportFolderName));
      }

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

  Future<Directory> _resolveDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final List<Directory>? externalDownloads =
          await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (externalDownloads != null && externalDownloads.isNotEmpty) {
        return externalDownloads.first;
      }
    } else if (Platform.isIOS) {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      return Directory(p.join(documentsDir.path, 'Downloads'));
    }

    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return downloadsDir;
    }

    return getApplicationDocumentsDirectory();
  }
}
