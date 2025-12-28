/// Поддерживаемые форматы импорта/экспорта данных.
enum DataTransferFormat {
  csv,
  json,
}

extension DataTransferFormatX on DataTransferFormat {
  /// Расширение файла для выбранного формата.
  String get fileExtension {
    switch (this) {
      case DataTransferFormat.csv:
        return 'csv';
      case DataTransferFormat.json:
        return 'json';
    }
  }
}
