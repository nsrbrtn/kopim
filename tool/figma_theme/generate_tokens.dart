import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';

Future<void> main(List<String> args) async {
  final File sourceFile = File('tool/figma_theme/tokens final/global.json');
  if (!await sourceFile.exists()) {
    stderr.writeln('Не найден исходный файл токенов: ${sourceFile.path}');
    exitCode = 1;
    return;
  }

  final Map<String, dynamic> raw =
      jsonDecode(await sourceFile.readAsString()) as Map<String, dynamic>;

  final _TokenBundle bundle = _TokenBundle.fromRaw(raw);
  final File targetFile = File(
    'lib/core/theme/data/generated/kopim_theme_tokens.g.dart',
  );
  await targetFile.writeAsString(bundle.render());
  stdout.writeln('Токены успешно сгенерированы: ${targetFile.path}');
}

class _TokenBundle {
  _TokenBundle({
    required this.lightColors,
    required this.darkColors,
    required this.typography,
    required this.radius,
    required this.borderWidth,
    required this.spacing,
    required this.sizes,
    required this.motionDurations,
    required this.motionCurves,
    required this.specialSurfaces,
  });

  factory _TokenBundle.fromRaw(Map<String, dynamic> raw) {
    final Map<String, dynamic> kopim = (raw['Kopim'] as Map<String, dynamic>)
        .cast<String, dynamic>();
    final Map<String, dynamic> sys = (kopim['sys'] as Map<String, dynamic>)
        .cast<String, dynamic>();

    return _TokenBundle(
      lightColors: _mapSystemColors(
        (sys['light'] as Map<String, dynamic>).cast<String, dynamic>(),
      ),
      darkColors: _mapSystemColors(
        (sys['dark'] as Map<String, dynamic>).cast<String, dynamic>(),
      ),
      typography: _mapTypography(kopim, raw),
      radius: _parseDimensionMap(
        ((kopim['shape'] as Map<String, dynamic>)['radius']
                as Map<String, dynamic>)
            .cast<String, dynamic>(),
      ),
      borderWidth: _parseDimensionMap(
        ((kopim['shape'] as Map<String, dynamic>)['borderWidth']
                as Map<String, dynamic>)
            .cast<String, dynamic>(),
      ),
      spacing: _parseDimensionMap(
        (kopim['spacing'] as Map<String, dynamic>).cast<String, dynamic>(),
      ),
      sizes: _mapSizes(
        (kopim['sizes'] as Map<String, dynamic>).cast<String, dynamic>(),
      ),
      motionDurations: _mapMotionDurations(
        ((kopim['motion'] as Map<String, dynamic>)['duration']
                as Map<String, dynamic>)
            .cast<String, dynamic>(),
      ),
      motionCurves: _mapMotionCurves(
        ((kopim['motion'] as Map<String, dynamic>)['easing']
                as Map<String, dynamic>)
            .cast<String, dynamic>(),
      ),
      specialSurfaces: _mapSpecialSurfaces(kopim),
    );
  }

  final Map<String, String> lightColors;
  final Map<String, String> darkColors;
  final Map<String, Map<String, dynamic>> typography;
  final Map<String, double> radius;
  final Map<String, double> borderWidth;
  final Map<String, double> spacing;
  final Map<String, Map<String, double>> sizes;
  final Map<String, int> motionDurations;
  final Map<String, List<double>> motionCurves;
  final Map<String, String> specialSurfaces;

