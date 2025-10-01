import 'package:freezed_annotation/freezed_annotation.dart';

part 'phosphor_icon_descriptor.freezed.dart';
part 'phosphor_icon_descriptor.g.dart';

@JsonEnum(fieldRename: FieldRename.kebab)
enum PhosphorIconStyle { thin, light, regular, bold, fill }

extension PhosphorIconStyleX on PhosphorIconStyle {
  static PhosphorIconStyle fromName(String? raw) {
    if (raw == null || raw.isEmpty) {
      return PhosphorIconStyle.regular;
    }
    final String normalized = raw.toLowerCase();
    return PhosphorIconStyle.values.firstWhere(
      (PhosphorIconStyle style) => style.name == normalized,
      orElse: () => PhosphorIconStyle.regular,
    );
  }

  String get label => name;
}

@freezed
abstract class PhosphorIconDescriptor with _$PhosphorIconDescriptor {
  const factory PhosphorIconDescriptor({
    required String name,
    @Default(PhosphorIconStyle.regular) PhosphorIconStyle style,
  }) = _PhosphorIconDescriptor;

  const PhosphorIconDescriptor._();

  static const PhosphorIconDescriptor empty = PhosphorIconDescriptor(name: '');

  bool get isEmpty => name.isEmpty;

  bool get isNotEmpty => name.isNotEmpty;

  factory PhosphorIconDescriptor.fromJson(Map<String, Object?> json) =>
      _$PhosphorIconDescriptorFromJson(json);
}
