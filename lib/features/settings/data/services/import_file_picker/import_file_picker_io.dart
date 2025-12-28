import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';

ImportFilePicker buildImportFilePicker() => _ImportFilePickerIo();

class _ImportFilePickerIo implements ImportFilePicker {
  @override
  Future<PickedImportFile?> pickFile(DataTransferFormat format) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>[format.fileExtension],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final PlatformFile file = result.files.first;
    Uint8List? bytes = file.bytes;

    if (bytes == null) {
      final String? path = file.path;
      if (path == null) {
        return null;
      }
      final File physicalFile = File(path);
      if (!await physicalFile.exists()) {
        return null;
      }
      bytes = await physicalFile.readAsBytes();
    }

    return PickedImportFile(fileName: file.name, bytes: bytes);
  }
}
