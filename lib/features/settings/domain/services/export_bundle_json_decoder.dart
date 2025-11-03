import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/features/settings/domain/entities/export_bundle.dart';

/// Декодирует JSON-представление экспортированного бандла обратно в модель.
class ExportBundleJsonDecoder {
  const ExportBundleJsonDecoder();

  /// Преобразует набор байтов JSON в [`ExportBundle`].
  ExportBundle decode(Uint8List bytes) {
    try {
      final String jsonString = utf8.decode(bytes);
      final Map<String, Object?> jsonMap =
          json.decode(jsonString) as Map<String, Object?>;
      return ExportBundle.fromJson(jsonMap);
    } on FormatException catch (error) {
      throw FormatException(
        'Некорректный формат файла экспорта: ${error.message}',
      );
    } on Object catch (error) {
      throw FormatException('Не удалось разобрать файл экспорта: $error');
    }
  }
}
