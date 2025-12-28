import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';

/// Контракт импорта пользовательских данных из экспортированного файла.
class ImportUserDataParams {
  const ImportUserDataParams({this.format = DataTransferFormat.csv});

  final DataTransferFormat format;
}

abstract class ImportUserDataUseCase {
  Future<ImportUserDataResult> call(ImportUserDataParams params);
}
