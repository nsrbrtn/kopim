import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

import 'export_file_saver_stub.dart'
    if (dart.library.io) 'export_file_saver_io.dart'
    if (dart.library.html) 'export_file_saver_web.dart';

ExportFileSaver createExportFileSaver() => buildExportFileSaver();
