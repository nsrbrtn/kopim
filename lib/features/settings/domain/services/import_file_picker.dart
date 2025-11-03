import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';

/// Абстракция выбора файла импорта пользователем.
abstract class ImportFilePicker {
  /// Открывает диалог выбора файла и возвращает выбранный JSON-файл.
  ///
  /// Возвращает `null`, если пользователь отменил выбор или операция
  /// недоступна на платформе.
  Future<PickedImportFile?> pickJsonFile();
}
