import 'package:kopim/core/money/money.dart';

class MoneyAmount {
  const MoneyAmount({
    required this.minor,
    required this.scale,
  });

  final BigInt minor;
  final int scale;

  MoneyAmount abs() => MoneyAmount(minor: minor.abs(), scale: scale);

  double toDouble() {
    final Money money = Money(minor: minor, currency: 'XXX', scale: scale);
    return double.tryParse(money.toDecimalString()) ?? 0;
  }
}

class MoneyAccumulator {
  BigInt _minor = BigInt.zero;
  int? _scale;

  void add(MoneyAmount amount) {
    if (_scale == null) {
      _scale = amount.scale;
      _minor = amount.minor;
      return;
    }
    if (amount.scale > _scale!) {
      _minor = _minor * _pow10(amount.scale - _scale!);
      _scale = amount.scale;
      _minor = _minor + amount.minor;
      return;
    }
    if (amount.scale < _scale!) {
      _minor = _minor + amount.minor * _pow10(_scale! - amount.scale);
      return;
    }
    _minor = _minor + amount.minor;
  }

  void subtract(MoneyAmount amount) {
    add(MoneyAmount(minor: -amount.minor, scale: amount.scale));
  }

  bool get isZero => _minor == BigInt.zero;

  double toDouble() {
    final int scale = _scale ?? 2;
    final Money money = Money(minor: _minor, currency: 'XXX', scale: scale);
    return double.tryParse(money.toDecimalString()) ?? 0;
  }

  BigInt get minor => _minor;

  int get scale => _scale ?? 2;

  static BigInt _pow10(int exponent) {
    if (exponent <= 0) return BigInt.one;
    BigInt result = BigInt.one;
    for (int i = 0; i < exponent; i += 1) {
      result *= BigInt.from(10);
    }
    return result;
  }
}

MoneyAmount resolveMoneyAmount({
  required double amount,
  BigInt? minor,
  int? scale,
  int fallbackScale = 2,
  bool useAbs = false,
}) {
  final int resolvedScale = (scale ?? 0) > 0 ? scale! : fallbackScale;
  final BigInt resolvedMinor = minor ??
      Money.fromDouble(amount, currency: 'XXX', scale: resolvedScale).minor;
  final MoneyAmount resolved = MoneyAmount(
    minor: resolvedMinor,
    scale: resolvedScale,
  );
  return useAbs ? resolved.abs() : resolved;
}

MoneyAmount? tryParseMoneyAmount({
  required String input,
  required int scale,
  bool useAbs = false,
}) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  try {
    final Money money = Money.fromDecimalString(
      trimmed,
      currency: 'XXX',
      scale: scale,
    );
    final MoneyAmount amount = MoneyAmount(minor: money.minor, scale: scale);
    return useAbs ? amount.abs() : amount;
  } catch (_) {
    return null;
  }
}

MoneyAmount rescaleMoneyAmount(MoneyAmount amount, int targetScale) {
  if (amount.scale == targetScale) return amount;
  final Money source = Money(minor: amount.minor, currency: 'XXX', scale: amount.scale);
  final Money normalized = Money.fromDecimalString(
    source.toDecimalString(),
    currency: 'XXX',
    scale: targetScale,
  );
  return MoneyAmount(minor: normalized.minor, scale: targetScale);
}
