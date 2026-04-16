import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_bundle_integrity.freezed.dart';
part 'export_bundle_integrity.g.dart';

@freezed
abstract class ExportBundleIntegrity with _$ExportBundleIntegrity {
  const ExportBundleIntegrity._();

  const factory ExportBundleIntegrity({
    required String format,
    required String contentHash,
    @Default(<String, String>{}) Map<String, String> sectionHashes,
    @Default(<String, int>{}) Map<String, int> entityCounts,
  }) = _ExportBundleIntegrity;

  factory ExportBundleIntegrity.fromJson(Map<String, Object?> json) =>
      _$ExportBundleIntegrityFromJson(json);
}
