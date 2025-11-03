import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';

/// Контракт импорта пользовательских данных из экспортированного файла.
abstract class ImportUserDataUseCase {
  Future<ImportUserDataResult> call();
}