  String render() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// coverage:ignore-file')
      ..writeln('// ignore_for_file: type=lint')
      ..writeln()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln("import '../dto/kopim_theme_tokens.dart';")
      ..writeln()
      ..writeln('const KopimThemeTokenBundle kopimThemeTokens =')
      ..writeln(_indent(_renderBundle(), 0))
      ..writeln(';');
    return buffer.toString();
  }

  String _renderBundle() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('KopimThemeTokenBundle(')
      ..writeln('  lightColors: ${_renderColors(lightColors)},')
      ..writeln('  darkColors: ${_renderColors(darkColors)},')
      ..writeln('  typography: ${_renderTypography()},')
      ..writeln('  shape: KopimShapeTokens(')
      ..writeln('    radius: ${_renderDoubleMap(radius)},')
      ..writeln('    borderWidth: ${_renderDoubleMap(borderWidth)},')
      ..writeln('  ),')
      ..writeln('  spacing: KopimSpacingTokens(')
      ..writeln('    values: ${_renderDoubleMap(spacing)},')
      ..writeln('  ),')
      ..writeln('  sizes: ${_renderSizes()},')
      ..writeln('  motion: ${_renderMotion()},')
      ..writeln('  specialSurfaces: ${_renderSpecialSurfaces()},')
      ..write(')');
    return buffer.toString();
  }

  String _renderColors(Map<String, String> colors) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('KopimSystemColorTokens(');
    for (final MapEntry<String, String> entry in colors.entries.sorted(
      (MapEntry<String, String> a, MapEntry<String, String> b) =>
          a.key.compareTo(b.key),
    )) {
      buffer.writeln('    ${entry.key}: ${_formatColor(entry.value)},');
    }
    buffer.write('  )');
    return buffer.toString();
  }

  String _renderTypography() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('KopimTypographyTokens(');
    for (final MapEntry<String, Map<String, dynamic>> entry
        in typography.entries.sorted(
          (
            MapEntry<String, Map<String, dynamic>> a,
            MapEntry<String, Map<String, dynamic>> b,
          ) => a.key.compareTo(b.key),
        )) {
      buffer.writeln('    ${entry.key}: ${_renderTextStyle(entry.value)},');
    }
    buffer.write('  )');
    return buffer.toString();
  }

  String _renderTextStyle(Map<String, dynamic> style) {
    return 'KopimTextStyleTokens(\n'
        "      fontFamily: ${_quote(style['fontFamily'] as String)},\n"
        "      fontWeight: ${_formatFontWeight(style['fontWeight'] as String)},\n"
        "      fontSize: ${_formatDouble(style['fontSize'] as double)},\n"
        "      lineHeight: ${_formatDouble(style['lineHeight'] as double)},\n"
        "      letterSpacing: ${_formatDouble(style['letterSpacing'] as double)},\n"
        '    )';
  }

  String _renderSizes() {
    final StringBuffer buffer = StringBuffer()..writeln('KopimSizeTokens(');
    for (final MapEntry<String, Map<String, double>> entry
        in sizes.entries.sorted(
          (
            MapEntry<String, Map<String, double>> a,
            MapEntry<String, Map<String, double>> b,
          ) => a.key.compareTo(b.key),
        )) {
      buffer.writeln('    ${entry.key}: ${_renderDoubleMap(entry.value)},');
    }
    buffer.write('  )');
    return buffer.toString();
  }

  String _renderMotion() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('KopimMotionTokens(')
      ..writeln('    durations: KopimMotionDurations(');
    for (final MapEntry<String, int> entry in motionDurations.entries.sorted(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          a.key.compareTo(b.key),
    )) {
      buffer.writeln(
        '      ${entry.key}: Duration(milliseconds: ${entry.value}),',
      );
    }
    buffer
      ..writeln('    ),')
      ..writeln('    easing: KopimMotionEasing(');
    for (final MapEntry<String, List<double>> entry
        in motionCurves.entries.sorted(
          (
            MapEntry<String, List<double>> a,
            MapEntry<String, List<double>> b,
          ) => a.key.compareTo(b.key),
        )) {
      final List<double> values = entry.value;
      buffer.writeln(
        '      ${entry.key}: Cubic(${_formatDouble(values[0])}, ${_formatDouble(values[1])}, '
        '${_formatDouble(values[2])}, ${_formatDouble(values[3])}),',
      );
    }
    buffer
      ..writeln('    ),')
      ..write('  )');
    return buffer.toString();
  }

  String _renderSpecialSurfaces() {
    return 'KopimSpecialSurfacesTokens(\n'
        '    fabGradientStart: ${_formatColor(specialSurfaces['fabGradientStart']!)},\n'
        '    fabGradientEnd: ${_formatColor(specialSurfaces['fabGradientEnd']!)},\n'
        '    navbarLight: ${_formatColor(specialSurfaces['navbarLight']!)},\n'
        '    navbarDark: ${_formatColor(specialSurfaces['navbarDark']!)},\n'
        '  )';
  }
}

