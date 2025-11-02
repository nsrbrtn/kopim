import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';

/// Кодирует `ExportBundle` в читаемый JSON-файл.
class ExportBundleJsonEncoder {
  const ExportBundleJsonEncoder({this.indent = '  '});

  /// Отступ для форматированного JSON.
  final String indent;

  /// Создаёт DTO файла, готового к сохранению.
  ExportedFile encode(ExportBundle bundle) {
    final Map<String, dynamic> payload = bundle.toJson()
      ..['generatedAt'] = bundle.generatedAt.toIso8601String();

    final JsonEncoder encoder = JsonEncoder.withIndent(indent);
    final String jsonString = encoder.convert(payload);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    final String timestamp = bundle.generatedAt.toIso8601String().replaceAll(
      ':',
      '-',
    );

    final String fileName = 'kopim-export-$timestamp.json';

    return ExportedFile(
      fileName: fileName,
      mimeType: 'application/json',
      bytes: bytes,
    );
  }
}
