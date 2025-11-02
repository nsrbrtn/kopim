import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exported_file.freezed.dart';

/// Сериализованный файл экспорта с метаданными.
@freezed
abstract class ExportedFile with _$ExportedFile {
  const ExportedFile._();

  const factory ExportedFile({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) = _ExportedFile;
}
