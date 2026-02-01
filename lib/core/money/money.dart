class Money {
  const Money({
    required this.minor,
    required this.currency,
    required this.scale,
  });

  factory Money.fromMinor(
    BigInt minor, {
    required String currency,
    required int scale,
  }) {
    return Money(minor: minor, currency: currency, scale: scale);
  }

  factory Money.fromDecimalString(
    String value, {
    required String currency,
    required int scale,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Empty amount string');
    }
    final bool isNegative = trimmed.startsWith('-');
    final String normalized = isNegative ? trimmed.substring(1) : trimmed;
    final List<String> parts = normalized.split('.');
    if (parts.length > 2) {
      throw ArgumentError('Invalid amount format');
    }
    final String whole = parts[0].isEmpty ? '0' : parts[0];
    final String fraction = parts.length == 2 ? parts[1] : '';
    if (!RegExp(r'^\d+$').hasMatch(whole) ||
        (fraction.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fraction))) {
      throw ArgumentError('Invalid amount format');
    }
    final String paddedFraction = fraction.padRight(scale, '0');
    final bool hasOverflow = paddedFraction.length > scale;
    final String keptFraction = hasOverflow
        ? paddedFraction.substring(0, scale)
        : paddedFraction;
    final String remainder = hasOverflow ? paddedFraction.substring(scale) : '';
    final bool roundUp = _shouldRoundUp(
      remainder: remainder,
      whole: whole,
      keptFraction: keptFraction,
      scale: scale,
    );
    final String minorString = '$whole$keptFraction';
    final BigInt baseMinorValue = BigInt.parse(
      minorString.isEmpty ? '0' : minorString,
    );
    final BigInt minorValue = roundUp
        ? baseMinorValue + BigInt.one
        : baseMinorValue;
    return Money(
      minor: isNegative ? -minorValue : minorValue,
      currency: currency,
      scale: scale,
    );
  }

  factory Money.fromDouble(
    double value, {
    required String currency,
    required int scale,
  }) {
    final String normalized = value.toStringAsFixed(scale);
    return Money.fromDecimalString(
      normalized,
      currency: currency,
      scale: scale,
    );
  }

  final BigInt minor;
  final String currency;
  final int scale;

  String toDecimalString() {
    final BigInt absValue = minor.abs();
    final String raw = absValue.toString().padLeft(scale + 1, '0');
    final int splitIndex = raw.length - scale;
    final String whole = raw.substring(0, splitIndex);
    final String fraction = raw.substring(splitIndex);
    final String sign = minor.isNegative ? '-' : '';
    if (scale == 0) {
      return '$sign$whole';
    }
    return '$sign$whole.$fraction';
  }

  double toDouble() {
    return double.tryParse(toDecimalString()) ?? 0;
  }

  static bool _shouldRoundUp({
    required String remainder,
    required String whole,
    required String keptFraction,
    required int scale,
  }) {
    if (remainder.isEmpty) {
      return false;
    }
    final int first = int.parse(remainder[0]);
    if (first > 5) {
      return true;
    }
    if (first < 5) {
      return false;
    }
    final bool hasMoreNonZero = remainder
        .substring(1)
        .split('')
        .any((String digit) => digit != '0');
    if (hasMoreNonZero) {
      return true;
    }
    final String lastDigitSource = scale == 0 ? whole : keptFraction;
    final int lastDigit = lastDigitSource.isEmpty
        ? 0
        : int.parse(lastDigitSource[lastDigitSource.length - 1]);
    return lastDigit.isOdd;
  }
}
