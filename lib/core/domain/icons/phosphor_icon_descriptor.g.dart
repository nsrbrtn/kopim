// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phosphor_icon_descriptor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhosphorIconDescriptor _$PhosphorIconDescriptorFromJson(
  Map<String, dynamic> json,
) => _PhosphorIconDescriptor(
  name: json['name'] as String,
  style:
      $enumDecodeNullable(_$PhosphorIconStyleEnumMap, json['style']) ??
      PhosphorIconStyle.regular,
);

Map<String, dynamic> _$PhosphorIconDescriptorToJson(
  _PhosphorIconDescriptor instance,
) => <String, dynamic>{
  'name': instance.name,
  'style': _$PhosphorIconStyleEnumMap[instance.style]!,
};

const _$PhosphorIconStyleEnumMap = {
  PhosphorIconStyle.thin: 'thin',
  PhosphorIconStyle.light: 'light',
  PhosphorIconStyle.regular: 'regular',
  PhosphorIconStyle.bold: 'bold',
  PhosphorIconStyle.fill: 'fill',
};
