import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';

ImportFilePicker buildImportFilePicker() => _UnsupportedImportFilePicker();

class _UnsupportedImportFilePicker implements ImportFilePicker {
  @override
  Future<PickedImportFile?> pickJsonFile() async {
    return null;
  }
}
