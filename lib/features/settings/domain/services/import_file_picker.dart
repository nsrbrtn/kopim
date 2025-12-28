import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';

/// Абстракция выбора файла импорта пользователем.
abstract class ImportFilePicker {
  /// Открывает диалог выбора файла и возвращает выбранный файл.
  ///
  /// Возвращает `null`, если пользователь отменил выбор или операция
  /// недоступна на платформе.
  Future<PickedImportFile?> pickFile(DataTransferFormat format);
}
