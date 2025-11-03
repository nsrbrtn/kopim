import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'picked_import_file.freezed.dart';

/// Файл, выбранный пользователем для импорта данных.
@freezed
abstract class PickedImportFile with _$PickedImportFile {
  const factory PickedImportFile({
    required String fileName,
    required Uint8List bytes,
  }) = _PickedImportFile;
}
