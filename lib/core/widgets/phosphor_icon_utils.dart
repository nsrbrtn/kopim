import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/widgets/phosphor_icon_registry.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

PhosphorIconsStyle _mapStyle(PhosphorIconStyle style) {
  switch (style) {
    case PhosphorIconStyle.thin:
      return PhosphorIconsStyle.thin;
    case PhosphorIconStyle.light:
      return PhosphorIconsStyle.light;
    case PhosphorIconStyle.regular:
      return PhosphorIconsStyle.regular;
    case PhosphorIconStyle.bold:
      return PhosphorIconsStyle.bold;
    case PhosphorIconStyle.fill:
      return PhosphorIconsStyle.fill;
  }
}

PhosphorIconData? resolvePhosphorIconData(PhosphorIconDescriptor? descriptor) {
  if (descriptor == null || descriptor.isEmpty) {
    return null;
  }
  final PhosphorIconResolver? resolver = phosphorIconResolvers[descriptor.name];
  if (resolver == null) {
    return null;
  }
  return resolver(_mapStyle(descriptor.style));
}

String formatPhosphorIconName(String name) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < name.length; i++) {
    final String char = name[i];
    final bool isUpper =
        char.toUpperCase() == char && char.toLowerCase() != char;
    if (i > 0 && isUpper) {
      buffer.write(' ');
    }
    buffer.write(char);
  }
  return buffer.toString().toLowerCase();
}

