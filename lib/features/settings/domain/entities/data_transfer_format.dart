/// Поддерживаемые форматы импорта/экспорта данных.
enum DataTransferFormat { csv, json }

extension DataTransferFormatX on DataTransferFormat {
  bool get isCanonicalMigrationFormat => this == DataTransferFormat.json;

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
