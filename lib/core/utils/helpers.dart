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

  final int argbValue = color.toARGB32();
  final int value = includeAlpha ? argbValue : (argbValue & 0x00FFFFFF);

  final String buffer = value
      .toRadixString(16)
      .padLeft(includeAlpha ? 8 : 6, '0');

  return leadingHashSign ? '#${buffer.toUpperCase()}' : buffer.toUpperCase();
}

String getCurrencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'RUB':
      return '₽';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    default:
      return currencyCode;
  }
}
