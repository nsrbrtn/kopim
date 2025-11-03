import 'package:kopim/features/settings/domain/entities/exported_file.dart';

/// Абстракция сохранения экспортированного файла на платформенно-специфичном уровне.
abstract class ExportFileSaver {
  /// Сохраняет файл и возвращает путь или дескриптор, пригодный для отображения в UI.
  Future<ExportFileSaveResult> save(ExportedFile file, {String? directoryPath});
}

/// Результат сохранения файла экспорта.
class ExportFileSaveResult {
  const ExportFileSaveResult({
    required this.isSuccess,
    this.filePath,
    this.downloadUrl,
    this.errorMessage,
  });

  factory ExportFileSaveResult.success({String? filePath, Uri? downloadUrl}) =>
      ExportFileSaveResult(
        isSuccess: true,
        filePath: filePath,
        downloadUrl: downloadUrl,
      );

  factory ExportFileSaveResult.failure(String message) =>
      ExportFileSaveResult(isSuccess: false, errorMessage: message);

  /// Флаг успешного завершения операции.
  final bool isSuccess;

  /// Путь к файлу в файловой системе (для мобильных/десктоп).
  final String? filePath;

  /// URL для загрузки (для web).
  final Uri? downloadUrl;

  /// Текст ошибки в случае неуспеха.
  final String? errorMessage;
}
