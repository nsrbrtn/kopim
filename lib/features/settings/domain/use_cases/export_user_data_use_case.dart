import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

class ExportUserDataParams {
  const ExportUserDataParams({this.directoryPath});

  final String? directoryPath;
}

/// Запускает полный цикл экспорта данных пользователя и возвращает результат сохранения.
abstract class ExportUserDataUseCase {
  Future<ExportFileSaveResult> call(ExportUserDataParams params);
}
