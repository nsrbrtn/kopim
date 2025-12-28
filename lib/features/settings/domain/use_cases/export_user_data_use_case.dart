import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';

class ExportUserDataParams {
  const ExportUserDataParams({
    this.directoryPath,
    this.format = DataTransferFormat.csv,
  });

  final String? directoryPath;
  final DataTransferFormat format;
}

/// Запускает полный цикл экспорта данных пользователя и возвращает результат сохранения.
abstract class ExportUserDataUseCase {
  Future<ExportFileSaveResult> call(ExportUserDataParams params);
}
