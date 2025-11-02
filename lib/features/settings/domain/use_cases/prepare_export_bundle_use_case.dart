import 'package:kopim/features/settings/domain/entities/export_bundle.dart';

/// Собирает данные пользователя в один бандл для последующего экспорта.
abstract class PrepareExportBundleUseCase {
  Future<ExportBundle> call();
}