Map<String, String> _mapSystemColors(Map<String, dynamic> source) {
  const Map<String, String> mapping = <String, String>{
    'primary': 'primary',
    'on-primary': 'onPrimary',
    'primary-container': 'primaryContainer',
    'on-primary-container': 'onPrimaryContainer',
    'primary-fixed': 'primaryFixed',
    'primary-fixed-dim': 'primaryFixedDim',
    'on-primary-fixed': 'onPrimaryFixed',
    'on-primary-fixed-variant': 'onPrimaryFixedVariant',
    'secondary': 'secondary',
    'on-secondary': 'onSecondary',
    'secondary-container': 'secondaryContainer',
    'on-secondary-container': 'onSecondaryContainer',
    'secondary-fixed': 'secondaryFixed',
    'secondary-fixed-dim': 'secondaryFixedDim',
    'on-secondary-fixed': 'onSecondaryFixed',
    'on-secondary-fixed-variant': 'onSecondaryFixedVariant',
    'tertiary': 'tertiary',
    'on-tertiary': 'onTertiary',
    'tertiary-container': 'tertiaryContainer',
    'on-tertiary-container': 'onTertiaryContainer',
    'tertiary-fixed': 'tertiaryFixed',
    'tertiary-fixed-dim': 'tertiaryFixedDim',
    'on-tertiary-fixed': 'onTertiaryFixed',
    'on-tertiary-fixed-variant': 'onTertiaryFixedVariant',
    'error': 'error',
    'on-error': 'onError',
    'error-container': 'errorContainer',
    'on-error-container': 'onErrorContainer',
    'surface': 'surface',
    'on-surface': 'onSurface',
    'surface-dim': 'surfaceDim',
    'surface-bright': 'surfaceBright',
    'surface-container-lowest': 'surfaceContainerLowest',
    'surface-container-low': 'surfaceContainerLow',
    'surface-container': 'surfaceContainer',
    'surface-container-high': 'surfaceContainerHigh',
    'surface-container-highest': 'surfaceContainerHighest',
    'on-surface-variant': 'onSurfaceVariant',
    'outline': 'outline',
    'outline-variant': 'outlineVariant',
    'shadow': 'shadow',
    'scrim': 'scrim',
    'inverse-surface': 'inverseSurface',
    'inverse-on-surface': 'inverseOnSurface',
    'inverse-primary': 'inversePrimary',
    'surface-tint': 'surfaceTint',
    'background': 'background',
    'on-background': 'onBackground',
    'surface-variant': 'surfaceVariant',
  };

  return <String, String>{
    for (final MapEntry<String, String> entry in mapping.entries)
      entry.value: _colorToken(source, entry.key),
  };
}

Map<String, Map<String, dynamic>> _mapTypography(
  Map<String, dynamic> kopim,
  Map<String, dynamic> root,
) {
  const Map<String, String> mapping = <String, String>{
    'display.large': 'displayLarge',
    'display.medium': 'displayMedium',
    'display.small': 'displaySmall',
    'headline.large': 'headlineLarge',
    'headline.medium': 'headlineMedium',
    'headline.small': 'headlineSmall',
    'title.large': 'titleLarge',
    'title.medium': 'titleMedium',
    'title.small': 'titleSmall',
    'body.large': 'bodyLarge',
    'body.medium': 'bodyMedium',
    'body.small': 'bodySmall',
    'label.large': 'labelLarge',
    'label.medium': 'labelMedium',
    'label.small': 'labelSmall',
  };

  return <String, Map<String, dynamic>>{
    for (final MapEntry<String, String> entry in mapping.entries)
      entry.value: _mapTextStyle(_readTokenGroup(kopim, entry.key), root),
  };
}

Map<String, dynamic> _mapTextStyle(
  Map<String, dynamic> style,
  Map<String, dynamic> root,
) {
  return <String, dynamic>{
    'fontFamily': _resolveString(style['fontFamily'], root) ?? '',
    'fontWeight': _resolveString(style['fontWeight'], root) ?? 'Regular',
    'fontSize': _resolveDouble(style['fontSize'], root) ?? 14.0,
    'lineHeight': _resolveDouble(style['lineHeight'], root) ?? 20.0,
    'letterSpacing': _resolveDouble(style['letterSpacing'], root) ?? 0.0,
  };
}

Map<String, double> _parseDimensionMap(Map<String, dynamic> source) {
  final Map<String, double> result = <String, double>{};
  for (final MapEntry<String, dynamic> entry in source.entries) {
    final dynamic value = entry.value;
    if (value is Map<String, dynamic>) {
      result[entry.key] = double.parse(value['value'].toString());
    } else {
      result[entry.key] = double.parse(value.toString());
    }
  }
  return result;
}

Map<String, Map<String, double>> _mapSizes(Map<String, dynamic> sizes) {
  final Map<String, Map<String, double>> result =
      <String, Map<String, double>>{};
  for (final MapEntry<String, dynamic> entry in sizes.entries) {
    result[entry.key] = _parseDimensionMap(
      (entry.value as Map<String, dynamic>).cast<String, dynamic>(),
    );
  }
  return result;
}

Map<String, int> _mapMotionDurations(Map<String, dynamic> durations) {
  return <String, int>{
    for (final MapEntry<String, dynamic> entry in durations.entries)
      entry.key: int.parse(
        (entry.value as Map<String, dynamic>)['value'].toString(),
      ),
  };
}

Map<String, List<double>> _mapMotionCurves(Map<String, dynamic> easing) {
  return <String, List<double>>{
    for (final MapEntry<String, dynamic> entry in easing.entries)
      entry.key: List<double>.from(
        ((entry.value as Map<String, dynamic>)['value'] as List<dynamic>).map(
          (dynamic value) => (value as num).toDouble(),
        ),
      ),
  };
}

