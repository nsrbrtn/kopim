// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_bundle_integrity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportBundleIntegrity _$ExportBundleIntegrityFromJson(
  Map<String, dynamic> json,
) => _ExportBundleIntegrity(
  format: json['format'] as String,
  contentHash: json['contentHash'] as String,
  sectionHashes:
      (json['sectionHashes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  entityCounts:
      (json['entityCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
);

Map<String, dynamic> _$ExportBundleIntegrityToJson(
  _ExportBundleIntegrity instance,
) => <String, dynamic>{
  'format': instance.format,
  'contentHash': instance.contentHash,
  'sectionHashes': instance.sectionHashes,
  'entityCounts': instance.entityCounts,
};
