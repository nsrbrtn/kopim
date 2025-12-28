import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';

ImportFilePicker buildImportFilePicker() => _UnsupportedImportFilePicker();

class _UnsupportedImportFilePicker implements ImportFilePicker {
  @override
  Future<PickedImportFile?> pickFile(DataTransferFormat format) async {
    return null;
  }
}