Map<String, String> _mapSpecialSurfaces(Map<String, dynamic> kopim) {
  final String fabGradientRaw =
      (kopim['Fab'] as Map<String, dynamic>)['value'] as String;
  final List<String> fabColors = RegExp(r'#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?')
      .allMatches(fabGradientRaw)
      .map((RegExpMatch match) => match.group(0)!.toUpperCase())
      .toList();
  if (fabColors.length < 2) {
    throw StateError('Невозможно разобрать градиент FAB: $fabGradientRaw');
  }

  return <String, String>{
    'fabGradientStart': fabColors.first,
    'fabGradientEnd': fabColors.last,
    'navbarLight':
        ((kopim['navbar light'] as Map<String, dynamic>)['value'] as String)
            .toUpperCase(),
    'navbarDark':
        ((kopim['navbar dark'] as Map<String, dynamic>)['value'] as String)
            .toUpperCase(),
  };
}

Map<String, dynamic> _readTokenGroup(Map<String, dynamic> kopim, String key) {
  final List<String> parts = key.split('.');
  Map<String, dynamic> current = kopim;
  for (final String part in parts) {
    final dynamic value = current[part];
    if (value is Map<String, dynamic>) {
      current = value.cast<String, dynamic>();
    } else {
      throw StateError('Не удалось найти группу токенов: $key');
    }
  }
  return current;
}

String? _resolveString(dynamic token, Map<String, dynamic> root) {
  final dynamic resolved = _resolveValue(token, root);
  if (resolved == null) {
    return null;
  }
  if (resolved is String) {
    return resolved;
  }
  return resolved.toString();
}

double? _resolveDouble(dynamic token, Map<String, dynamic> root) {
  final dynamic resolved = _resolveValue(token, root);
  if (resolved == null) {
    return null;
  }
  if (resolved is num) {
    return resolved.toDouble();
  }
  return double.tryParse(resolved.toString());
}

dynamic _resolveValue(dynamic token, Map<String, dynamic> root) {
  if (token is Map<String, dynamic> && token.containsKey('value')) {
    return _resolveValue(token['value'], root);
  }
  if (token is String && token.startsWith('{') && token.endsWith('}')) {
    final String path = token.substring(1, token.length - 1);
    final List<String> segments = path.split('.');
    dynamic current = root;
    for (final String segment in segments) {
      if (current is Map<String, dynamic>) {
        current = current[segment];
      } else {
        current = null;
        break;
      }
    }
    if (current is Map<String, dynamic> && current.containsKey('value')) {
      return current['value'];
    }
    return current;
  }
  return token;
}

String _colorToken(Map<String, dynamic> source, String key) {
  final Map<String, dynamic>? token = source[key] as Map<String, dynamic>?;
  if (token == null) {
    throw StateError('Цветовой токен "$key" не найден');
  }
  return (token['value'] as String).toUpperCase();
}

String _formatColor(String raw) {
  final String hex = raw.startsWith('#') ? raw.substring(1) : raw;
  final String normalized = hex.length == 6
      ? 'FF${hex.toUpperCase()}'
      : '${hex.substring(6).toUpperCase()}${hex.substring(0, 6).toUpperCase()}';
  return 'Color(0x$normalized)';
}

String _formatFontWeight(String weight) {
  switch (weight) {
    case 'Thin':
      return 'FontWeight.w100';
    case 'ExtraLight':
      return 'FontWeight.w200';
    case 'Light':
      return 'FontWeight.w300';
    case 'Regular':
      return 'FontWeight.w400';
    case 'Medium':
      return 'FontWeight.w500';
    case 'SemiBold':
      return 'FontWeight.w600';
    case 'Bold':
      return 'FontWeight.w700';
    case 'ExtraBold':
      return 'FontWeight.w800';
    case 'Black':
      return 'FontWeight.w900';
    default:
      throw StateError('Неизвестный вес шрифта: $weight');
  }
}

String _formatDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(1);
  }
  return value.toString();
}

String _renderDoubleMap(Map<String, double> values) {
  final StringBuffer buffer = StringBuffer('const <String, double>{\n');
  for (final MapEntry<String, double> entry in values.entries.sorted(
    (MapEntry<String, double> a, MapEntry<String, double> b) =>
        a.key.compareTo(b.key),
  )) {
    buffer.writeln("      '${entry.key}': ${_formatDouble(entry.value)},");
  }
  buffer.write('    }');
  return buffer.toString();
}

String _quote(String value) => "'${value.replaceAll("'", r"\'")}'";

String _indent(String value, int spaces) {
  final String indent = ' ' * spaces;
  return value
      .split('\n')
      .map((String line) => line.isEmpty ? line : '$indent$line')
      .join('\n');
}
