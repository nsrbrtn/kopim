import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

/// Запускает полный цикл экспорта данных пользователя и возвращает результат сохранения.
abstract class ExportUserDataUseCase {
  Future<ExportFileSaveResult> call();
}
