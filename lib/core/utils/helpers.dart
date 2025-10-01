import 'package:flutter/material.dart';

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

String? colorToHex(
    Color? color, {
      bool leadingHashSign = true,
      bool includeAlpha = false,
    }) {
  if (color == null) return null;

  final int value = includeAlpha
      ? color.toARGB32()
      : (color.r.toInt() << 16) | (color.g.toInt() << 8) | color.b.toInt();

  final String buffer =
  value.toRadixString(16).padLeft(includeAlpha ? 8 : 6, '0');

  return leadingHashSign ? '#${buffer.toUpperCase()}' : buffer.toUpperCase();
}
