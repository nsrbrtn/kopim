import 'package:kopim/features/settings/domain/services/import_file_picker.dart';

import 'import_file_picker_stub.dart'
    if (dart.library.io) 'import_file_picker_io.dart'
    if (dart.library.html) 'import_file_picker_web.dart';

ImportFilePicker createImportFilePicker() => buildImportFilePicker();
