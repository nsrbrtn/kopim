// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

ExportFileSaver buildExportFileSaver() => _ExportFileSaverWeb();

class _ExportFileSaverWeb implements ExportFileSaver {
  @override
  Future<ExportFileSaveResult> save(ExportedFile file) async {
    final html.Blob blob = html.Blob(
      <dynamic>[file.bytes],
      file.mimeType,
      'native',
    );
    final String url = html.Url.createObjectUrlFromBlob(blob);
    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..download = file.fileName
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    Future<void>.microtask(() => html.Url.revokeObjectUrl(url));

    return ExportFileSaveResult.success(downloadUrl: Uri.parse(url));
  }
}
