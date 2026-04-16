import 'package:kopim/features/settings/domain/entities/export_bundle.dart';

/// Репозиторий, отвечающий за сохранение импортируемых данных.
abstract class ImportDataRepository {
  Future<void> importData({required ExportBundle bundle});
}
