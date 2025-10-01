import 'package:flutter/material.dart';

/// Converts a hexadecimal color string into a [Color].
///
/// The [value] can optionally include a leading `#` and support either
/// `RRGGBB` or `AARRGGBB` formats. When the alpha channel is omitted it will
/// default to fully opaque. Returns `null` when [value] is empty or cannot be
/// parsed.
Color? parseHexColor(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final String sanitized = value.replaceFirst('#', '').toUpperCase();
  final String hex = sanitized.length == 6 ? 'FF$sanitized' : sanitized;
  try {
    return Color(int.parse(hex, radix: 16));
  } on FormatException {
    return null;
  }
}

/// Converts a [Color] into a hexadecimal string representation.
///
/// When [color] is `null` the method returns `null`. By default the returned
/// string has a leading hash sign and excludes the alpha channel, resulting in
/// the format `#RRGGBB`.
String? colorToHex(
  Color? color, {
  bool leadingHashSign = true,
  bool includeAlpha = false,
}) {
  if (color == null) {
    return null;

  }
  final int value = includeAlpha ? color.value : color.value & 0x00FFFFFF;
  final String buffer = value.toRadixString(16).padLeft(includeAlpha ? 8 : 6, '0');
  return leadingHashSign ? '#${buffer.toUpperCase()}' : buffer.toUpperCase();
}
