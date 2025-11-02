// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportBundle _$ExportBundleFromJson(Map<String, dynamic> json) =>
    _ExportBundle(
      schemaVersion: json['schemaVersion'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      accounts:
          (json['accounts'] as List<dynamic>?)
              ?.map((e) => AccountEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AccountEntity>[],
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map(
                (e) => TransactionEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <TransactionEntity>[],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Category>[],
    );

Map<String, dynamic> _$ExportBundleToJson(_ExportBundle instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'accounts': instance.accounts,
      'transactions': instance.transactions,
      'categories': instance.categories,
    };
